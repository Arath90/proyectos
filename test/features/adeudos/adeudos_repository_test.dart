import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/adeudos/data/adeudos_repository.dart';
import 'package:punto_venta_madre/features/clientes/data/clientes_repository.dart';
import 'package:punto_venta_madre/features/clientes/domain/cliente.dart';
import 'package:punto_venta_madre/features/inventario/data/inventario_repository.dart';
import 'package:punto_venta_madre/features/inventario/domain/producto_borrador.dart';
import 'package:punto_venta_madre/features/ventas/data/ventas_repository.dart';
import 'package:punto_venta_madre/features/ventas/domain/linea_venta_borrador.dart';
import 'package:punto_venta_madre/infrastructure/database/app_database.dart';

/// Pruebas de los adeudos contra la base.
///
/// Lo que se ejercita es la promesa que justifica el feature: **un adeudo no
/// toca el inventario**. La deuda vieja de alguien es dinero, no mercancia, y
/// registrarla no puede mover ni una pieza del catalogo, porque esas piezas
/// salieron de la casa hace meses.
///
/// Y la otra mitad: un pago que tapa adeudo es una sola fila en `abonos`, con
/// su reparto guardado, y por eso se lee tanto desde la venta como desde el
/// cliente.
void main() {
  late AppDatabase db;
  late InventarioRepository inventario;
  late VentasRepository ventas;
  late ClientesRepository clientes;
  late AdeudosRepository repo;
  late Cliente tony;

  setUp(() async {
    db = AppDatabase.paraPruebas(NativeDatabase.memory());
    inventario = InventarioRepository(db);
    ventas = VentasRepository(db, inventario);
    clientes = ClientesRepository(db);
    repo = AdeudosRepository(db);
    tony = await clientes.asegurarCliente('Tony');
  });

  tearDown(() => db.close());

  test('anotar lo que alguien debe no mueve el inventario', () async {
    final producto = await inventario.crearProducto(
      const ProductoBorrador(
        marca: 'Jafra',
        codigo: '0123',
        descripcion: 'Crema de noche',
        cantidadActual: 10,
      ),
    );

    await repo.crearAdeudo(
      clienteId: tony.id,
      monto: 200000,
      concepto: 'Lo de diciembre',
    );

    final guardado = await inventario.obtenerProducto(producto.id);
    expect(guardado!.cantidadActual, 10);
    expect(guardado.cantidadOriginal, 10);
    expect(await ventas.observarVentas().first, isEmpty);
  });

  test('un cargo se corrige y se borra logicamente', () async {
    final cargo = await repo.crearAdeudo(clienteId: tony.id, monto: 200000);

    await repo.guardarAdeudo(cargo.copyWith(monto: 150000, concepto: 'Ajuste'));
    var lista = await repo.observarAdeudos().first;
    expect(lista.single.monto, 150000);
    expect(lista.single.concepto, 'Ajuste');

    await repo.eliminarAdeudo(cargo.id);
    lista = await repo.observarAdeudos().first;
    expect(lista, isEmpty);
  });

  test('el cargo traspasado recuerda de que venta salio', () async {
    final venta = await ventas.crearVenta(
      cliente: tony.nombre,
      clienteId: tony.id,
    );
    await repo.crearAdeudo(
      clienteId: tony.id,
      monto: 80000,
      ventaOrigenId: venta.id,
    );

    final cargo = (await repo.observarAdeudos().first).single;
    expect(cargo.ventaOrigenId, venta.id);
    expect(cargo.vieneDeVenta, isTrue);
  });

  group('un pago que tapa adeudo y venta a la vez', () {
    /// El caso que la propietaria describio: Tony debe dos mil de antes, se
    /// lleva mil mas y deja quinientos. El billete es uno solo.
    test('se guarda como una fila leible por los dos lados', () async {
      final producto = await inventario.crearProducto(
        const ProductoBorrador(
          marca: 'Jafra',
          codigo: '0123',
          descripcion: 'Crema de noche',
          cantidadActual: 10,
        ),
      );
      await repo.crearAdeudo(clienteId: tony.id, monto: 200000);

      final venta = await ventas.crearVenta(
        cliente: tony.nombre,
        clienteId: tony.id,
      );
      await ventas.agregarLinea(
        venta.id,
        LineaVentaBorrador.deProducto(
          producto,
          cantidad: 1,
          precioUnitario: 100000,
        ),
      );

      await ventas.registrarAbono(
        monto: 50000,
        ventaId: venta.id,
        clienteId: tony.id,
        montoAdeudo: 30000,
      );

      final porVenta = await ventas.observarAbonosPorVenta().first;
      final porCliente = await ventas.observarAbonosPorCliente().first;

      expect(porVenta[venta.id], hasLength(1));
      expect(porCliente[tony.id], hasLength(1));
      expect(
        porVenta[venta.id]!.single.id,
        porCliente[tony.id]!.single.id,
        reason: 'es el mismo pago visto por sus dos mitades',
      );

      final pago = porVenta[venta.id]!.single;
      expect(pago.monto, 50000);
      expect(pago.montoAdeudo, 30000);
      expect(pago.montoVenta, 20000);
    });

    test('un pago de pura deuda vieja no cuelga de ninguna venta', () async {
      await repo.crearAdeudo(clienteId: tony.id, monto: 200000);
      await ventas.registrarAbono(
        monto: 50000,
        clienteId: tony.id,
        montoAdeudo: 50000,
      );

      expect(
        await ventas.observarAbonosPorVenta().first,
        isEmpty,
        reason: 'meterlo ahi haria que alguna venta cobrara lo que no es suyo',
      );
      final porCliente = await ventas.observarAbonosPorCliente().first;
      expect(porCliente[tony.id]!.single.ventaId, null);
      expect(porCliente[tony.id]!.single.montoAdeudo, 50000);
    });
  });

  /// Borrar una venta se lleva sus pagos, porque eran de ella. Pero un pago que
  /// ademas tapo deuda vieja no puede desaparecer: ese dinero si se cobro y
  /// bajo una deuda que nada tiene que ver con la venta que se esta borrando.
  group('borrar una venta con pagos repartidos', () {
    test('el pago mixto sobrevive recortado a su parte de adeudo', () async {
      await repo.crearAdeudo(clienteId: tony.id, monto: 200000);
      final venta = await ventas.crearVenta(
        cliente: tony.nombre,
        clienteId: tony.id,
      );
      await ventas.registrarAbono(
        monto: 50000,
        ventaId: venta.id,
        clienteId: tony.id,
        montoAdeudo: 30000,
      );

      await ventas.eliminarVenta(venta.id);

      final porCliente = await ventas.observarAbonosPorCliente().first;
      final pago = porCliente[tony.id]!.single;
      expect(pago.ventaId, null, reason: 'ya no cuelga de nada');
      expect(pago.monto, 30000);
      expect(
        pago.montoAdeudo,
        30000,
        reason: 'lo que quedo es exactamente lo que bajo la deuda vieja',
      );
    });

    test('el pago que solo era de la venta se va con ella', () async {
      final venta = await ventas.crearVenta(
        cliente: tony.nombre,
        clienteId: tony.id,
      );
      await ventas.registrarAbono(
        monto: 50000,
        ventaId: venta.id,
        clienteId: tony.id,
      );

      await ventas.eliminarVenta(venta.id);

      expect(await ventas.observarAbonosPorCliente().first, isEmpty);
    });
  });
}
