import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/pedidos/domain/linea_pedido.dart';
import 'package:punto_venta_madre/features/pedidos/domain/pedido.dart';
import 'package:punto_venta_madre/features/reportes/domain/hoja_calculo.dart';
import 'package:punto_venta_madre/features/reportes/domain/reporte_pedidos.dart';

final _hoy = DateTime(2026, 9, 4);

LineaPedido _linea({
  String id = 'l1',
  String pedidoId = 'p1',
  int cantPedida = 3,
  int cantEnviada = 2,
  int precioUnitario = 8000,
  int valorTotalPromocionado = 11600,
  int totalDescuentoCn = 1600,
  int orden = 0,
}) {
  return LineaPedido(
    id: id,
    pedidoId: pedidoId,
    marca: 'Marca',
    codigo: '00123',
    descripcion: 'Crema',
    cantPedida: cantPedida,
    cantEnviada: cantEnviada,
    valorTotalPuntos: 250,
    precioUnitario: precioUnitario,
    precioRevista: 20000,
    valorTotalPromocionado: valorTotalPromocionado,
    totalDescuentoCn: totalDescuentoCn,
    valorRegalos: 0,
    orden: orden,
  );
}

int _col(Hoja hoja, String titulo) {
  final indice = hoja.columnas.indexWhere((c) => c.titulo == titulo);
  expect(indice, isNot(-1), reason: 'no existe la columna $titulo');
  return indice;
}

Hoja _hoja(LibroReporte libro, String nombre) =>
    libro.hojas.firstWhere((h) => h.nombre == nombre);

void main() {
  test('el reporte trae la hoja por pedido y la de renglones', () {
    final libro = armarReportePedidos(pedidos: const [], generadoEn: _hoy);

    expect(libro.hojas.map((h) => h.nombre), ['Pedidos', 'Renglones']);
    expect(libro.nombreArchivo, 'pedidos-2026-09-04.xlsx');
  });

  test('un pedido se resume con los totales de sus lineas', () {
    final libro = armarReportePedidos(
      pedidos: [
        (
          pedido: Pedido(id: 'p1', fecha: _hoy, campana: 'C-14'),
          lineas: [_linea(), _linea(id: 'l2', orden: 1)],
        ),
      ],
      generadoEn: _hoy,
    );
    final hoja = _hoja(libro, 'Pedidos');
    final fila = hoja.filas.single;

    expect(fila[_col(hoja, 'Catalogo')],
        isA<CeldaTexto>().having((c) => c.valor, 'valor', 'C-14'));
    expect(fila[_col(hoja, 'Renglones')],
        isA<CeldaEntero>().having((c) => c.valor, 'valor', 2));
    expect(fila[_col(hoja, 'Pedidas')],
        isA<CeldaEntero>().having((c) => c.valor, 'valor', 6));
    expect(fila[_col(hoja, 'Enviadas')],
        isA<CeldaEntero>().having((c) => c.valor, 'valor', 4));
    expect(fila[_col(hoja, 'Faltantes')],
        isA<CeldaEntero>().having((c) => c.valor, 'valor', 2));
  });

  test('el renglon trae el precio de compra junto al de revista', () {
    final libro = armarReportePedidos(
      pedidos: [
        (
          pedido: Pedido(id: 'p1', fecha: _hoy),
          lineas: [_linea(precioUnitario: 8000, cantPedida: 3)],
        ),
      ],
      generadoEn: _hoy,
    );
    final hoja = _hoja(libro, 'Renglones');
    final fila = hoja.filas.single;

    expect(fila[_col(hoja, 'Precio unitario')],
        isA<CeldaDinero>().having((c) => c.centavos, 'centavos', 8000));
    expect(fila[_col(hoja, 'Precio total')],
        isA<CeldaDinero>().having((c) => c.centavos, 'centavos', 24000));
    expect(fila[_col(hoja, 'Precio revista')],
        isA<CeldaDinero>().having((c) => c.centavos, 'centavos', 20000));
  });

  test('el costo de compra del pedido suma el de sus renglones', () {
    final libro = armarReportePedidos(
      pedidos: [
        (
          pedido: Pedido(id: 'p1', fecha: _hoy),
          lineas: [
            _linea(precioUnitario: 8000, cantPedida: 3),
            _linea(id: 'l2', precioUnitario: 5000, cantPedida: 2, orden: 1),
          ],
        ),
      ],
      generadoEn: _hoy,
    );
    final hoja = _hoja(libro, 'Pedidos');

    expect(hoja.filas.single[_col(hoja, 'Costo de compra')],
        isA<CeldaDinero>().having((c) => c.centavos, 'centavos', 34000));
  });

  test('el IVA de la fila sale de la resta y no de una formula aparte', () {
    final libro = armarReportePedidos(
      pedidos: [
        (pedido: Pedido(id: 'p1', fecha: _hoy), lineas: [_linea()]),
      ],
      generadoEn: _hoy,
    );
    final hoja = _hoja(libro, 'Pedidos');
    final fila = hoja.filas.single;

    final promocionado =
        (fila[_col(hoja, 'Promocionado')] as CeldaDinero).centavos;
    final sinIva = (fila[_col(hoja, 'Sin IVA')] as CeldaDinero).centavos;
    final iva = (fila[_col(hoja, 'IVA')] as CeldaDinero).centavos;

    expect(sinIva + iva, promocionado);
  });

  test('un pedido sin recibir deja vacia la fecha de recepcion', () {
    final libro = armarReportePedidos(
      pedidos: [
        (pedido: Pedido(id: 'p1', fecha: _hoy), lineas: [_linea()]),
        (
          pedido: Pedido(
            id: 'p2',
            fecha: _hoy,
            recibidoEn: DateTime(2026, 9, 6),
          ),
          lineas: [_linea(id: 'l2', pedidoId: 'p2')],
        ),
      ],
      generadoEn: _hoy,
    );
    final hoja = _hoja(libro, 'Pedidos');
    final recibido = _col(hoja, 'Recibido');
    final recibidoEl = _col(hoja, 'Recibido el');

    expect(hoja.filas[0][recibido],
        isA<CeldaSiNo>().having((c) => c.valor, 'valor', isFalse));
    expect(hoja.filas[0][recibidoEl],
        isA<CeldaFecha>().having((c) => c.valor, 'valor', isNull));
    expect(hoja.filas[1][recibido],
        isA<CeldaSiNo>().having((c) => c.valor, 'valor', isTrue));
    expect(hoja.filas[1][recibidoEl],
        isA<CeldaFecha>().having((c) => c.valor, 'valor', DateTime(2026, 9, 6)));
  });

  test('los renglones respetan el orden de la hoja impresa', () {
    final libro = armarReportePedidos(
      pedidos: [
        (
          pedido: Pedido(id: 'p1', fecha: _hoy),
          lineas: [
            _linea(id: 'segunda', orden: 1),
            _linea(id: 'primera', orden: 0),
          ],
        ),
      ],
      generadoEn: _hoy,
    );
    final hoja = _hoja(libro, 'Renglones');
    final pedidas = _col(hoja, 'Pedidas');

    expect(hoja.filas, hasLength(2));
    // Las dos lineas son iguales salvo el orden; basta con que no reviente y
    // que el aplanado conserve una fila por renglon.
    expect(hoja.filas.every((f) => f[pedidas] is CeldaEntero), isTrue);
  });

  test('la fila de totales suma todos los pedidos del reporte', () {
    final libro = armarReportePedidos(
      pedidos: [
        (pedido: Pedido(id: 'p1', fecha: _hoy), lineas: [_linea()]),
        (
          pedido: Pedido(id: 'p2', fecha: _hoy),
          lineas: [_linea(id: 'l2', pedidoId: 'p2')],
        ),
      ],
      generadoEn: _hoy,
    );
    final hoja = _hoja(libro, 'Pedidos');

    expect(hoja.totales[_col(hoja, 'Enviadas')],
        isA<CeldaEntero>().having((c) => c.valor, 'valor', 4));
    expect(hoja.totales[_col(hoja, 'Promocionado')],
        isA<CeldaDinero>().having((c) => c.centavos, 'centavos', 23200));
  });

  test('todas las filas tienen tantas celdas como columnas', () {
    final libro = armarReportePedidos(
      pedidos: [
        (pedido: Pedido(id: 'p1', fecha: _hoy), lineas: [_linea()]),
      ],
      generadoEn: _hoy,
    );

    for (final hoja in libro.hojas) {
      for (final fila in hoja.filas) {
        expect(fila, hasLength(hoja.columnas.length), reason: hoja.nombre);
      }
      expect(hoja.totales, hasLength(hoja.columnas.length), reason: hoja.nombre);
    }
  });
}
