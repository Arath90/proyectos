import '../../clientes/domain/cliente.dart';
import '../../ventas/domain/abono.dart';
import 'adeudo.dart';

/// Todo lo que una persona debe, junto.
///
/// Es la pantalla de adeudos vista desde el dominio, y contesta la pregunta
/// que ninguna venta suelta podia contestar: *cuanto me debe Tony*. La
/// respuesta tiene dos mitades que no se pueden sumar a ciegas porque se
/// cobran distinto:
///
///  - el **adeudo**, que son cargos de dinero sin mercancia detras -lo viejo,
///    o el saldo de una venta que se traspaso-, y
///  - el **saldo en ventas**, que sigue colgando de las hojas abiertas de esa
///    persona y baja conforme se le cobra ahi.
///
/// Los dos se muestran por separado y ademas sumados, porque la propietaria
/// necesita las dos cosas: el total es lo que le dice, y el desglose es lo que
/// le permite saber donde tocar para corregirlo.
///
/// Igual que `VentaDetallada`, no guarda nada: se arma cada vez con lo que
/// haya en las tablas. Un saldo almacenado se desincroniza en cuanto se
/// corrige un pago mal capturado, que es exactamente lo que mas pasa.
class CuentaCliente {
  const CuentaCliente({
    required this.cliente,
    this.adeudos = const [],
    this.pagos = const [],
    this.saldoEnVentas = 0,
    this.ventasAbiertas = 0,
  });

  final Cliente cliente;

  /// Los cargos vigentes de esta persona, del mas reciente al mas viejo.
  final List<Adeudo> adeudos;

  /// Los pagos de esta persona que taparon adeudo, aunque haya sido en parte.
  ///
  /// Son los mismos `Abono` de siempre: un pago hecho dentro de una venta
  /// tambien aparece aqui si una parte se aplico al adeudo. No hay dos
  /// historias de pagos, hay una vista dos veces.
  final List<Abono> pagos;

  /// Lo que esta persona debe todavia en sus ventas abiertas, en centavos.
  ///
  /// Llega desde afuera, sumado por quien si conoce las ventas: esta clase no
  /// vuelve a decidir que cuenta como saldo de una venta, porque esa regla ya
  /// vive en `VentaDetallada` y escribirla otra vez aqui dejaria dos
  /// versiones que tarde o temprano dejan de coincidir.
  final int saldoEnVentas;

  /// Cuantas ventas de esta persona siguen con saldo.
  final int ventasAbiertas;

  // --- Adeudo --------------------------------------------------------------

  /// Suma de los cargos, en centavos.
  int get cargado => adeudos.fold(0, (suma, adeudo) => suma + adeudo.monto);

  /// Suma de lo que ya se le cobro contra esos cargos, en centavos.
  int get pagado => pagos.fold(0, (suma, abono) => suma + abono.montoAdeudo);

  /// Lo que falta del adeudo, en centavos.
  ///
  /// Se recorta a cero por la misma razon que el saldo de una venta: un adeudo
  /// negativo se leeria como si la propietaria le debiera a el.
  int get saldoAdeudo {
    final resultado = cargado - pagado;
    return resultado < 0 ? 0 : resultado;
  }

  // --- La cuenta completa --------------------------------------------------

  /// Todo lo que esta persona debe hoy, en centavos.
  int get deudaTotal => saldoAdeudo + saldoEnVentas;

  bool get debe => deudaTotal > 0;

  /// Cierto cuando arrastra deuda vieja ademas de sus ventas abiertas. Es lo
  /// que decide que al cobrarle se le proponga tapar primero el adeudo.
  bool get tieneAdeudo => saldoAdeudo > 0;

  /// Fecha del ultimo pago que toco su adeudo, o `null` si nunca ha abonado.
  DateTime? get ultimoPago {
    if (pagos.isEmpty) return null;
    return pagos.map((p) => p.fecha).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// Como se repartiria un pago de [monto] entre el adeudo y la venta.
  int repartoAAdeudo(int monto) =>
      repartoPropuesto(monto: monto, saldoAdeudo: saldoAdeudo);
}

/// Cuanto de un pago de [monto] deberia ir al adeudo antes de tocar la venta.
///
/// Es la regla que la propietaria pidio y la unica del sistema que decide a
/// que le pega el dinero: **primero se tapa lo viejo**. Quien arrastra deuda de
/// hace meses y hoy se lleva mas mercancia deja lo que trae contra lo de antes,
/// y solo lo que sobre baja la venta del dia.
///
/// Es una funcion suelta y no un metodo porque tambien la usa la pantalla de
/// una venta, que conoce el saldo de adeudo de su cliente pero no arma su
/// cuenta completa. Escrita una sola vez es lo que garantiza que cobrar desde
/// la venta y cobrar desde el adeudo propongan lo mismo.
///
/// Es solo la propuesta: la propietaria puede moverla antes de guardar, porque
/// a veces prefiere abonar todo a la venta del dia y el sistema no tiene por
/// que decidir eso por ella.
int repartoPropuesto({required int monto, required int saldoAdeudo}) {
  if (monto <= 0 || saldoAdeudo <= 0) return 0;
  return monto < saldoAdeudo ? monto : saldoAdeudo;
}

/// Lo que corona la pantalla de adeudos: cuanto se debe en total y cuantos
/// deben.
///
/// Se calcula sobre las cuentas ya armadas, no con SQL, por la misma razon que
/// `ResumenVentas`: las reglas de que cuenta como deuda viven en
/// [CuentaCliente] y repetirlas como sumas en la consulta dejaria dos
/// versiones de la misma regla.
class ResumenAdeudos {
  const ResumenAdeudos({
    required this.clientes,
    required this.deudores,
    required this.adeudo,
    required this.enVentas,
  });

  factory ResumenAdeudos.de(Iterable<CuentaCliente> cuentas) {
    var clientes = 0;
    var deudores = 0;
    var adeudo = 0;
    var enVentas = 0;

    for (final cuenta in cuentas) {
      clientes++;
      if (cuenta.debe) deudores++;
      adeudo += cuenta.saldoAdeudo;
      enVentas += cuenta.saldoEnVentas;
    }

    return ResumenAdeudos(
      clientes: clientes,
      deudores: deudores,
      adeudo: adeudo,
      enVentas: enVentas,
    );
  }

  static const vacio =
      ResumenAdeudos(clientes: 0, deudores: 0, adeudo: 0, enVentas: 0);

  final int clientes;

  /// Cuantos de esos clientes deben algo hoy.
  final int deudores;

  /// Suma de los adeudos pendientes, en centavos.
  final int adeudo;

  /// Suma de lo que se debe en ventas abiertas, en centavos.
  final int enVentas;

  int get total => adeudo + enVentas;

  bool get hayDeuda => total > 0;
}
