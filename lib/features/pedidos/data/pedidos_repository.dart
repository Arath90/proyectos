import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../infrastructure/database/app_database.dart';
import '../../inventario/data/inventario_repository.dart';
import '../../inventario/domain/producto_borrador.dart';
import '../domain/linea_borrador.dart';
import '../domain/linea_pedido.dart';
import '../domain/pedido.dart';

/// Traduce entre las filas de Drift y los modelos de dominio.
///
/// Es el unico lugar del feature que sabe que existe SQLite. Ni los ViewModel
/// ni las pantallas conocen a Drift, para que agregar un backend despues no
/// obligue a tocar la interfaz.
///
/// Recibe un [InventarioRepository] porque el pedido no termina cuando se
/// captura sino cuando llega la caja: [recibirPedido] convierte la
/// `cantEnviada` de cada linea en existencias de un `Producto`. Delegar ese
/// movimiento en vez de escribir la tabla `productos` desde aqui mantiene la
/// regla de "que sube y que baja" en un solo lugar, compartida con
/// `VentasRepository`.
class PedidosRepository {
  PedidosRepository(this._db, this._inventario, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final InventarioRepository _inventario;
  final Uuid _uuid;

  // --- Lectura -------------------------------------------------------------

  /// Pedidos vigentes, del mas reciente al mas antiguo.
  Stream<List<Pedido>> observarPedidos() {
    final consulta = _db.select(_db.pedidos)
      ..where((t) => t.eliminadoEn.isNull())
      ..orderBy([
        (t) => OrderingTerm(expression: t.fecha, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.creadoEn, mode: OrderingMode.desc),
      ]);
    return consulta.watch().map((filas) => filas.map(_aPedido).toList());
  }

  Stream<Pedido?> observarPedido(String pedidoId) {
    final consulta = _db.select(_db.pedidos)
      ..where((t) => t.id.equals(pedidoId) & t.eliminadoEn.isNull());
    return consulta
        .watchSingleOrNull()
        .map((fila) => fila == null ? null : _aPedido(fila));
  }

  /// Lineas vigentes de un pedido, en el orden en que se capturaron.
  Stream<List<LineaPedido>> observarLineas(String pedidoId) {
    final consulta = _db.select(_db.lineasPedido)
      ..where((t) => t.pedidoId.equals(pedidoId) & t.eliminadoEn.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.orden)]);
    return consulta.watch().map((filas) => filas.map(_aLinea).toList());
  }

  /// Todas las lineas vigentes, agrupadas por pedido.
  ///
  /// El listado necesita el total de cada pedido. Se agrupa en Dart en vez de
  /// sumar con SQL a proposito: `tu pagas` admite un valor manual, y escribir
  /// esa regla tambien como un COALESCE en la consulta dejaria dos versiones
  /// de la misma regla que tarde o temprano dejan de coincidir.
  Stream<Map<String, List<LineaPedido>>> observarLineasPorPedido() {
    final consulta = _db.select(_db.lineasPedido)
      ..where((t) => t.eliminadoEn.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.orden)]);
    return consulta.watch().map((filas) {
      final agrupadas = <String, List<LineaPedido>>{};
      for (final fila in filas) {
        agrupadas.putIfAbsent(fila.pedidoId, () => []).add(_aLinea(fila));
      }
      return agrupadas;
    });
  }

  // --- Escritura de pedidos ------------------------------------------------

  Future<Pedido> crearPedido({
    String campana = '',
    String marcaPredeterminada = '',
    DateTime? fecha,
  }) async {
    final ahora = DateTime.now();
    final pedido = Pedido(
      id: _uuid.v4(),
      fecha: fecha ?? ahora,
      campana: campana,
      marcaPredeterminada: marcaPredeterminada,
    );
    await _db.into(_db.pedidos).insert(
          PedidosCompanion.insert(
            id: pedido.id,
            fecha: pedido.fecha,
            campana: Value(pedido.campana),
            marcaPredeterminada: Value(pedido.marcaPredeterminada),
            notas: Value(pedido.notas),
            cerrado: Value(pedido.cerrado),
            creadoEn: ahora,
            actualizadoEn: ahora,
          ),
        );
    return pedido;
  }

  Future<void> guardarPedido(Pedido pedido) async {
    await (_db.update(_db.pedidos)..where((t) => t.id.equals(pedido.id))).write(
      PedidosCompanion(
        fecha: Value(pedido.fecha),
        campana: Value(pedido.campana),
        marcaPredeterminada: Value(pedido.marcaPredeterminada),
        notas: Value(pedido.notas),
        cerrado: Value(pedido.cerrado),
        actualizadoEn: Value(DateTime.now()),
      ),
    );
  }

  /// Marca el pedido y sus lineas como eliminados.
  ///
  /// Va en una transaccion para que no quede un pedido borrado con lineas
  /// vivas, ni al reves, si la aplicacion muere a media operacion.
  Future<void> eliminarPedido(String pedidoId) {
    return _db.transaction(() async {
      final ahora = DateTime.now();
      await (_db.update(_db.lineasPedido)
            ..where(
              (t) => t.pedidoId.equals(pedidoId) & t.eliminadoEn.isNull(),
            ))
          .write(
        LineasPedidoCompanion(
          eliminadoEn: Value(ahora),
          actualizadoEn: Value(ahora),
        ),
      );
      await (_db.update(_db.pedidos)..where((t) => t.id.equals(pedidoId)))
          .write(
        PedidosCompanion(
          eliminadoEn: Value(ahora),
          actualizadoEn: Value(ahora),
        ),
      );
    });
  }

  /// Surte el pedido: lo que la distribuidora envio entra al inventario.
  ///
  /// Es la operacion que une los dos features. Para cada linea con piezas
  /// recibidas busca a que producto sumarselas, en este orden:
  ///
  ///  1. el `productoId` que la linea ya traiga, si se capturo desde el
  ///     catalogo;
  ///  2. un producto vivo con la misma marca y codigo;
  ///  3. si no existe, lo da de alta en cero y le suma lo recibido.
  ///
  /// El paso 3 es deliberado: obligar a la propietaria a capturar el catalogo
  /// antes de poder surtir su primera caja convertiria el inventario en un
  /// tramite, y en la practica los articulos nuevos aparecen justo asi, en un
  /// pedido. El id resuelto se escribe de vuelta en la linea para que la hoja
  /// quede enlazada de aqui en adelante.
  ///
  /// Se ignora si el pedido ya fue recibido: `recibidoEn` es el seguro contra
  /// surtir dos veces. Todo ocurre en una transaccion, para que no quede un
  /// pedido marcado como recibido cuyas piezas no entraron.
  Future<void> recibirPedido(String pedidoId) {
    return _db.transaction(() async {
      final pedido = await (_db.select(_db.pedidos)
            ..where((t) => t.id.equals(pedidoId)))
          .getSingleOrNull();
      if (pedido == null || pedido.recibidoEn != null) return;

      final lineas = await (_db.select(_db.lineasPedido)
            ..where(
              (t) => t.pedidoId.equals(pedidoId) & t.eliminadoEn.isNull(),
            ))
          .get();

      final ahora = DateTime.now();
      for (final fila in lineas) {
        if (fila.cantEnviada <= 0) continue;

        final productoId = await _resolverProducto(fila);
        await _inventario.registrarEntrada(
          productoId: productoId,
          piezas: fila.cantEnviada,
        );

        if (fila.productoId != productoId) {
          await (_db.update(_db.lineasPedido)
                ..where((t) => t.id.equals(fila.id)))
              .write(
            LineasPedidoCompanion(
              productoId: Value(productoId),
              actualizadoEn: Value(ahora),
            ),
          );
        }
      }

      await (_db.update(_db.pedidos)..where((t) => t.id.equals(pedidoId)))
          .write(
        PedidosCompanion(
          recibidoEn: Value(ahora),
          // Recibir tambien cierra: la hoja ya se concilio contra la caja.
          cerrado: const Value(true),
          actualizadoEn: Value(ahora),
        ),
      );
    });
  }

  /// Devuelve el id del producto al que le tocan las piezas de [fila],
  /// creandolo si hace falta.
  Future<String> _resolverProducto(LineaRow fila) async {
    final yaEnlazado = fila.productoId;
    if (yaEnlazado != null) {
      final existente = await _inventario.obtenerProducto(yaEnlazado);
      if (existente != null) return existente.id;
    }

    final porCodigo = await _inventario.buscarPorCodigo(
      marca: fila.marca,
      codigo: fila.codigo,
    );
    if (porCodigo != null) return porCodigo.id;

    // Nace en cero: las piezas las pone `registrarEntrada`, que es quien sabe
    // que una entrada sube tanto la existencia actual como la original.
    final nuevo = await _inventario.crearProducto(
      ProductoBorrador(
        marca: fila.marca,
        codigo: fila.codigo,
        descripcion: fila.descripcion,
        cantidadActual: 0,
        cantidadOriginal: 0,
      ),
    );
    return nuevo.id;
  }

  // --- Escritura de lineas -------------------------------------------------

  /// Inserta una linea al final del pedido.
  ///
  /// El `orden` se calcula dentro de la transaccion para que dos altas casi
  /// simultaneas no reciban la misma posicion.
  Future<LineaPedido> agregarLinea(String pedidoId, LineaBorrador borrador) {
    return _db.transaction(() async {
      final maximo = _db.lineasPedido.orden.max();
      final consulta = _db.selectOnly(_db.lineasPedido)
        ..addColumns([maximo])
        ..where(_db.lineasPedido.pedidoId.equals(pedidoId));
      final ultimo =
          await consulta.map((fila) => fila.read(maximo)).getSingleOrNull();

      final ahora = DateTime.now();
      final linea = borrador.aLinea(
        id: _uuid.v4(),
        pedidoId: pedidoId,
        orden: (ultimo ?? -1) + 1,
      );
      await _db.into(_db.lineasPedido).insert(_aCompanion(linea, ahora));
      await _tocarPedido(pedidoId, ahora);
      return linea;
    });
  }

  Future<void> guardarLinea(LineaPedido linea) {
    return _db.transaction(() async {
      final ahora = DateTime.now();
      await (_db.update(_db.lineasPedido)..where((t) => t.id.equals(linea.id)))
          .write(
        LineasPedidoCompanion(
          marca: Value(linea.marca),
          codigo: Value(linea.codigo),
          descripcion: Value(linea.descripcion),
          cantPedida: Value(linea.cantPedida),
          cantEnviada: Value(linea.cantEnviada),
          valorTotalPuntos: Value(linea.valorTotalPuntos),
          precioUnitario: Value(linea.precioUnitario),
          precioRevista: Value(linea.precioRevista),
          valorTotalPromocionado: Value(linea.valorTotalPromocionado),
          totalDescuentoCn: Value(linea.totalDescuentoCn),
          valorRegalos: Value(linea.valorRegalos),
          precioTotalManual: Value(linea.precioTotalManual),
          valorPromSinIvaManual: Value(linea.valorPromSinIvaManual),
          tuPagasManual: Value(linea.tuPagasManual),
          productoId: Value(linea.productoId),
          actualizadoEn: Value(ahora),
        ),
      );
      await _tocarPedido(linea.pedidoId, ahora);
    });
  }

  Future<void> eliminarLinea(LineaPedido linea) {
    return _db.transaction(() async {
      final ahora = DateTime.now();
      await (_db.update(_db.lineasPedido)..where((t) => t.id.equals(linea.id)))
          .write(
        LineasPedidoCompanion(
          eliminadoEn: Value(ahora),
          actualizadoEn: Value(ahora),
        ),
      );
      await _tocarPedido(linea.pedidoId, ahora);
    });
  }

  /// Refresca la marca de tiempo del pedido cuando cambian sus lineas, para
  /// que la sincronizacion futura sepa que el conjunto cambio.
  Future<void> _tocarPedido(String pedidoId, DateTime ahora) {
    return (_db.update(_db.pedidos)..where((t) => t.id.equals(pedidoId)))
        .write(PedidosCompanion(actualizadoEn: Value(ahora)));
  }

  // --- Mapeo ---------------------------------------------------------------

  Pedido _aPedido(PedidoRow fila) => Pedido(
        id: fila.id,
        fecha: fila.fecha,
        campana: fila.campana,
        marcaPredeterminada: fila.marcaPredeterminada,
        notas: fila.notas,
        cerrado: fila.cerrado,
        recibidoEn: fila.recibidoEn,
      );

  LineaPedido _aLinea(LineaRow fila) => LineaPedido(
        id: fila.id,
        pedidoId: fila.pedidoId,
        marca: fila.marca,
        codigo: fila.codigo,
        descripcion: fila.descripcion,
        cantPedida: fila.cantPedida,
        cantEnviada: fila.cantEnviada,
        valorTotalPuntos: fila.valorTotalPuntos,
        precioUnitario: fila.precioUnitario,
        precioRevista: fila.precioRevista,
        valorTotalPromocionado: fila.valorTotalPromocionado,
        totalDescuentoCn: fila.totalDescuentoCn,
        valorRegalos: fila.valorRegalos,
        precioTotalManual: fila.precioTotalManual,
        valorPromSinIvaManual: fila.valorPromSinIvaManual,
        tuPagasManual: fila.tuPagasManual,
        productoId: fila.productoId,
        orden: fila.orden,
      );

  LineasPedidoCompanion _aCompanion(LineaPedido linea, DateTime ahora) =>
      LineasPedidoCompanion.insert(
        id: linea.id,
        pedidoId: linea.pedidoId,
        marca: Value(linea.marca),
        codigo: Value(linea.codigo),
        descripcion: Value(linea.descripcion),
        cantPedida: Value(linea.cantPedida),
        cantEnviada: Value(linea.cantEnviada),
        valorTotalPuntos: Value(linea.valorTotalPuntos),
        precioUnitario: Value(linea.precioUnitario),
        precioRevista: Value(linea.precioRevista),
        valorTotalPromocionado: Value(linea.valorTotalPromocionado),
        totalDescuentoCn: Value(linea.totalDescuentoCn),
        valorRegalos: Value(linea.valorRegalos),
        precioTotalManual: Value(linea.precioTotalManual),
        valorPromSinIvaManual: Value(linea.valorPromSinIvaManual),
        tuPagasManual: Value(linea.tuPagasManual),
        productoId: Value(linea.productoId),
        orden: Value(linea.orden),
        creadoEn: ahora,
        actualizadoEn: ahora,
      );
}
