/// Un pago que el cliente entrega.
///
/// Existe porque el cobro casi nunca es de contado: la venta se entrega hoy y
/// se termina de pagar en semanas o meses, cien pesos a la vez. Sin esta clase
/// la unica forma de saber cuanto deben seria un campo "saldo" en la venta, y
/// ese campo se desincroniza en cuanto se corrige un pago mal capturado.
///
/// Un pago es **uno solo aunque tape dos cosas**. Cuando el cliente arrastra
/// una deuda vieja y ademas se acaba de llevar mercancia, lo que pasa en la
/// vida real es que entrega un billete, no dos pagos; lo que se guarda no son
/// dos abonos sino como se repartio este: [montoAdeudo] es la parte que bajo
/// el adeudo del cliente y [montoVenta] la que bajo el saldo de la venta.
///
/// Partirlo en dos registros obligaria a borrar los dos para corregir un
/// dedazo y dejaria la puerta abierta a que uno sobreviva sin el otro; asi,
/// corregir el monto o mover el reparto es tocar una sola fila.
class Abono {
  const Abono({
    required this.id,
    required this.fecha,
    required this.monto,
    this.ventaId,
    this.clienteId,
    this.montoAdeudo = 0,
    this.nota = '',
  });

  final String id;

  /// Venta cuyo saldo baja con este pago, o `null` cuando el cliente vino a
  /// pagar pura deuda vieja y no hay ninguna venta abierta contra la cual
  /// aplicarlo.
  final String? ventaId;

  /// Quien pago. Nunca es `null` cuando [montoAdeudo] es mayor que cero: sin
  /// cliente no habria de que adeudo descontarlo.
  final String? clienteId;

  final DateTime fecha;

  /// Importe total entregado por el cliente, en centavos.
  final int monto;

  /// La parte de [monto] que se aplico al adeudo del cliente, en centavos.
  ///
  /// El reparto se guarda y no se deduce porque la propietaria lo puede mover:
  /// la propuesta es tapar primero lo viejo, pero a veces prefiere abonar todo
  /// a la venta del dia y esa decision tiene que sobrevivir a cerrar la
  /// pantalla.
  final int montoAdeudo;

  /// Texto libre para anotar como se pago: "efectivo", "transferencia".
  final String nota;

  /// Lo que este pago le bajo al saldo de la venta.
  int get montoVenta => monto - montoAdeudo;

  /// Cierto cuando el pago tapo, aunque sea en parte, deuda vieja.
  bool get tocaAdeudo => montoAdeudo > 0;

  Abono copyWith({
    DateTime? fecha,
    int? monto,
    int? montoAdeudo,
    String? nota,
    ({String? valor})? ventaId,
    ({String? valor})? clienteId,
  }) =>
      Abono(
        id: id,
        ventaId: ventaId == null ? this.ventaId : ventaId.valor,
        clienteId: clienteId == null ? this.clienteId : clienteId.valor,
        fecha: fecha ?? this.fecha,
        monto: monto ?? this.monto,
        montoAdeudo: montoAdeudo ?? this.montoAdeudo,
        nota: nota ?? this.nota,
      );
}
