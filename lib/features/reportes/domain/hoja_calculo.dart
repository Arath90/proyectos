/// La forma de un reporte antes de convertirse en un archivo.
///
/// Describe columnas, filas y totales sin saber nada de Excel. Existe para que
/// el contenido del reporte -que columnas lleva, en que orden, que suma al
/// pie- se pueda escribir y probar en Dart puro, y para que el dia que haya
/// que exportar a otra cosa (un PDF, un CSV, una hoja en la nube) solo se
/// escriba un exportador nuevo y ningun reporte cambie.
///
/// Las celdas van tipadas y no como texto ya formateado. Un importe escrito
/// como `"$1,234.56"` llega a Excel como una cadena: no se puede sumar, ni
/// ordenar, ni graficar. Mandarlo como numero con su formato de moneda es lo
/// que hace que el archivo sirva de verdad, porque la propietaria abre la hoja
/// justamente para sacarle una suma que la aplicacion todavia no le da.
library;

/// Una celda del reporte, con el tipo que el exportador debe respetar.
sealed class Celda {
  const Celda();

  /// Texto libre: un nombre, una descripcion, una etiqueta de estado.
  const factory Celda.texto(String valor) = CeldaTexto;

  /// Un conteo: piezas, renglones, faltantes.
  const factory Celda.entero(int valor) = CeldaEntero;

  /// Un importe guardado en centavos, como viaja por todo el sistema.
  const factory Celda.dinero(int centavos) = CeldaDinero;

  /// Puntos de catalogo guardados en centesimas de punto.
  const factory Celda.puntos(int centesimas) = CeldaPuntos;

  /// Una fecha. `null` se escribe como celda vacia y no como texto vacio: una
  /// venta sin entregar no tiene fecha, y eso no es lo mismo que tenerla en
  /// blanco.
  const factory Celda.fecha(DateTime? valor) = CeldaFecha;

  /// Un si o un no, para columnas como "recibido" o "ajuste manual".
  const factory Celda.siNo(bool valor) = CeldaSiNo;

  /// Hueco: la fila no tiene nada que decir en esa columna.
  static const vacia = CeldaTexto('');
}

class CeldaTexto extends Celda {
  const CeldaTexto(this.valor);

  final String valor;
}

class CeldaEntero extends Celda {
  const CeldaEntero(this.valor);

  final int valor;
}

class CeldaDinero extends Celda {
  const CeldaDinero(this.centavos);

  final int centavos;
}

class CeldaPuntos extends Celda {
  const CeldaPuntos(this.centesimas);

  final int centesimas;
}

class CeldaFecha extends Celda {
  const CeldaFecha(this.valor);

  final DateTime? valor;
}

class CeldaSiNo extends Celda {
  const CeldaSiNo(this.valor);

  final bool valor;
}

/// El encabezado de una columna y que tan ancha se abre.
///
/// El ancho se declara aqui y no se calcula al exportar porque depende del
/// contenido esperado, no del que trajo este archivo en particular: una
/// columna de descripciones debe abrirse ancha aunque hoy todas vengan cortas.
class Columna {
  const Columna(this.titulo, {this.ancho = 14});

  final String titulo;
  final double ancho;

  /// Ancho comodo para nombres largos: descripciones, clientes, notas.
  static const anchoTexto = 34.0;

  /// Ancho de una fecha corta.
  static const anchoFecha = 12.0;

  /// Ancho de un conteo de piezas.
  static const anchoConteo = 10.0;
}

/// Una pestana del archivo.
class Hoja {
  const Hoja({
    required this.nombre,
    required this.columnas,
    required this.filas,
    this.totales = const [],
  });

  /// Como se llama la pestana. Excel corta los nombres de mas de 31
  /// caracteres, asi que se mantienen cortos a proposito.
  final String nombre;

  final List<Columna> columnas;
  final List<List<Celda>> filas;

  /// Fila de cierre, o vacia si la hoja no suma nada.
  ///
  /// Va como una fila mas y no como una formula de Excel para que el archivo
  /// diga lo mismo que la pantalla: los totales del sistema salen de
  /// `TotalesPedido` y `VentaDetallada`, y una formula recalculada por Excel
  /// podria contestar otra cosa el dia que las reglas cambien.
  final List<Celda> totales;

  bool get vacia => filas.isEmpty;
}

/// El archivo completo, con sus pestanas.
class LibroReporte {
  const LibroReporte({
    required this.nombre,
    required this.generadoEn,
    required this.hojas,
  });

  /// Como se llama el reporte: `Pedidos`, `Ventas`.
  final String nombre;

  /// Cuando se saco. Va en el nombre del archivo para que dos exportaciones
  /// del mismo dia no se confundan al llegar por WhatsApp.
  final DateTime generadoEn;

  final List<Hoja> hojas;

  /// Cuantas filas de datos trae el reporte en total.
  int get filas => hojas.fold(0, (suma, hoja) => suma + hoja.filas.length);

  bool get vacio => filas == 0;

  /// `ventas-2026-09-04.xlsx`.
  ///
  /// La fecha va en formato ISO y no en el formato de pantalla porque asi los
  /// archivos se ordenan solos por nombre en la carpeta de descargas de quien
  /// los reciba.
  String get nombreArchivo {
    final y = generadoEn.year.toString().padLeft(4, '0');
    final m = generadoEn.month.toString().padLeft(2, '0');
    final d = generadoEn.day.toString().padLeft(2, '0');
    return '${nombre.toLowerCase()}-$y-$m-$d.xlsx';
  }
}
