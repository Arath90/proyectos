import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// Abre el explorador de archivos de Android para elegir un respaldo.
///
/// Es una envoltura de tres lineas alrededor de `file_picker` y existe para
/// que el ViewModel no dependa de un plugin: sin ella, probar la pantalla
/// exigiria un canal de plataforma vivo.
///
/// **No filtra por extension.** Podria pedir solo `.sqlite`, pero en Android
/// ese filtro se traduce a tipos MIME y un archivo que volvio de WhatsApp o de
/// Drive llega con el tipo que le puso quien lo mando -muchas veces
/// `application/octet-stream`, a veces ninguno-. Un filtro asi esconderia el
/// archivo correcto y dejaria a la propietaria mirando una carpeta vacia sin
/// entender por que. Quien decide si el archivo sirve es
/// `RespaldosRepository.importar`, leyendo su cabecera: eso no se puede
/// falsear con un nombre.
class SelectorDeArchivo {
  const SelectorDeArchivo();

  /// El archivo elegido, o `null` si se cerro el explorador sin elegir.
  Future<File?> elegirRespaldo() async {
    final elegido = await FilePicker.pickFile(
      dialogTitle: 'Elige el archivo de respaldo',
    );
    final ruta = elegido?.path;
    return ruta == null ? null : File(ruta);
  }
}
