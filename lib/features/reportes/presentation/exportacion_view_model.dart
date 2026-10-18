import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/formato.dart';
import '../../adeudos/presentation/adeudos_view_model.dart';
import '../../pedidos/presentation/pedidos_view_model.dart';
import '../../ventas/presentation/ventas_view_model.dart';
import '../domain/hoja_calculo.dart';
import '../domain/reporte_adeudos.dart';
import '../domain/reporte_pedidos.dart';
import '../domain/reporte_ventas.dart';

/// Que reporte se esta pidiendo.
enum Reporte {
  pedidos,
  ventas,
  adeudos;

  String get etiqueta => switch (this) {
        Reporte.pedidos => 'pedidos',
        Reporte.ventas => 'ventas',
        Reporte.adeudos => 'adeudos',
      };
}

/// Saca el reporte de lo que la propietaria tiene en pantalla y lo comparte.
///
/// Exporta lo *visible*, no todo el historico: si filtro "me deben" y busco a
/// una clienta, el archivo trae eso. Es la unica interpretacion que no
/// sorprende -el boton esta arriba de una lista y saca esa lista- y de paso es
/// lo que convierte los filtros que ya existen en un generador de reportes sin
/// escribir una sola pantalla nueva.
///
/// El estado es un booleano: si hay una exportacion en curso. Armar el archivo
/// tarda lo suyo y sin eso el boton se puede tocar tres veces y abrir tres
/// menus de compartir.
class ExportacionViewModel extends Notifier<bool> {
  @override
  bool build() => false;

  /// Devuelve `null` si todo salio bien, o el mensaje a mostrar si no.
  Future<String?> exportar(Reporte reporte) async {
    if (state) return null;
    state = true;
    try {
      final libro = switch (reporte) {
        Reporte.pedidos => _libroDePedidos(),
        Reporte.ventas => _libroDeVentas(),
        Reporte.adeudos => _libroDeAdeudos(),
      };
      if (libro == null) {
        return 'Todavia no hay ${reporte.etiqueta} que exportar.';
      }
      if (libro.vacio) {
        return 'No hay ${reporte.etiqueta} en lo que estas viendo. Quita el '
            'filtro o la busqueda y vuelve a intentar.';
      }

      await ref.read(compartidorReportesProvider).compartir(
            libro,
            mensaje: _mensaje(libro),
          );
      return null;
    } catch (e) {
      // El menu de compartir y el sistema de archivos fallan por razones que a
      // la propietaria no le dicen nada. Se traduce a algo accionable y el
      // detalle se deja fuera.
      return 'No se pudo generar el archivo de ${reporte.etiqueta}.';
    } finally {
      state = false;
    }
  }

  LibroReporte? _libroDePedidos() {
    final visibles = ref.read(pedidosViewModelProvider).visibles.value;
    if (visibles == null) return null;
    return armarReportePedidos(
      pedidos: [
        for (final detalle in visibles)
          (pedido: detalle.pedido, lineas: detalle.lineas),
      ],
      generadoEn: DateTime.now(),
    );
  }

  LibroReporte? _libroDeVentas() {
    final estado = ref.read(ventasViewModelProvider);
    final visibles = estado.visibles.value;
    if (visibles == null) return null;
    return armarReporteVentas(
      ventas: visibles,
      generadoEn: DateTime.now(),
      // Los nombres de las carpetas se pasan resueltos porque una venta solo
      // guarda el id de la suya, y un archivo con ids adentro no se puede leer.
      carpetas: {for (final c in estado.carpetas) c.id: c.titulo},
    );
  }

  LibroReporte? _libroDeAdeudos() {
    final visibles = ref.read(adeudosViewModelProvider).visibles.value;
    if (visibles == null) return null;
    return armarReporteAdeudos(
      cuentas: visibles,
      generadoEn: DateTime.now(),
    );
  }

  /// El texto que acompana al archivo en la conversacion de WhatsApp.
  ///
  /// Dice de que es y de cuando, porque del otro lado se ve un adjunto con
  /// nombre de archivo y poco mas; sin esta linea, dos reportes seguidos son
  /// indistinguibles en el chat.
  String _mensaje(LibroReporte libro) {
    final cuantos = libro.hojas.first.filas.length;
    return '${libro.nombre} al ${Formato.fecha(libro.generadoEn)} '
        '($cuantos ${cuantos == 1 ? 'registro' : 'registros'})';
  }
}

final exportacionViewModelProvider =
    NotifierProvider<ExportacionViewModel, bool>(ExportacionViewModel.new);
