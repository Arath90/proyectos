import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/core/escala_decimal.dart';

void main() {
  group('redondearDivision', () {
    test('redondea al entero mas cercano', () {
      expect(redondearDivision(1, 3), 0);
      expect(redondearDivision(2, 3), 1);
      expect(redondearDivision(10, 5), 2);
    });

    test('el medio exacto se aleja de cero', () {
      expect(redondearDivision(10, 4), 3);
      expect(redondearDivision(-10, 4), -3);
      expect(redondearDivision(7, 2), 4);
      expect(redondearDivision(-7, 2), -4);
    });

    test('acepta denominador negativo', () {
      expect(redondearDivision(10, -4), -3);
    });

    test('rechaza el cero', () {
      expect(() => redondearDivision(1, 0), throwsArgumentError);
    });
  });

  group('dinero.parse', () {
    test('lee decimales', () {
      expect(dinero.parse('1234.56'), 123456);
      expect(dinero.parse('12'), 1200);
      expect(dinero.parse('12.5'), 1250);
      expect(dinero.parse('0'), 0);
    });

    test('tolera separador de miles, simbolo y espacios', () {
      expect(dinero.parse('1,234.56'), 123456);
      expect(dinero.parse(r'$1,234.56'), 123456);
      expect(dinero.parse('  1,234.56  '), 123456);
      expect(dinero.parse('10,000'), 1000000);
    });

    test('el texto vacio vale cero', () {
      expect(dinero.parse(''), 0);
      expect(dinero.parse('   '), 0);
    });

    test('redondea si se capturan mas decimales de los que caben', () {
      expect(dinero.parse('12.567'), 1257);
      expect(dinero.parse('12.564'), 1256);
      expect(dinero.parse('12.565'), 1257);
    });

    test('lee negativos', () {
      expect(dinero.parse('-5.25'), -525);
      expect(dinero.parse(r'-$1,000.00'), -100000);
    });

    test('acepta formas incompletas', () {
      expect(dinero.parse('.5'), 50);
      expect(dinero.parse('1.'), 100);
    });

    test('devuelve null ante texto que no es numero', () {
      expect(dinero.parse('abc'), isNull);
      expect(dinero.parse('12.3.4'), isNull);
      expect(dinero.parse('-'), isNull);
      expect(dinero.parse('.'), isNull);
    });
  });

  group('dinero.formatear', () {
    test('agrupa miles y fija dos decimales', () {
      expect(dinero.formatear(123456), r'$1,234.56');
      expect(dinero.formatear(0), r'$0.00');
      expect(dinero.formatear(100), r'$1.00');
      expect(dinero.formatear(5), r'$0.05');
      expect(dinero.formatear(100000000), r'$1,000,000.00');
    });

    test('el signo va antes del simbolo', () {
      expect(dinero.formatear(-123456), r'-$1,234.56');
    });
  });

  group('dinero.aTexto', () {
    test('produce texto que parse puede volver a leer', () {
      for (final valor in [0, 5, 100, 123456, -98765]) {
        expect(dinero.parse(dinero.aTexto(valor)), valor,
            reason: 'ida y vuelta de $valor');
      }
    });

    test('no incluye simbolo ni separador de miles', () {
      expect(dinero.aTexto(123456), '1234.56');
      expect(dinero.aTexto(-98765), '-987.65');
    });
  });

  group('puntos', () {
    test('usa la misma escala pero sin simbolo', () {
      expect(puntos.parse('123.45'), 12345);
      expect(puntos.formatear(12345), '123.45');
    });
  });
}
