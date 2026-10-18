/// Una hoja de pedido a la distribuidora: el encabezado que agrupa las lineas.
///
/// Es la puerta de entrada de la mercancia. La propietaria le pide a la
/// distribuidora, captura la hoja tal como viene impresa (con sus puntos, su
/// descuento de consultora y sus regalos), y cuando la caja llega la *recibe*:
/// en ese momento la `cantEnviada` de cada linea se convierte en existencias
/// de un `Producto` del inventario. De ahi salen despues las `Venta` a los
/// clientes.
///
/// Por eso este pedido es lo contrario de una venta y no debe confundirse con
/// ella: aqui la propietaria compra y las piezas entran; en la venta vende y
/// las piezas salen.
class Pedido {
  const Pedido({
    required this.id,
    required this.fecha,
    this.campana = '',
    this.marcaPredeterminada = '',
    this.notas = '',
    this.cerrado = false,
    this.recibidoEn,
  });

  final String id;
  final DateTime fecha;

  /// Nombre o numero del catalogo al que pertenece el pedido.
  ///
  /// Se llama `campana` porque asi le dice la distribuidora en su hoja, pero
  /// en la interfaz se pide como "nombre del catalogo", que es como lo nombra
  /// la propietaria.
  final String campana;

  /// Marca que se propone al agregar una linea nueva. La marca real vive en
  /// cada linea, porque una hoja puede mezclar varias.
  final String marcaPredeterminada;

  final String notas;

  /// Un pedido cerrado ya se concilio contra lo recibido y no deberia editarse.
  final bool cerrado;

  /// Momento en que las piezas de este pedido entraron al inventario.
  ///
  /// Es distinto de [cerrado]: cerrado significa "ya no lo edites", recibido
  /// significa "sus piezas ya sumaron existencias". Guardar la fecha en vez de
  /// un booleano es lo que impide surtir el mismo pedido dos veces.
  final DateTime? recibidoEn;

  /// Cierto si la mercancia de este pedido ya esta en el inventario.
  bool get recibido => recibidoEn != null;

  String get titulo {
    if (campana.trim().isNotEmpty) return campana.trim();
    if (marcaPredeterminada.trim().isNotEmpty) return marcaPredeterminada.trim();
    return 'Pedido sin catalogo';
  }

  Pedido copyWith({
    DateTime? fecha,
    String? campana,
    String? marcaPredeterminada,
    String? notas,
    bool? cerrado,
    // Envuelto porque `null` significa "todavia no llega", que es un valor con
    // sentido propio y no "deja el que ya tenias".
    ({DateTime? valor})? recibidoEn,
  }) {
    return Pedido(
      id: id,
      fecha: fecha ?? this.fecha,
      campana: campana ?? this.campana,
      marcaPredeterminada: marcaPredeterminada ?? this.marcaPredeterminada,
      notas: notas ?? this.notas,
      cerrado: cerrado ?? this.cerrado,
      recibidoEn: recibidoEn == null ? this.recibidoEn : recibidoEn.valor,
    );
  }
}
