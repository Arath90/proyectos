import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/core/escala_decimal.dart';
import 'package:punto_venta_madre/features/pedidos/domain/calculo_linea.dart';
import 'package:punto_venta_madre/features/pedidos/domain/linea_pedido.dart';

/// Construye una linea con valores neutros y solo lo que cada prueba necesita.
LineaPedido linea({
  int cantPedida = 0,
  int cantEnviada = 0,
  int valorTotalPuntos = 0,
  int precioUnitario = 0,
  int precioRevista = 0,
  int valorTotalPromocionado = 0,
  int totalDescuentoCn = 0,
  int valorRegalos = 0,
  int? precioTotalManual,
  int? valorPromSinIvaManual,
  int? tuPagasManual,
}) {
  return LineaPedido(
    id: 'l1',
    pedidoId: 'p1',
    marca: 'Marca',
    codigo: '00123',
    descripcion: 'Producto de prueba',
    cantPedida: cantPedida,
    cantEnviada: cantEnviada,
    valorTotalPuntos: valorTotalPuntos,
    precioUnitario: precioUnitario,
    precioRevista: precioRevista,
    valorTotalPromocionado: valorTotalPromocionado,
    totalDescuentoCn: totalDescuentoCn,
    valorRegalos: valorRegalos,
    precioTotalManual: precioTotalManual,
    valorPromSinIvaManual: valorPromSinIvaManual,
    tuPagasManual: tuPagasManual,
  );
}

void main() {
  group('promSinIva', () {
    test('quita el IVA de un importe que ya lo incluye', () {
      // $116.00 con IVA incluido son $100.00 de base.
      expect(CalculoLinea.promSinIva(11600), 10000);
      expect(CalculoLinea.promSinIva(23200), 20000);
    });

    test('cero no genera IVA', () {
      expect(CalculoLinea.promSinIva(0), 0);
      expect(CalculoLinea.ivaIncluido(0), 0);
    });

    test('redondea al centavo mas cercano', () {
      // 10000 / 1.16 = 8620.6896...
      expect(CalculoLinea.promSinIva(10000), 8621);
    });

    test('base mas IVA reconstruye siempre el importe original', () {
      // Es la razon de calcular el IVA como residuo y no por separado:
      // sin esto, el total del pedido se descuadra un centavo por linea.
      for (var importe = 0; importe <= 5000; importe += 7) {
        expect(
          CalculoLinea.promSinIva(importe) + CalculoLinea.ivaIncluido(importe),
          importe,
          reason: 'importe $importe',
        );
      }
    });

    test('admite la tasa de franja fronteriza', () {
      expect(CalculoLinea.promSinIva(10800, ivaPorMil: 80), 10000);
    });
  });

  group('precioTotal', () {
    test('es el precio de compra por las piezas pedidas', () {
      expect(
        CalculoLinea.precioTotal(precioUnitario: 12850, cantPedida: 3),
        38550,
      );
    });

    test('multiplica por la pedida y no por la enviada', () {
      // La hoja se captura al hacer el pedido, cuando todavia no se sabe que
      // va a llegar; si la distribuidora manda de menos, el papel trae la
      // cifra corregida y esa entra por el campo manual.
      final l = linea(precioUnitario: 10000, cantPedida: 5, cantEnviada: 2);
      expect(l.precioTotal, 50000);
    });

    test('sin precio unitario la linea no cuesta nada', () {
      expect(linea(cantPedida: 9).precioTotal, 0);
    });
  });

  group('margenEsperado', () {
    test('es lo que deja la linea si se vende todo a precio de revista', () {
      // 3 piezas que costaron $80 y se venden en $200: $360 de ganancia.
      final l = linea(precioUnitario: 8000, precioRevista: 20000, cantPedida: 3);
      expect(l.margenEsperado, 36000);
    });

    test('un precio de compra arriba del de revista da margen negativo', () {
      final l = linea(precioUnitario: 25000, precioRevista: 20000, cantPedida: 1);
      expect(l.margenEsperado, -5000);
    });

    test('sigue al precio total manual y no al calculado', () {
      final l = linea(
        precioUnitario: 8000,
        precioRevista: 20000,
        cantPedida: 3,
        precioTotalManual: 30000,
      );
      expect(l.margenEsperado, 30000);
    });
  });

  group('tuPagas', () {
    test('es el promocionado menos el descuento de consultora', () {
      expect(
        CalculoLinea.tuPagas(
          valorTotalPromocionado: 10000,
          totalDescuentoCn: 1500,
        ),
        8500,
      );
    });

    test('sin descuento se paga el promocionado completo', () {
      expect(
        CalculoLinea.tuPagas(
          valorTotalPromocionado: 10000,
          totalDescuentoCn: 0,
        ),
        10000,
      );
    });

    test('un descuento mayor al importe deja saldo a favor', () {
      expect(
        CalculoLinea.tuPagas(
          valorTotalPromocionado: 10000,
          totalDescuentoCn: 12000,
        ),
        -2000,
      );
    });
  });

  group('faltantes', () {
    test('son las piezas pedidas que no llegaron', () {
      expect(CalculoLinea.faltantes(cantPedida: 10, cantEnviada: 7), 3);
      expect(linea(cantPedida: 10, cantEnviada: 7).tieneFaltantes, isTrue);
    });

    test('enviar de mas da negativo y no cuenta como faltante', () {
      expect(CalculoLinea.faltantes(cantPedida: 5, cantEnviada: 8), -3);
      expect(linea(cantPedida: 5, cantEnviada: 8).tieneFaltantes, isFalse);
    });
  });

  group('LineaPedido con valores derivados', () {
    test('calcula sin IVA y tu pagas cuando no hay ajuste manual', () {
      final l = linea(valorTotalPromocionado: 11600, totalDescuentoCn: 1600);
      expect(l.valorPromSinIva, 10000);
      expect(l.iva, 1600);
      expect(l.tuPagas, 10000);
      expect(l.tieneAjusteManual, isFalse);
    });

    test('el valor manual gana sobre el calculado', () {
      final l = linea(
        valorTotalPromocionado: 11600,
        totalDescuentoCn: 1600,
        valorPromSinIvaManual: 9999,
        tuPagasManual: 8888,
      );
      expect(l.valorPromSinIva, 9999);
      expect(l.tuPagas, 8888);
      expect(l.tieneAjusteManual, isTrue);
    });

    test('el precio total manual gana sobre el calculado', () {
      final l = linea(
        precioUnitario: 12850,
        cantPedida: 3,
        precioTotalManual: 35000,
      );
      expect(l.precioTotalCalculado, 38550);
      expect(l.precioTotal, 35000);
      expect(l.tieneAjusteManual, isTrue);
    });

    test('un manual identico al calculado no cuenta como ajuste', () {
      final l = linea(
        precioUnitario: 10000,
        cantPedida: 2,
        valorTotalPromocionado: 11600,
        totalDescuentoCn: 1600,
        precioTotalManual: 20000,
        valorPromSinIvaManual: 10000,
        tuPagasManual: 10000,
      );
      expect(l.tieneAjusteManual, isFalse);
    });

    test('el IVA sigue al valor manual y no al calculado', () {
      final l = linea(
        valorTotalPromocionado: 11600,
        valorPromSinIvaManual: 10500,
      );
      expect(l.iva, 1100);
    });
  });

  group('copyWith', () {
    test('conserva los ajustes manuales si no se mencionan', () {
      final original = linea(
        valorTotalPromocionado: 11600,
        tuPagasManual: 8888,
      );
      final copia = original.copyWith(descripcion: 'Otro nombre');
      expect(copia.tuPagasManual, 8888);
      expect(copia.descripcion, 'Otro nombre');
    });

    test('permite devolver un campo a modo calculado', () {
      final original = linea(
        valorTotalPromocionado: 11600,
        totalDescuentoCn: 1600,
        tuPagasManual: 8888,
      );
      final copia = original.copyWith(tuPagasManual: (valor: null));
      expect(copia.tuPagasManual, isNull);
      expect(copia.tuPagas, 10000);
    });

    test('permite fijar un ajuste manual nuevo', () {
      final copia = linea(valorTotalPromocionado: 11600)
          .copyWith(tuPagasManual: (valor: 7777));
      expect(copia.tuPagas, 7777);
    });
  });

  group('los dos precios de la hoja no se estorban', () {
    test('el de compra y el de revista viven aparte en la misma linea', () {
      final l = linea(precioUnitario: 8000, precioRevista: 20000, cantPedida: 2);
      expect(l.precioUnitario, 8000);
      expect(l.precioRevista, 20000);
      expect(l.precioTotal, 16000);
    });

    test('copyWith conserva el precio de compra si no se menciona', () {
      final copia = linea(precioUnitario: 8000, cantPedida: 2)
          .copyWith(descripcion: 'Otro nombre');
      expect(copia.precioUnitario, 8000);
      expect(copia.precioTotal, 16000);
    });

    test('el precio total vuelve al calculo al soltar el manual', () {
      final original = linea(
        precioUnitario: 8000,
        cantPedida: 2,
        precioTotalManual: 30000,
      );
      final copia = original.copyWith(precioTotalManual: (valor: null));
      expect(copia.precioTotalManual, isNull);
      expect(copia.precioTotal, 16000);
    });
  });

  group('formato de salida', () {
    test('los importes se muestran como pesos', () {
      final l = linea(valorTotalPromocionado: 11600, totalDescuentoCn: 1600);
      expect(dinero.formatear(l.valorTotalPromocionado), r'$116.00');
      expect(dinero.formatear(l.valorPromSinIva), r'$100.00');
      expect(dinero.formatear(l.tuPagas), r'$100.00');
    });
  });
}
