import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/reportes/domain/hoja_calculo.dart';
import 'package:punto_venta_madre/features/reportes/domain/reporte_ventas.dart';
import 'package:punto_venta_madre/features/ventas/domain/abono.dart';
import 'package:punto_venta_madre/features/ventas/domain/linea_venta.dart';
import 'package:punto_venta_madre/features/ventas/domain/venta.dart';
import 'package:punto_venta_madre/features/ventas/domain/venta_detallada.dart';

final _hoy = DateTime(2026, 9, 4);

VentaDetallada _venta({
  String id = 'v1',
  String cliente = 'Ana',
  EstadoVenta estado = EstadoVenta.entregada,
  List<LineaVenta> lineas = const [],
  List<Abono> abonos = const [],
}) {
  return VentaDetallada(
    venta: Venta(id: id, fecha: _hoy, cliente: cliente, estado: estado),
    lineas: lineas,
    abonos: abonos,
  );
}

LineaVenta _linea({
  String id = 'l1',
  String ventaId = 'v1',
  String? productoId = 'p1',
  int cantidad = 2,
  int precioUnitario = 15000,
  int descuento = 0,
  int orden = 0,
}) {
  return LineaVenta(
    id: id,
    ventaId: ventaId,
    productoId: productoId,
    marca: 'Marca',
    codigo: '00123',
    descripcion: 'Crema',
    cantidad: cantidad,
    precioUnitario: precioUnitario,
    descuento: descuento,
    orden: orden,
  );
}

/// Indice de una columna por su titulo, para que las pruebas no se rompan al
/// insertar una columna nueva en medio.
int _col(Hoja hoja, String titulo) {
  final indice = hoja.columnas.indexWhere((c) => c.titulo == titulo);
  expect(indice, isNot(-1), reason: 'no existe la columna $titulo');
  return indice;
}

Hoja _hoja(LibroReporte libro, String nombre) =>
    libro.hojas.firstWhere((h) => h.nombre == nombre);

void main() {
  test('el reporte trae las tres hojas del negocio', () {
    final libro = armarReporteVentas(ventas: const [], generadoEn: _hoy);

    expect(
      libro.hojas.map((h) => h.nombre),
      ['Ventas', 'Renglones', 'Abonos'],
    );
    expect(libro.vacio, isTrue);
  });

  test('el nombre del archivo lleva la fecha en orden ordenable', () {
    final libro = armarReporteVentas(ventas: const [], generadoEn: _hoy);

    expect(libro.nombreArchivo, 'ventas-2026-09-04.xlsx');
  });

  test('cada venta es una fila con su total y su saldo', () {
    final libro = armarReporteVentas(
      ventas: [
        _venta(
          lineas: [_linea()],
          abonos: [Abono(id: 'a1', ventaId: 'v1', fecha: _hoy, monto: 10000)],
        ),
      ],
      generadoEn: _hoy,
    );
    final hoja = _hoja(libro, 'Ventas');

    expect(hoja.filas, hasLength(1));
    final fila = hoja.filas.single;
    expect(fila[_col(hoja, 'Cliente')], isA<CeldaTexto>().having((c) => c.valor, 'valor', 'Ana'));
    expect(fila[_col(hoja, 'Piezas')], isA<CeldaEntero>().having((c) => c.valor, 'valor', 2));
    // 2 x $150.00 = $300.00, abonado $100.00, saldo $200.00.
    expect(fila[_col(hoja, 'Total')], isA<CeldaDinero>().having((c) => c.centavos, 'centavos', 30000));
    expect(fila[_col(hoja, 'Abonado')], isA<CeldaDinero>().having((c) => c.centavos, 'centavos', 10000));
    expect(fila[_col(hoja, 'Saldo')], isA<CeldaDinero>().having((c) => c.centavos, 'centavos', 20000));
  });

  test('una venta cancelada no suma en la fila de totales', () {
    final libro = armarReporteVentas(
      ventas: [
        _venta(lineas: [_linea()]),
        _venta(
          id: 'v2',
          cliente: 'Beto',
          estado: EstadoVenta.cancelada,
          lineas: [_linea(id: 'l2', ventaId: 'v2')],
        ),
      ],
      generadoEn: _hoy,
    );
    final hoja = _hoja(libro, 'Ventas');

    expect(hoja.filas, hasLength(2), reason: 'la cancelada sigue apareciendo');
    final totales = hoja.totales;
    // Solo cuenta la venta viva, aunque la cancelada tenga los mismos renglones.
    expect(totales[_col(hoja, 'Total')], isA<CeldaDinero>().having((c) => c.centavos, 'centavos', 30000));
    expect(totales[_col(hoja, 'Piezas')], isA<CeldaEntero>().having((c) => c.valor, 'valor', 2));
  });

  test('el subtotal de los totales no se contradice con el total', () {
    final libro = armarReporteVentas(
      ventas: [
        _venta(lineas: [_linea(descuento: 5000)]),
        _venta(
          id: 'v2',
          estado: EstadoVenta.cancelada,
          lineas: [_linea(id: 'l2', ventaId: 'v2')],
        ),
      ],
      generadoEn: _hoy,
    );
    final hoja = _hoja(libro, 'Ventas');
    final totales = hoja.totales;

    final subtotal = (totales[_col(hoja, 'Subtotal')] as CeldaDinero).centavos;
    final descuento = (totales[_col(hoja, 'Descuento')] as CeldaDinero).centavos;
    final total = (totales[_col(hoja, 'Total')] as CeldaDinero).centavos;

    expect(subtotal - descuento, total);
  });

  test('los renglones marcan cuales mueven inventario', () {
    final libro = armarReporteVentas(
      ventas: [
        _venta(
          lineas: [
            _linea(),
            _linea(id: 'l2', productoId: null, orden: 1),
          ],
        ),
      ],
      generadoEn: _hoy,
    );
    final hoja = _hoja(libro, 'Renglones');
    final columna = _col(hoja, 'Del inventario');

    expect(hoja.filas, hasLength(2));
    expect(hoja.filas[0][columna], isA<CeldaSiNo>().having((c) => c.valor, 'valor', isTrue));
    expect(hoja.filas[1][columna], isA<CeldaSiNo>().having((c) => c.valor, 'valor', isFalse));
  });

  test('los abonos salen ordenados por fecha aunque sean de clientes distintos', () {
    final libro = armarReporteVentas(
      ventas: [
        _venta(
          cliente: 'Ana',
          abonos: [
            Abono(
              id: 'a1',
              ventaId: 'v1',
              fecha: DateTime(2026, 9, 10),
              monto: 10000,
            ),
          ],
        ),
        _venta(
          id: 'v2',
          cliente: 'Beto',
          abonos: [
            Abono(
              id: 'a2',
              ventaId: 'v2',
              fecha: DateTime(2026, 9, 2),
              monto: 5000,
            ),
          ],
        ),
      ],
      generadoEn: _hoy,
    );
    final hoja = _hoja(libro, 'Abonos');
    final cliente = _col(hoja, 'Cliente');

    expect(
      hoja.filas.map((f) => (f[cliente] as CeldaTexto).valor),
      ['Beto', 'Ana'],
    );
    expect(
      hoja.totales[_col(hoja, 'Monto')],
      isA<CeldaDinero>().having((c) => c.centavos, 'centavos', 15000),
    );
  });

  test('todas las filas tienen tantas celdas como columnas', () {
    final libro = armarReporteVentas(
      ventas: [
        _venta(
          lineas: [_linea()],
          abonos: [Abono(id: 'a1', ventaId: 'v1', fecha: _hoy, monto: 100)],
        ),
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
