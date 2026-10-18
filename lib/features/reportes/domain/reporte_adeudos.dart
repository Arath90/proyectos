import '../../adeudos/domain/cuenta_cliente.dart';
import 'hoja_calculo.dart';

/// Arma el reporte de adeudos: quien debe y de donde viene esa deuda.
///
/// Salen tres pestanas porque son tres preguntas distintas. `Adeudos` es una
/// fila por persona y contesta "a quien tengo que ir a cobrar". `Cargos`
/// desglosa de que es cada deuda, incluyendo cuales nacieron de una venta que
/// se traspaso. `Pagos` es el corte de lo que ya se cobro contra deuda vieja.
///
/// Las cifras salen de [CuentaCliente], que es donde vive la regla de que la
/// deuda de una persona son dos mitades -lo de antes y lo de sus ventas
/// abiertas- y que ninguna de las dos puede ser negativa. El reporte no vuelve
/// a decidir nada de eso.
LibroReporte armarReporteAdeudos({
  required List<CuentaCliente> cuentas,
  required DateTime generadoEn,
}) {
  return LibroReporte(
    nombre: 'Adeudos',
    generadoEn: generadoEn,
    hojas: [_hojaCuentas(cuentas), _hojaCargos(cuentas), _hojaPagos(cuentas)],
  );
}

Hoja _hojaCuentas(List<CuentaCliente> cuentas) {
  final columnas = <Columna>[
    const Columna('Cliente', ancho: Columna.anchoTexto),
    const Columna('Deuda anterior'),
    const Columna('Saldo en ventas'),
    const Columna('Deuda total'),
    const Columna('Cargado'),
    const Columna('Pagado a la deuda'),
    const Columna('Ventas abiertas', ancho: Columna.anchoConteo),
    const Columna('Ultimo pago', ancho: Columna.anchoFecha),
    const Columna('Notas', ancho: Columna.anchoTexto),
  ];

  final filas = <List<Celda>>[];
  var cargado = 0;
  var pagado = 0;
  var abiertas = 0;

  for (final cuenta in cuentas) {
    filas.add([
      Celda.texto(cuenta.cliente.titulo),
      Celda.dinero(cuenta.saldoAdeudo),
      Celda.dinero(cuenta.saldoEnVentas),
      Celda.dinero(cuenta.deudaTotal),
      Celda.dinero(cuenta.cargado),
      Celda.dinero(cuenta.pagado),
      Celda.entero(cuenta.ventasAbiertas),
      Celda.fecha(cuenta.ultimoPago),
      Celda.texto(cuenta.cliente.notas),
    ]);
    cargado += cuenta.cargado;
    pagado += cuenta.pagado;
    abiertas += cuenta.ventasAbiertas;
  }

  final resumen = ResumenAdeudos.de(cuentas);

  return Hoja(
    nombre: 'Adeudos',
    columnas: columnas,
    filas: filas,
    totales: [
      Celda.texto('TOTAL de ${resumen.clientes} clientes'),
      Celda.dinero(resumen.adeudo),
      Celda.dinero(resumen.enVentas),
      Celda.dinero(resumen.total),
      Celda.dinero(cargado),
      Celda.dinero(pagado),
      Celda.entero(abiertas),
      Celda.vacia,
      Celda.texto('${resumen.deudores} deben'),
    ],
  );
}

Hoja _hojaCargos(List<CuentaCliente> cuentas) {
  final columnas = <Columna>[
    const Columna('Fecha', ancho: Columna.anchoFecha),
    const Columna('Cliente', ancho: Columna.anchoTexto),
    const Columna('Concepto', ancho: Columna.anchoTexto),
    const Columna('Monto'),
    // Distinguirlos importa: un cargo traspasado ya aparece tambien en el
    // reporte de ventas, y sin esta columna alguien sumaria los dos archivos y
    // contaria ese dinero dos veces.
    const Columna('De una venta', ancho: Columna.anchoConteo),
  ];

  final filas = <List<Celda>>[];
  var monto = 0;

  final cargos = <({DateTime fecha, String cliente, String concepto, int monto, bool deVenta})>[];
  for (final cuenta in cuentas) {
    for (final adeudo in cuenta.adeudos) {
      cargos.add((
        fecha: adeudo.fecha,
        cliente: cuenta.cliente.titulo,
        concepto: adeudo.titulo,
        monto: adeudo.monto,
        deVenta: adeudo.vieneDeVenta,
      ));
    }
  }
  cargos.sort((a, b) => a.fecha.compareTo(b.fecha));

  for (final cargo in cargos) {
    filas.add([
      Celda.fecha(cargo.fecha),
      Celda.texto(cargo.cliente),
      Celda.texto(cargo.concepto),
      Celda.dinero(cargo.monto),
      Celda.siNo(cargo.deVenta),
    ]);
    monto += cargo.monto;
  }

  return Hoja(
    nombre: 'Cargos',
    columnas: columnas,
    filas: filas,
    totales: [
      const Celda.texto('TOTAL'),
      Celda.texto('${filas.length} cargos'),
      Celda.vacia,
      Celda.dinero(monto),
      Celda.vacia,
    ],
  );
}

Hoja _hojaPagos(List<CuentaCliente> cuentas) {
  final columnas = <Columna>[
    const Columna('Fecha', ancho: Columna.anchoFecha),
    const Columna('Cliente', ancho: Columna.anchoTexto),
    const Columna('A la deuda'),
    // El pago completo, para que se vea cuando parte del dinero se fue a bajar
    // una venta: son la misma entrega y aqui solo se cuenta una mitad.
    const Columna('Pago completo'),
    const Columna('Nota', ancho: Columna.anchoTexto),
  ];

  final filas = <List<Celda>>[];
  var aLaDeuda = 0;

  final pagos = <({DateTime fecha, String cliente, int adeudo, int total, String nota})>[];
  for (final cuenta in cuentas) {
    for (final pago in cuenta.pagos) {
      if (!pago.tocaAdeudo) continue;
      pagos.add((
        fecha: pago.fecha,
        cliente: cuenta.cliente.titulo,
        adeudo: pago.montoAdeudo,
        total: pago.monto,
        nota: pago.nota,
      ));
    }
  }
  pagos.sort((a, b) => a.fecha.compareTo(b.fecha));

  for (final pago in pagos) {
    filas.add([
      Celda.fecha(pago.fecha),
      Celda.texto(pago.cliente),
      Celda.dinero(pago.adeudo),
      Celda.dinero(pago.total),
      Celda.texto(pago.nota),
    ]);
    aLaDeuda += pago.adeudo;
  }

  return Hoja(
    nombre: 'Pagos',
    columnas: columnas,
    filas: filas,
    totales: [
      const Celda.texto('TOTAL'),
      Celda.texto('${filas.length} pagos'),
      Celda.dinero(aLaDeuda),
      Celda.vacia,
      Celda.vacia,
    ],
  );
}
