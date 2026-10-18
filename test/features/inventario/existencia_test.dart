import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/inventario/domain/existencia.dart';
import 'package:punto_venta_madre/features/inventario/domain/producto.dart';
import 'package:punto_venta_madre/features/inventario/domain/producto_borrador.dart';

/// Pruebas del modelo del inventario, sin base de datos.
///
/// La distincion que se prueba aqui es la que mas confunde a un inventario:
/// lo que hay fisicamente no es lo que se puede prometer. Entre las dos cifras
/// esta lo apartado.
void main() {
  Producto producto({
    String marca = 'Jafra',
    String codigo = '0123',
    String descripcion = 'Crema de noche',
    int actual = 10,
    int original = 10,
  }) {
    return Producto(
      id: 'p1',
      marca: marca,
      codigo: codigo,
      descripcion: descripcion,
      cantidadActual: actual,
      cantidadOriginal: original,
    );
  }

  group('producto', () {
    test('el titulo junta codigo y descripcion', () {
      expect(producto().titulo, '0123 - Crema de noche');
    });

    test('sin codigo ni descripcion queda un titulo utilizable', () {
      expect(
        producto(codigo: '', descripcion: '').titulo,
        'Producto sin nombre',
      );
    });

    test('las salidas son lo entrado menos lo que queda', () {
      expect(producto(actual: 4, original: 10).salidas, 6);
    });

    test('se marca agotado en cero o menos', () {
      expect(producto(actual: 0).agotado, isTrue);
      expect(producto(actual: -1).agotado, isTrue);
      expect(producto(actual: 1).agotado, isFalse);
    });

    test('la fraccion restante no divide entre cero', () {
      expect(producto(actual: 0, original: 0).fraccionRestante, 0);
      expect(producto(actual: 5, original: 10).fraccionRestante, 0.5);
    });

    test('la fraccion restante nunca pasa de uno', () {
      expect(producto(actual: 15, original: 10).fraccionRestante, 1);
    });
  });

  group('existencia', () {
    test('lo disponible es lo que hay menos lo apartado', () {
      final e = Existencia(producto: producto(actual: 10), apartadas: 3);
      expect(e.disponibles, 7);
      expect(e.hayApartado, isTrue);
      expect(e.sobrevendido, isFalse);
    });

    test('sin apartados, disponible es todo lo que hay', () {
      final e = Existencia(producto: producto(actual: 10));
      expect(e.disponibles, 10);
      expect(e.hayApartado, isFalse);
    });

    test('el sobrevendido se muestra en negativo, no se recorta', () {
      final e = Existencia(producto: producto(actual: 2), apartadas: 5);
      expect(e.disponibles, -3);
      expect(e.sobrevendido, isTrue);
    });
  });

  group('borrador', () {
    test('al dar de alta, lo que hay es lo que entro', () {
      const b = ProductoBorrador(codigo: '0123', cantidadActual: 7);
      expect(b.cantidadOriginalEfectiva, 7);
      expect(b.aProducto('p1').cantidadOriginal, 7);
    });

    test('una original explicita gana sobre la actual', () {
      const b = ProductoBorrador(
        codigo: '0123',
        cantidadActual: 3,
        cantidadOriginal: 12,
      );
      expect(b.cantidadOriginalEfectiva, 12);
    });

    test('recorta los espacios al convertirse en producto', () {
      const b = ProductoBorrador(
        marca: '  Jafra ',
        codigo: ' 0123 ',
        descripcion: '  Crema  ',
      );
      final p = b.aProducto('p1');
      expect(p.marca, 'Jafra');
      expect(p.codigo, '0123');
      expect(p.descripcion, 'Crema');
    });

    test('ida y vuelta desde un producto guardado conserva las cifras', () {
      final original = producto(actual: 4, original: 9);
      final vuelta = ProductoBorrador.deProducto(original).aProducto('p1');
      expect(vuelta.cantidadActual, 4);
      expect(vuelta.cantidadOriginal, 9);
    });
  });
}
