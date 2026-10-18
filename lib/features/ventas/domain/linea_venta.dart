/// Un renglon de la venta: que producto, cuantas piezas y a que precio.
///
/// Es el equivalente de `LineaPedido` del otro lado del mostrador, pero mucho
/// mas corta: la hoja de la distribuidora arrastra puntos, descuento de
/// consultora y regalos porque asi viene impresa, mientras que al cliente solo
/// se le cobra cantidad por precio menos lo que se le rebajo.
///
/// Copia `marca`, `codigo` y `descripcion` del `Producto` en vez de leerlos
/// por `productoId` cada vez. Es duplicacion a proposito: la venta es un
/// documento historico y debe seguir diciendo lo que decia el dia que se hizo,
/// aunque despues se corrija el catalogo. El `productoId` se conserva solo
/// para mover existencias.
class LineaVenta {
  const LineaVenta({
    required this.id,
    required this.ventaId,
    required this.marca,
    required this.codigo,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    this.productoId,
    this.descuento = 0,
    this.orden = 0,
  });

  final String id;
  final String ventaId;

  /// Producto del inventario del que salen las piezas.
  ///
  /// `null` cuando se vendio algo que no esta dado de alta; esa linea no mueve
  /// existencias, solo cobra.
  final String? productoId;

  final String marca;
  final String codigo;
  final String descripcion;

  /// Piezas vendidas en este renglon.
  final int cantidad;

  /// Precio unitario cobrado al cliente, en centavos.
  final int precioUnitario;

  /// Rebaja sobre el renglon completo, en centavos.
  final int descuento;

  /// Posicion dentro de la venta, para conservar el orden de captura.
  final int orden;

  /// Lo que suman las piezas antes de rebajar, en centavos.
  int get subtotal => cantidad * precioUnitario;

  /// Lo que se cobra por este renglon, en centavos.
  ///
  /// Nunca baja de cero: un descuento capturado de mas seria un renglon que le
  /// regresa dinero al cliente, y eso siempre es un error de captura.
  int get importe {
    final resultado = subtotal - descuento;
    return resultado < 0 ? 0 : resultado;
  }

  /// Cierto si el renglon debe descontar piezas al entregar la venta.
  bool get mueveInventario => productoId != null && cantidad > 0;

  LineaVenta copyWith({
    String? marca,
    String? codigo,
    String? descripcion,
    int? cantidad,
    int? precioUnitario,
    int? descuento,
    int? orden,
    ({String? valor})? productoId,
  }) {
    return LineaVenta(
      id: id,
      ventaId: ventaId,
      productoId: productoId == null ? this.productoId : productoId.valor,
      marca: marca ?? this.marca,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      descuento: descuento ?? this.descuento,
      orden: orden ?? this.orden,
    );
  }
}
