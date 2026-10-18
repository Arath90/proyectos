import 'calculo_linea.dart';

/// Una linea capturada de la hoja de pedido.
///
/// Todos los importes estan en centavos y los puntos en centesimas de punto.
/// Los tres campos derivados (`precio total`, `prom sin IVA` y `tu pagas`) se
/// calculan solos, pero admiten un valor manual: si la hoja impresa trae otra
/// cifra, gana el papel y se guarda el ajuste para poder auditarlo despues.
///
/// Ojo con los dos precios, que se parecen y no son lo mismo:
/// [precioUnitario] es lo que la propietaria le paga a la distribuidora por
/// una pieza, y [precioRevista] lo que el catalogo le pide al cliente final.
class LineaPedido {
  const LineaPedido({
    required this.id,
    required this.pedidoId,
    required this.marca,
    required this.codigo,
    required this.descripcion,
    required this.cantPedida,
    required this.cantEnviada,
    required this.valorTotalPuntos,
    required this.precioUnitario,
    required this.precioRevista,
    required this.valorTotalPromocionado,
    required this.totalDescuentoCn,
    required this.valorRegalos,
    this.precioTotalManual,
    this.valorPromSinIvaManual,
    this.tuPagasManual,
    this.productoId,
    this.orden = 0,
  });

  final String id;
  final String pedidoId;

  /// Producto del inventario al que se le sumaran las piezas al recibir.
  ///
  /// Es el hilo que conecta esta hoja con `Producto`. Nullable porque la hoja
  /// se puede capturar antes de dar de alta el articulo: al recibir el pedido
  /// el repositorio lo resuelve por marca y codigo, o da de alta el producto
  /// en ese momento, y escribe aqui el id que encontro.
  final String? productoId;

  final String marca;
  final String codigo;
  final String descripcion;

  final int cantPedida;
  final int cantEnviada;

  /// Valor total en puntos, en centesimas de punto.
  final int valorTotalPuntos;

  /// Precio unitario de compra: lo que se le paga a la distribuidora por una
  /// pieza, en centavos.
  final int precioUnitario;

  /// Precio de revista unitario: lo que el catalogo le pide al cliente final,
  /// en centavos.
  final int precioRevista;

  /// Valor total promocionado con IVA incluido, en centavos.
  final int valorTotalPromocionado;

  /// Total de descuento de consultora, en centavos.
  final int totalDescuentoCn;

  /// Valor de lo recibido como regalo, en centavos.
  final int valorRegalos;

  /// Precio total de compra capturado a mano; `null` deja que se calcule.
  final int? precioTotalManual;

  /// Valor sin IVA capturado a mano; `null` deja que se calcule.
  final int? valorPromSinIvaManual;

  /// Importe a pagar capturado a mano; `null` deja que se calcule.
  final int? tuPagasManual;

  /// Posicion dentro del pedido, para conservar el orden de la hoja.
  final int orden;

  int get precioTotalCalculado => CalculoLinea.precioTotal(
        precioUnitario: precioUnitario,
        cantPedida: cantPedida,
      );

  /// Lo que cuesta la linea completa a precio de compra, en centavos.
  int get precioTotal => precioTotalManual ?? precioTotalCalculado;

  /// Ganancia bruta esperada si se vende todo lo pedido a precio de revista.
  ///
  /// Es la razon de capturar los dos precios en la misma hoja: la diferencia
  /// entre lo que cobra el catalogo y lo que costo la caja.
  int get margenEsperado => precioRevista * cantPedida - precioTotal;

  int get valorPromSinIvaCalculado =>
      CalculoLinea.promSinIva(valorTotalPromocionado);

  /// Valor total promocionado sin IVA, en centavos.
  int get valorPromSinIva => valorPromSinIvaManual ?? valorPromSinIvaCalculado;

  int get tuPagasCalculado => CalculoLinea.tuPagas(
        valorTotalPromocionado: valorTotalPromocionado,
        totalDescuentoCn: totalDescuentoCn,
      );

  /// Lo que se paga por esta linea, en centavos.
  int get tuPagas => tuPagasManual ?? tuPagasCalculado;

  /// IVA contenido en el valor promocionado, en centavos.
  int get iva => valorTotalPromocionado - valorPromSinIva;

  int get faltantes => CalculoLinea.faltantes(
        cantPedida: cantPedida,
        cantEnviada: cantEnviada,
      );

  bool get tieneFaltantes => faltantes > 0;

  /// Cierto si algun derivado fue sobrescrito con un valor distinto al calculado.
  bool get tieneAjusteManual =>
      (precioTotalManual != null && precioTotalManual != precioTotalCalculado) ||
      (valorPromSinIvaManual != null &&
          valorPromSinIvaManual != valorPromSinIvaCalculado) ||
      (tuPagasManual != null && tuPagasManual != tuPagasCalculado);

  LineaPedido copyWith({
    String? marca,
    String? codigo,
    String? descripcion,
    int? cantPedida,
    int? cantEnviada,
    int? valorTotalPuntos,
    int? precioUnitario,
    int? precioRevista,
    int? valorTotalPromocionado,
    int? totalDescuentoCn,
    int? valorRegalos,
    int? orden,
    // Se pasan envueltos porque `null` es un valor con significado propio:
    // vuelve el campo a modo calculado, o desliga la linea del inventario.
    ({int? valor})? precioTotalManual,
    ({int? valor})? valorPromSinIvaManual,
    ({int? valor})? tuPagasManual,
    ({String? valor})? productoId,
  }) {
    return LineaPedido(
      id: id,
      pedidoId: pedidoId,
      marca: marca ?? this.marca,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      cantPedida: cantPedida ?? this.cantPedida,
      cantEnviada: cantEnviada ?? this.cantEnviada,
      valorTotalPuntos: valorTotalPuntos ?? this.valorTotalPuntos,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      precioRevista: precioRevista ?? this.precioRevista,
      valorTotalPromocionado:
          valorTotalPromocionado ?? this.valorTotalPromocionado,
      totalDescuentoCn: totalDescuentoCn ?? this.totalDescuentoCn,
      valorRegalos: valorRegalos ?? this.valorRegalos,
      precioTotalManual: precioTotalManual == null
          ? this.precioTotalManual
          : precioTotalManual.valor,
      valorPromSinIvaManual: valorPromSinIvaManual == null
          ? this.valorPromSinIvaManual
          : valorPromSinIvaManual.valor,
      tuPagasManual:
          tuPagasManual == null ? this.tuPagasManual : tuPagasManual.valor,
      productoId: productoId == null ? this.productoId : productoId.valor,
      orden: orden ?? this.orden,
    );
  }
}
