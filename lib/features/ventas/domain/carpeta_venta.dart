import 'venta_detallada.dart';

/// Un separador del listado de ventas.
///
/// La propietaria vende en varios lugares y la lista corrida deja de servirle
/// en cuanto pasa de unas cuantas ventas: la pregunta que se hace antes de
/// salir a cobrar no es "cuanto me deben" sino "cuanto me deben en Xalisco", y
/// una sola lista no la contesta sin leerla entera.
///
/// Es un solo nivel a proposito. No hay carpetas dentro de carpetas porque el
/// criterio real es el lugar, y un arbol obligaria a decidir en cual de dos
/// ramas va cada venta cada vez que se abre una.
class CarpetaVenta {
  const CarpetaVenta({
    required this.id,
    required this.nombre,
    this.notas = '',
  });

  final String id;
  final String nombre;
  final String notas;

  String get titulo =>
      nombre.trim().isEmpty ? 'Carpeta sin nombre' : nombre.trim();

  CarpetaVenta copyWith({String? nombre, String? notas}) => CarpetaVenta(
        id: id,
        nombre: nombre ?? this.nombre,
        notas: notas ?? this.notas,
      );
}

/// Una carpeta con lo que se ve de ella desde afuera: cuantas ventas guarda y
/// cuanto dinero representa.
///
/// Es lo que pinta la estanteria, la pantalla que la propietaria ve al entrar
/// a Ventas cuando ya separo su trabajo. Trae el resumen completo y no solo un
/// conteo porque la carpeta se abre para cobrar: el dato que decide si vale la
/// pena el viaje es el saldo, no cuantas hojas hay dentro.
class ResumenCarpeta {
  const ResumenCarpeta({required this.carpeta, required this.resumen});

  /// La carpeta, o `null` para el monton de las ventas que nunca se
  /// separaron. "Sin carpeta" se ve como una carpeta mas pero no es una fila
  /// de la tabla: es el resto, y por eso no se puede renombrar ni borrar.
  final CarpetaVenta? carpeta;

  final ResumenVentas resumen;

  String get titulo => carpeta?.titulo ?? 'Sin carpeta';

  bool get esSinCarpeta => carpeta == null;
}
