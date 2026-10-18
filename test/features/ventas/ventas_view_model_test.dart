import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/app/providers.dart';
import 'package:punto_venta_madre/features/inventario/domain/producto.dart';
import 'package:punto_venta_madre/features/inventario/domain/producto_borrador.dart';
import 'package:punto_venta_madre/features/ventas/domain/linea_venta_borrador.dart';
import 'package:punto_venta_madre/features/ventas/domain/venta.dart';
import 'package:punto_venta_madre/features/ventas/presentation/ventas_view_model.dart';
import 'package:punto_venta_madre/infrastructure/database/app_database.dart';

/// Pruebas del ViewModel del listado de ventas.
///
/// Lo que se ejercita aqui es lo que ninguna otra capa puede hacer sola: coser
/// tres lecturas independientes -encabezados, renglones y abonos- en una lista
/// de `VentaDetallada`, y decidir que se ve con cada filtro. El resumen de
/// arriba debe hablar de lo filtrado, no del historico.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.paraPruebas(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [baseDeDatosProvider.overrideWithValue(db)],
    );
    container.listen(ventasViewModelProvider, (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Espera a que el estado cumpla una condicion.
  ///
  /// Entre escribir en la base y verlo aqui hay dos saltos asincronos: el
  /// stream de Drift emite y solo entonces Riverpod recalcula. Leer de
  /// inmediato dejaria pruebas que pasan o fallan segun la maquina.
  Future<VentasEstado> esperar(
    bool Function(VentasEstado) condicion, {
    Duration limite = const Duration(seconds: 5),
  }) async {
    final plazo = DateTime.now().add(limite);
    while (DateTime.now().isBefore(plazo)) {
      final estado = container.read(ventasViewModelProvider);
      if (condicion(estado)) return estado;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    fail('El estado de ventas nunca cumplio lo esperado.');
  }

  Future<VentasEstado> estadoCon(int ventas) =>
      esperar((e) => e.ventas.value?.length == ventas);

  /// Espera a que todas las ventas listadas ya traigan sus renglones.
  ///
  /// Encabezados, renglones y abonos llegan por streams distintos: una venta
  /// puede aparecer un instante antes que lo que vendio.
  Future<VentasEstado> estadoConRenglones(int ventas) => esperar(
        (e) =>
            e.ventas.value?.length == ventas &&
            e.ventas.value!.every((d) => d.lineas.isNotEmpty),
      );

  VentasViewModel vm() => container.read(ventasViewModelProvider.notifier);

  Future<Producto> darDeAlta({String codigo = '0123', int piezas = 50}) {
    return container.read(inventarioRepositoryProvider).crearProducto(
          ProductoBorrador(
            marca: 'Jafra',
            codigo: codigo,
            descripcion: 'Crema de noche',
            cantidadActual: piezas,
          ),
        );
  }

  /// Arma una venta completa y devuelve su id.
  Future<String> venderA(
    String cliente, {
    required Producto producto,
    int cantidad = 1,
    int precio = 10000,
    int abonado = 0,
    bool entregar = false,
    bool cancelar = false,
  }) async {
    final ventas = container.read(ventasRepositoryProvider);
    final venta = await ventas.crearVenta(cliente: cliente);
    await ventas.agregarLinea(
      venta.id,
      LineaVentaBorrador.deProducto(
        producto,
        cantidad: cantidad,
        precioUnitario: precio,
      ),
    );
    if (abonado > 0) {
      await ventas.registrarAbono(ventaId: venta.id, monto: abonado);
    }
    if (entregar) await ventas.entregarVenta(venta.id);
    if (cancelar) await ventas.cancelarVenta(venta.id);
    return venta.id;
  }

  test('la venta llega al estado con sus renglones y sus abonos', () async {
    final producto = await darDeAlta();
    await venderA('Rosa', producto: producto, cantidad: 2, abonado: 5000);

    final estado = await esperar(
      (e) => (e.ventas.value?.single.abonos.length ?? 0) == 1,
    );
    final detalle = estado.ventas.value!.single;
    expect(detalle.venta.cliente, 'Rosa');
    expect(detalle.piezas, 2);
    expect(detalle.total, 20000);
    expect(detalle.abonado, 5000);
    expect(detalle.saldo, 15000);
  });

  test('el filtro "me deben" deja solo las que tienen saldo', () async {
    final producto = await darDeAlta();
    await venderA('Rosa', producto: producto, precio: 10000, abonado: 4000);
    await venderA('Ana', producto: producto, precio: 10000, abonado: 10000);

    await estadoCon(2);

    vm().filtrar(FiltroVentas.porCobrar);
    var estado = container.read(ventasViewModelProvider);
    expect(estado.visibles.value, hasLength(1));
    expect(estado.visibles.value!.single.venta.cliente, 'Rosa');

    vm().filtrar(FiltroVentas.liquidadas);
    estado = container.read(ventasViewModelProvider);
    expect(estado.visibles.value!.single.venta.cliente, 'Ana');
  });

  test('el filtro de apartadas ignora las ya entregadas', () async {
    final producto = await darDeAlta();
    await venderA('Rosa', producto: producto);
    await venderA('Ana', producto: producto, entregar: true);

    await esperar((e) => e.ventas.value?.any((d) => d.venta.entregada) ?? false);

    vm().filtrar(FiltroVentas.apartadas);
    final estado = container.read(ventasViewModelProvider);
    expect(estado.visibles.value, hasLength(1));
    expect(estado.visibles.value!.single.venta.cliente, 'Rosa');
  });

  test('el resumen habla de lo filtrado, no del historico', () async {
    final producto = await darDeAlta();
    await venderA('Rosa', producto: producto, precio: 10000, abonado: 4000);
    await venderA('Ana', producto: producto, precio: 30000, abonado: 30000);

    await esperar((e) => (e.resumen.total) == 40000);
    expect(container.read(ventasViewModelProvider).resumen.saldo, 6000);

    vm().filtrar(FiltroVentas.porCobrar);
    final estado = container.read(ventasViewModelProvider);
    expect(estado.resumen.ventas, 1);
    expect(estado.resumen.total, 10000);
    expect(estado.resumen.saldo, 6000);
  });

  test('una venta cancelada se lista pero no suma dinero', () async {
    final producto = await darDeAlta();
    await venderA('Rosa', producto: producto, precio: 99900, cancelar: true);

    final estado = await esperar(
      (e) => e.ventas.value?.single.venta.estado == EstadoVenta.cancelada,
    );
    expect(estado.visibles.value, hasLength(1));
    expect(estado.resumen.total, 0);
    expect(estado.resumen.saldo, 0);
  });

  test('la busqueda encuentra por cliente y por producto', () async {
    final crema = await darDeAlta(codigo: '0123');
    await venderA('Rosa Martinez', producto: crema);

    await estadoConRenglones(1);

    vm().buscar('martinez');
    expect(container.read(ventasViewModelProvider).visibles.value,
        hasLength(1));

    vm().buscar('0123');
    expect(container.read(ventasViewModelProvider).visibles.value,
        hasLength(1));

    vm().buscar('inexistente');
    expect(container.read(ventasViewModelProvider).visibles.value, isEmpty);
  });

  test('crear una venta devuelve el id para abrir su detalle', () async {
    final id = await vm().crearVenta(cliente: 'Rosa');

    final estado = await estadoCon(1);
    expect(estado.ventas.value!.single.venta.id, id);
    expect(estado.ventas.value!.single.venta.cliente, 'Rosa');
  });

  test('borrar una venta la saca del listado', () async {
    final producto = await darDeAlta();
    await venderA('Rosa', producto: producto);
    final estado = await estadoConRenglones(1);

    await vm().eliminar(estado.ventas.value!.single.venta);

    final vacio = await estadoCon(0);
    expect(vacio.visibles.value, isEmpty);
  });

  /// Las carpetas cambian la pantalla, no los datos: la lista corrida se
  /// vuelve una estanteria cuando hay algo que separar, y vuelve a ser una
  /// lista en cuanto se busca a alguien.
  group('carpetas', () {
    Future<VentasEstado> esperarCarpetas(int cuantas) =>
        esperar((e) => e.carpetas.length == cuantas);

    test('sin carpetas la pantalla se comporta como siempre', () async {
      final producto = await darDeAlta();
      await venderA('Rosa', producto: producto);
      final estado = await estadoConRenglones(1);

      expect(estado.hayCarpetas, isFalse);
      expect(
        estado.mostrarEstanteria,
        isFalse,
        reason: 'separar no le sirve a quien todavia tiene diez ventas',
      );
      expect(estado.visibles.value, hasLength(1));
    });

    test('la primera carpeta convierte la lista en estanteria', () async {
      final producto = await darDeAlta();
      await venderA('Rosa', producto: producto);
      await estadoConRenglones(1);

      await vm().crearCarpeta('Tepic');
      var estado = await esperarCarpetas(1);

      // Crear una carpeta entra a ella, que es lo que se queria al crearla.
      expect(estado.enRaiz, isFalse);
      expect(estado.titulo, 'Tepic');
      expect(estado.visibles.value, isEmpty, reason: 'nace vacia');

      vm().volver();
      estado = container.read(ventasViewModelProvider);
      expect(estado.mostrarEstanteria, isTrue);
      expect(
        estado.estanteria.map((c) => c.titulo),
        ['Tepic', 'Sin carpeta'],
        reason: 'el monton de las ventas sueltas se ve como una carpeta mas',
      );
    });

    test('dentro de una carpeta solo se ven sus ventas y sus totales',
        () async {
      final producto = await darDeAlta();
      await venderA('Rosa', producto: producto, precio: 10000);
      await venderA('Ana', producto: producto, precio: 30000);
      await estadoConRenglones(2);

      await vm().crearCarpeta('Tepic');
      final estado = await esperarCarpetas(1);
      final tepic = estado.carpetas.single;
      final rosa = estado.ventas.value!
          .firstWhere((d) => d.venta.cliente == 'Rosa')
          .venta;

      await vm().moverVenta(rosa, tepic.id);
      await esperar((e) => e.visibles.value?.length == 1);

      final dentro = container.read(ventasViewModelProvider);
      expect(dentro.visibles.value!.single.venta.cliente, 'Rosa');
      expect(
        dentro.resumen.total,
        10000,
        reason: 'el resumen habla de la carpeta abierta, no del historico',
      );

      vm().volver();
      final raiz = container.read(ventasViewModelProvider);
      final porCarpeta = {
        for (final fila in raiz.estanteria) fila.titulo: fila.resumen,
      };
      expect(porCarpeta['Tepic']!.total, 10000);
      expect(porCarpeta['Sin carpeta']!.total, 30000);
    });

    test('la venta nueva nace en la carpeta abierta', () async {
      await vm().crearCarpeta('Tepic');
      final estado = await esperarCarpetas(1);
      final tepic = estado.carpetas.single;

      final id = await vm().crearVenta(cliente: 'Rosa');
      final conVenta = await estadoCon(1);
      expect(conVenta.ventas.value!.single.venta.id, id);
      expect(conVenta.ventas.value!.single.venta.carpetaId, tepic.id);
    });

    test('buscar salta por encima de las carpetas', () async {
      final producto = await darDeAlta();
      await venderA('Rosa', producto: producto);
      await venderA('Ana', producto: producto);
      await estadoConRenglones(2);

      await vm().crearCarpeta('Tepic');
      final estado = await esperarCarpetas(1);
      final rosa = estado.ventas.value!
          .firstWhere((d) => d.venta.cliente == 'Rosa')
          .venta;
      await vm().moverVenta(rosa, estado.carpetas.single.id);
      vm().volver();

      // Desde la estanteria, quien teclea un nombre busca a una persona y no
      // un lugar: la busqueda tiene que cruzar las carpetas.
      vm().buscar('Rosa');
      final buscando = container.read(ventasViewModelProvider);
      expect(buscando.mostrarEstanteria, isFalse);
      expect(buscando.visibles.value, hasLength(1));
      expect(buscando.visibles.value!.single.venta.cliente, 'Rosa');

      vm().buscar('');
      expect(
        container.read(ventasViewModelProvider).mostrarEstanteria,
        isTrue,
      );
    });

    test('borrar la carpeta abierta regresa a la estanteria', () async {
      final producto = await darDeAlta();
      await venderA('Rosa', producto: producto);
      await estadoConRenglones(1);

      await vm().crearCarpeta('Tepic');
      final estado = await esperarCarpetas(1);
      expect(estado.enRaiz, isFalse);

      await vm().eliminarCarpeta(estado.carpetas.single);

      final fuera = await esperarCarpetas(0);
      expect(fuera.enRaiz, isTrue);
      expect(fuera.ventas.value, hasLength(1), reason: 'la venta sigue ahi');
    });

    test('una carpeta sin nombre no se crea', () async {
      expect(await vm().crearCarpeta('   '), isNotNull);
      expect(container.read(ventasViewModelProvider).carpetas, isEmpty);
    });
  });
}
