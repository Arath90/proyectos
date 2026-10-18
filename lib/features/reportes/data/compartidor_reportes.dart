import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/hoja_calculo.dart';
import 'libro_a_excel.dart';

/// Escribe el reporte como archivo y lo entrega al menu de compartir.
///
/// Se comparte en vez de guardarse en una carpeta porque el destino real no es
/// la tablet: la propietaria manda la hoja por WhatsApp a quien se la pide -su
/// contadora, la distribuidora, ella misma a su telefono-. El menu de Android
/// es lo unico que puede adjuntar un archivo a una conversacion de WhatsApp;
/// no existe forma de mandarlo directo desde la aplicacion.
///
/// El archivo se escribe en la carpeta temporal a proposito. Android la limpia
/// solo, y una copia vieja de un reporte en el almacenamiento del telefono no
/// sirve de nada: el reporte se vuelve a sacar en un segundo, y el que importa
/// es el que ya viajo por WhatsApp.
class CompartidorReportes {
  const CompartidorReportes();

  /// Lo que Android y WhatsApp necesitan para reconocer el archivo como una
  /// hoja de calculo y no como un binario cualquiera.
  static const _tipoXlsx =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  /// Genera el `.xlsx` de [libro] y abre el menu de compartir con [mensaje]
  /// como texto que acompana al archivo.
  Future<void> compartir(LibroReporte libro, {required String mensaje}) async {
    // Armar el archivo es trabajo de CPU y crece con el numero de renglones.
    // Va en otro isolate para que la pantalla no se congele mientras tanto:
    // una tablet economica se nota.
    final Uint8List bytes = await Isolate.run(() => convertirAExcel(libro));

    final carpeta = await getTemporaryDirectory();
    final archivo = File('${carpeta.path}/${libro.nombreArchivo}');
    await archivo.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(archivo.path, mimeType: _tipoXlsx)],
        text: mensaje,
        subject: mensaje,
        title: 'Enviar ${libro.nombre.toLowerCase()}',
      ),
    );
  }
}
