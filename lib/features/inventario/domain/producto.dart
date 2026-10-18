/// Un articulo del inventario de la propietaria.
///
/// Es la pieza central del modelo: los otros dos flujos existen para moverlo.
/// Un `Pedido` a la distribuidora le *suma* piezas cuando se recibe, y una
/// `Venta` a un cliente se las *resta* cuando se entrega. Por eso el producto
/// no sabe nada de precios ni de clientes: solo cuenta piezas y se deja
/// identificar por marca y codigo.
///
/// La identidad real de un articulo es el par marca + codigo. El `id` es un
/// UUID generado en el dispositivo, igual que en `Pedido`, para que dos
/// tablets que dieron de alta productos sin conexion no colisionen al
/// sincronizar; pero la unicidad que le importa a la usuaria es la del par,
/// y esa la vigila `InventarioRepository`.
class Producto {
  const Producto({
    required this.id,
    required this.marca,
    required this.codigo,
    required this.descripcion,
    required this.cantidadActual,
    required this.cantidadOriginal,
  });

  final String id;
  final String marca;
  final String codigo;
  final String descripcion;

  /// Piezas que hay fisicamente ahora mismo.
  final int cantidadActual;

  /// Piezas que han entrado en total. Nunca baja por una venta, asi que
  /// `cantidadOriginal - cantidadActual` es lo que ha salido.
  final int cantidadOriginal;

  /// Como se nombra el producto en una lista: `0123 - Crema de noche`.
  String get titulo {
    final partes = [
      if (codigo.trim().isNotEmpty) codigo.trim(),
      if (descripcion.trim().isNotEmpty) descripcion.trim(),
    ];
    return partes.isEmpty ? 'Producto sin nombre' : partes.join(' - ');
  }

  /// Piezas que ya salieron: vendidas, regaladas o ajustadas a la baja.
  int get salidas => cantidadOriginal - cantidadActual;

  bool get agotado => cantidadActual <= 0;

  /// Fraccion de la existencia original que queda, entre 0 y 1.
  ///
  /// Devuelve 0 cuando nunca entro nada, para que la barra de la interfaz no
  /// tenga que dividir entre cero.
  double get fraccionRestante {
    if (cantidadOriginal <= 0) return 0;
    final fraccion = cantidadActual / cantidadOriginal;
    return fraccion.clamp(0, 1).toDouble();
  }

  Producto copyWith({
    String? marca,
    String? codigo,
    String? descripcion,
    int? cantidadActual,
    int? cantidadOriginal,
  }) {
    return Producto(
      id: id,
      marca: marca ?? this.marca,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      cantidadActual: cantidadActual ?? this.cantidadActual,
      cantidadOriginal: cantidadOriginal ?? this.cantidadOriginal,
    );
  }
}
