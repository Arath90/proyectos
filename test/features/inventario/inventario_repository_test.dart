import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/inventario/data/inventario_repository.dart';
import 'package:punto_venta_madre/features/inventario/domain/producto_borrador.dart';
import 'package:punto_venta_madre/infrastructure/database/app_database.dart';

/// Pruebas del CRUD del inventario y, sobre todo, de la regla que lo gobierna:
/// una entrada sube existencia actual y original; una salida solo baja la
/// actual. Es la regla de la que dependen los otros dos features.
void main() {
  late AppDatabase db;
  late InventarioRepository repo;

  setUp(() {
    db = AppDatabase.paraPruebas(NativeDatabase.memory());
    repo = InventarioRepository(db);
  });

  tearDown(() => db.close());

  test('un producto recien dado de alta aparece en el catalogo', () async {
    await repo.crearProducto(
      const ProductoBorrador(
        marca: 'Jafra',
        codigo: '0123',
        descripcion: 'Crema de noche',
        cantidadActual: 5,
      ),
    );

    final productos = await repo.observarProductos().first;
    expect(productos, hasLength(1));
    expect(productos.single.codigo, '0123');
    // Al capturar por primera vez, lo que hay es lo que entro.
    expect(productos.single.cantidadOriginal, 5);
  });

  test('no se puede repetir el par marca y codigo', () async {
    const borrador = ProductoBorrador(marca: 'Jafra', codigo: '0123');
    await repo.crearProducto(borrador);

    expect(
      () => repo.crearProducto(borrador),
      throwsA(isA<ProductoDuplicadoException>()),
    );
  });

  test('el mismo codigo en otra marca si se permite', () async {
    await repo.crearProducto(
      const ProductoBorrador(marca: 'Jafra', codigo: '0123'),
    );
    await repo.crearProducto(
      const ProductoBorrador(marca: 'Avon', codigo: '0123'),
    );

    final productos = await repo.observarProductos().first;
    expect(productos, hasLength(2));
  });

  test('una entrada sube la existencia actual y la original', () async {
    final producto = await repo.crearProducto(
      const ProductoBorrador(codigo: '0123', cantidadActual: 2),
    );

    await repo.registrarEntrada(productoId: producto.id, piezas: 8);

    final guardado = await repo.obtenerProducto(producto.id);
    expect(guardado!.cantidadActual, 10);
    expect(guardado.cantidadOriginal, 10);
  });

  test('una salida solo baja la existencia actual', () async {
    final producto = await repo.crearProducto(
      const ProductoBorrador(codigo: '0123', cantidadActual: 10),
    );

    await repo.registrarSalida(productoId: producto.id, piezas: 3);

    final guardado = await repo.obtenerProducto(producto.id);
    expect(guardado!.cantidadActual, 7);
    expect(guardado.cantidadOriginal, 10, reason: 'vender no es devolver');
    expect(guardado.salidas, 3);
  });

  test('revertir una salida no infla la existencia original', () async {
    final producto = await repo.crearProducto(
      const ProductoBorrador(codigo: '0123', cantidadActual: 10),
    );

    await repo.registrarSalida(productoId: producto.id, piezas: 4);
    await repo.revertirSalida(productoId: producto.id, piezas: 4);

    final guardado = await repo.obtenerProducto(producto.id);
    expect(guardado!.cantidadActual, 10);
    expect(guardado.cantidadOriginal, 10);
  });

  test('un producto dado de baja desaparece del catalogo', () async {
    final producto = await repo.crearProducto(
      const ProductoBorrador(codigo: '0123'),
    );

    await repo.eliminarProducto(producto.id);

    expect(await repo.observarProductos().first, isEmpty);
    // Pero la fila sigue ahi: las ventas viejas la apuntan.
    expect(await repo.obtenerProducto(producto.id), isNotNull);
  });

  test('la busqueda por codigo ignora mayusculas y espacios', () async {
    await repo.crearProducto(
      const ProductoBorrador(marca: 'Jafra', codigo: 'AB12'),
    );

    final encontrado = await repo.buscarPorCodigo(
      marca: '  jafra ',
      codigo: ' ab12 ',
    );
    expect(encontrado, isNotNull);
  });
}
