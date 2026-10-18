import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/inventario/data/inventario_repository.dart';
import 'package:punto_venta_madre/features/inventario/domain/producto_borrador.dart';
import 'package:punto_venta_madre/features/pedidos/data/pedidos_repository.dart';
import 'package:punto_venta_madre/features/pedidos/domain/linea_borrador.dart';
import 'package:punto_venta_madre/infrastructure/database/app_database.dart';

/// Pruebas de la operacion que une el pedido a la distribuidora con el
/// inventario: recibir. Es el unico camino por el que las existencias suben
/// sin que la propietaria las teclee.
void main() {
  late AppDatabase db;
  late InventarioRepository inventario;
  late PedidosRepository repo;

  setUp(() {
    db = AppDatabase.paraPruebas(NativeDatabase.memory());
    inventario = InventarioRepository(db);
    repo = PedidosRepository(db, inventario);
  });

  tearDown(() => db.close());

  LineaBorrador linea({
    String codigo = '0123',
    String descripcion = 'Crema de noche',
    int cantPedida = 6,
    int cantEnviada = 6,
    String? productoId,
  }) {
    return LineaBorrador(
      marca: 'Jafra',
      codigo: codigo,
      descripcion: descripcion,
      cantPedida: cantPedida,
      cantEnviada: cantEnviada,
      valorTotalPuntos: 0,
      precioUnitario: 0,
      precioRevista: 0,
      valorTotalPromocionado: 11600,
      totalDescuentoCn: 1600,
      valorRegalos: 0,
      productoId: productoId,
    );
  }

  test('recibir da de alta el producto que no existia', () async {
    final pedido = await repo.crearPedido(campana: 'C-14');
    await repo.agregarLinea(pedido.id, linea());

    await repo.recibirPedido(pedido.id);

    final productos = await inventario.observarProductos().first;
    expect(productos, hasLength(1));
    expect(productos.single.codigo, '0123');
    expect(productos.single.descripcion, 'Crema de noche');
    expect(productos.single.cantidadActual, 6);
    expect(productos.single.cantidadOriginal, 6);
  });

  test('recibir suma al producto que ya existia, por marca y codigo', () async {
    await inventario.crearProducto(
      const ProductoBorrador(
        marca: 'Jafra',
        codigo: '0123',
        descripcion: 'Crema de noche',
        cantidadActual: 4,
      ),
    );

    final pedido = await repo.crearPedido();
    await repo.agregarLinea(pedido.id, linea(cantEnviada: 6));
    await repo.recibirPedido(pedido.id);

    final productos = await inventario.observarProductos().first;
    expect(productos, hasLength(1), reason: 'no debe duplicar el articulo');
    expect(productos.single.cantidadActual, 10);
    expect(productos.single.cantidadOriginal, 10);
  });

  test('entra lo enviado, no lo pedido', () async {
    final pedido = await repo.crearPedido();
    await repo.agregarLinea(pedido.id, linea(cantPedida: 10, cantEnviada: 7));

    await repo.recibirPedido(pedido.id);

    final productos = await inventario.observarProductos().first;
    expect(productos.single.cantidadActual, 7);

    final lineas = await repo.observarLineas(pedido.id).first;
    expect(lineas.single.faltantes, 3);
  });

  test('una linea sin piezas enviadas no crea producto', () async {
    final pedido = await repo.crearPedido();
    await repo.agregarLinea(pedido.id, linea(cantPedida: 5, cantEnviada: 0));

    await repo.recibirPedido(pedido.id);

    expect(await inventario.observarProductos().first, isEmpty);
  });

  test('recibir dos veces no duplica existencias', () async {
    final pedido = await repo.crearPedido();
    await repo.agregarLinea(pedido.id, linea(cantEnviada: 5));

    await repo.recibirPedido(pedido.id);
    await repo.recibirPedido(pedido.id);

    final productos = await inventario.observarProductos().first;
    expect(productos.single.cantidadActual, 5);
  });

  test('al recibir, la linea queda enlazada al producto y el pedido cerrado',
      () async {
    final pedido = await repo.crearPedido();
    await repo.agregarLinea(pedido.id, linea());

    await repo.recibirPedido(pedido.id);

    final productos = await inventario.observarProductos().first;
    final lineas = await repo.observarLineas(pedido.id).first;
    expect(lineas.single.productoId, productos.single.id);

    final guardado = await repo.observarPedido(pedido.id).first;
    expect(guardado!.recibido, isTrue);
    expect(guardado.cerrado, isTrue);
  });

  test('dos lineas del mismo articulo suman al mismo producto', () async {
    final pedido = await repo.crearPedido();
    await repo.agregarLinea(pedido.id, linea(cantEnviada: 3));
    await repo.agregarLinea(pedido.id, linea(cantEnviada: 2));

    await repo.recibirPedido(pedido.id);

    final productos = await inventario.observarProductos().first;
    expect(productos, hasLength(1));
    expect(productos.single.cantidadActual, 5);
  });
}
