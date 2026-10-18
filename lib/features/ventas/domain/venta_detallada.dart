import 'abono.dart';
import 'linea_venta.dart';
import 'venta.dart';

/// La venta completa: encabezado, renglones y abonos en una sola pieza.
///
/// Es "la tabla final" del sistema, la vista donde por fin aparecen juntos los
/// datos de los tres features: el articulo viene del `Producto` del
/// inventario, que a su vez entro por un `Pedido` a la distribuidora, y el
/// dinero se cierra con los `Abono` que el cliente va dejando.
///
/// Ninguno de sus totales se guarda en la base. Se recalculan cada vez, por la
/// misma razon que `TotalesPedido`: un total almacenado se desincroniza en
/// cuanto se edita un renglon o se corrige un abono, y una hoja de cobro que
/// no cuadra con sus renglones no sirve para cobrar.
class VentaDetallada {
  const VentaDetallada({
    required this.venta,
    required this.lineas,
    required this.abonos,
    this.traspasado = 0,
  });

  const VentaDetallada.soloEncabezado(this.venta)
      : lineas = const [],
        abonos = const [],
        traspasado = 0;

  final Venta venta;
  final List<LineaVenta> lineas;
  final List<Abono> abonos;

  /// Cuanto de esta venta dejo de cobrarse aqui porque se paso a la cuenta de
  /// adeudos del cliente, en centavos.
  ///
  /// No es una columna de la venta: es la suma de los cargos de adeudo que
  /// nacieron de ella, y llega desde afuera igual que llegan los renglones y
  /// los abonos. Se pasa un saldo a adeudos cuando la venta ya se entrego y
  /// perseguirla hoja por hoja dejo de tener sentido; el dinero sigue
  /// debiendose, solo que ahora se cobra junto con lo demas que esa persona
  /// arrastra.
  final int traspasado;

  // --- Mercancia -----------------------------------------------------------

  /// Piezas vendidas en total.
  int get piezas => lineas.fold(0, (suma, linea) => suma + linea.cantidad);

  /// Suma de los renglones antes de rebajas, en centavos.
  int get subtotal => lineas.fold(0, (suma, linea) => suma + linea.subtotal);

  /// Rebajas concedidas al cliente, en centavos.
  int get descuento => lineas.fold(0, (suma, linea) => suma + linea.descuento);

  /// Lo que el cliente debe pagar por la venta completa, en centavos.
  ///
  /// Una venta cancelada vale cero: no se le cobra al cliente un apartado que
  /// se cayo, aunque sus renglones sigan guardados como constancia.
  int get total =>
      venta.estado.cobrable ? lineas.fold(0, (s, l) => s + l.importe) : 0;

  // --- Cobranza ------------------------------------------------------------

  /// Suma de lo que el cliente ya entrego a cuenta de *esta* venta, en
  /// centavos.
  ///
  /// De cada pago cuenta solo [Abono.montoVenta]: si el cliente dejo
  /// quinientos y trescientos taparon deuda vieja, esta venta cobro
  /// doscientos. Sumar el pago completo aqui haria que la venta se viera
  /// liquidada con dinero que se fue a otro lado.
  int get abonado => abonos.fold(0, (suma, abono) => suma + abono.montoVenta);

  /// Lo que falta por cobrar *en esta venta*, en centavos.
  ///
  /// Lo traspasado a adeudos se resta igual que un abono aunque no haya
  /// entrado un peso: dejo de deberse aqui porque se debe en la cuenta del
  /// cliente, y seguir mostrandolo como saldo de la venta lo contaria dos
  /// veces.
  ///
  /// Se recorta a cero cuando el cliente abono de mas: un saldo negativo se
  /// leeria como si la venta le debiera dinero a el, y el sobrante se aclara
  /// en la siguiente venta, no en esta.
  int get saldo {
    final resultado = total - abonado - traspasado;
    return resultado < 0 ? 0 : resultado;
  }

  /// Cierto cuando el saldo de esta venta se mando a la cuenta del cliente.
  bool get traspasadaAAdeudo => traspasado > 0;

  /// Cierto cuando ya no hay nada que cobrar porque el cliente pago.
  ///
  /// Una venta sin renglones no cuenta como liquidada: todavia no se le vendio
  /// nada al cliente. Una traspasada tampoco, aunque su saldo sea cero: nadie
  /// pago, la deuda cambio de lugar, y llamarla liquidada seria mentir en la
  /// unica columna que la propietaria usa para dejar de perseguir a alguien.
  bool get liquidada => total > 0 && saldo == 0 && !traspasadaAAdeudo;

  /// Cierto cuando el cliente entrego algo pero no todo.
  bool get pagoParcial => abonado > 0 && saldo > 0;

  /// Fraccion del total que ya no se cobra aqui, entre 0 y 1, para la barra de
  /// avance. Incluye lo traspasado porque la barra contesta "cuanto le falta a
  /// esta hoja", y a una hoja traspasada no le falta nada.
  double get avanceCobro {
    if (total <= 0) return 0;
    return ((abonado + traspasado) / total).clamp(0, 1).toDouble();
  }

  /// Fecha del ultimo pago recibido, o `null` si nunca ha abonado.
  DateTime? get ultimoAbono {
    if (abonos.isEmpty) return null;
    return abonos
        .map((abono) => abono.fecha)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  // --- Inventario ----------------------------------------------------------

  /// Cuantas piezas compromete o saco esta venta de cada producto.
  ///
  /// Es lo que el inventario necesita para calcular el apartado sin conocer la
  /// estructura de una venta: solo un mapa de producto a piezas. Las lineas
  /// sin producto no aparecen, porque no mueven existencias.
  Map<String, int> get piezasPorProducto {
    final mapa = <String, int>{};
    for (final linea in lineas) {
      if (!linea.mueveInventario) continue;
      final productoId = linea.productoId!;
      mapa[productoId] = (mapa[productoId] ?? 0) + linea.cantidad;
    }
    return mapa;
  }

  VentaDetallada copyWith({
    Venta? venta,
    List<LineaVenta>? lineas,
    List<Abono>? abonos,
    int? traspasado,
  }) {
    return VentaDetallada(
      venta: venta ?? this.venta,
      lineas: lineas ?? this.lineas,
      abonos: abonos ?? this.abonos,
      traspasado: traspasado ?? this.traspasado,
    );
  }
}

/// Resumen de un conjunto de ventas: lo que la propietaria ve arriba del
/// listado para saber como va.
///
/// Se calcula sobre las ventas ya cargadas en memoria en vez de con SQL, por
/// la misma razon que `PedidosRepository` agrupa en Dart: las reglas de
/// "cuanto se cobra" y "que cuenta como saldo" viven en [VentaDetallada], y
/// escribirlas otra vez como sumas en la consulta dejaria dos versiones de la
/// misma regla que tarde o temprano dejan de coincidir.
class ResumenVentas {
  const ResumenVentas({
    required this.ventas,
    required this.piezas,
    required this.total,
    required this.abonado,
    required this.saldo,
    required this.traspasado,
    required this.apartadas,
  });

  factory ResumenVentas.de(Iterable<VentaDetallada> detalles) {
    var conteo = 0;
    var piezas = 0;
    var total = 0;
    var abonado = 0;
    var saldo = 0;
    var traspasado = 0;
    var apartadas = 0;

    for (final detalle in detalles) {
      conteo++;
      if (!detalle.venta.estado.cobrable) continue;
      piezas += detalle.piezas;
      total += detalle.total;
      abonado += detalle.abonado;
      saldo += detalle.saldo;
      traspasado += detalle.traspasado;
      if (detalle.venta.estado.aparta) apartadas++;
    }

    return ResumenVentas(
      ventas: conteo,
      piezas: piezas,
      total: total,
      abonado: abonado,
      saldo: saldo,
      traspasado: traspasado,
      apartadas: apartadas,
    );
  }

  static const vacio = ResumenVentas(
    ventas: 0,
    piezas: 0,
    total: 0,
    abonado: 0,
    saldo: 0,
    traspasado: 0,
    apartadas: 0,
  );

  final int ventas;
  final int piezas;
  final int total;
  final int abonado;
  final int saldo;

  /// Lo que estas ventas dejaron de cobrar aqui porque paso a la cuenta de
  /// adeudos de sus clientes. Se cuenta aparte para que no parezca cobrado.
  final int traspasado;

  /// Cuantas ventas siguen apartadas sin entregar.
  final int apartadas;

  bool get hayPorCobrar => saldo > 0;

  bool get hayTraspasado => traspasado > 0;
}
