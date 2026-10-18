import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../infrastructure/database/app_database.dart';
import '../../inventario/data/inventario_repository.dart';
import '../domain/abono.dart';
import '../domain/carpeta_venta.dart';
import '../domain/linea_venta.dart';
import '../domain/linea_venta_borrador.dart';
import '../domain/venta.dart';

/// Traduce entre las filas de `Ventas`, `LineasVenta` y `Abonos` y los modelos
/// de dominio, y coordina el efecto que una venta tiene sobre el inventario.
///
/// Es el unico lugar donde se cruzan los dos features: recibe un
/// [InventarioRepository] y lo llama cuando la mercancia sale de verdad. La
/// regla que implementa es una sola, y esta escrita aqui porque es la venta
/// quien la dispara:
///
///  - venta `apartada`: no se toca `cantidadActual`; las piezas quedan
///    comprometidas y el apartado se calcula al vuelo con
///    [observarApartadoPorProducto].
///  - venta `entregada`: las piezas salen del inventario una sola vez, y
///    `entregadaEn` marca que ya salieron.
///  - venta `cancelada` o borrada: si ya habian salido, regresan.
///
/// Cada operacion que toca las dos tablas va en una transaccion, para que no
/// quede una venta entregada cuyo inventario no bajo, ni al reves.
///
/// Tambien es dueno de dos tablas que no mueven mercancia pero si acompanan a
/// la venta toda su vida: `CarpetasVenta`, que es como la propietaria separa
/// su trabajo por lugar, y `Abonos`, donde vive cada pago aunque una parte de
/// el haya ido a tapar un adeudo viejo. Los abonos se quedan aqui y no en el
/// feature de adeudos porque son una sola tabla y un pago es un pago venga de
/// donde venga; lo que cambia es a que le pega, no quien lo guarda.
class VentasRepository {
  VentasRepository(this._db, this._inventario, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final InventarioRepository _inventario;
  final Uuid _uuid;

  // --- Lectura -------------------------------------------------------------

  /// Las carpetas vigentes, en orden alfabetico.
  ///
  /// Alfabetico y no por fecha de creacion: la lista de carpetas se lee para
  /// encontrar un lugar por su nombre, y un orden que cambia solo -segun
  /// cuando se creo cada una- obliga a buscar con la vista cada vez.
  Stream<List<CarpetaVenta>> observarCarpetas() {
    final consulta = _db.select(_db.carpetasVenta)
      ..where((t) => t.eliminadoEn.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.nombre)]);
    return consulta.watch().map((filas) => filas.map(_aCarpeta).toList());
  }

  /// Ventas vigentes, de la mas reciente a la mas antigua.
  Stream<List<Venta>> observarVentas() {
    final consulta = _db.select(_db.ventas)
      ..where((t) => t.eliminadoEn.isNull())
      ..orderBy([
        (t) => OrderingTerm(expression: t.fecha, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.creadoEn, mode: OrderingMode.desc),
      ]);
    return consulta.watch().map((filas) => filas.map(_aVenta).toList());
  }

  Stream<Venta?> observarVenta(String ventaId) {
    final consulta = _db.select(_db.ventas)
      ..where((t) => t.id.equals(ventaId) & t.eliminadoEn.isNull());
    return consulta
        .watchSingleOrNull()
        .map((fila) => fila == null ? null : _aVenta(fila));
  }

  /// Renglones vigentes de una venta, en orden de captura.
  Stream<List<LineaVenta>> observarLineas(String ventaId) {
    final consulta = _db.select(_db.lineasVenta)
      ..where((t) => t.ventaId.equals(ventaId) & t.eliminadoEn.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.orden)]);
    return consulta.watch().map((filas) => filas.map(_aLinea).toList());
  }

  /// Todos los renglones vigentes, agrupados por venta.
  ///
  /// El listado necesita el total de cada venta y agruparlo en Dart deja las
  /// reglas de `VentaDetallada` como unica version de la verdad, igual que
  /// hace `PedidosRepository.observarLineasPorPedido`.
  Stream<Map<String, List<LineaVenta>>> observarLineasPorVenta() {
    final consulta = _db.select(_db.lineasVenta)
      ..where((t) => t.eliminadoEn.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.orden)]);
    return consulta.watch().map((filas) {
      final agrupadas = <String, List<LineaVenta>>{};
      for (final fila in filas) {
        agrupadas.putIfAbsent(fila.ventaId, () => []).add(_aLinea(fila));
      }
      return agrupadas;
    });
  }

  Stream<List<Abono>> observarAbonos(String ventaId) {
    final consulta = _db.select(_db.abonos)
      ..where((t) => t.ventaId.equals(ventaId) & t.eliminadoEn.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.fecha)]);
    return consulta.watch().map((filas) => filas.map(_aAbono).toList());
  }

  /// Todos los abonos vigentes, agrupados por venta.
  ///
  /// Los pagos de pura deuda vieja no aparecen: no cuelgan de ninguna venta y
  /// meterlos aqui haria que el listado de ventas cobrara dinero que nunca fue
  /// suyo.
  Stream<Map<String, List<Abono>>> observarAbonosPorVenta() {
    final consulta = _db.select(_db.abonos)
      ..where((t) => t.eliminadoEn.isNull() & t.ventaId.isNotNull())
      ..orderBy([(t) => OrderingTerm(expression: t.fecha)]);
    return consulta.watch().map((filas) {
      final agrupados = <String, List<Abono>>{};
      for (final fila in filas) {
        agrupados.putIfAbsent(fila.ventaId!, () => []).add(_aAbono(fila));
      }
      return agrupados;
    });
  }

  /// Todos los abonos vigentes de clientes del padron, agrupados por cliente.
  ///
  /// Es la otra mitad de la misma tabla: el mismo pago aparece aqui y en
  /// [observarAbonosPorVenta] cuando se repartio entre las dos cosas. No hay
  /// dos historias de pagos, hay una leida por dos lados, y por eso ninguna de
  /// las dos consultas suma nada: quien suma es el dominio, que sabe que de un
  /// pago la venta se lleva `montoVenta` y el adeudo `montoAdeudo`.
  Stream<Map<String, List<Abono>>> observarAbonosPorCliente() {
    final consulta = _db.select(_db.abonos)
      ..where((t) => t.eliminadoEn.isNull() & t.clienteId.isNotNull())
      ..orderBy([(t) => OrderingTerm(expression: t.fecha)]);
    return consulta.watch().map((filas) {
      final agrupados = <String, List<Abono>>{};
      for (final fila in filas) {
        agrupados.putIfAbsent(fila.clienteId!, () => []).add(_aAbono(fila));
      }
      return agrupados;
    });
  }

  /// Piezas comprometidas por ventas apartadas, por producto.
  ///
  /// Es lo que `Existencia` necesita para contestar "cuantas puedo prometer".
  /// Esta suma si se hace en SQL y no en Dart: a diferencia de los totales de
  /// una venta, aqui no hay ninguna regla de negocio que duplicar, solo un
  /// `SUM`, y traerse a memoria todos los renglones vendidos en la historia
  /// del negocio para sumar una columna seria pagar el catalogo completo cada
  /// vez que se abre el inventario.
  Stream<Map<String, int>> observarApartadoPorProducto() {
    return _db.customSelect(
      'SELECT lv.producto_id AS producto_id, SUM(lv.cantidad) AS piezas '
      'FROM lineas_venta lv '
      'JOIN ventas v ON v.id = lv.venta_id '
      'WHERE lv.eliminado_en IS NULL '
      '  AND v.eliminado_en IS NULL '
      '  AND v.estado = ? '
      '  AND v.entregada_en IS NULL '
      '  AND lv.producto_id IS NOT NULL '
      'GROUP BY lv.producto_id',
      variables: [Variable.withString(EstadoVenta.apartada.name)],
      readsFrom: {_db.lineasVenta, _db.ventas},
    ).watch().map((filas) {
      return {
        for (final fila in filas)
          fila.read<String>('producto_id'): fila.read<int>('piezas'),
      };
    });
  }

  // --- Escritura de ventas -------------------------------------------------

  Future<Venta> crearVenta({
    String cliente = '',
    String? clienteId,
    String? carpetaId,
    String notas = '',
    DateTime? fecha,
  }) async {
    final ahora = DateTime.now();
    final venta = Venta(
      id: _uuid.v4(),
      fecha: fecha ?? ahora,
      clienteId: clienteId,
      cliente: cliente.trim(),
      carpetaId: carpetaId,
      notas: notas,
    );
    await _db.into(_db.ventas).insert(
          VentasCompanion.insert(
            id: venta.id,
            fecha: venta.fecha,
            clienteId: Value(venta.clienteId),
            cliente: Value(venta.cliente),
            carpetaId: Value(venta.carpetaId),
            notas: Value(venta.notas),
            estado: Value(venta.estado.name),
            creadoEn: ahora,
            actualizadoEn: ahora,
          ),
        );
    return venta;
  }

  /// Guarda los datos del encabezado.
  ///
  /// A proposito no toca `estado` ni `entregadaEn`: cambiar de estado mueve
  /// inventario, asi que se hace con [entregarVenta], [cancelarVenta] o
  /// [reabrirVenta] y no editando un campo.
  Future<void> guardarVenta(Venta venta) {
    return (_db.update(_db.ventas)..where((t) => t.id.equals(venta.id))).write(
      VentasCompanion(
        fecha: Value(venta.fecha),
        clienteId: Value(venta.clienteId),
        cliente: Value(venta.cliente.trim()),
        carpetaId: Value(venta.carpetaId),
        notas: Value(venta.notas),
        actualizadoEn: Value(DateTime.now()),
      ),
    );
  }

  /// Cambia la venta de carpeta. `null` la saca de la que estuviera y la deja
  /// suelta.
  ///
  /// Es un metodo propio y no una edicion del encabezado porque se hace desde
  /// el listado, con la venta cerrada y sin haberla cargado entera: separar
  /// treinta ventas en carpetas seria insoportable si cada una obligara a
  /// abrirla.
  Future<void> moverVenta(String ventaId, String? carpetaId) {
    return _escribirVenta(
      ventaId,
      VentasCompanion(
        carpetaId: Value(carpetaId),
        actualizadoEn: Value(DateTime.now()),
      ),
    );
  }

  /// Entrega la venta: las piezas salen del inventario.
  ///
  /// Si ya estaba entregada no hace nada, para que tocar el boton dos veces no
  /// descuente dos veces.
  Future<void> entregarVenta(String ventaId) {
    return _db.transaction(() async {
      final fila = await _filaVenta(ventaId);
      if (fila == null || fila.entregadaEn != null) return;

      for (final linea in await _lineasVigentes(ventaId)) {
        if (!linea.mueveInventario) continue;
        await _inventario.registrarSalida(
          productoId: linea.productoId!,
          piezas: linea.cantidad,
        );
      }

      final ahora = DateTime.now();
      await _escribirVenta(
        ventaId,
        VentasCompanion(
          estado: Value(EstadoVenta.entregada.name),
          entregadaEn: Value(ahora),
          actualizadoEn: Value(ahora),
        ),
      );
    });
  }

  /// Cancela el apartado. Si la mercancia ya habia salido, regresa.
  Future<void> cancelarVenta(String ventaId) =>
      _cambiarEstadoDevolviendo(ventaId, EstadoVenta.cancelada);

  /// Regresa la venta a apartada: deshace una entrega o una cancelacion.
  Future<void> reabrirVenta(String ventaId) =>
      _cambiarEstadoDevolviendo(ventaId, EstadoVenta.apartada);

  /// Borra la venta y todo lo suyo, devolviendo al inventario lo que hubiera
  /// salido.
  ///
  /// Es borrado logico, como en el resto del esquema: un registro que
  /// desaparece no se puede propagar a las demas tablets.
  Future<void> eliminarVenta(String ventaId) {
    return _db.transaction(() async {
      await _devolverSiHabiaSalido(ventaId);

      final ahora = DateTime.now();
      await (_db.update(_db.lineasVenta)
            ..where((t) => t.ventaId.equals(ventaId) & t.eliminadoEn.isNull()))
          .write(
        LineasVentaCompanion(
          eliminadoEn: Value(ahora),
          actualizadoEn: Value(ahora),
        ),
      );
      // Los pagos que solo tocaron esta venta se van con ella. Los que ademas
      // taparon adeudo se quedan, sueltos y recortados a esa parte: ese dinero
      // si se cobro y bajo una deuda que nada tiene que ver con la venta que
      // se esta borrando, y hacerlo desaparecer resucitaria un adeudo que ya
      // estaba pagado.
      final mixtos = await (_db.select(_db.abonos)
            ..where((t) =>
                t.ventaId.equals(ventaId) &
                t.eliminadoEn.isNull() &
                t.montoAdeudo.isBiggerThanValue(0)))
          .get();
      for (final fila in mixtos) {
        await (_db.update(_db.abonos)..where((t) => t.id.equals(fila.id)))
            .write(
          AbonosCompanion(
            ventaId: const Value(null),
            monto: Value(fila.montoAdeudo),
            actualizadoEn: Value(ahora),
          ),
        );
      }
      await (_db.update(_db.abonos)
            ..where((t) => t.ventaId.equals(ventaId) & t.eliminadoEn.isNull()))
          .write(
        AbonosCompanion(
          eliminadoEn: Value(ahora),
          actualizadoEn: Value(ahora),
        ),
      );
      await _escribirVenta(
        ventaId,
        VentasCompanion(
          entregadaEn: const Value(null),
          eliminadoEn: Value(ahora),
          actualizadoEn: Value(ahora),
        ),
      );
    });
  }

  // --- Escritura de carpetas -----------------------------------------------

  Future<CarpetaVenta> crearCarpeta({
    String nombre = '',
    String notas = '',
  }) async {
    final ahora = DateTime.now();
    final carpeta = CarpetaVenta(
      id: _uuid.v4(),
      nombre: nombre.trim(),
      notas: notas.trim(),
    );
    await _db.into(_db.carpetasVenta).insert(
          CarpetasVentaCompanion.insert(
            id: carpeta.id,
            nombre: Value(carpeta.nombre),
            notas: Value(carpeta.notas),
            creadoEn: ahora,
            actualizadoEn: ahora,
          ),
        );
    return carpeta;
  }

  Future<void> guardarCarpeta(CarpetaVenta carpeta) {
    return (_db.update(_db.carpetasVenta)
          ..where((t) => t.id.equals(carpeta.id)))
        .write(
      CarpetasVentaCompanion(
        nombre: Value(carpeta.nombre.trim()),
        notas: Value(carpeta.notas.trim()),
        actualizadoEn: Value(DateTime.now()),
      ),
    );
  }

  /// Quita la carpeta y suelta sus ventas.
  ///
  /// Las ventas nunca se van con la carpeta. Una carpeta es una etiqueta -donde
  /// la propietaria decidio guardar la hoja-; la venta es el documento, con su
  /// mercancia y su saldo. Borrar la etiqueta no puede llevarse el documento,
  /// asi que sus ventas caen en "Sin carpeta", que es donde estaban antes de
  /// separarlas.
  Future<void> eliminarCarpeta(String carpetaId) {
    return _db.transaction(() async {
      final ahora = DateTime.now();
      await (_db.update(_db.ventas)
            ..where((t) => t.carpetaId.equals(carpetaId)))
          .write(
        VentasCompanion(
          carpetaId: const Value(null),
          actualizadoEn: Value(ahora),
        ),
      );
      await (_db.update(_db.carpetasVenta)
            ..where((t) => t.id.equals(carpetaId)))
          .write(
        CarpetasVentaCompanion(
          eliminadoEn: Value(ahora),
          actualizadoEn: Value(ahora),
        ),
      );
    });
  }

  // --- Escritura de renglones ----------------------------------------------

  /// Agrega un renglon al final de la venta.
  ///
  /// Si la venta ya estaba entregada, las piezas del renglon nuevo salen del
  /// inventario en el mismo momento: una venta entregada y su inventario no
  /// pueden quedar desalineados ni un instante.
  Future<LineaVenta> agregarLinea(String ventaId, LineaVentaBorrador borrador) {
    return _db.transaction(() async {
      final maximo = _db.lineasVenta.orden.max();
      final consulta = _db.selectOnly(_db.lineasVenta)
        ..addColumns([maximo])
        ..where(_db.lineasVenta.ventaId.equals(ventaId));
      final ultimo =
          await consulta.map((fila) => fila.read(maximo)).getSingleOrNull();

      final ahora = DateTime.now();
      final linea = borrador.aLinea(
        id: _uuid.v4(),
        ventaId: ventaId,
        orden: (ultimo ?? -1) + 1,
      );
      await _db.into(_db.lineasVenta).insert(_aCompanion(linea, ahora));

      if (await _yaEntregada(ventaId) && linea.mueveInventario) {
        await _inventario.registrarSalida(
          productoId: linea.productoId!,
          piezas: linea.cantidad,
        );
      }
      await _tocarVenta(ventaId, ahora);
      return linea;
    });
  }

  /// Guarda la edicion de un renglon, ajustando el inventario por la
  /// diferencia si la venta ya estaba entregada.
  Future<void> guardarLinea(LineaVenta linea) {
    return _db.transaction(() async {
      final anterior = await _filaLinea(linea.id);
      final ahora = DateTime.now();

      await (_db.update(_db.lineasVenta)..where((t) => t.id.equals(linea.id)))
          .write(
        LineasVentaCompanion(
          productoId: Value(linea.productoId),
          marca: Value(linea.marca.trim()),
          codigo: Value(linea.codigo.trim()),
          descripcion: Value(linea.descripcion.trim()),
          cantidad: Value(linea.cantidad),
          precioUnitario: Value(linea.precioUnitario),
          descuento: Value(linea.descuento),
          actualizadoEn: Value(ahora),
        ),
      );

      if (anterior != null && await _yaEntregada(linea.ventaId)) {
        await _ajustarSalida(_aLinea(anterior), linea);
      }
      await _tocarVenta(linea.ventaId, ahora);
    });
  }

  /// Quita un renglon y, si la venta ya estaba entregada, regresa sus piezas.
  Future<void> eliminarLinea(LineaVenta linea) {
    return _db.transaction(() async {
      final ahora = DateTime.now();
      await (_db.update(_db.lineasVenta)..where((t) => t.id.equals(linea.id)))
          .write(
        LineasVentaCompanion(
          eliminadoEn: Value(ahora),
          actualizadoEn: Value(ahora),
        ),
      );

      if (await _yaEntregada(linea.ventaId) && linea.mueveInventario) {
        await _inventario.revertirSalida(
          productoId: linea.productoId!,
          piezas: linea.cantidad,
        );
      }
      await _tocarVenta(linea.ventaId, ahora);
    });
  }

  // --- Escritura de abonos -------------------------------------------------

  /// Registra un pago. No toca el inventario: entregar y cobrar son dos cosas
  /// distintas y pueden pasar con meses de diferencia.
  ///
  /// Un pago es una sola fila aunque tape dos cosas. [montoAdeudo] es la parte
  /// que se aplico a la deuda vieja del cliente y el resto baja el saldo de
  /// [ventaId]; cualquiera de los dos destinos puede faltar, y de hecho falta
  /// seguido: un cliente sin deuda vieja paga con `montoAdeudo` en cero, y uno
  /// que solo viene a pagar lo de antes paga sin `ventaId`.
  ///
  /// El reparto llega decidido desde arriba. Aqui no se calcula porque la
  /// regla -tapar primero lo viejo- es del dominio y la propietaria la puede
  /// sobrescribir antes de guardar; el repositorio guarda lo que ella dijo.
  Future<Abono> registrarAbono({
    required int monto,
    String? ventaId,
    String? clienteId,
    int montoAdeudo = 0,
    DateTime? fecha,
    String nota = '',
  }) async {
    final ahora = DateTime.now();
    final abono = Abono(
      id: _uuid.v4(),
      ventaId: ventaId,
      clienteId: clienteId,
      fecha: fecha ?? ahora,
      monto: monto,
      montoAdeudo: montoAdeudo,
      nota: nota.trim(),
    );
    await _db.into(_db.abonos).insert(
          AbonosCompanion.insert(
            id: abono.id,
            ventaId: Value(abono.ventaId),
            clienteId: Value(abono.clienteId),
            fecha: abono.fecha,
            monto: Value(abono.monto),
            montoAdeudo: Value(abono.montoAdeudo),
            nota: Value(abono.nota),
            creadoEn: ahora,
            actualizadoEn: ahora,
          ),
        );
    await _tocarVenta(ventaId, ahora);
    return abono;
  }

  Future<void> guardarAbono(Abono abono) {
    return _db.transaction(() async {
      final ahora = DateTime.now();
      await (_db.update(_db.abonos)..where((t) => t.id.equals(abono.id))).write(
        AbonosCompanion(
          fecha: Value(abono.fecha),
          monto: Value(abono.monto),
          montoAdeudo: Value(abono.montoAdeudo),
          nota: Value(abono.nota.trim()),
          actualizadoEn: Value(ahora),
        ),
      );
      await _tocarVenta(abono.ventaId, ahora);
    });
  }

  Future<void> eliminarAbono(Abono abono) {
    return _db.transaction(() async {
      final ahora = DateTime.now();
      await (_db.update(_db.abonos)..where((t) => t.id.equals(abono.id))).write(
        AbonosCompanion(
          eliminadoEn: Value(ahora),
          actualizadoEn: Value(ahora),
        ),
      );
      await _tocarVenta(abono.ventaId, ahora);
    });
  }

  // --- Apoyos privados -----------------------------------------------------

  /// Cambia el estado devolviendo al inventario lo que hubiera salido.
  ///
  /// Cancelar y reabrir hacen exactamente lo mismo con las existencias, solo
  /// difieren en la etiqueta que dejan; tenerlo escrito una vez evita que una
  /// de las dos se olvide de devolver las piezas.
  Future<void> _cambiarEstadoDevolviendo(String ventaId, EstadoVenta destino) {
    return _db.transaction(() async {
      await _devolverSiHabiaSalido(ventaId);
      final ahora = DateTime.now();
      await _escribirVenta(
        ventaId,
        VentasCompanion(
          estado: Value(destino.name),
          entregadaEn: const Value(null),
          actualizadoEn: Value(ahora),
        ),
      );
    });
  }

  /// Regresa al inventario las piezas de una venta que ya habia sido
  /// entregada. No hace nada si nunca salio.
  Future<void> _devolverSiHabiaSalido(String ventaId) async {
    final fila = await _filaVenta(ventaId);
    if (fila == null || fila.entregadaEn == null) return;
    for (final linea in await _lineasVigentes(ventaId)) {
      if (!linea.mueveInventario) continue;
      await _inventario.revertirSalida(
        productoId: linea.productoId!,
        piezas: linea.cantidad,
      );
    }
  }

  /// Traslada al inventario la diferencia entre un renglon y su version nueva.
  ///
  /// Si cambio de producto son dos movimientos: lo viejo regresa a su producto
  /// y lo nuevo sale del otro. Si es el mismo producto basta con el delta.
  Future<void> _ajustarSalida(LineaVenta anterior, LineaVenta nueva) async {
    if (anterior.productoId != nueva.productoId) {
      if (anterior.mueveInventario) {
        await _inventario.revertirSalida(
          productoId: anterior.productoId!,
          piezas: anterior.cantidad,
        );
      }
      if (nueva.mueveInventario) {
        await _inventario.registrarSalida(
          productoId: nueva.productoId!,
          piezas: nueva.cantidad,
        );
      }
      return;
    }

    final productoId = nueva.productoId;
    if (productoId == null) return;
    final delta = nueva.cantidad - anterior.cantidad;
    if (delta > 0) {
      await _inventario.registrarSalida(productoId: productoId, piezas: delta);
    } else if (delta < 0) {
      await _inventario.revertirSalida(productoId: productoId, piezas: -delta);
    }
  }

  Future<bool> _yaEntregada(String ventaId) async =>
      (await _filaVenta(ventaId))?.entregadaEn != null;

  Future<VentaRow?> _filaVenta(String ventaId) {
    final consulta = _db.select(_db.ventas)..where((t) => t.id.equals(ventaId));
    return consulta.getSingleOrNull();
  }

  Future<LineaVentaRow?> _filaLinea(String lineaId) {
    final consulta = _db.select(_db.lineasVenta)
      ..where((t) => t.id.equals(lineaId));
    return consulta.getSingleOrNull();
  }

  Future<List<LineaVenta>> _lineasVigentes(String ventaId) async {
    final consulta = _db.select(_db.lineasVenta)
      ..where((t) => t.ventaId.equals(ventaId) & t.eliminadoEn.isNull());
    final filas = await consulta.get();
    return filas.map(_aLinea).toList();
  }

  Future<void> _escribirVenta(String ventaId, VentasCompanion cambios) {
    return (_db.update(_db.ventas)..where((t) => t.id.equals(ventaId)))
        .write(cambios);
  }

  /// Refresca la marca de tiempo de la venta cuando cambian sus renglones o
  /// sus abonos, para que la sincronizacion futura sepa que el conjunto
  /// cambio. Es el mismo criterio que usa `PedidosRepository`.
  ///
  /// Acepta `null` y no hace nada: un pago de pura deuda vieja no tiene venta
  /// que tocar, y obligar a quien llama a preguntarlo repartiria el mismo `if`
  /// por los tres metodos de abonos.
  Future<void> _tocarVenta(String? ventaId, DateTime ahora) async {
    if (ventaId == null) return;
    await _escribirVenta(
      ventaId,
      VentasCompanion(actualizadoEn: Value(ahora)),
    );
  }

  // --- Mapeo ---------------------------------------------------------------

  Venta _aVenta(VentaRow fila) => Venta(
        id: fila.id,
        fecha: fila.fecha,
        clienteId: fila.clienteId,
        cliente: fila.cliente,
        carpetaId: fila.carpetaId,
        notas: fila.notas,
        estado: EstadoVenta.desdeTexto(fila.estado),
        entregadaEn: fila.entregadaEn,
      );

  CarpetaVenta _aCarpeta(CarpetaVentaRow fila) =>
      CarpetaVenta(id: fila.id, nombre: fila.nombre, notas: fila.notas);

  LineaVenta _aLinea(LineaVentaRow fila) => LineaVenta(
        id: fila.id,
        ventaId: fila.ventaId,
        productoId: fila.productoId,
        marca: fila.marca,
        codigo: fila.codigo,
        descripcion: fila.descripcion,
        cantidad: fila.cantidad,
        precioUnitario: fila.precioUnitario,
        descuento: fila.descuento,
        orden: fila.orden,
      );

  Abono _aAbono(AbonoRow fila) => Abono(
        id: fila.id,
        ventaId: fila.ventaId,
        clienteId: fila.clienteId,
        fecha: fila.fecha,
        monto: fila.monto,
        montoAdeudo: fila.montoAdeudo,
        nota: fila.nota,
      );

  LineasVentaCompanion _aCompanion(LineaVenta linea, DateTime ahora) =>
      LineasVentaCompanion.insert(
        id: linea.id,
        ventaId: linea.ventaId,
        productoId: Value(linea.productoId),
        marca: Value(linea.marca),
        codigo: Value(linea.codigo),
        descripcion: Value(linea.descripcion),
        cantidad: Value(linea.cantidad),
        precioUnitario: Value(linea.precioUnitario),
        descuento: Value(linea.descuento),
        orden: Value(linea.orden),
        creadoEn: ahora,
        actualizadoEn: ahora,
      );
}
