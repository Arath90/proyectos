import 'package:async/async.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/inventario/data/inventario_repository.dart';
import 'package:punto_venta_madre/features/pedidos/data/pedidos_repository.dart';
import 'package:punto_venta_madre/features/pedidos/domain/linea_borrador.dart';
import 'package:punto_venta_madre/features/pedidos/domain/totales_pedido.dart';
import 'package:punto_venta_madre/infrastructure/database/app_database.dart';

LineaBorrador borrador({
  String codigo = '00123',
  String descripcion = 'Producto',
  int cantPedida = 1,
  int cantEnviada = 1,
  int valorTotalPuntos = 0,
  int precioUnitario = 0,
  int precioRevista = 0,
  int valorTotalPromocionado = 11600,
  int totalDescuentoCn = 1600,
  int valorRegalos = 0,
}) {
  return LineaBorrador(
    marca: 'Marca',
    codigo: codigo,
    descripcion: descripcion,
    cantPedida: cantPedida,
    cantEnviada: cantEnviada,
    valorTotalPuntos: valorTotalPuntos,
    precioUnitario: precioUnitario,
    precioRevista: precioRevista,
    valorTotalPromocionado: valorTotalPromocionado,
    totalDescuentoCn: totalDescuentoCn,
    valorRegalos: valorRegalos,
  );
}

void main() {
  late AppDatabase db;
  late PedidosRepository repo;

  setUp(() {
    db = AppDatabase.paraPruebas(NativeDatabase.memory());
    repo = PedidosRepository(db, InventarioRepository(db));
  });

  tearDown(() => db.close());

  test('un pedido recien creado aparece en el listado', () async {
    await repo.crearPedido(campana: 'C-14', marcaPredeterminada: 'Marca');
    final pedidos = await repo.observarPedidos().first;

    expect(pedidos, hasLength(1));
    expect(pedidos.single.campana, 'C-14');
    expect(pedidos.single.id, isNotEmpty);
  });

  test('cada pedido recibe un identificador propio', () async {
    final a = await repo.crearPedido();
    final b = await repo.crearPedido();
    expect(a.id, isNot(b.id));
  });

  test('las lineas conservan el orden de captura', () async {
    final pedido = await repo.crearPedido();
    await repo.agregarLinea(pedido.id, borrador(descripcion: 'Primera'));
    await repo.agregarLinea(pedido.id, borrador(descripcion: 'Segunda'));
    await repo.agregarLinea(pedido.id, borrador(descripcion: 'Tercera'));

    final lineas = await repo.observarLineas(pedido.id).first;
    expect(
      lineas.map((l) => l.descripcion),
      ['Primera', 'Segunda', 'Tercera'],
    );
    expect(lineas.map((l) => l.orden), [0, 1, 2]);
  });

  test('el codigo conserva los ceros a la izquierda', () async {
    final pedido = await repo.crearPedido();
    await repo.agregarLinea(pedido.id, borrador(codigo: '00042'));

    final lineas = await repo.observarLineas(pedido.id).first;
    expect(lineas.single.codigo, '00042');
  });

  test('las lineas de un pedido no se mezclan con las de otro', () async {
    final uno = await repo.crearPedido();
    final otro = await repo.crearPedido();
    await repo.agregarLinea(uno.id, borrador(descripcion: 'De uno'));
    await repo.agregarLinea(otro.id, borrador(descripcion: 'De otro'));

    final lineas = await repo.observarLineas(uno.id).first;
    expect(lineas.single.descripcion, 'De uno');
  });

  test('los valores derivados sobreviven al viaje a la base', () async {
    final pedido = await repo.crearPedido();
    await repo.agregarLinea(
      pedido.id,
      borrador(valorTotalPromocionado: 11600, totalDescuentoCn: 1600),
    );

    final linea = (await repo.observarLineas(pedido.id).first).single;
    expect(linea.valorPromSinIva, 10000);
    expect(linea.tuPagas, 10000);
    expect(linea.tieneAjusteManual, isFalse);
  });

  test('el precio de compra sobrevive al viaje a la base', () async {
    final pedido = await repo.crearPedido();
    await repo.agregarLinea(
      pedido.id,
      borrador(precioUnitario: 12850, precioRevista: 20000, cantPedida: 3),
    );

    final linea = (await repo.observarLineas(pedido.id).first).single;
    expect(linea.precioUnitario, 12850);
    expect(linea.precioRevista, 20000);
    expect(linea.precioTotal, 38550);
    expect(linea.precioTotalManual, isNull);
  });

  test('guardarLinea persiste un precio total capturado a mano', () async {
    final pedido = await repo.crearPedido();
    final linea = await repo.agregarLinea(
      pedido.id,
      borrador(precioUnitario: 12850, cantPedida: 3),
    );

    await repo.guardarLinea(linea.copyWith(precioTotalManual: (valor: 35000)));

    final guardada = (await repo.observarLineas(pedido.id).first).single;
    expect(guardada.precioTotal, 35000);
    expect(guardada.tieneAjusteManual, isTrue);
  });

  test('guardarLinea persiste un ajuste manual', () async {
    final pedido = await repo.crearPedido();
    final linea = await repo.agregarLinea(pedido.id, borrador());

    await repo.guardarLinea(linea.copyWith(tuPagasManual: (valor: 9999)));

    final guardada = (await repo.observarLineas(pedido.id).first).single;
    expect(guardada.tuPagasManual, 9999);
    expect(guardada.tuPagas, 9999);
    expect(guardada.tieneAjusteManual, isTrue);
  });

  test('un ajuste manual se puede devolver a modo calculado', () async {
    final pedido = await repo.crearPedido();
    final linea = await repo.agregarLinea(pedido.id, borrador());
    await repo.guardarLinea(linea.copyWith(tuPagasManual: (valor: 9999)));

    final conAjuste = (await repo.observarLineas(pedido.id).first).single;
    await repo.guardarLinea(conAjuste.copyWith(tuPagasManual: (valor: null)));

    final limpia = (await repo.observarLineas(pedido.id).first).single;
    expect(limpia.tuPagasManual, isNull);
    expect(limpia.tuPagas, 10000);
  });

  test('eliminar una linea la saca del listado', () async {
    final pedido = await repo.crearPedido();
    final linea = await repo.agregarLinea(pedido.id, borrador());
    await repo.agregarLinea(pedido.id, borrador(descripcion: 'Sobreviviente'));

    await repo.eliminarLinea(linea);

    final lineas = await repo.observarLineas(pedido.id).first;
    expect(lineas, hasLength(1));
    expect(lineas.single.descripcion, 'Sobreviviente');
  });

  test('eliminar es logico: la fila sigue en la tabla', () async {
    final pedido = await repo.crearPedido();
    final linea = await repo.agregarLinea(pedido.id, borrador());
    await repo.eliminarLinea(linea);

    // Un DELETE fisico no se podria propagar a las demas tablets cuando
    // exista backend, por eso solo se marca la fecha de baja.
    final filas = await db.select(db.lineasPedido).get();
    expect(filas, hasLength(1));
    expect(filas.single.eliminadoEn, isNotNull);
  });

  test('eliminar un pedido arrastra sus lineas', () async {
    final pedido = await repo.crearPedido();
    await repo.agregarLinea(pedido.id, borrador());
    await repo.agregarLinea(pedido.id, borrador());

    await repo.eliminarPedido(pedido.id);

    expect(await repo.observarPedidos().first, isEmpty);
    expect(await repo.observarLineas(pedido.id).first, isEmpty);
  });

  test('guardarPedido actualiza el encabezado', () async {
    final pedido = await repo.crearPedido(campana: 'C-14');
    await repo.guardarPedido(pedido.copyWith(campana: 'C-15', cerrado: true));

    final guardado = await repo.observarPedido(pedido.id).first;
    expect(guardado!.campana, 'C-15');
    expect(guardado.cerrado, isTrue);
  });

  test('observarPedido deja de emitir un pedido eliminado', () async {
    final pedido = await repo.crearPedido();
    await repo.eliminarPedido(pedido.id);

    expect(await repo.observarPedido(pedido.id).first, isNull);
  });

  test('los totales suman las lineas vigentes del pedido', () async {
    final pedido = await repo.crearPedido();
    await repo.agregarLinea(
      pedido.id,
      borrador(
        cantPedida: 10,
        cantEnviada: 8,
        precioUnitario: 5000,
        valorTotalPromocionado: 11600,
        totalDescuentoCn: 1600,
        valorRegalos: 500,
      ),
    );
    final descartada = await repo.agregarLinea(
      pedido.id,
      borrador(valorTotalPromocionado: 99900),
    );
    await repo.eliminarLinea(descartada);

    final totales =
        TotalesPedido.de(await repo.observarLineas(pedido.id).first);
    expect(totales.lineas, 1);
    // El costo suma por linea; el precio unitario, que es por pieza, no se
    // suma en ningun lado.
    expect(totales.precioTotal, 50000);
    expect(totales.valorTotalPromocionado, 11600);
    expect(totales.valorPromSinIva, 10000);
    expect(totales.tuPagas, 10000);
    expect(totales.valorRegalos, 500);
    expect(totales.faltantes, 2);
    expect(totales.tieneFaltantes, isTrue);
  });

  test('el listado emite de nuevo cuando cambian los datos', () async {
    // Comprueba que la interfaz se refresca sola: las pantallas escuchan este
    // stream en vez de volver a consultar a mano.
    //
    // Se espera cada emision antes de provocar el siguiente cambio; si no, la
    // insercion le gana a la consulta inicial y la prueba queda a merced del
    // orden en que se resuelvan los futures.
    final emisiones = StreamQueue(repo.observarPedidos());
    addTearDown(emisiones.cancel);

    expect(await emisiones.next, isEmpty);

    await repo.crearPedido();
    expect(await emisiones.next, hasLength(1));

    await repo.crearPedido();
    expect(await emisiones.next, hasLength(2));
  });
}
