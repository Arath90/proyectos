import 'producto.dart';

/// Un producto visto junto con lo que las ventas ya comprometieron.
///
/// El producto por si solo no puede contestar "cuantas puedo vender": sus
/// `cantidadActual` piezas siguen en casa aunque haya ventas apartadas que ya
/// las tienen prometidas. El apartado no se guarda en la fila del producto
/// porque es una consecuencia de las ventas abiertas, y un dato derivado que
/// se almacena se desincroniza; se recalcula al vuelo y se une aqui, en el
/// borde entre los dos features.
///
/// Lo arma el `InventarioViewModel` cruzando el catalogo con el mapa de
/// apartados que publica `VentasRepository`.
class Existencia {
  const Existencia({required this.producto, this.apartadas = 0});

  final Producto producto;

  /// Piezas comprometidas en ventas con estado `apartada` y sin entregar.
  final int apartadas;

  /// Piezas que se pueden prometer a un cliente nuevo.
  ///
  /// Puede quedar en negativo si se aparto de mas o si un ajuste manual bajo
  /// la existencia por debajo de lo comprometido; se deja ver el negativo en
  /// vez de recortarlo a cero, porque es justo el problema que la propietaria
  /// necesita notar.
  int get disponibles => producto.cantidadActual - apartadas;

  bool get sobrevendido => disponibles < 0;

  bool get hayApartado => apartadas > 0;
}
