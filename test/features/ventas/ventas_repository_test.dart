import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/inventario/data/inventario_repository.dart';
import 'package:punto_venta_madre/features/inventario/domain/producto.dart';
import 'package:punto_venta_madre/features/inventario/domain/producto_borrador.dart';
import 'package:punto_venta_madre/features/ventas/data/ventas_repository.dart';
import 'package:punto_venta_madre/features/ventas/domain/linea_venta_borrador.dart';
import 'package:punto_venta_madre/features/ventas/domain/venta.dart';
import 'package:punto_venta_madre/features/ventas/domain/venta_detallada.dart';
import 'package:punto_venta_madre/infrastructure/database/app_database.dart';

/// Pruebas del cruce entre venta e inventario, que es donde estan las reglas
/// que mas facil se rompen: cuando bajan las existencias, cuando regresan, y
/// que se sigue debiendo despues de entregar.
void main() {
  late AppDatabase db;
  late InventarioRepository inventario;
  late VentasRepository repo;

  setUp(() {
    db = AppDatabase.paraPruebas(NativeDatabase.memory());
    inventario = InventarioRepository(db);
    repo = VentasRepository(db, inventario);
  });

  tearDown(() => db.close());

  Future<Producto> darDeAlta({int piezas = 10}) => inventario.crearProducto(
        ProductoBorrador(
          marca: 'Jafra',
          codigo: '0123',
          descripcion: 'Crema de noche',
          cantidadActual: piezas,
        ),
      );

  Future<VentaDetallada> detalleDe(String ventaId) async {
    final venta = await repo.observarVenta(ventaId).first;
    return VentaDetallada(
      venta: venta!,
      lineas: await repo.observarLineas(ventaId).first,
      abonos: await repo.observarAbonos(ventaId).first,
    );
  }

  test('una venta apartada no baja la existencia, la compromete', () async {
    final producto = await darDeAlta();
    final venta = await repo.crearVenta(cliente: 'Rosa');
    await repo.agregarLinea(
      venta.id,
      LineaVentaBorrador.deProducto(producto, cantidad: 3, precioUnitario: 9900),
    );

    final guardado = await inventario.obtenerProducto(producto.id);
    expect(guardado!.cantidadActual, 10, reason: 'todavia no se entrega');

    final apartado = await repo.observarApartadoPorProducto().first;
    expect(apartado[producto.id], 3);
  });

  test('entregar saca las piezas del inventario', () async {
    final producto = await darDeAlta();
    final venta = await repo.crearVenta(cliente: 'Rosa');
    await repo.agregarLinea(
      venta.id,
      LineaVentaBorrador.deProducto(producto, cantidad: 3, precioUnitario: 9900),
    );

    await repo.entregarVenta(venta.id);

    final guardado = await inventario.obtenerProducto(producto.id);
    expect(guardado!.cantidadActual, 7);
    expect(guardado.cantidadOriginal, 10);

    // Ya entregada, deja de apartar.
    final apartado = await repo.observarApartadoPorProducto().first;
    expect(apartado[producto.id], isNull);
  });

  test('entregar dos veces no descuenta dos veces', () async {
    final producto = await darDeAlta();
    final venta = await repo.crearVenta();
    await repo.agregarLinea(
      venta.id,
      LineaVentaBorrador.deProducto(producto, cantidad: 4),
    );

    await repo.entregarVenta(venta.id);
    await repo.entregarVenta(venta.id);

    final guardado = await inventario.obtenerProducto(producto.id);
    expect(guardado!.cantidadActual, 6);
  });

  test('cancelar una venta entregada regresa las piezas', () async {
    final producto = await darDeAlta();
    final venta = await repo.crearVenta();
    await repo.agregarLinea(
      venta.id,
      LineaVentaBorrador.deProducto(producto, cantidad: 4),
    );
    await repo.entregarVenta(venta.id);

    await repo.cancelarVenta(venta.id);

    final guardado = await inventario.obtenerProducto(producto.id);
    expect(guardado!.cantidadActual, 10);
    expect(guardado.cantidadOriginal, 10);

    final detalle = await detalleDe(venta.id);
    expect(detalle.venta.estado, EstadoVenta.cancelada);
    expect(detalle.total, 0, reason: 'una venta cancelada no se cobra');
  });

  test('cambiar la cantidad de un renglon ya entregado ajusta la diferencia',
      () async {
    final producto = await darDeAlta();
    final venta = await repo.crearVenta();
    final linea = await repo.agregarLinea(
      venta.id,
      LineaVentaBorrador.deProducto(producto, cantidad: 2),
    );
    await repo.entregarVenta(venta.id);

    await repo.guardarLinea(linea.copyWith(cantidad: 5));

    final guardado = await inventario.obtenerProducto(producto.id);
    expect(guardado!.cantidadActual, 5, reason: '10 - 5, no 10 - 2 - 5');
  });

  test('quitar un renglon de una venta entregada devuelve sus piezas',
      () async {
    final producto = await darDeAlta();
    final venta = await repo.crearVenta();
    final linea = await repo.agregarLinea(
      venta.id,
      LineaVentaBorrador.deProducto(producto, cantidad: 6),
    );
    await repo.entregarVenta(venta.id);

    await repo.eliminarLinea(linea);

    final guardado = await inventario.obtenerProducto(producto.id);
    expect(guardado!.cantidadActual, 10);
  });

  test('agregar un renglon a una venta ya entregada descuenta enseguida',
      () async {
    final producto = await darDeAlta();
    final venta = await repo.crearVenta();
    await repo.entregarVenta(venta.id);

    await repo.agregarLinea(
      venta.id,
      LineaVentaBorrador.deProducto(producto, cantidad: 2),
    );

    final guardado = await inventario.obtenerProducto(producto.id);
    expect(guardado!.cantidadActual, 8);
  });

  test('el saldo baja con cada abono hasta liquidar', () async {
    final producto = await darDeAlta();
    final venta = await repo.crearVenta(cliente: 'Rosa');
    await repo.agregarLinea(
      venta.id,
      LineaVentaBorrador.deProducto(producto, cantidad: 2, precioUnitario: 5000),
    );

    var detalle = await detalleDe(venta.id);
    expect(detalle.total, 10000);
    expect(detalle.saldo, 10000);

    await repo.registrarAbono(ventaId: venta.id, monto: 4000);
    detalle = await detalleDe(venta.id);
    expect(detalle.abonado, 4000);
    expect(detalle.saldo, 6000);
    expect(detalle.pagoParcial, isTrue);

    await repo.registrarAbono(ventaId: venta.id, monto: 6000);
    detalle = await detalleDe(venta.id);
    expect(detalle.saldo, 0);
    expect(detalle.liquidada, isTrue);
  });

  test('abonar de mas deja el saldo en cero, no en negativo', () async {
    final producto = await darDeAlta();
    final venta = await repo.crearVenta();
    await repo.agregarLinea(
      venta.id,
      LineaVentaBorrador.deProducto(producto, cantidad: 1, precioUnitario: 5000),
    );
    await repo.registrarAbono(ventaId: venta.id, monto: 8000);

    final detalle = await detalleDe(venta.id);
    expect(detalle.saldo, 0);
  });

  test('el descuento del renglon se resta del importe', () async {
    final producto = await darDeAlta();
    final venta = await repo.crearVenta();
    await repo.agregarLinea(
      venta.id,
      LineaVentaBorrador(
        productoId: producto.id,
        descripcion: 'Crema',
        cantidad: 3,
        precioUnitario: 10000,
        descuento: 5000,
      ),
    );

    final detalle = await detalleDe(venta.id);
    expect(detalle.subtotal, 30000);
    expect(detalle.descuento, 5000);
    expect(detalle.total, 25000);
  });

  test('un renglon sin producto cobra pero no mueve inventario', () async {
    final producto = await darDeAlta();
    final venta = await repo.crearVenta();
    await repo.agregarLinea(
      venta.id,
      const LineaVentaBorrador(
        descripcion: 'Muestra suelta',
        cantidad: 2,
        precioUnitario: 3000,
      ),
    );
    await repo.entregarVenta(venta.id);

    final guardado = await inventario.obtenerProducto(producto.id);
    expect(guardado!.cantidadActual, 10);
    expect((await detalleDe(venta.id)).total, 6000);
  });

  test('borrar una venta entregada regresa las piezas y la saca del listado',
      () async {
    final producto = await darDeAlta();
    final venta = await repo.crearVenta();
    await repo.agregarLinea(
      venta.id,
      LineaVentaBorrador.deProducto(producto, cantidad: 3),
    );
    await repo.entregarVenta(venta.id);

    await repo.eliminarVenta(venta.id);

    expect(await repo.observarVentas().first, isEmpty);
    final guardado = await inventario.obtenerProducto(producto.id);
    expect(guardado!.cantidadActual, 10);
  });

  test('los renglones conservan el orden de captura', () async {
    final venta = await repo.crearVenta();
    for (final nombre in ['uno', 'dos', 'tres']) {
      await repo.agregarLinea(
        venta.id,
        LineaVentaBorrador(descripcion: nombre, cantidad: 1),
      );
    }

    final lineas = await repo.observarLineas(venta.id).first;
    expect(lineas.map((l) => l.descripcion), ['uno', 'dos', 'tres']);
  });
}
