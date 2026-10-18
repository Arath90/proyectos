import '../../pedidos/domain/linea_pedido.dart';
import '../../pedidos/domain/pedido.dart';
import '../../pedidos/domain/totales_pedido.dart';
import 'hoja_calculo.dart';

/// Un pedido con sus lineas, que es lo minimo para poder reportarlo.
///
/// Se declara aqui como un alias y no se reusa `PedidoDetallado` porque aquel
/// vive en la capa de presentacion y este archivo es dominio: el reporte no
/// puede depender de una pantalla.
typedef PedidoConLineas = ({Pedido pedido, List<LineaPedido> lineas});

/// Arma el reporte de pedidos a la distribuidora.
///
/// Ambas pestanas traen el costo de compra junto al promocionado: son las dos
/// caras del mismo renglon -lo que costo la caja y lo que vale su contenido- y
/// separarlas obligaria a cruzar dos archivos para sacar el margen.
///
/// Salen dos pestanas de los mismos datos porque contestan dos preguntas
/// distintas. `Pedidos` es una hoja por caja recibida y sirve para revisar el
/// gasto del mes de un vistazo. `Renglones` aplana todo a un articulo por
/// fila, que es lo que se puede filtrar y ordenar en Excel cuando la pregunta
/// es por producto y no por hoja -que tanto se pidio de una marca, donde
/// vinieron los faltantes-.
///
/// Los totales se copian de [TotalesPedido] en vez de sumarse aqui otra vez:
/// la regla de cuanto suma un pedido ya existe y tener dos versiones garantiza
/// que un dia dejen de coincidir.
LibroReporte armarReportePedidos({
  required List<PedidoConLineas> pedidos,
  required DateTime generadoEn,
}) {
  return LibroReporte(
    nombre: 'Pedidos',
    generadoEn: generadoEn,
    hojas: [_hojaPedidos(pedidos), _hojaRenglones(pedidos)],
  );
}

Hoja _hojaPedidos(List<PedidoConLineas> pedidos) {
  final columnas = <Columna>[
    const Columna('Fecha', ancho: Columna.anchoFecha),
    const Columna('Catalogo', ancho: Columna.anchoTexto),
    const Columna('Marca'),
    const Columna('Renglones', ancho: Columna.anchoConteo),
    const Columna('Pedidas', ancho: Columna.anchoConteo),
    const Columna('Enviadas', ancho: Columna.anchoConteo),
    const Columna('Faltantes', ancho: Columna.anchoConteo),
    const Columna('Puntos'),
    const Columna('Costo de compra'),
    const Columna('Promocionado'),
    const Columna('Sin IVA'),
    const Columna('IVA'),
    const Columna('Descuento CN'),
    const Columna('Regalos'),
    const Columna('Tu pagas'),
    const Columna('Recibido', ancho: Columna.anchoConteo),
    const Columna('Recibido el', ancho: Columna.anchoFecha),
    const Columna('Notas', ancho: Columna.anchoTexto),
  ];

  final filas = <List<Celda>>[];
  for (final entrada in pedidos) {
    final pedido = entrada.pedido;
    final totales = TotalesPedido.de(entrada.lineas);
    filas.add([
      Celda.fecha(pedido.fecha),
      Celda.texto(pedido.campana),
      Celda.texto(pedido.marcaPredeterminada),
      Celda.entero(totales.lineas),
      Celda.entero(totales.cantPedida),
      Celda.entero(totales.cantEnviada),
      Celda.entero(totales.faltantes),
      Celda.puntos(totales.valorTotalPuntos),
      Celda.dinero(totales.precioTotal),
      Celda.dinero(totales.valorTotalPromocionado),
      Celda.dinero(totales.valorPromSinIva),
      Celda.dinero(totales.iva),
      Celda.dinero(totales.totalDescuentoCn),
      Celda.dinero(totales.valorRegalos),
      Celda.dinero(totales.tuPagas),
      Celda.siNo(pedido.recibido),
      Celda.fecha(pedido.recibidoEn),
      Celda.texto(pedido.notas),
    ]);
  }

  final granTotal =
      TotalesPedido.de(pedidos.expand((entrada) => entrada.lineas));

  return Hoja(
    nombre: 'Pedidos',
    columnas: columnas,
    filas: filas,
    totales: [
      const Celda.texto('TOTAL'),
      Celda.texto('${pedidos.length} pedidos'),
      Celda.vacia,
      Celda.entero(granTotal.lineas),
      Celda.entero(granTotal.cantPedida),
      Celda.entero(granTotal.cantEnviada),
      Celda.entero(granTotal.faltantes),
      Celda.puntos(granTotal.valorTotalPuntos),
      Celda.dinero(granTotal.precioTotal),
      Celda.dinero(granTotal.valorTotalPromocionado),
      Celda.dinero(granTotal.valorPromSinIva),
      Celda.dinero(granTotal.iva),
      Celda.dinero(granTotal.totalDescuentoCn),
      Celda.dinero(granTotal.valorRegalos),
      Celda.dinero(granTotal.tuPagas),
      Celda.vacia,
      Celda.vacia,
      Celda.vacia,
    ],
  );
}

Hoja _hojaRenglones(List<PedidoConLineas> pedidos) {
  final columnas = <Columna>[
    const Columna('Fecha', ancho: Columna.anchoFecha),
    const Columna('Catalogo', ancho: Columna.anchoTexto),
    const Columna('Marca'),
    const Columna('Codigo'),
    const Columna('Descripcion', ancho: Columna.anchoTexto),
    const Columna('Pedidas', ancho: Columna.anchoConteo),
    const Columna('Enviadas', ancho: Columna.anchoConteo),
    const Columna('Faltantes', ancho: Columna.anchoConteo),
    const Columna('Puntos'),
    const Columna('Precio unitario'),
    const Columna('Precio total'),
    const Columna('Precio revista'),
    const Columna('Promocionado'),
    const Columna('Sin IVA'),
    const Columna('IVA'),
    const Columna('Descuento CN'),
    const Columna('Regalos'),
    const Columna('Tu pagas'),
    const Columna('Ajuste manual', ancho: Columna.anchoConteo),
  ];

  final filas = <List<Celda>>[];
  for (final entrada in pedidos) {
    final pedido = entrada.pedido;
    // Se respeta el orden de captura, que es el orden de la hoja impresa: asi
    // el archivo se puede leer contra el papel renglon por renglon.
    final lineas = [...entrada.lineas]
      ..sort((a, b) => a.orden.compareTo(b.orden));
    for (final linea in lineas) {
      filas.add([
        Celda.fecha(pedido.fecha),
        Celda.texto(pedido.campana),
        Celda.texto(linea.marca),
        Celda.texto(linea.codigo),
        Celda.texto(linea.descripcion),
        Celda.entero(linea.cantPedida),
        Celda.entero(linea.cantEnviada),
        Celda.entero(linea.faltantes),
        Celda.puntos(linea.valorTotalPuntos),
        Celda.dinero(linea.precioUnitario),
        Celda.dinero(linea.precioTotal),
        Celda.dinero(linea.precioRevista),
        Celda.dinero(linea.valorTotalPromocionado),
        Celda.dinero(linea.valorPromSinIva),
        Celda.dinero(linea.iva),
        Celda.dinero(linea.totalDescuentoCn),
        Celda.dinero(linea.valorRegalos),
        Celda.dinero(linea.tuPagas),
        Celda.siNo(linea.tieneAjusteManual),
      ]);
    }
  }

  final totales =
      TotalesPedido.de(pedidos.expand((entrada) => entrada.lineas));

  return Hoja(
    nombre: 'Renglones',
    columnas: columnas,
    filas: filas,
    totales: [
      const Celda.texto('TOTAL'),
      Celda.vacia,
      Celda.vacia,
      Celda.vacia,
      Celda.texto('${totales.lineas} renglones'),
      Celda.entero(totales.cantPedida),
      Celda.entero(totales.cantEnviada),
      Celda.entero(totales.faltantes),
      Celda.puntos(totales.valorTotalPuntos),
      // El precio unitario y el de revista son por pieza: sumarlos entre
      // renglones distintos no significaria nada.
      Celda.vacia,
      Celda.dinero(totales.precioTotal),
      Celda.vacia,
      Celda.dinero(totales.valorTotalPromocionado),
      Celda.dinero(totales.valorPromSinIva),
      Celda.dinero(totales.iva),
      Celda.dinero(totales.totalDescuentoCn),
      Celda.dinero(totales.valorRegalos),
      Celda.dinero(totales.tuPagas),
      Celda.vacia,
    ],
  );
}
