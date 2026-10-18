import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/app/providers.dart';
import 'package:punto_venta_madre/features/inventario/domain/producto_borrador.dart';
import 'package:punto_venta_madre/features/inventario/presentation/inventario_view_model.dart';
import 'package:punto_venta_madre/features/ventas/domain/linea_venta_borrador.dart';
import 'package:punto_venta_madre/infrastructure/database/app_database.dart';

/// Pruebas del ViewModel del inventario.
///
/// Se ejercita sin interfaz, con un `ProviderContainer`: eso es justo lo que
/// compra la separacion de MVVM. Lo que se prueba aqui es lo que la vista no
/// puede hacer sola: cruzar el catalogo con el apartado que publican las
/// ventas, y decidir que renglones se ven.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.paraPruebas(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [baseDeDatosProvider.overrideWithValue(db)],
    );
    // Mantiene vivo el ViewModel durante toda la prueba.
    container.listen(inventarioViewModelProvider, (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Espera a que el estado del ViewModel cumpla una condicion.
  ///
  /// Hace falta porque entre escribir en la base y ver el cambio aqui hay dos
  /// saltos asincronos: el stream de Drift emite, y solo entonces Riverpod
  /// vuelve a ejecutar `build`. Leer de inmediato dejaria pruebas que pasan o
  /// fallan segun la maquina.
  Future<InventarioEstado> esperar(
    bool Function(InventarioEstado) condicion, {
    Duration limite = const Duration(seconds: 5),
  }) async {
    final plazo = DateTime.now().add(limite);
    while (DateTime.now().isBefore(plazo)) {
      final estado = container.read(inventarioViewModelProvider);
      if (condicion(estado)) return estado;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    fail('El estado del inventario nunca cumplio lo esperado.');
  }

  /// Espera a que el catalogo tenga exactamente [cuantos] productos.
  Future<InventarioEstado> estadoCon(int cuantos) =>
      esperar((e) => e.existencias.value?.length == cuantos);

  InventarioViewModel vm() =>
      container.read(inventarioViewModelProvider.notifier);

  Future<void> darDeAlta({
    String marca = 'Jafra',
    String codigo = '0123',
    String descripcion = 'Crema de noche',
    int piezas = 10,
  }) async {
    await container.read(inventarioRepositoryProvider).crearProducto(
          ProductoBorrador(
            marca: marca,
            codigo: codigo,
            descripcion: descripcion,
            cantidadActual: piezas,
          ),
        );
  }

  test('el catalogo llega al estado con el apartado en cero', () async {
    await darDeAlta();

    final estado = await estadoCon(1);
    expect(estado.existencias.value!.single.apartadas, 0);
    expect(estado.existencias.value!.single.disponibles, 10);
    expect(estado.piezasTotales, 10);
  });

  test('una venta apartada baja lo disponible sin bajar la existencia',
      () async {
    await darDeAlta(piezas: 10);
    final producto =
        (await container.read(inventarioRepositoryProvider).observarProductos().first)
            .single;

    final ventas = container.read(ventasRepositoryProvider);
    final venta = await ventas.crearVenta(cliente: 'Rosa');
    await ventas.agregarLinea(
      venta.id,
      LineaVentaBorrador.deProducto(producto, cantidad: 4),
    );

    final estado = await esperar(
      (e) => (e.existencias.value?.single.apartadas ?? 0) == 4,
    );
    final existencia = estado.existencias.value!.single;
    expect(existencia.producto.cantidadActual, 10);
    expect(existencia.apartadas, 4);
    expect(existencia.disponibles, 6);
    expect(estado.piezasApartadas, 4);
  });

  test('la busqueda filtra por marca, codigo o descripcion', () async {
    await darDeAlta(marca: 'Jafra', codigo: '0123', descripcion: 'Crema');
    await darDeAlta(marca: 'Avon', codigo: '9988', descripcion: 'Labial');

    await estadoCon(2);

    vm().buscar('labial');
    expect(container.read(inventarioViewModelProvider).visibles.value,
        hasLength(1));

    vm().buscar('0123');
    expect(container.read(inventarioViewModelProvider).visibles.value,
        hasLength(1));

    vm().buscar('avon');
    expect(container.read(inventarioViewModelProvider).visibles.value,
        hasLength(1));

    vm().buscar('');
    expect(container.read(inventarioViewModelProvider).visibles.value,
        hasLength(2));
  });

  test('el filtro de agotados esconde lo que ya no hay', () async {
    await darDeAlta(codigo: '0123', piezas: 5);
    await darDeAlta(codigo: '9988', piezas: 0);

    var estado = await estadoCon(2);
    expect(estado.agotados, 1);
    expect(estado.visibles.value, hasLength(2));

    vm().alternarOcultarAgotados();
    estado = container.read(inventarioViewModelProvider);
    expect(estado.visibles.value, hasLength(1));
  });

  test('la busqueda sobrevive a que llegue un producto nuevo', () async {
    await darDeAlta(codigo: '0123', descripcion: 'Crema');
    await estadoCon(1);

    vm().buscar('crema');
    await darDeAlta(codigo: '9988', descripcion: 'Labial');
    await estadoCon(2);

    final estado = container.read(inventarioViewModelProvider);
    expect(estado.busqueda, 'crema', reason: 'no se debe borrar lo tecleado');
    expect(estado.visibles.value, hasLength(1));
  });

  test('crear un producto duplicado devuelve el mensaje, no revienta',
      () async {
    await darDeAlta(marca: 'Jafra', codigo: '0123');
    await estadoCon(1);

    final mensaje = await vm().crear(
      const ProductoBorrador(marca: 'Jafra', codigo: '0123'),
    );
    expect(mensaje, contains('Ya existe'));
  });

  test('un producto sin codigo ni descripcion se rechaza', () async {
    final mensaje = await vm().crear(const ProductoBorrador(marca: 'Jafra'));
    expect(mensaje, contains('al menos el codigo'));
  });

  test('ajustar por arriba de lo entrado tambien sube la original', () async {
    await darDeAlta(piezas: 5);
    var estado = await estadoCon(1);
    final producto = estado.existencias.value!.single.producto;
    expect(producto.cantidadOriginal, 5);

    await vm().ajustarExistencia(producto, 8);
    estado = await esperar(
      (e) => e.existencias.value?.single.producto.cantidadActual == 8,
    );

    final guardado = estado.existencias.value!.single.producto;
    expect(guardado.cantidadActual, 8);
    expect(guardado.cantidadOriginal, 8);
  });

  test('ajustar a la baja no toca la existencia original', () async {
    await darDeAlta(piezas: 10);
    var estado = await estadoCon(1);

    await vm().ajustarExistencia(estado.existencias.value!.single.producto, 6);
    estado = await esperar(
      (e) => e.existencias.value?.single.producto.cantidadActual == 6,
    );

    final guardado = estado.existencias.value!.single.producto;
    expect(guardado.cantidadActual, 6);
    expect(guardado.cantidadOriginal, 10);
  });

  test('un ajuste negativo se recorta a cero', () async {
    await darDeAlta(piezas: 2);
    final estado = await estadoCon(1);

    await vm().ajustarExistencia(estado.existencias.value!.single.producto, -5);
    final ajustado = await esperar(
      (e) => e.existencias.value?.single.producto.cantidadActual == 0,
    );

    expect(ajustado.existencias.value!.single.producto.agotado, isTrue);
  });
}
