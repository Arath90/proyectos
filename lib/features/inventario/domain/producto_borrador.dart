import 'producto.dart';

/// Los datos de un producto antes de existir en la base: aun no tiene id.
///
/// Cumple para el inventario el mismo papel que `LineaBorrador` para el
/// pedido: es lo que produce el formulario y lo que consume el repositorio,
/// de modo que la pantalla nunca inventa identificadores.
class ProductoBorrador {
  const ProductoBorrador({
    this.marca = '',
    this.codigo = '',
    this.descripcion = '',
    this.cantidadActual = 0,
    this.cantidadOriginal,
  });

  /// Precarga el formulario con lo que ya tiene un producto guardado.
  factory ProductoBorrador.deProducto(Producto producto) => ProductoBorrador(
        marca: producto.marca,
        codigo: producto.codigo,
        descripcion: producto.descripcion,
        cantidadActual: producto.cantidadActual,
        cantidadOriginal: producto.cantidadOriginal,
      );

  final String marca;
  final String codigo;
  final String descripcion;
  final int cantidadActual;

  /// Existencia original. Si viene `null` al dar de alta, se toma la actual:
  /// al capturar el inventario por primera vez lo que hay *es* lo que entro.
  final int? cantidadOriginal;

  int get cantidadOriginalEfectiva => cantidadOriginal ?? cantidadActual;

  Producto aProducto(String id) => Producto(
        id: id,
        marca: marca.trim(),
        codigo: codigo.trim(),
        descripcion: descripcion.trim(),
        cantidadActual: cantidadActual,
        cantidadOriginal: cantidadOriginalEfectiva,
      );

  ProductoBorrador copyWith({
    String? marca,
    String? codigo,
    String? descripcion,
    int? cantidadActual,
    int? cantidadOriginal,
  }) {
    return ProductoBorrador(
      marca: marca ?? this.marca,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      cantidadActual: cantidadActual ?? this.cantidadActual,
      cantidadOriginal: cantidadOriginal ?? this.cantidadOriginal,
    );
  }
}
