import 'linea_pedido.dart';

/// Suma de las lineas de un pedido, columna por columna.
///
/// Se calcula a partir de las lineas en vez de guardarse: un total almacenado
/// se desincroniza en cuanto se edita una linea.
class TotalesPedido {
  const TotalesPedido({
    required this.lineas,
    required this.cantPedida,
    required this.cantEnviada,
    required this.valorTotalPuntos,
    required this.precioTotal,
    required this.valorTotalPromocionado,
    required this.valorPromSinIva,
    required this.totalDescuentoCn,
    required this.valorRegalos,
    required this.tuPagas,
  });

  factory TotalesPedido.de(Iterable<LineaPedido> lineas) {
    var conteo = 0;
    var pedida = 0;
    var enviada = 0;
    var puntos = 0;
    var compra = 0;
    var promocionado = 0;
    var sinIva = 0;
    var descuento = 0;
    var regalos = 0;
    var pagas = 0;

    for (final linea in lineas) {
      conteo++;
      pedida += linea.cantPedida;
      enviada += linea.cantEnviada;
      puntos += linea.valorTotalPuntos;
      compra += linea.precioTotal;
      promocionado += linea.valorTotalPromocionado;
      sinIva += linea.valorPromSinIva;
      descuento += linea.totalDescuentoCn;
      regalos += linea.valorRegalos;
      pagas += linea.tuPagas;
    }

    return TotalesPedido(
      lineas: conteo,
      cantPedida: pedida,
      cantEnviada: enviada,
      valorTotalPuntos: puntos,
      precioTotal: compra,
      valorTotalPromocionado: promocionado,
      valorPromSinIva: sinIva,
      totalDescuentoCn: descuento,
      valorRegalos: regalos,
      tuPagas: pagas,
    );
  }

  static const vacio = TotalesPedido(
    lineas: 0,
    cantPedida: 0,
    cantEnviada: 0,
    valorTotalPuntos: 0,
    precioTotal: 0,
    valorTotalPromocionado: 0,
    valorPromSinIva: 0,
    totalDescuentoCn: 0,
    valorRegalos: 0,
    tuPagas: 0,
  );

  final int lineas;
  final int cantPedida;
  final int cantEnviada;
  final int valorTotalPuntos;

  /// Lo que cuesta la hoja completa a precio de compra, en centavos.
  ///
  /// No se suma el precio unitario: un precio por pieza sumado entre renglones
  /// distintos no significa nada.
  final int precioTotal;

  final int valorTotalPromocionado;
  final int valorPromSinIva;
  final int totalDescuentoCn;
  final int valorRegalos;
  final int tuPagas;

  /// IVA contenido en el total promocionado, en centavos.
  int get iva => valorTotalPromocionado - valorPromSinIva;

  /// Piezas pedidas que no llegaron en todo el pedido.
  int get faltantes => cantPedida - cantEnviada;

  bool get tieneFaltantes => faltantes > 0;
}
