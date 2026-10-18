import 'package:share_plus/share_plus.dart';

import '../domain/respaldo.dart';

/// Saca una copia de la base **fuera** de la tablet.
///
/// Es la mitad que de verdad protege el negocio. Una copia guardada junto al
/// original solo salva de una migracion que salga mal; no salva de lo mas
/// probable, que es que la tablet se caiga, se moje, se pierda o se resetee.
/// Para eso el archivo tiene que irse a otro lado, y el unico camino que
/// existe en Android es el menu de compartir: de ahi la propietaria lo manda a
/// su WhatsApp, a su Drive o a su correo, que es donde ya guarda lo que no
/// quiere perder.
///
/// El tipo se declara como binario generico a proposito. No hay un MIME
/// estandar para SQLite que WhatsApp reconozca, y anunciarlo como algo que no
/// es haria que la aplicacion de destino intente abrirlo. Como binario, lo
/// unico que puede hacer es guardarlo, que es justo lo que se quiere.
class CompartidorRespaldo {
  const CompartidorRespaldo();

  Future<void> compartir(Respaldo respaldo) {
    return SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(respaldo.archivo.path, mimeType: 'application/octet-stream'),
        ],
        text: 'Respaldo de mi punto de venta. Guardalo: con este archivo se '
            'recuperan las ventas, los clientes y las deudas.',
        subject: 'Respaldo del punto de venta',
        title: 'Guardar el respaldo',
      ),
    );
  }
}
