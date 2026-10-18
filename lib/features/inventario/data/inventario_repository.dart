import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../infrastructure/database/app_database.dart';
import '../domain/producto.dart';
import '../domain/producto_borrador.dart';

/// Se lanza al intentar dar de alta un producto cuyo par marca + codigo ya
/// existe.
///
/// La restriccion no vive en el esquema a proposito: con borrado logico, un
/// UNIQUE de SQLite tambien chocaria contra productos dados de baja, y la
/// propietaria si tiene derecho a volver a dar de alta algo que borro.
class ProductoDuplicadoException implements Exception {
  const ProductoDuplicadoException(this.marca, this.codigo);

  final String marca;
  final String codigo;

  @override
  String toString() {
    final deMarca = marca.isEmpty ? '' : ' de la marca "$marca"';
    return 'Ya existe un producto con codigo "$codigo"$deMarca.';
  }
}

/// Traduce entre las filas de `Productos` y el modelo de dominio, y es el
/// unico lugar autorizado para mover existencias.
///
/// Los otros dos repositorios lo reciben como dependencia en vez de tocar la
/// tabla por su cuenta: `PedidosRepository` lo usa para sumar lo que llego de
/// la distribuidora y `VentasRepository` para restar lo que se entrego al
/// cliente. Concentrar las dos operaciones aqui es lo que permite que la regla
/// "una entrada sube actual y original, una salida solo baja actual" exista
/// una sola vez.
///
/// Los metodos de movimiento no abren transaccion propia: se llaman desde la
/// transaccion del repositorio que los invoca, para que recibir un pedido o
/// entregar una venta sea todo o nada.
class InventarioRepository {
  InventarioRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  // --- Lectura -------------------------------------------------------------

  /// Catalogo vigente, ordenado como se lee en una lista: marca y luego codigo.
  Stream<List<Producto>> observarProductos() {
    final consulta = _db.select(_db.productos)
      ..where((t) => t.eliminadoEn.isNull())
      ..orderBy([
        (t) => OrderingTerm(expression: t.marca),
        (t) => OrderingTerm(expression: t.codigo),
      ]);
    return consulta.watch().map((filas) => filas.map(_aProducto).toList());
  }

  Stream<Producto?> observarProducto(String productoId) {
    final consulta = _db.select(_db.productos)
      ..where((t) => t.id.equals(productoId) & t.eliminadoEn.isNull());
    return consulta
        .watchSingleOrNull()
        .map((fila) => fila == null ? null : _aProducto(fila));
  }

  Future<Producto?> obtenerProducto(String productoId) async {
    final consulta = _db.select(_db.productos)
      ..where((t) => t.id.equals(productoId));
    final fila = await consulta.getSingleOrNull();
    return fila == null ? null : _aProducto(fila);
  }

  /// Busca por el par que identifica al articulo para la usuaria.
  ///
  /// Lo usa el alta para rechazar duplicados y la recepcion de pedidos para
  /// enlazar una linea capturada antes de que el producto existiera.
  Future<Producto?> buscarPorCodigo({
    required String marca,
    required String codigo,
  }) async {
    final consulta = _db.select(_db.productos)
      ..where(
        (t) =>
            t.codigo.lower().equals(codigo.trim().toLowerCase()) &
            t.marca.lower().equals(marca.trim().toLowerCase()) &
            t.eliminadoEn.isNull(),
      )
      ..limit(1);
    final fila = await consulta.getSingleOrNull();
    return fila == null ? null : _aProducto(fila);
  }

  // --- Escritura -----------------------------------------------------------

  /// Da de alta un producto. Lanza [ProductoDuplicadoException] si el par
  /// marca + codigo ya esta vivo en el catalogo.
  Future<Producto> crearProducto(ProductoBorrador borrador) {
    return _db.transaction(() async {
      final codigo = borrador.codigo.trim();
      if (codigo.isNotEmpty) {
        final existente = await buscarPorCodigo(
          marca: borrador.marca,
          codigo: codigo,
        );
        if (existente != null) {
          throw ProductoDuplicadoException(borrador.marca.trim(), codigo);
        }
      }

      final ahora = DateTime.now();
      final producto = borrador.aProducto(_uuid.v4());
      await _db.into(_db.productos).insert(
            ProductosCompanion.insert(
              id: producto.id,
              marca: Value(producto.marca),
              codigo: Value(producto.codigo),
              descripcion: Value(producto.descripcion),
              cantidadActual: Value(producto.cantidadActual),
              cantidadOriginal: Value(producto.cantidadOriginal),
              creadoEn: ahora,
              actualizadoEn: ahora,
            ),
          );
      return producto;
    });
  }

  /// Guarda la edicion de un producto, incluida la correccion manual de
  /// existencias: la propietaria cuenta las cajas y ajusta lo que diga el
  /// conteo, aunque no cuadre con lo que el sistema calculo.
  Future<void> guardarProducto(Producto producto) {
    return _db.transaction(() async {
      final codigo = producto.codigo.trim();
      if (codigo.isNotEmpty) {
        final existente = await buscarPorCodigo(
          marca: producto.marca,
          codigo: codigo,
        );
        if (existente != null && existente.id != producto.id) {
          throw ProductoDuplicadoException(producto.marca.trim(), codigo);
        }
      }

      await (_db.update(_db.productos)..where((t) => t.id.equals(producto.id)))
          .write(
        ProductosCompanion(
          marca: Value(producto.marca.trim()),
          codigo: Value(codigo),
          descripcion: Value(producto.descripcion.trim()),
          cantidadActual: Value(producto.cantidadActual),
          cantidadOriginal: Value(producto.cantidadOriginal),
          actualizadoEn: Value(DateTime.now()),
        ),
      );
    });
  }

  /// Baja logica. Las lineas de venta que lo apuntan conservan su copia de
  /// marca, codigo y descripcion, asi que las ventas viejas siguen legibles.
  Future<void> eliminarProducto(String productoId) {
    final ahora = DateTime.now();
    return (_db.update(_db.productos)..where((t) => t.id.equals(productoId)))
        .write(
      ProductosCompanion(
        eliminadoEn: Value(ahora),
        actualizadoEn: Value(ahora),
      ),
    );
  }

  // --- Movimientos de existencias ------------------------------------------

  /// Suma piezas que llegaron de la distribuidora.
  ///
  /// Sube `cantidadActual` y tambien `cantidadOriginal`, porque son piezas que
  /// entraron al negocio por primera vez. Lo llama `PedidosRepository` al
  /// recibir un pedido, dentro de su propia transaccion.
  ///
  /// Se escribe como un UPDATE relativo y no leyendo-modificando-escribiendo
  /// para que dos movimientos sobre el mismo producto no se pisen: cada uno
  /// aplica su delta sobre lo que haya en la fila en ese instante.
  Future<void> registrarEntrada({
    required String productoId,
    required int piezas,
  }) =>
      _moverExistencias(
        productoId: productoId,
        deltaActual: piezas,
        deltaOriginal: piezas,
      );

  /// Resta piezas que salieron hacia un cliente.
  ///
  /// Solo baja `cantidadActual`: `cantidadOriginal` es el historico de
  /// entradas y una venta no lo cambia. Lo llama `VentasRepository` al
  /// entregar una venta.
  Future<void> registrarSalida({
    required String productoId,
    required int piezas,
  }) =>
      _moverExistencias(
        productoId: productoId,
        deltaActual: -piezas,
        deltaOriginal: 0,
      );

  /// Devuelve al inventario piezas que ya habian salido: cancelar una venta
  /// entregada o corregir a la baja una linea.
  ///
  /// No es una entrada nueva, asi que `cantidadOriginal` se queda igual.
  Future<void> revertirSalida({
    required String productoId,
    required int piezas,
  }) =>
      _moverExistencias(
        productoId: productoId,
        deltaActual: piezas,
        deltaOriginal: 0,
      );

  Future<void> _moverExistencias({
    required String productoId,
    required int deltaActual,
    required int deltaOriginal,
  }) async {
    if (deltaActual == 0 && deltaOriginal == 0) return;
    await _db.customUpdate(
      'UPDATE productos SET cantidad_actual = cantidad_actual + ?, '
      'cantidad_original = cantidad_original + ?, actualizado_en = ? '
      'WHERE id = ?',
      variables: [
        Variable.withInt(deltaActual),
        Variable.withInt(deltaOriginal),
        Variable.withDateTime(DateTime.now()),
        Variable.withString(productoId),
      ],
      updates: {_db.productos},
    );
  }

  // --- Mapeo ---------------------------------------------------------------

  Producto _aProducto(ProductoRow fila) => Producto(
        id: fila.id,
        marca: fila.marca,
        codigo: fila.codigo,
        descripcion: fila.descripcion,
        cantidadActual: fila.cantidadActual,
        cantidadOriginal: fila.cantidadOriginal,
      );
}
