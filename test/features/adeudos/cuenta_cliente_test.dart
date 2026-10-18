import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/adeudos/domain/adeudo.dart';
import 'package:punto_venta_madre/features/adeudos/domain/cuenta_cliente.dart';
import 'package:punto_venta_madre/features/clientes/domain/cliente.dart';
import 'package:punto_venta_madre/features/ventas/domain/abono.dart';

/// Pruebas de la cuenta de un cliente, sin base de datos.
///
/// `CuentaCliente` es la unica version de la verdad sobre cuanto debe una
/// persona, y sobre como se propone repartir lo que trae. Si estas cuentas se
/// rompen, se cobra de mas o se deja de cobrar.
void main() {
  const tony = Cliente(id: 'c1', nombre: 'Tony');
  var contador = 0;

  Adeudo cargo(int monto, {String? deVenta}) {
    contador++;
    return Adeudo(
      id: 'ad$contador',
      clienteId: tony.id,
      fecha: DateTime(2026, 9, contador),
      monto: monto,
      ventaOrigenId: deVenta,
    );
  }

  Abono pago(int monto, {int? aAdeudo, int dia = 1}) {
    contador++;
    return Abono(
      id: 'ab$contador',
      clienteId: tony.id,
      fecha: DateTime(2026, 9, dia),
      monto: monto,
      montoAdeudo: aAdeudo ?? monto,
    );
  }

  CuentaCliente cuenta({
    List<Adeudo> adeudos = const [],
    List<Abono> pagos = const [],
    int saldoEnVentas = 0,
    int ventasAbiertas = 0,
  }) {
    return CuentaCliente(
      cliente: tony,
      adeudos: adeudos,
      pagos: pagos,
      saldoEnVentas: saldoEnVentas,
      ventasAbiertas: ventasAbiertas,
    );
  }

  group('el adeudo', () {
    test('es lo cargado menos lo que ya se cobro contra el', () {
      final c = cuenta(
        adeudos: [cargo(200000)],
        pagos: [pago(50000), pago(30000)],
      );

      expect(c.cargado, 200000);
      expect(c.pagado, 80000);
      expect(c.saldoAdeudo, 120000);
    });

    test('de un pago repartido solo cuenta la parte que fue al adeudo', () {
      final c = cuenta(
        adeudos: [cargo(200000)],
        pagos: [pago(50000, aAdeudo: 30000)],
      );

      expect(
        c.pagado,
        30000,
        reason: 'los otros 200 bajaron una venta, no la deuda vieja',
      );
      expect(c.saldoAdeudo, 170000);
    });

    test('pagar de mas deja el adeudo en cero, no en negativo', () {
      final c = cuenta(adeudos: [cargo(50000)], pagos: [pago(80000)]);
      expect(c.saldoAdeudo, 0);
    });

    test('sin cargos no debe nada de antes', () {
      expect(cuenta().saldoAdeudo, 0);
      expect(cuenta().tieneAdeudo, isFalse);
    });
  });

  group('la deuda completa', () {
    /// Es la razon de ser de la pantalla: Tony arrastra dos mil de antes y
    /// ademas se acaba de llevar mil en producto. Ninguna venta suelta podia
    /// contestar esa suma.
    test('suma lo de antes y lo de sus ventas abiertas', () {
      final c = cuenta(
        adeudos: [cargo(200000)],
        saldoEnVentas: 100000,
        ventasAbiertas: 1,
      );

      expect(c.saldoAdeudo, 200000);
      expect(c.saldoEnVentas, 100000);
      expect(c.deudaTotal, 300000);
      expect(c.debe, isTrue);
    });

    test('quien no debe nada queda al corriente', () {
      final c = cuenta(adeudos: [cargo(50000)], pagos: [pago(50000)]);
      expect(c.deudaTotal, 0);
      expect(c.debe, isFalse);
    });

    test('el ultimo pago es el mas reciente', () {
      final c = cuenta(
        adeudos: [cargo(200000)],
        pagos: [pago(10000, dia: 3), pago(10000, dia: 20), pago(10000, dia: 9)],
      );
      expect(c.ultimoPago, DateTime(2026, 9, 20));
    });
  });

  /// La regla que la propietaria pidio: lo que dejen tapa primero lo viejo.
  group('el reparto que se propone al cobrar', () {
    test('todo va al adeudo mientras no alcance a cubrirlo', () {
      final c = cuenta(adeudos: [cargo(200000)], saldoEnVentas: 100000);
      expect(c.repartoAAdeudo(50000), 50000);
    });

    test('lo que sobra despues de tapar el adeudo queda para la venta', () {
      final c = cuenta(adeudos: [cargo(200000)], saldoEnVentas: 100000);
      expect(
        c.repartoAAdeudo(250000),
        200000,
        reason: 'los otros 500 bajan la venta del dia',
      );
    });

    test('sin deuda vieja no se reparte nada', () {
      expect(cuenta(saldoEnVentas: 100000).repartoAAdeudo(50000), 0);
    });

    test('un monto vacio o negativo no reparte', () {
      final c = cuenta(adeudos: [cargo(200000)]);
      expect(c.repartoAAdeudo(0), 0);
      expect(c.repartoAAdeudo(-100), 0);
    });

    test('la funcion suelta contesta igual que la cuenta', () {
      // La usa la pantalla de una venta, que conoce el saldo de adeudo de su
      // cliente pero no arma su cuenta completa. Si las dos no coincidieran,
      // cobrar desde la venta y cobrar desde el adeudo propondrian cosas
      // distintas.
      expect(repartoPropuesto(monto: 50000, saldoAdeudo: 200000), 50000);
      expect(repartoPropuesto(monto: 250000, saldoAdeudo: 200000), 200000);
      expect(repartoPropuesto(monto: 50000, saldoAdeudo: 0), 0);
    });
  });

  group('resumen de varias cuentas', () {
    test('separa lo viejo de lo que se debe en ventas', () {
      final resumen = ResumenAdeudos.de([
        cuenta(adeudos: [cargo(200000)], saldoEnVentas: 100000),
        cuenta(saldoEnVentas: 50000),
        cuenta(adeudos: [cargo(10000)], pagos: [pago(10000)]),
      ]);

      expect(resumen.clientes, 3);
      expect(resumen.deudores, 2, reason: 'el tercero ya quedo a mano');
      expect(resumen.adeudo, 200000);
      expect(resumen.enVentas, 150000);
      expect(resumen.total, 350000);
      expect(resumen.hayDeuda, isTrue);
    });

    test('el resumen vacio esta en ceros', () {
      expect(ResumenAdeudos.de(const []).total, 0);
      expect(ResumenAdeudos.vacio.hayDeuda, isFalse);
    });
  });

  group('un cargo dice de donde viene', () {
    test('el capturado a mano es deuda anterior', () {
      final a = cargo(200000);
      expect(a.vieneDeVenta, isFalse);
      expect(a.titulo, 'Deuda anterior');
    });

    test('el traspasado recuerda su venta', () {
      final a = cargo(80000, deVenta: 'v1');
      expect(a.vieneDeVenta, isTrue);
      expect(a.ventaOrigenId, 'v1');
      expect(a.titulo, 'Saldo de una venta');
    });
  });
}
