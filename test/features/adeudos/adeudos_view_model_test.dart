import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/app/app.dart';
import 'package:punto_venta_madre/app/providers.dart';
import 'package:punto_venta_madre/features/adeudos/domain/cuenta_cliente.dart';
import 'package:punto_venta_madre/features/adeudos/presentation/adeudos_view_model.dart';
import 'package:punto_venta_madre/features/clientes/domain/cliente.dart';
import 'package:punto_venta_madre/features/inventario/domain/producto.dart';
import 'package:punto_venta_madre/features/inventario/domain/producto_borrador.dart';
import 'package:punto_venta_madre/features/ventas/domain/linea_venta_borrador.dart';
import 'package:punto_venta_madre/features/ventas/domain/venta_detallada.dart';
import 'package:punto_venta_madre/features/ventas/presentation/venta_detalle_view_model.dart';
import 'package:punto_venta_madre/features/ventas/presentation/ventas_view_model.dart';
import 'package:punto_venta_madre/infrastructure/database/app_database.dart';

/// La historia completa de Tony, que es la que pidio la propietaria.
///
/// Tony debe dos mil pesos de antes -mercancia que se llevo cuando la
/// aplicacion no existia- y ademas se acaba de llevar mil en producto. Cuando
/// deja un pago, se descuenta primero del adeudo y solo lo que sobra baja la
/// venta.
///
/// Es la prueba que cruza los tres features a la vez, y por eso corre sobre el
/// cableado real de providers en vez de sobre un repositorio suelto: lo que se
/// esta verificando es justamente que ventas y adeudos, que no se conocen,
/// sumen la misma cuenta.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  // El concepto del cargo traspasado lleva la fecha de la venta escrita en
  // espanol, igual que la pantalla: sin los formatos cargados, `Formato`
  // revienta. Es la misma preparacion que hace `main`.
  setUpAll(prepararFormatos);

  setUp(() {
    db = AppDatabase.paraPruebas(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [baseDeDatosProvider.overrideWithValue(db)],
    );
    // Sin un oyente los `Notifier` no se recalculan solos.
    container.listen(ventasViewModelProvider, (_, _) {});
    container.listen(adeudosViewModelProvider, (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Espera a que la cuenta de alguien cumpla una condicion.
  ///
  /// Entre escribir en la base y verlo aqui hay varios saltos asincronos:
  /// emiten los streams de Drift, se recalcula el ViewModel de ventas y solo
  /// entonces el de adeudos, que lee del anterior. Leer de inmediato dejaria
  /// pruebas que pasan o fallan segun la maquina.
  Future<CuentaCliente> esperarCuenta(
    String clienteId,
    bool Function(CuentaCliente) condicion, {
    Duration limite = const Duration(seconds: 5),
  }) async {
    final plazo = DateTime.now().add(limite);
    while (DateTime.now().isBefore(plazo)) {
      final cuenta = container.read(cuentaClienteProvider(clienteId));
      if (cuenta != null && condicion(cuenta)) return cuenta;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    fail('La cuenta del cliente nunca cumplio lo esperado.');
  }

  /// Espera a que la venta abierta cumpla una condicion.
  ///
  /// Hace falta ademas de [esperarCuenta] porque hay cambios que no mueven la
  /// deuda: entregar una venta saca la mercancia del inventario pero le debe
  /// exactamente lo mismo al cliente, y sin esperar a que el ViewModel lo vea
  /// la prueba pediria traspasar una venta que para el sigue sin entregar.
  Future<VentaDetallada> esperarVenta(
    String ventaId,
    bool Function(VentaDetallada) condicion, {
    Duration limite = const Duration(seconds: 5),
  }) async {
    final plazo = DateTime.now().add(limite);
    while (DateTime.now().isBefore(plazo)) {
      final detalle = container.read(ventaDetalleViewModelProvider(ventaId)).venta;
      if (detalle != null && condicion(detalle)) return detalle;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    fail('La venta nunca cumplio lo esperado.');
  }

  Future<Cliente> darDeAltaA(String nombre) =>
      container.read(clientesRepositoryProvider).asegurarCliente(nombre);

  Future<Producto> darDeAltaProducto({int piezas = 50}) {
    return container.read(inventarioRepositoryProvider).crearProducto(
          const ProductoBorrador(
            marca: 'Jafra',
            codigo: '0123',
            descripcion: 'Crema de noche',
            cantidadActual: 50,
          ).copyWith(cantidadActual: piezas),
        );
  }

  /// Le vende [precio] centavos de producto a alguien y devuelve el id.
  ///
  /// Deja escuchando el ViewModel de esa venta, que es lo que hace su pantalla
  /// al abrirse. Sin oyente, Riverpod no lo reconstruye cuando cambia lo que
  /// observa y el `Notifier` se queda desfasado: llamarle un comando entonces
  /// revienta con "Cannot use ref functions after the dependency of a provider
  /// changed".
  Future<String> venderleA(Cliente cliente, {required int precio}) async {
    final producto = await darDeAltaProducto();
    final id = await container
        .read(ventasViewModelProvider.notifier)
        .crearVenta(cliente: cliente.nombre, clienteId: cliente.id);
    container.listen(ventaDetalleViewModelProvider(id), (_, _) {});
    await container.read(ventasRepositoryProvider).agregarLinea(
          id,
          LineaVentaBorrador.deProducto(
            producto,
            cantidad: 1,
            precioUnitario: precio,
          ),
        );
    return id;
  }

  test('la cuenta suma lo de antes y lo de la venta nueva', () async {
    final tony = await darDeAltaA('Tony');
    await container.read(adeudosViewModelProvider.notifier).registrarAdeudo(
          clienteId: tony.id,
          monto: 200000,
          concepto: 'Lo de diciembre',
        );
    await venderleA(tony, precio: 100000);

    final cuenta = await esperarCuenta(tony.id, (c) => c.deudaTotal == 300000);
    expect(cuenta.saldoAdeudo, 200000);
    expect(cuenta.saldoEnVentas, 100000);
    expect(cuenta.ventasAbiertas, 1);
  });

  test('el abono en la venta baja primero el adeudo', () async {
    final tony = await darDeAltaA('Tony');
    await container.read(adeudosViewModelProvider.notifier).registrarAdeudo(
          clienteId: tony.id,
          monto: 200000,
        );
    final ventaId = await venderleA(tony, precio: 100000);
    await esperarCuenta(tony.id, (c) => c.deudaTotal == 300000);

    // La pantalla de la venta propone el reparto y lo entrega decidido.
    final vm = container.read(ventaDetalleViewModelProvider(ventaId).notifier);
    final estado = container.read(ventaDetalleViewModelProvider(ventaId));
    expect(
      estado.repartoAAdeudo(50000),
      50000,
      reason: 'no alcanza a tapar los 2000 viejos: todo va para alla',
    );

    final falla = await vm.abonar(50000, montoAdeudo: 50000);
    expect(falla, isNull);

    final cuenta = await esperarCuenta(tony.id, (c) => c.saldoAdeudo == 150000);
    expect(
      cuenta.saldoEnVentas,
      100000,
      reason: 'la venta del dia no bajo: el pago se fue contra lo viejo',
    );
    expect(cuenta.deudaTotal, 250000);
  });

  test('lo que sobra despues de tapar el adeudo baja la venta', () async {
    final tony = await darDeAltaA('Tony');
    await container.read(adeudosViewModelProvider.notifier).registrarAdeudo(
          clienteId: tony.id,
          monto: 200000,
        );
    final ventaId = await venderleA(tony, precio: 100000);
    await esperarCuenta(tony.id, (c) => c.deudaTotal == 300000);

    final vm = container.read(ventaDetalleViewModelProvider(ventaId).notifier);
    await vm.abonar(250000, montoAdeudo: 200000);

    final cuenta = await esperarCuenta(tony.id, (c) => c.saldoAdeudo == 0);
    expect(cuenta.saldoEnVentas, 50000);
    expect(cuenta.deudaTotal, 50000);
  });

  test('un abono a la venta sin tocar el adeudo tambien se puede', () async {
    final tony = await darDeAltaA('Tony');
    await container.read(adeudosViewModelProvider.notifier).registrarAdeudo(
          clienteId: tony.id,
          monto: 200000,
        );
    final ventaId = await venderleA(tony, precio: 100000);
    await esperarCuenta(tony.id, (c) => c.deudaTotal == 300000);

    // La propuesta es tapar lo viejo, pero la decision es de ella.
    final vm = container.read(ventaDetalleViewModelProvider(ventaId).notifier);
    await vm.abonar(50000);

    final cuenta = await esperarCuenta(tony.id, (c) => c.saldoEnVentas == 50000);
    expect(cuenta.saldoAdeudo, 200000);
  });

  test('no se puede mandar al adeudo mas de lo que entrego', () async {
    final tony = await darDeAltaA('Tony');
    final ventaId = await venderleA(tony, precio: 100000);
    await esperarCuenta(tony.id, (c) => c.saldoEnVentas == 100000);

    final vm = container.read(ventaDetalleViewModelProvider(ventaId).notifier);
    expect(await vm.abonar(50000, montoAdeudo: 80000), isNotNull);
    expect(await vm.abonar(0), isNotNull);
  });

  test('una venta sin cliente del padron no puede abonar al adeudo', () async {
    final ventaId =
        await container.read(ventasViewModelProvider.notifier).crearVenta();
    container.listen(ventaDetalleViewModelProvider(ventaId), (_, _) {});
    final vm = container.read(ventaDetalleViewModelProvider(ventaId).notifier);
    expect(await vm.abonar(50000, montoAdeudo: 50000), isNotNull);
  });

  /// Traspasar no cobra nada: la deuda cambia de lugar y el total no se mueve.
  /// Es lo que la propietaria hace cuando deja de perseguir hoja por hoja.
  group('pasar el saldo de una venta a la cuenta del cliente', () {
    test('sale de ventas, entra al adeudo y el total no cambia', () async {
      final tony = await darDeAltaA('Tony');
      final ventaId = await venderleA(tony, precio: 100000);
      await container.read(ventasRepositoryProvider).entregarVenta(ventaId);
      await esperarVenta(ventaId, (d) => d.venta.entregada);

      final vm = container.read(ventaDetalleViewModelProvider(ventaId).notifier);
      expect(await vm.pasarSaldoAAdeudo(), isNull);

      final cuenta = await esperarCuenta(tony.id, (c) => c.saldoAdeudo == 100000);
      expect(cuenta.saldoEnVentas, 0);
      expect(cuenta.deudaTotal, 100000, reason: 'nadie pago nada');
    });

    test('la venta queda sin saldo pero no como liquidada', () async {
      final tony = await darDeAltaA('Tony');
      final ventaId = await venderleA(tony, precio: 100000);
      await container.read(ventasRepositoryProvider).entregarVenta(ventaId);
      await esperarVenta(ventaId, (d) => d.venta.entregada);

      await container
          .read(ventaDetalleViewModelProvider(ventaId).notifier)
          .pasarSaldoAAdeudo();
      await esperarCuenta(tony.id, (c) => c.saldoAdeudo == 100000);

      final detalle =
          container.read(ventaDetalleViewModelProvider(ventaId)).venta!;
      expect(detalle.saldo, 0);
      expect(detalle.traspasado, 100000);
      expect(detalle.traspasadaAAdeudo, isTrue);
      expect(detalle.liquidada, isFalse);
    });

    test('deshacerlo devuelve el saldo a su venta', () async {
      final tony = await darDeAltaA('Tony');
      final ventaId = await venderleA(tony, precio: 100000);
      await container.read(ventasRepositoryProvider).entregarVenta(ventaId);
      await esperarVenta(ventaId, (d) => d.venta.entregada);

      final vm = container.read(ventaDetalleViewModelProvider(ventaId).notifier);
      await vm.pasarSaldoAAdeudo();
      await esperarCuenta(tony.id, (c) => c.saldoAdeudo == 100000);

      await vm.deshacerTraspaso();

      final cuenta = await esperarCuenta(tony.id, (c) => c.saldoAdeudo == 0);
      expect(cuenta.saldoEnVentas, 100000);
    });

    test('una venta sin entregar no se puede traspasar', () async {
      final tony = await darDeAltaA('Tony');
      final ventaId = await venderleA(tony, precio: 100000);
      await esperarCuenta(tony.id, (c) => c.saldoEnVentas == 100000);

      final vm = container.read(ventaDetalleViewModelProvider(ventaId).notifier);
      expect(
        await vm.pasarSaldoAAdeudo(),
        isNotNull,
        reason: 'mientras la mercancia no salga, lo que hay es un apartado',
      );
    });
  });

  group('el listado de adeudos', () {
    test('empieza mostrando solo a quien debe', () async {
      final tony = await darDeAltaA('Tony');
      await darDeAltaA('Rosa');
      await container.read(adeudosViewModelProvider.notifier).registrarAdeudo(
            clienteId: tony.id,
            monto: 200000,
          );
      await esperarCuenta(tony.id, (c) => c.saldoAdeudo == 200000);

      final estado = container.read(adeudosViewModelProvider);
      expect(estado.visibles.value!.map((c) => c.cliente.nombre), ['Tony']);
      expect(estado.resumen.adeudo, 200000);

      container.read(adeudosViewModelProvider.notifier)
          .filtrar(FiltroAdeudos.todos);
      expect(container.read(adeudosViewModelProvider).visibles.value, hasLength(2));
    });

    test('busca por nombre ignorando acentos y mayusculas', () async {
      final tono = await darDeAltaA('Toño');
      await darDeAltaA('Rosa');
      await container.read(adeudosViewModelProvider.notifier).registrarAdeudo(
            clienteId: tono.id,
            monto: 200000,
          );
      await esperarCuenta(tono.id, (c) => c.saldoAdeudo == 200000);

      final vm = container.read(adeudosViewModelProvider.notifier)
        ..filtrar(FiltroAdeudos.todos)
        ..buscar('TONO');

      final visibles = container.read(adeudosViewModelProvider).visibles.value!;
      expect(visibles.map((c) => c.cliente.nombre), ['Toño']);
      vm.buscar('');
    });
  });
}
