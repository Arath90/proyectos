import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/adeudos/domain/adeudo.dart';
import 'package:punto_venta_madre/features/adeudos/domain/cuenta_cliente.dart';
import 'package:punto_venta_madre/features/clientes/domain/cliente.dart';
import 'package:punto_venta_madre/features/reportes/domain/hoja_calculo.dart';
import 'package:punto_venta_madre/features/reportes/domain/reporte_adeudos.dart';
import 'package:punto_venta_madre/features/ventas/domain/abono.dart';

final _hoy = DateTime(2026, 9, 4);

CuentaCliente _cuenta({
  String id = 'c1',
  String nombre = 'Tony',
  List<Adeudo> adeudos = const [],
  List<Abono> pagos = const [],
  int saldoEnVentas = 0,
  int ventasAbiertas = 0,
}) {
  return CuentaCliente(
    cliente: Cliente(id: id, nombre: nombre),
    adeudos: adeudos,
    pagos: pagos,
    saldoEnVentas: saldoEnVentas,
    ventasAbiertas: ventasAbiertas,
  );
}

Adeudo _cargo({
  String id = 'ad1',
  String clienteId = 'c1',
  int monto = 200000,
  String concepto = 'Lo de diciembre',
  String? deVenta,
}) {
  return Adeudo(
    id: id,
    clienteId: clienteId,
    fecha: _hoy,
    monto: monto,
    concepto: concepto,
    ventaOrigenId: deVenta,
  );
}

Abono _pago({
  String id = 'ab1',
  String clienteId = 'c1',
  int monto = 50000,
  int? aAdeudo,
  String? ventaId,
}) {
  return Abono(
    id: id,
    clienteId: clienteId,
    ventaId: ventaId,
    fecha: _hoy,
    monto: monto,
    montoAdeudo: aAdeudo ?? monto,
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

int _dinero(Celda celda) => (celda as CeldaDinero).centavos;

void main() {
  test('el reporte trae las tres hojas de la cobranza', () {
    final libro = armarReporteAdeudos(cuentas: const [], generadoEn: _hoy);
    expect(
      libro.hojas.map((h) => h.nombre),
      ['Adeudos', 'Cargos', 'Pagos'],
    );
  });

  test('cada cliente sale con sus dos deudas separadas y sumadas', () {
    final libro = armarReporteAdeudos(
      cuentas: [
        _cuenta(
          adeudos: [_cargo()],
          pagos: [_pago(monto: 50000)],
          saldoEnVentas: 100000,
          ventasAbiertas: 1,
        ),
      ],
      generadoEn: _hoy,
    );

    final hoja = _hoja(libro, 'Adeudos');
    final fila = hoja.filas.single;
    expect(_dinero(fila[_col(hoja, 'Deuda anterior')]), 150000);
    expect(_dinero(fila[_col(hoja, 'Saldo en ventas')]), 100000);
    expect(_dinero(fila[_col(hoja, 'Deuda total')]), 250000);
    expect(_dinero(fila[_col(hoja, 'Cargado')]), 200000);
    expect(_dinero(fila[_col(hoja, 'Pagado a la deuda')]), 50000);
  });

  test('los totales de la hoja cuadran con lo que suman las filas', () {
    final libro = armarReporteAdeudos(
      cuentas: [
        _cuenta(adeudos: [_cargo()], saldoEnVentas: 100000),
        _cuenta(id: 'c2', nombre: 'Rosa', saldoEnVentas: 50000),
        _cuenta(id: 'c3', nombre: 'Ana'),
      ],
      generadoEn: _hoy,
    );

    final hoja = _hoja(libro, 'Adeudos');
    expect(hoja.filas, hasLength(3));
    expect(_dinero(hoja.totales[_col(hoja, 'Deuda anterior')]), 200000);
    expect(_dinero(hoja.totales[_col(hoja, 'Saldo en ventas')]), 150000);
    expect(_dinero(hoja.totales[_col(hoja, 'Deuda total')]), 350000);
  });

  /// Un cargo traspasado ya aparece tambien en el reporte de ventas, en la
  /// columna "Pasado a adeudos". Sin esta marca, alguien sumaria los dos
  /// archivos y contaria ese dinero dos veces.
  test('los cargos dicen cuales salieron de una venta', () {
    final libro = armarReporteAdeudos(
      cuentas: [
        _cuenta(
          adeudos: [
            _cargo(),
            _cargo(id: 'ad2', monto: 80000, concepto: '', deVenta: 'v1'),
          ],
        ),
      ],
      generadoEn: _hoy,
    );

    final hoja = _hoja(libro, 'Cargos');
    final columna = _col(hoja, 'De una venta');
    expect(hoja.filas, hasLength(2));
    expect(
      hoja.filas.map((f) => (f[columna] as CeldaSiNo).valor),
      [false, true],
    );
    expect(_dinero(hoja.totales[_col(hoja, 'Monto')]), 280000);
  });

  /// De un pago repartido, esta hoja solo cuenta la mitad que bajo la deuda, y
  /// ensena el pago completo al lado para que no parezca que falta dinero.
  test('los pagos separan lo que fue a la deuda de lo que entrego', () {
    final libro = armarReporteAdeudos(
      cuentas: [
        _cuenta(
          adeudos: [_cargo()],
          pagos: [
            _pago(monto: 50000, aAdeudo: 30000, ventaId: 'v1'),
            _pago(id: 'ab2', monto: 20000),
            // Un pago que no toco la deuda no pertenece a esta hoja.
            _pago(id: 'ab3', monto: 90000, aAdeudo: 0, ventaId: 'v1'),
          ],
        ),
      ],
      generadoEn: _hoy,
    );

    final hoja = _hoja(libro, 'Pagos');
    expect(hoja.filas, hasLength(2));
    expect(_dinero(hoja.filas.first[_col(hoja, 'A la deuda')]), 30000);
    expect(_dinero(hoja.filas.first[_col(hoja, 'Pago completo')]), 50000);
    expect(_dinero(hoja.totales[_col(hoja, 'A la deuda')]), 50000);
  });

  test('sin clientes el libro sale vacio y el boton lo puede avisar', () {
    final libro = armarReporteAdeudos(cuentas: const [], generadoEn: _hoy);
    expect(libro.vacio, isTrue);
  });
}
