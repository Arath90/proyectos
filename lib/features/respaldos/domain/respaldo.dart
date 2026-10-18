import 'dart:io';

/// Por que existe una copia de la base.
///
/// El motivo no es decorativo: decide como se lee la copia en la lista y
/// cuales se pueden tirar solas. Las que hizo la aplicacion por su cuenta se
/// van rotando -si no, llenarian la tablet-, y las que hizo la propietaria a
/// mano no se borran nunca sin que ella lo diga: las hizo porque queria
/// guardar ese momento.
enum MotivoRespaldo {
  /// Copia tomada al arrancar, justo antes de que una version nueva de la
  /// aplicacion migre la base. Es la red de seguridad de cada actualizacion.
  antesDeActualizar('auto', 'Antes de actualizar'),

  /// Copia que pidio la propietaria.
  aMano('mano', 'La hiciste tu'),

  /// Copia del estado actual, tomada un instante antes de restaurar otra.
  /// Restaurar tambien es perder algo -lo capturado desde el respaldo-, y sin
  /// esta copia esa perdida no tendria vuelta atras.
  antesDeRestaurar('previo', 'Antes de restaurar');

  const MotivoRespaldo(this.clave, this.etiqueta);

  /// Como se escribe en el nombre del archivo.
  final String clave;

  /// Como se lee en la pantalla.
  final String etiqueta;

  /// Cierto si la aplicacion puede borrarla sola al rotar.
  bool get esAutomatico => this != MotivoRespaldo.aMano;

  static MotivoRespaldo? porClave(String clave) {
    for (final motivo in MotivoRespaldo.values) {
      if (motivo.clave == clave) return motivo;
    }
    return null;
  }
}

/// Una copia de la base guardada en la tablet.
///
/// Es un archivo y cuatro datos que se leen de su nombre. El nombre carga la
/// informacion a proposito -en vez de un indice aparte- porque un indice se
/// puede desincronizar del disco, y aqui lo que importa es que la lista diga
/// exactamente lo que hay: una lista que promete un respaldo que ya no existe
/// es peor que no tener lista.
class Respaldo {
  const Respaldo({
    required this.archivo,
    required this.motivo,
    required this.fecha,
    required this.versionEsquema,
    required this.bytes,
  });

  final File archivo;
  final MotivoRespaldo motivo;
  final DateTime fecha;

  /// La version del esquema que traia la base copiada, o `null` si el archivo
  /// no se pudo leer. Sirve para dos cosas: explicar de que epoca es la copia,
  /// y negarse a restaurar una que venga de una version mas nueva que la
  /// aplicacion instalada -esa la migraria hacia atras, que es justo lo que
  /// ninguna migracion sabe hacer-.
  final int? versionEsquema;

  final int bytes;

  /// `1.2 MB`, `340 KB`. Se redondea a proposito: lo unico que contesta es
  /// "esto tiene datos dentro" frente a "esto esta vacio".
  String get tamano {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) return '${(bytes / 1024).round()} KB';
    return '$bytes B';
  }

  /// Cierto cuando esta copia viene de una version del programa mas nueva que
  /// la instalada. Restaurarla dejaria una base que este codigo no sabe leer.
  bool vieneDelFuturo(int versionDelCodigo) =>
      versionEsquema != null && versionEsquema! > versionDelCodigo;
}
