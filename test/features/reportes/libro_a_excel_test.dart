import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/reportes/data/libro_a_excel.dart';
import 'package:punto_venta_madre/features/reportes/domain/hoja_calculo.dart';

/// Vuelve a abrir el archivo generado, que es la unica forma de comprobar que
/// Excel entendera lo que se escribio.
///
/// El paquete `excel` revienta al guardar si una celda numerica no trae un
/// formato numerico -y una fecha, uno de fecha-, y ese error solo aparece al
/// codificar. Estas pruebas existen para que aparezca aqui y no en la tablet,
/// con la propietaria esperando el archivo.
Excel _abrir(LibroReporte libro) => Excel.decodeBytes(convertirAExcel(libro));

LibroReporte _libro({List<Hoja>? hojas}) {
  return LibroReporte(
    nombre: 'Prueba',
    generadoEn: DateTime(2026, 9, 4),
    hojas: hojas ??
        [
          Hoja(
            nombre: 'Datos',
            columnas: const [
              Columna('Fecha'),
              Columna('Cliente'),
              Columna('Piezas'),
              Columna('Total'),
              Columna('Puntos'),
              Columna('Entregada'),
            ],
            filas: [
              [
                Celda.fecha(DateTime(2026, 9, 4)),
                const Celda.texto('Ana'),
                const Celda.entero(3),
                const Celda.dinero(123456),
                const Celda.puntos(250),
                const Celda.siNo(true),
              ],
              [
                const Celda.fecha(null),
                const Celda.texto('Beto'),
                const Celda.entero(0),
                const Celda.dinero(0),
                const Celda.puntos(0),
                const Celda.siNo(false),
              ],
            ],
            totales: const [
              Celda.texto('TOTAL'),
              Celda.vacia,
              Celda.entero(3),
              Celda.dinero(123456),
              Celda.puntos(250),
              Celda.vacia,
            ],
          ),
        ],
  );
}

void main() {
  test('genera un archivo que se puede volver a abrir', () {
    final excel = _abrir(_libro());

    expect(excel.tables.keys, contains('Datos'));
  });

  test('deja solo las hojas del reporte, sin la de ejemplo', () {
    final libro = _libro(
      hojas: [
        Hoja(
          nombre: 'Uno',
          columnas: const [Columna('A')],
          filas: const [
            [Celda.texto('x')],
          ],
        ),
        Hoja(
          nombre: 'Dos',
          columnas: const [Columna('A')],
          filas: const [
            [Celda.texto('y')],
          ],
        ),
      ],
    );

    final excel = _abrir(libro);

    expect(excel.tables.keys, ['Uno', 'Dos']);
    expect(excel.getDefaultSheet(), 'Uno');
  });

  test('el encabezado va en la primera fila', () {
    final hoja = _abrir(_libro()).tables['Datos']!;

    expect(
      hoja.row(0).map((celda) => celda?.value.toString()),
      ['Fecha', 'Cliente', 'Piezas', 'Total', 'Puntos', 'Entregada'],
    );
  });

  test('el dinero viaja como numero y no como texto', () {
    final hoja = _abrir(_libro()).tables['Datos']!;
    final celda = hoja.row(1)[3]!;

    // $1,234.56 guardados como 123456 centavos.
    expect(celda.value, isA<DoubleCellValue>());
    expect((celda.value as DoubleCellValue).value, closeTo(1234.56, 0.001));
  });

  test('el dinero lleva formato de moneda para que Excel lo muestre bien', () {
    final hoja = _abrir(_libro()).tables['Datos']!;
    final celda = hoja.row(1)[3]!;

    expect(celda.cellStyle?.numberFormat.formatCode, contains(r'$'));
  });

  test('las piezas viajan como entero', () {
    final hoja = _abrir(_libro()).tables['Datos']!;

    expect(hoja.row(1)[2]!.value, const IntCellValue(3));
  });

  test('una fecha se guarda como fecha y no como texto', () {
    final hoja = _abrir(_libro()).tables['Datos']!;
    final celda = hoja.row(1)[0]!;

    expect(celda.value, isA<DateCellValue>());
    expect(
      (celda.value as DateCellValue).asDateTimeLocal(),
      DateTime(2026, 9, 4),
    );
  });

  test('una fecha ausente queda como celda vacia', () {
    final hoja = _abrir(_libro()).tables['Datos']!;

    expect(hoja.row(2)[0]?.value, isNull);
  });

  test('la fila de totales va despues de los datos', () {
    final hoja = _abrir(_libro()).tables['Datos']!;

    // Encabezado + dos filas + totales.
    expect(hoja.row(3)[0]!.value.toString(), 'TOTAL');
    expect((hoja.row(3)[3]!.value as DoubleCellValue).value,
        closeTo(1234.56, 0.001));
  });

  test('una hoja sin filas sigue trayendo su encabezado', () {
    final libro = _libro(
      hojas: [
        const Hoja(
          nombre: 'Vacia',
          columnas: [Columna('Fecha'), Columna('Total')],
          filas: [],
        ),
      ],
    );

    final hoja = _abrir(libro).tables['Vacia']!;

    expect(
      hoja.row(0).map((celda) => celda?.value.toString()),
      ['Fecha', 'Total'],
    );
  });
}
