import 'package:intl/intl.dart';

/// Formatos de fecha que usa toda la aplicacion.
///
/// Vive en `core` y no en un feature porque los tres los usan igual, y estar
/// en un solo lugar es lo que garantiza que la fecha de un pedido y la de una
/// venta se lean identicas en la pantalla.
abstract final class Formato {
  /// `04 sep 2026`. Lo normal en listados y encabezados.
  static String fecha(DateTime valor) =>
      DateFormat('dd MMM yyyy', 'es').format(valor);

  /// `04 sep 2026, 18:30`. Solo donde importa la hora exacta, como el momento
  /// en que se recibio un pedido.
  static String fechaHora(DateTime valor) =>
      DateFormat('dd MMM yyyy, HH:mm', 'es').format(valor);

  /// `04/09/26`, para cuando el espacio es poco, como la lista de abonos.
  static String fechaCorta(DateTime valor) =>
      DateFormat('dd/MM/yy', 'es').format(valor);
}
