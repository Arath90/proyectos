import '../../inventario/domain/producto.dart';
import 'linea_pedido.dart';

/// Los datos de una linea antes de existir en la base: aun no tiene id ni
/// posicion dentro del pedido.
///
/// Es lo que el formulario produce y lo que el repositorio consume, de modo
/// que la pantalla no necesita inventar identificadores ni saber en que orden
/// va la linea.
class LineaBorrador {
  const LineaBorrador({
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
  });

  /// Precarga el formulario con lo que ya tiene una linea guardada.
  factory LineaBorrador.deLinea(LineaPedido linea) => LineaBorrador(
        marca: linea.marca,
        codigo: linea.codigo,
        descripcion: linea.descripcion,
        cantPedida: linea.cantPedida,
        cantEnviada: linea.cantEnviada,
        valorTotalPuntos: linea.valorTotalPuntos,
        precioUnitario: linea.precioUnitario,
        precioRevista: linea.precioRevista,
        valorTotalPromocionado: linea.valorTotalPromocionado,
        totalDescuentoCn: linea.totalDescuentoCn,
        valorRegalos: linea.valorRegalos,
        precioTotalManual: linea.precioTotalManual,
        valorPromSinIvaManual: linea.valorPromSinIvaManual,
        tuPagasManual: linea.tuPagasManual,
        productoId: linea.productoId,
      );

  /// Arranca la linea desde un articulo que ya esta en el inventario, para
  /// resurtir sin volver a teclear marca, codigo y descripcion.
  factory LineaBorrador.deProducto(
    Producto producto, {
    int cantPedida = 1,
  }) =>
      LineaBorrador(
        marca: producto.marca,
        codigo: producto.codigo,
        descripcion: producto.descripcion,
        cantPedida: cantPedida,
        cantEnviada: 0,
        valorTotalPuntos: 0,
        precioUnitario: 0,
        precioRevista: 0,
        valorTotalPromocionado: 0,
        totalDescuentoCn: 0,
        valorRegalos: 0,
        productoId: producto.id,
      );

  final String marca;
  final String codigo;
  final String descripcion;
  final int cantPedida;
  final int cantEnviada;
  final int valorTotalPuntos;

  /// Lo que la propietaria le paga a la distribuidora por una pieza.
  final int precioUnitario;

  /// Lo que el catalogo le pide al cliente final por una pieza.
  final int precioRevista;
  final int valorTotalPromocionado;
  final int totalDescuentoCn;
  final int valorRegalos;
  final int? precioTotalManual;
  final int? valorPromSinIvaManual;
  final int? tuPagasManual;

  /// Producto del inventario al que pertenece la linea, si se eligio del
  /// catalogo en vez de teclearse a mano.
  final String? productoId;

  LineaPedido aLinea({
    required String id,
    required String pedidoId,
    required int orden,
  }) =>
      LineaPedido(
        id: id,
        pedidoId: pedidoId,
        marca: marca,
        codigo: codigo,
        descripcion: descripcion,
        cantPedida: cantPedida,
        cantEnviada: cantEnviada,
        valorTotalPuntos: valorTotalPuntos,
        precioUnitario: precioUnitario,
        precioRevista: precioRevista,
        valorTotalPromocionado: valorTotalPromocionado,
        totalDescuentoCn: totalDescuentoCn,
        valorRegalos: valorRegalos,
        precioTotalManual: precioTotalManual,
        valorPromSinIvaManual: valorPromSinIvaManual,
        tuPagasManual: tuPagasManual,
        productoId: productoId,
        orden: orden,
      );
}
