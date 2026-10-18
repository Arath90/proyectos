import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../domain/hoja_calculo.dart';

/// Convierte un [LibroReporte] en los bytes de un archivo `.xlsx`.
///
/// No toca el disco ni sabe donde va a terminar el archivo: recibe la
/// descripcion del reporte y devuelve bytes. Eso lo hace probable sin
/// dispositivo y deja el manejo de archivos y del menu de compartir en
/// [CompartidorReportes], que si depende del sistema.
///
/// Cada celda numerica sale con su formato de Excel -moneda, entero, fecha- y
/// no como texto ya formateado. Es la diferencia entre un archivo que la
/// propietaria puede sumar, ordenar y filtrar, y una imagen de una tabla.
Uint8List convertirAExcel(LibroReporte libro) {
  final excel = Excel.createExcel();

  // `createExcel` deja una hoja de ejemplo. Se anotan las nuestras primero y
  // se borra al final, porque `delete` se niega a quitar la ultima hoja que
  // queda y borrarla antes de tiempo no haria nada.
  final hojaDeEjemplo = excel.getDefaultSheet();

  for (final hoja in libro.hojas) {
    _escribirHoja(excel[hoja.nombre], hoja);
  }

  if (libro.hojas.isNotEmpty) {
    excel.setDefaultSheet(libro.hojas.first.nombre);
    if (hojaDeEjemplo != null) excel.delete(hojaDeEjemplo);
  }

  final bytes = excel.encode();
  if (bytes == null) {
    throw StateError('Excel no pudo generar el archivo del reporte.');
  }
  return Uint8List.fromList(bytes);
}

void _escribirHoja(Sheet destino, Hoja hoja) {
  for (var c = 0; c < hoja.columnas.length; c++) {
    final columna = hoja.columnas[c];
    destino.setColumnWidth(c, columna.ancho);
    _escribirCelda(
      destino,
      fila: 0,
      columna: c,
      valor: TextCellValue(columna.titulo),
      estilo: _encabezado,
    );
  }

  for (var f = 0; f < hoja.filas.length; f++) {
    final fila = hoja.filas[f];
    for (var c = 0; c < fila.length; c++) {
      _escribirCelda(
        destino,
        // La fila 0 es el encabezado, asi que los datos empiezan en la 1.
        fila: f + 1,
        columna: c,
        valor: _valorDe(fila[c]),
        estilo: _estiloDe(fila[c], totales: false),
      );
    }
  }

  if (hoja.totales.isEmpty) return;
  final filaTotales = hoja.filas.length + 1;
  for (var c = 0; c < hoja.totales.length; c++) {
    _escribirCelda(
      destino,
      fila: filaTotales,
      columna: c,
      valor: _valorDe(hoja.totales[c]),
      estilo: _estiloDe(hoja.totales[c], totales: true),
    );
  }
}

void _escribirCelda(
  Sheet destino, {
  required int fila,
  required int columna,
  required CellValue? valor,
  required CellStyle estilo,
}) {
  destino.updateCell(
    CellIndex.indexByColumnRow(columnIndex: columna, rowIndex: fila),
    valor,
    cellStyle: estilo,
  );
}

/// Traduce una celda del reporte al tipo que entiende Excel.
///
/// El dinero pasa de centavos a un numero con dos decimales: es el unico punto
/// del sistema donde un importe se convierte a `double`, y es inevitable
/// porque un `.xlsx` guarda sus numeros asi. La conversion es una sola
/// division al final, sobre un total ya sumado en enteros, de modo que ningun
/// redondeo se acumula.
CellValue? _valorDe(Celda celda) {
  return switch (celda) {
    CeldaTexto(:final valor) => valor.trim().isEmpty ? null : TextCellValue(valor),
    CeldaEntero(:final valor) => IntCellValue(valor),
    CeldaDinero(:final centavos) => DoubleCellValue(centavos / 100),
    CeldaPuntos(:final centesimas) => DoubleCellValue(centesimas / 100),
    CeldaFecha(:final valor) =>
      valor == null ? null : DateCellValue.fromDateTime(valor),
    CeldaSiNo(:final valor) => TextCellValue(valor ? 'Si' : 'No'),
  };
}

CellStyle _estiloDe(Celda celda, {required bool totales}) {
  final base = switch (celda) {
    CeldaTexto() || CeldaSiNo() => _texto,
    CeldaEntero() => _entero,
    CeldaDinero() => _moneda,
    CeldaPuntos() => _decimal,
    CeldaFecha() => _fecha,
  };
  if (!totales) return base;
  return base.copyWith(
    boldVal: true,
    topBorderVal: Border(borderStyle: BorderStyle.Thin),
  );
}

// Los estilos se declaran una sola vez y se reusan: Excel guarda una tabla de
// estilos y repetir el mismo objeto evita que el archivo cargue una entrada
// distinta por celda.

final _encabezado = CellStyle(
  bold: true,
  backgroundColorHex: ExcelColor.grey300,
  horizontalAlign: HorizontalAlign.Left,
  bottomBorder: Border(borderStyle: BorderStyle.Thin),
);

final _texto = CellStyle(horizontalAlign: HorizontalAlign.Left);

final _entero = CellStyle(
  horizontalAlign: HorizontalAlign.Right,
  numberFormat: NumFormat.standard_3,
);

/// Pesos con separador de miles: `$1,234.56`.
final _moneda = CellStyle(
  horizontalAlign: HorizontalAlign.Right,
  numberFormat: NumFormat.custom(formatCode: r'"$"#,##0.00'),
);

/// Puntos de catalogo: dos decimales, sin simbolo.
final _decimal = CellStyle(
  horizontalAlign: HorizontalAlign.Right,
  numberFormat: NumFormat.standard_4,
);

/// Fecha como la lee la propietaria, no como la escribe Estados Unidos.
final _fecha = CellStyle(
  horizontalAlign: HorizontalAlign.Left,
  numberFormat: NumFormat.custom(formatCode: 'dd/mm/yyyy'),
);
