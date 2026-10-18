import '../../inventario/domain/producto.dart';
import 'linea_venta.dart';

/// Los datos de un renglon de venta antes de existir en la base: aun no tiene
/// id ni posicion.
///
/// Es lo que produce el formulario y lo que consume `VentasRepository`, igual
/// que `LineaBorrador` en el pedido y `ProductoBorrador` en el inventario. El
/// patron se repite en los tres features para que ninguna pantalla tenga que
/// inventar identificadores ni saber en que orden va lo que captura.
class LineaVentaBorrador {
  const LineaVentaBorrador({
    this.productoId,
    this.marca = '',
    this.codigo = '',
    this.descripcion = '',
    this.cantidad = 1,
    this.precioUnitario = 0,
    this.descuento = 0,
  });

  /// Arranca el renglon desde un articulo del inventario.
  ///
  /// Es el camino normal de una venta: la propietaria elige del catalogo y
  /// solo teclea cuantas piezas y a cuanto. La descripcion queda copiada en
  /// ese momento, que es lo que convierte la venta en un documento historico.
  factory LineaVentaBorrador.deProducto(
    Producto producto, {
    int cantidad = 1,
    int precioUnitario = 0,
  }) {
    return LineaVentaBorrador(
      productoId: producto.id,
      marca: producto.marca,
      codigo: producto.codigo,
      descripcion: producto.descripcion,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
    );
  }

  /// Precarga el formulario con lo que ya tiene un renglon guardado.
  factory LineaVentaBorrador.deLinea(LineaVenta linea) => LineaVentaBorrador(
        productoId: linea.productoId,
        marca: linea.marca,
        codigo: linea.codigo,
        descripcion: linea.descripcion,
        cantidad: linea.cantidad,
        precioUnitario: linea.precioUnitario,
        descuento: linea.descuento,
      );

  final String? productoId;
  final String marca;
  final String codigo;
  final String descripcion;
  final int cantidad;
  final int precioUnitario;
  final int descuento;

  LineaVenta aLinea({
    required String id,
    required String ventaId,
    required int orden,
  }) =>
      LineaVenta(
        id: id,
        ventaId: ventaId,
        productoId: productoId,
        marca: marca.trim(),
        codigo: codigo.trim(),
        descripcion: descripcion.trim(),
        cantidad: cantidad,
        precioUnitario: precioUnitario,
        descuento: descuento,
        orden: orden,
      );

  LineaVentaBorrador copyWith({
    String? marca,
    String? codigo,
    String? descripcion,
    int? cantidad,
    int? precioUnitario,
    int? descuento,
    ({String? valor})? productoId,
  }) {
    return LineaVentaBorrador(
      productoId: productoId == null ? this.productoId : productoId.valor,
      marca: marca ?? this.marca,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      descuento: descuento ?? this.descuento,
    );
  }
}
