import '../../../core/escala_decimal.dart';

/// Reglas de negocio de una linea de pedido.
///
/// No conoce la base de datos ni la interfaz: recibe enteros escalados y
/// devuelve enteros escalados, de modo que se puede probar sin levantar la
/// aplicacion.
abstract final class CalculoLinea {
  /// IVA general vigente en Mexico, expresado por mil para operar con enteros.
  /// La franja fronteriza usa 80 (8%).
  static const int ivaPorMilGeneral = 160;

  /// Quita el IVA a un importe que ya lo trae incluido.
  ///
  /// El precio de revista se exhibe con IVA incluido, asi que la base se
  /// obtiene dividiendo entre 1.16 y no multiplicando por 0.84.
  static int promSinIva(
    int promocionado, {
    int ivaPorMil = ivaPorMilGeneral,
  }) =>
      redondearDivision(promocionado * 1000, 1000 + ivaPorMil);

  /// IVA contenido en un importe que ya lo trae incluido.
  ///
  /// Se calcula como el residuo para que `sinIva + iva` siempre reconstruya
  /// el importe original, sin descuadres de un centavo por redondeo.
  static int ivaIncluido(
    int promocionado, {
    int ivaPorMil = ivaPorMilGeneral,
  }) =>
      promocionado - promSinIva(promocionado, ivaPorMil: ivaPorMil);

  /// Precio de compra de la linea completa.
  ///
  /// Es lo que le cuestan a la propietaria las piezas que pidio, y se
  /// multiplica por la cantidad *pedida* y no por la enviada: la hoja se
  /// captura cuando se hace el pedido, mucho antes de saber que llego. Si la
  /// distribuidora manda de menos, el papel trae la cifra corregida y esa gana
  /// por el campo manual.
  static int precioTotal({
    required int precioUnitario,
    required int cantPedida,
  }) =>
      precioUnitario * cantPedida;

  /// Lo que la consultora paga por la linea.
  static int tuPagas({
    required int valorTotalPromocionado,
    required int totalDescuentoCn,
  }) =>
      valorTotalPromocionado - totalDescuentoCn;

  /// Piezas pedidas que no llegaron. Negativo si enviaron de mas.
  static int faltantes({required int cantPedida, required int cantEnviada}) =>
      cantPedida - cantEnviada;
}
