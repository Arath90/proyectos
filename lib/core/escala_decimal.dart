/// Magnitudes decimales representadas con enteros.
///
/// El dinero se guarda siempre en centavos y los puntos en centesimas de
/// punto. Nunca se usa `double` para valores que se suman, restan o comparan:
/// 0.1 + 0.2 no es 0.3 en punto flotante y en una hoja de pedido eso termina
/// en un total que no cuadra con el papel.
class EscalaDecimal {
  const EscalaDecimal({required this.decimales, this.simbolo = ''});

  /// Cantidad de decimales que representa el entero escalado.
  final int decimales;

  /// Simbolo antepuesto al formatear, por ejemplo `$`. Vacio para puntos.
  final String simbolo;

  /// Potencia de diez que separa el entero escalado de su valor real.
  int get factor {
    var resultado = 1;
    for (var i = 0; i < decimales; i++) {
      resultado *= 10;
    }
    return resultado;
  }

  /// Convierte texto capturado por la usuaria en un entero escalado.
  ///
  /// Acepta separador de miles (`1,234.56`), simbolo de moneda y espacios.
  /// El texto vacio vale cero. Devuelve `null` si el texto no representa un
  /// numero, para que el formulario pueda marcar el campo como invalido.
  int? parse(String texto) {
    final limpio = texto
        .trim()
        .replaceAll(RegExp(r'[\s ]'), '')
        .replaceAll(simbolo, '')
        .replaceAll(',', '');
    if (limpio.isEmpty) return 0;
    if (!RegExp(r'^-?\d*(\.\d*)?$').hasMatch(limpio)) return null;
    if (!RegExp(r'\d').hasMatch(limpio)) return null;

    final negativo = limpio.startsWith('-');
    final sinSigno = negativo ? limpio.substring(1) : limpio;
    final partes = sinSigno.split('.');

    final entera = partes[0].isEmpty ? '0' : partes[0];
    final base = int.tryParse(entera);
    if (base == null) return null;

    var fraccion = partes.length > 1 ? partes[1] : '';
    var acarreo = 0;
    if (fraccion.length > decimales) {
      // Se capturaron mas decimales de los que la escala guarda: se redondea
      // en lugar de truncar, para no perder un centavo en cada linea.
      acarreo = int.parse(fraccion[decimales]) >= 5 ? 1 : 0;
      fraccion = fraccion.substring(0, decimales);
    }
    fraccion = fraccion.padRight(decimales, '0');
    final decimal = fraccion.isEmpty ? 0 : int.parse(fraccion);

    final total = base * factor + decimal + acarreo;
    return negativo ? -total : total;
  }

  /// Texto legible con simbolo y separador de miles: `$1,234.56`.
  String formatear(int valor) {
    final signo = valor < 0 ? '-' : '';
    return '$signo$simbolo${_sinSigno(valor.abs(), miles: true)}';
  }

  /// Texto plano para precargar un campo de captura: `1234.56`.
  ///
  /// Sin simbolo ni separador de miles, para que al reabrir el formulario el
  /// valor se pueda volver a leer con [parse] sin ambiguedad.
  String aTexto(int valor) {
    final signo = valor < 0 ? '-' : '';
    return '$signo${_sinSigno(valor.abs(), miles: false)}';
  }

  String _sinSigno(int absoluto, {required bool miles}) {
    final entera = (absoluto ~/ factor).toString();
    final visible = miles ? _agruparMiles(entera) : entera;
    if (decimales == 0) return visible;
    final fraccion = (absoluto % factor).toString().padLeft(decimales, '0');
    return '$visible.$fraccion';
  }

  static String _agruparMiles(String entera) {
    final buffer = StringBuffer();
    for (var i = 0; i < entera.length; i++) {
      if (i > 0 && (entera.length - i) % 3 == 0) buffer.write(',');
      buffer.write(entera[i]);
    }
    return buffer.toString();
  }
}

/// Pesos guardados en centavos.
const dinero = EscalaDecimal(decimales: 2, simbolo: r'$');

/// Puntos de catalogo guardados en centesimas de punto.
const puntos = EscalaDecimal(decimales: 2);

/// Division entera redondeada al entero mas cercano; el 0.5 se aleja de cero.
///
/// Se usa en vez de `(a / b).round()` para que el resultado no dependa de la
/// representacion binaria de un `double`.
int redondearDivision(int numerador, int denominador) {
  if (denominador == 0) {
    throw ArgumentError.value(denominador, 'denominador', 'no puede ser cero');
  }
  if (denominador < 0) return redondearDivision(-numerador, -denominador);
  return numerador >= 0
      ? (2 * numerador + denominador) ~/ (2 * denominador)
      : -((-2 * numerador + denominador) ~/ (2 * denominador));
}
