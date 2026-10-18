/// Un cargo a la cuenta de un cliente.
///
/// Es la pieza que le faltaba al sistema para poder cobrar lo de antes. La
/// deuda vieja de alguien -mercancia que ya se llevo hace meses, cuando la
/// aplicacion no existia- no se puede capturar como venta: una venta mueve
/// inventario, y dar de alta hoy productos que salieron el ano pasado dejaria
/// las existencias mintiendo justo en el numero con el que la propietaria le
/// promete piezas a alguien mas. Un adeudo, en cambio, es puro dinero: se
/// captura cuanto debe y ya.
///
/// El otro origen es [ventaOrigenId]: una venta entregada que quedo con saldo
/// y que la propietaria mando a la cuenta del cliente para dejar de
/// perseguirla hoja por hoja. Guardar de donde vino es lo que permite
/// deshacerlo, y lo que explica meses despues por que existe ese cargo.
class Adeudo {
  const Adeudo({
    required this.id,
    required this.clienteId,
    required this.fecha,
    required this.monto,
    this.concepto = '',
    this.ventaOrigenId,
  });

  final String id;
  final String clienteId;
  final DateTime fecha;

  /// Que fue lo que se llevo: "productos de la campana 9", "lo de diciembre".
  final String concepto;

  /// Importe del cargo, en centavos.
  ///
  /// Los pagos no se restan de aqui. Viven en `Abono.montoAdeudo` y el saldo
  /// se calcula, por la misma razon que no se guarda el saldo de una venta:
  /// una cifra guardada se desincroniza en cuanto se corrige un pago.
  final int monto;

  /// Venta cuyo saldo se traspaso a este cargo, o `null` si se capturo a mano.
  final String? ventaOrigenId;

  bool get vieneDeVenta => ventaOrigenId != null;

  String get titulo {
    if (concepto.trim().isNotEmpty) return concepto.trim();
    return vieneDeVenta ? 'Saldo de una venta' : 'Deuda anterior';
  }

  Adeudo copyWith({DateTime? fecha, int? monto, String? concepto}) => Adeudo(
        id: id,
        clienteId: clienteId,
        fecha: fecha ?? this.fecha,
        monto: monto ?? this.monto,
        concepto: concepto ?? this.concepto,
        ventaOrigenId: ventaOrigenId,
      );
}
