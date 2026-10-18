import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/ventas/domain/abono.dart';
import 'package:punto_venta_madre/features/ventas/domain/linea_venta.dart';
import 'package:punto_venta_madre/features/ventas/domain/venta.dart';
import 'package:punto_venta_madre/features/ventas/domain/venta_detallada.dart';

/// Pruebas de las reglas de dinero de una venta, sin base de datos.
///
/// `VentaDetallada` es la unica version de la verdad sobre cuanto se cobra y
/// cuanto se debe: el listado, el detalle y el resumen leen de aqui. Si estas
/// cuentas se rompen, se rompe el cobro.
void main() {
  var contador = 0;

  LineaVenta linea({
    int cantidad = 1,
    int precioUnitario = 10000,
    int descuento = 0,
    String? productoId,
  }) {
    contador++;
    return LineaVenta(
      id: 'l$contador',
      ventaId: 'v1',
      productoId: productoId,
      marca: 'Jafra',
      codigo: '0123',
      descripcion: 'Crema',
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      descuento: descuento,
    );
  }

  VentaDetallada detalle({
    List<LineaVenta> lineas = const [],
    List<Abono> abonos = const [],
    EstadoVenta estado = EstadoVenta.apartada,
    int traspasado = 0,
  }) {
    return VentaDetallada(
      venta: Venta(
        id: 'v1',
        fecha: DateTime(2026, 9, 4),
        cliente: 'Rosa',
        estado: estado,
      ),
      lineas: lineas,
      abonos: abonos,
      traspasado: traspasado,
    );
  }

  Abono abono(int monto, {int dia = 1, int aAdeudo = 0}) => Abono(
        id: 'a$monto$dia',
        ventaId: 'v1',
        fecha: DateTime(2026, 9, dia),
        monto: monto,
        montoAdeudo: aAdeudo,
      );

  group('importe de un renglon', () {
    test('cantidad por precio menos descuento', () {
      final l = linea(cantidad: 3, precioUnitario: 10000, descuento: 5000);
      expect(l.subtotal, 30000);
      expect(l.importe, 25000);
    });

    test('un descuento mayor que el subtotal no devuelve dinero', () {
      final l = linea(cantidad: 1, precioUnitario: 10000, descuento: 50000);
      expect(l.importe, 0);
    });

    test('solo mueve inventario si tiene producto y piezas', () {
      expect(linea(productoId: 'p1', cantidad: 2).mueveInventario, isTrue);
      expect(linea(cantidad: 2).mueveInventario, isFalse);
      expect(linea(productoId: 'p1', cantidad: 0).mueveInventario, isFalse);
    });
  });

  group('totales de la venta', () {
    test('suma renglones, piezas y descuentos', () {
      final d = detalle(
        lineas: [
          linea(cantidad: 2, precioUnitario: 10000),
          linea(cantidad: 3, precioUnitario: 5000, descuento: 1000),
        ],
      );
      expect(d.piezas, 5);
      expect(d.subtotal, 35000);
      expect(d.descuento, 1000);
      expect(d.total, 34000);
    });

    test('una venta cancelada no se cobra aunque tenga renglones', () {
      final d = detalle(
        lineas: [linea(cantidad: 2, precioUnitario: 10000)],
        estado: EstadoVenta.cancelada,
      );
      expect(d.lineas, hasLength(1));
      expect(d.total, 0);
      expect(d.saldo, 0);
    });
  });

  group('cobranza a plazos', () {
    test('el saldo es lo que falta despues de los abonos', () {
      final d = detalle(
        lineas: [linea(cantidad: 1, precioUnitario: 30000)],
        abonos: [abono(5000, dia: 1), abono(7000, dia: 15)],
      );
      expect(d.abonado, 12000);
      expect(d.saldo, 18000);
      expect(d.pagoParcial, isTrue);
      expect(d.liquidada, isFalse);
    });

    test('abonar de mas deja el saldo en cero', () {
      final d = detalle(
        lineas: [linea(cantidad: 1, precioUnitario: 10000)],
        abonos: [abono(15000)],
      );
      expect(d.saldo, 0);
      expect(d.liquidada, isTrue);
    });

    test('una venta sin renglones no cuenta como liquidada', () {
      expect(detalle().liquidada, isFalse);
      expect(detalle().avanceCobro, 0);
    });

    test('el avance de cobro va de cero a uno', () {
      final d = detalle(
        lineas: [linea(cantidad: 1, precioUnitario: 10000)],
        abonos: [abono(2500)],
      );
      expect(d.avanceCobro, 0.25);
    });

    test('el ultimo abono es el mas reciente por fecha, no por orden', () {
      final d = detalle(
        lineas: [linea()],
        abonos: [abono(1000, dia: 20), abono(1000, dia: 3)],
      );
      expect(d.ultimoAbono, DateTime(2026, 9, 20));
    });
  });

  group('piezas por producto', () {
    test('agrupa los renglones del mismo articulo', () {
      final d = detalle(
        lineas: [
          linea(productoId: 'p1', cantidad: 2),
          linea(productoId: 'p1', cantidad: 3),
          linea(productoId: 'p2', cantidad: 1),
          linea(cantidad: 9),
        ],
      );
      expect(d.piezasPorProducto, {'p1': 5, 'p2': 1});
    });
  });

  group('resumen de varias ventas', () {
    test('ignora las canceladas y cuenta las apartadas', () {
      final resumen = ResumenVentas.de([
        detalle(
          lineas: [linea(cantidad: 1, precioUnitario: 10000)],
          abonos: [abono(4000)],
        ),
        detalle(
          lineas: [linea(cantidad: 1, precioUnitario: 20000)],
          estado: EstadoVenta.entregada,
        ),
        detalle(
          lineas: [linea(cantidad: 1, precioUnitario: 99900)],
          estado: EstadoVenta.cancelada,
        ),
      ]);

      expect(resumen.ventas, 3, reason: 'las canceladas si se listan');
      expect(resumen.total, 30000, reason: 'pero no se cobran');
      expect(resumen.abonado, 4000);
      expect(resumen.saldo, 26000);
      expect(resumen.apartadas, 1);
      expect(resumen.hayPorCobrar, isTrue);
    });

    test('el resumen vacio esta en ceros', () {
      expect(ResumenVentas.de(const []).total, 0);
      expect(ResumenVentas.vacio.hayPorCobrar, isFalse);
    });
  });

  /// Un pago puede tapar deuda vieja ademas de esta venta. Lo que la venta
  /// cobro es solo su mitad, y confundirlas la daria por liquidada con dinero
  /// que se fue a otro lado.
  group('un pago repartido', () {
    test('la venta solo se lleva su parte del pago', () {
      final d = detalle(
        lineas: [linea(cantidad: 1, precioUnitario: 100000)],
        abonos: [abono(50000, aAdeudo: 30000)],
      );

      expect(d.abonado, 20000, reason: 'los otros 300 taparon deuda vieja');
      expect(d.saldo, 80000);
      expect(d.liquidada, isFalse);
    });

    test('un pago que no toca adeudo se comporta como siempre', () {
      final d = detalle(
        lineas: [linea(cantidad: 1, precioUnitario: 100000)],
        abonos: [abono(100000)],
      );

      expect(d.abonado, 100000);
      expect(d.saldo, 0);
      expect(d.liquidada, isTrue);
    });
  });

  /// Traspasar el saldo a la cuenta del cliente no cobra nada: la deuda cambia
  /// de lugar. La venta deja de perseguirse aqui, pero no queda liquidada,
  /// porque nadie pago.
  group('saldo traspasado a adeudos', () {
    test('lo traspasado se resta del saldo sin contarse como cobrado', () {
      final d = detalle(
        lineas: [linea(cantidad: 1, precioUnitario: 100000)],
        abonos: [abono(40000)],
        traspasado: 60000,
      );

      expect(d.total, 100000);
      expect(d.abonado, 40000);
      expect(d.saldo, 0);
      expect(d.traspasadaAAdeudo, isTrue);
    });

    test('una venta traspasada no cuenta como liquidada', () {
      final d = detalle(
        lineas: [linea(cantidad: 1, precioUnitario: 100000)],
        traspasado: 100000,
      );

      expect(d.saldo, 0);
      expect(
        d.liquidada,
        isFalse,
        reason: 'nadie pago: llamarla liquidada seria dejar de cobrarla',
      );
    });

    test('el resumen lleva lo traspasado aparte de lo cobrado', () {
      final resumen = ResumenVentas.de([
        detalle(
          lineas: [linea(cantidad: 1, precioUnitario: 100000)],
          traspasado: 100000,
        ),
        detalle(
          lineas: [linea(cantidad: 1, precioUnitario: 50000)],
          abonos: [abono(20000)],
        ),
      ]);

      expect(resumen.total, 150000);
      expect(resumen.abonado, 20000);
      expect(resumen.traspasado, 100000);
      expect(resumen.saldo, 30000, reason: 'lo traspasado ya no se debe aqui');
      expect(resumen.hayTraspasado, isTrue);
    });
  });
}
