import '../../ventas/domain/venta_detallada.dart';
import 'hoja_calculo.dart';

/// Arma el reporte de ventas a clientes.
///
/// Salen tres pestanas porque el negocio tiene tres preguntas distintas y
/// mezclarlas en una sola tabla no deja contestar ninguna. `Ventas` es una
/// fila por cliente y contesta "cuanto vendi y quien me debe". `Renglones`
/// aplana a un articulo por fila y contesta "que se esta vendiendo".
/// `Abonos` es el corte de caja: cada pago que entro, con su fecha.
///
/// Los importes de cada fila salen de [VentaDetallada], que es donde vive la
/// regla de que una venta cancelada vale cero y de que un saldo nunca es
/// negativo. El reporte no vuelve a decidir nada de eso.
LibroReporte armarReporteVentas({
  required List<VentaDetallada> ventas,
  required DateTime generadoEn,
  Map<String, String> carpetas = const {},
}) {
  return LibroReporte(
    nombre: 'Ventas',
    generadoEn: generadoEn,
    hojas: [
      _hojaVentas(ventas, carpetas),
      _hojaRenglones(ventas),
      _hojaAbonos(ventas),
    ],
  );
}

/// Como se llama la carpeta de una venta en el archivo.
///
/// Las ventas sueltas no salen con la celda vacia sino con la misma etiqueta
/// que usa la pantalla: en una hoja de calculo un hueco se lee como "falta el
/// dato", y aqui no falta nada, estan sin separar.
String _carpetaDe(VentaDetallada detalle, Map<String, String> carpetas) {
  final id = detalle.venta.carpetaId;
  if (id == null) return 'Sin carpeta';
  return carpetas[id] ?? 'Sin carpeta';
}

Hoja _hojaVentas(List<VentaDetallada> ventas, Map<String, String> carpetas) {
  final columnas = <Columna>[
    const Columna('Fecha', ancho: Columna.anchoFecha),
    const Columna('Carpeta'),
    const Columna('Cliente', ancho: Columna.anchoTexto),
    const Columna('Estado'),
    const Columna('Renglones', ancho: Columna.anchoConteo),
    const Columna('Piezas', ancho: Columna.anchoConteo),
    const Columna('Subtotal'),
    const Columna('Descuento'),
    const Columna('Total'),
    const Columna('Abonado'),
    // Sin esta columna el archivo no cuadra: una venta traspasada tiene saldo
    // cero sin que nadie le haya pagado, y quien sume total menos abonado
    // pensaria que la hoja miente.
    const Columna('Pasado a adeudos'),
    const Columna('Saldo'),
    const Columna('Liquidada', ancho: Columna.anchoConteo),
    const Columna('Entregada el', ancho: Columna.anchoFecha),
    const Columna('Ultimo abono', ancho: Columna.anchoFecha),
    const Columna('Notas', ancho: Columna.anchoTexto),
  ];

  final filas = <List<Celda>>[];
  for (final detalle in ventas) {
    final venta = detalle.venta;
    filas.add([
      Celda.fecha(venta.fecha),
      Celda.texto(_carpetaDe(detalle, carpetas)),
      Celda.texto(venta.cliente),
      Celda.texto(venta.estado.etiqueta),
      Celda.entero(detalle.lineas.length),
      Celda.entero(detalle.piezas),
      Celda.dinero(detalle.subtotal),
      Celda.dinero(detalle.descuento),
      Celda.dinero(detalle.total),
      Celda.dinero(detalle.abonado),
      Celda.dinero(detalle.traspasado),
      Celda.dinero(detalle.saldo),
      Celda.siNo(detalle.liquidada),
      Celda.fecha(venta.entregadaEn),
      Celda.fecha(detalle.ultimoAbono),
      Celda.texto(venta.notas),
    ]);
  }

  final resumen = ResumenVentas.de(ventas);

  // Subtotal y descuento no viven en `ResumenVentas` porque la pantalla no los
  // muestra. Se suman aqui con el mismo criterio que usa ese resumen -lo
  // cancelado no cuenta- para que la fila de totales no se contradiga a si
  // misma: un subtotal que incluyera lo cancelado no cuadraria con su total.
  var subtotal = 0;
  var descuento = 0;
  for (final detalle in ventas) {
    if (!detalle.venta.estado.cobrable) continue;
    subtotal += detalle.subtotal;
    descuento += detalle.descuento;
  }

  return Hoja(
    nombre: 'Ventas',
    columnas: columnas,
    filas: filas,
    totales: [
      const Celda.texto('TOTAL'),
      Celda.texto('${resumen.ventas} ventas'),
      Celda.texto('${resumen.apartadas} apartadas'),
      Celda.vacia,
      Celda.vacia,
      Celda.entero(resumen.piezas),
      Celda.dinero(subtotal),
      Celda.dinero(descuento),
      Celda.dinero(resumen.total),
      Celda.dinero(resumen.abonado),
      Celda.dinero(resumen.traspasado),
      Celda.dinero(resumen.saldo),
      Celda.vacia,
      Celda.vacia,
      Celda.vacia,
      Celda.vacia,
    ],
  );
}

Hoja _hojaRenglones(List<VentaDetallada> ventas) {
  final columnas = <Columna>[
    const Columna('Fecha', ancho: Columna.anchoFecha),
    const Columna('Cliente', ancho: Columna.anchoTexto),
    const Columna('Estado'),
    const Columna('Marca'),
    const Columna('Codigo'),
    const Columna('Descripcion', ancho: Columna.anchoTexto),
    const Columna('Cantidad', ancho: Columna.anchoConteo),
    const Columna('Precio unitario'),
    const Columna('Subtotal'),
    const Columna('Descuento'),
    const Columna('Importe'),
    const Columna('Del inventario', ancho: Columna.anchoConteo),
  ];

  final filas = <List<Celda>>[];
  var piezas = 0;
  var subtotal = 0;
  var descuento = 0;
  var importe = 0;

  for (final detalle in ventas) {
    final venta = detalle.venta;
    final lineas = [...detalle.lineas]
      ..sort((a, b) => a.orden.compareTo(b.orden));
    for (final linea in lineas) {
      filas.add([
        Celda.fecha(venta.fecha),
        Celda.texto(venta.cliente),
        Celda.texto(venta.estado.etiqueta),
        Celda.texto(linea.marca),
        Celda.texto(linea.codigo),
        Celda.texto(linea.descripcion),
        Celda.entero(linea.cantidad),
        Celda.dinero(linea.precioUnitario),
        Celda.dinero(linea.subtotal),
        Celda.dinero(linea.descuento),
        Celda.dinero(linea.importe),
        // Un renglon capturado a mano cobra pero no descuenta existencias.
        // Verlo en el archivo es lo que explica que el inventario y las ventas
        // no cuadren pieza por pieza.
        Celda.siNo(linea.productoId != null),
      ]);
      // Aqui si cuentan los renglones de una venta cancelada: esta hoja dice
      // que se capturo, no que se cobro, y esconderlos dejaria filas visibles
      // que no suman a nada.
      piezas += linea.cantidad;
      subtotal += linea.subtotal;
      descuento += linea.descuento;
      importe += linea.importe;
    }
  }

  return Hoja(
    nombre: 'Renglones',
    columnas: columnas,
    filas: filas,
    totales: [
      const Celda.texto('TOTAL'),
      Celda.vacia,
      Celda.vacia,
      Celda.vacia,
      Celda.vacia,
      Celda.texto('${filas.length} renglones'),
      Celda.entero(piezas),
      Celda.vacia,
      Celda.dinero(subtotal),
      Celda.dinero(descuento),
      Celda.dinero(importe),
      Celda.vacia,
    ],
  );
}

Hoja _hojaAbonos(List<VentaDetallada> ventas) {
  final columnas = <Columna>[
    const Columna('Fecha', ancho: Columna.anchoFecha),
    const Columna('Cliente', ancho: Columna.anchoTexto),
    const Columna('Monto'),
    // Un pago puede haber tapado deuda vieja ademas de esta venta. Se separan
    // las dos mitades para que el corte de caja siga sumando lo que entro y
    // ademas se vea a donde se fue.
    const Columna('A esta venta'),
    const Columna('A su adeudo'),
    const Columna('Saldo de la venta'),
    const Columna('Nota', ancho: Columna.anchoTexto),
  ];

  final filas = <List<Celda>>[];
  var cobrado = 0;
  var aVentas = 0;
  var aAdeudos = 0;

  // Ordenados por fecha y no por venta: esta hoja se lee como un corte de
  // caja, y lo que se quiere ver es que entro cada dia, venga de quien venga.
  final pagos = <({
    DateTime fecha,
    String cliente,
    int monto,
    int aVenta,
    int aAdeudo,
    String nota,
    int saldo,
  })>[];
  for (final detalle in ventas) {
    for (final abono in detalle.abonos) {
      pagos.add((
        fecha: abono.fecha,
        cliente: detalle.venta.cliente,
        monto: abono.monto,
        aVenta: abono.montoVenta,
        aAdeudo: abono.montoAdeudo,
        nota: abono.nota,
        saldo: detalle.saldo,
      ));
    }
  }
  pagos.sort((a, b) => a.fecha.compareTo(b.fecha));

  for (final pago in pagos) {
    filas.add([
      Celda.fecha(pago.fecha),
      Celda.texto(pago.cliente),
      Celda.dinero(pago.monto),
      Celda.dinero(pago.aVenta),
      Celda.dinero(pago.aAdeudo),
      Celda.dinero(pago.saldo),
      Celda.texto(pago.nota),
    ]);
    cobrado += pago.monto;
    aVentas += pago.aVenta;
    aAdeudos += pago.aAdeudo;
  }

  return Hoja(
    nombre: 'Abonos',
    columnas: columnas,
    filas: filas,
    totales: [
      const Celda.texto('TOTAL'),
      Celda.texto('${filas.length} abonos'),
      Celda.dinero(cobrado),
      Celda.dinero(aVentas),
      Celda.dinero(aAdeudos),
      Celda.vacia,
      Celda.vacia,
    ],
  );
}
