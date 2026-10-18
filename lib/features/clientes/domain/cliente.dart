/// Una persona a la que la propietaria le vende.
///
/// El padron nace con los adeudos y no antes. Mientras cada venta se cobraba
/// sola, el nombre tecleado en el encabezado alcanzaba: nadie tenia que sumar
/// dos hojas para saber cuanto debia alguien. Un adeudo si obliga a decidir
/// que el "Tony" de la deuda vieja y el "tony " de la venta de hoy son la
/// misma persona, porque el abono tiene que saber a que deuda pegarle.
///
/// Sigue siendo flaco: no es un CRM, es la lista de nombres con la que la
/// propietaria ya trabaja, escrita una sola vez para que dos pantallas puedan
/// hablar de la misma persona. Lo unico que se le agrego son las dos cosas que
/// hacen falta para cerrar una venta -a que numero se le habla y donde se le
/// entrega-, y viven aqui y no en la venta porque son de la persona: teclearlas
/// de nuevo en cada hoja es lo que acaba produciendo dos direcciones distintas
/// para el mismo cliente.
class Cliente {
  const Cliente({
    required this.id,
    required this.nombre,
    this.telefono = '',
    this.direccion = '',
    this.notas = '',
  });

  final String id;

  /// Como lo llama la propietaria. Es el nombre vivo: corregirlo aqui lo
  /// corrige en las ventas de esa persona.
  final String nombre;

  /// A que numero se le marca, tal como ella lo escribe. Texto y no numero:
  /// hay ladas entre parentesis y espacios que sirven para leerlo en voz alta.
  final String telefono;

  /// Donde se le entrega.
  final String direccion;

  /// Texto libre para lo demas que ayuda a ubicarlo: quien lo recomendo, a que
  /// horas esta, de quien es pariente.
  final String notas;

  String get titulo =>
      nombre.trim().isEmpty ? 'Cliente sin nombre' : nombre.trim();

  /// La forma con la que este nombre se compara contra otro.
  String get clave => claveDeNombre(nombre);

  bool get tieneTelefono => telefono.trim().isNotEmpty;
  bool get tieneDireccion => direccion.trim().isNotEmpty;

  /// Lo que se puede leer de un vistazo debajo del nombre, sin repetir el
  /// nombre. Vacio cuando no se ha capturado nada de esto.
  String get contacto => [
        if (tieneTelefono) telefono.trim(),
        if (tieneDireccion) direccion.trim(),
        if (notas.trim().isNotEmpty) notas.trim(),
      ].join('  ·  ');

  Cliente copyWith({
    String? nombre,
    String? telefono,
    String? direccion,
    String? notas,
  }) =>
      Cliente(
        id: id,
        nombre: nombre ?? this.nombre,
        telefono: telefono ?? this.telefono,
        direccion: direccion ?? this.direccion,
        notas: notas ?? this.notas,
      );
}

/// Reduce un nombre a lo que queda de el cuando se ignoran las diferencias que
/// la propietaria no considera diferencias.
///
/// Sirve para una sola cosa: avisar que "TONY", "Tony " y "toni" muy
/// probablemente son la misma persona, y no para decidirlo. Quien decide es
/// ella, eligiendo de la lista; esta funcion solo hace que la lista le ofrezca
/// al de siempre en lugar de dejarla crear un duplicado sin darse cuenta.
///
/// Quita acentos porque el teclado de la tablet los pone o no segun la prisa,
/// y colapsa espacios porque un espacio de mas es invisible y parte una cuenta
/// en dos.
String claveDeNombre(String nombre) {
  final minusculas = nombre.trim().toLowerCase();
  final buffer = StringBuffer();
  var espaciando = false;

  for (final letra in minusculas.split('')) {
    if (letra == ' ') {
      espaciando = buffer.isNotEmpty;
      continue;
    }
    if (espaciando) {
      buffer.write(' ');
      espaciando = false;
    }
    buffer.write(_sinAcento[letra] ?? letra);
  }
  return buffer.toString();
}

/// La enie cae en `n` a proposito: "Tonio" y "Tonio" con enie se escriben
/// indistintamente en un cuaderno, y aqui se prefiere sugerir de mas -que ella
/// puede ignorar- a partir una cuenta en dos.
const _sinAcento = <String, String>{
  'a': 'a',
  'á': 'a',
  'à': 'a',
  'ä': 'a',
  'â': 'a',
  'é': 'e',
  'è': 'e',
  'ë': 'e',
  'ê': 'e',
  'í': 'i',
  'ì': 'i',
  'ï': 'i',
  'î': 'i',
  'ó': 'o',
  'ò': 'o',
  'ö': 'o',
  'ô': 'o',
  'ú': 'u',
  'ù': 'u',
  'ü': 'u',
  'û': 'u',
  'ñ': 'n',
};
