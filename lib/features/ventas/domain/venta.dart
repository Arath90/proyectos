/// En que punto del apartado esta una venta.
///
/// El estado es lo que decide si las piezas ya salieron del inventario o solo
/// estan comprometidas, asi que no es una etiqueta decorativa: `VentasRepository`
/// lo usa para saber cuando llamar a `InventarioRepository.registrarSalida`.
enum EstadoVenta {
  /// El cliente aparto: las piezas siguen contadas en `cantidadActual` del
  /// producto, pero ya no se le pueden prometer a nadie mas.
  apartada,

  /// El cliente ya se llevo la mercancia; las piezas salieron del inventario.
  /// Puede seguir debiendo dinero: entregar y pagar son cosas distintas.
  entregada,

  /// El apartado se cayo. No compromete existencias ni cobra saldo.
  cancelada;

  /// Reconstruye el estado desde el texto guardado en la columna `estado`.
  ///
  /// Un valor desconocido cae en [apartada] en vez de reventar: si una version
  /// futura agrega un estado y la usuaria abre la base con una version vieja,
  /// es preferible una venta mal etiquetada que una aplicacion que no arranca.
  static EstadoVenta desdeTexto(String texto) {
    return EstadoVenta.values.firstWhere(
      (estado) => estado.name == texto,
      orElse: () => EstadoVenta.apartada,
    );
  }

  String get etiqueta => switch (this) {
        EstadoVenta.apartada => 'Apartada',
        EstadoVenta.entregada => 'Entregada',
        EstadoVenta.cancelada => 'Cancelada',
      };

  /// Cierto si la venta todavia reserva piezas sin haberlas sacado.
  bool get aparta => this == EstadoVenta.apartada;

  /// Cierto si la venta cuenta para el dinero por cobrar.
  bool get cobrable => this != EstadoVenta.cancelada;
}

/// Encabezado de una venta a un cliente: la contraparte de `Pedido`.
///
/// En `Pedido` la propietaria le compra a la distribuidora y las piezas
/// *entran* al inventario; aqui le vende a una persona y las piezas *salen*.
/// Las dos hojas viven en el mismo sistema porque las une el mismo catalogo
/// de `Producto`.
///
/// El cliente vive en el encabezado y no en cada renglon porque una venta es
/// de una sola persona; al aplanar la tabla final la columna se repite en
/// todos los renglones de la venta. Y esta aqui, y no solo en la memoria de la
/// propietaria, porque el cobro es a plazos: sin nombre no hay a quien
/// cobrarle los `Abono` que faltan.
class Venta {
  const Venta({
    required this.id,
    required this.fecha,
    this.clienteId,
    this.cliente = '',
    this.carpetaId,
    this.notas = '',
    this.estado = EstadoVenta.apartada,
    this.entregadaEn,
  });

  final String id;
  final DateTime fecha;

  /// Quien compra, del padron de clientes. `null` en las ventas capturadas
  /// antes de que el padron existiera y en las que se abrieron sin elegir a
  /// nadie todavia.
  ///
  /// Es lo que permite que un abono sepa de que adeudo descontar: sin este
  /// enlace, la deuda vieja de una persona y su venta de hoy son dos cuentas
  /// que nadie puede sumar.
  final String? clienteId;

  /// Nombre con el que la propietaria identifica a quien compra.
  ///
  /// Convive con [clienteId] en vez de desaparecer: es lo que se lee, lo que
  /// se busca y lo que se exporta, y sigue teniendo algo que decir cuando la
  /// venta no esta enlazada a nadie. Mientras si lo este, el repositorio la
  /// mantiene igual al nombre del padron, para que corregir un nombre lo
  /// corrija en todas partes.
  final String cliente;

  /// Carpeta donde esta guardada. `null` es "Sin carpeta".
  final String? carpetaId;

  final String notas;

  final EstadoVenta estado;

  /// Cuando salieron las piezas del inventario. `null` mientras no se entregue.
  ///
  /// Es el seguro contra descontar dos veces: el repositorio solo aplica la
  /// salida si este campo esta vacio.
  final DateTime? entregadaEn;

  bool get entregada => entregadaEn != null;

  String get titulo =>
      cliente.trim().isEmpty ? 'Venta sin cliente' : cliente.trim();

  Venta copyWith({
    DateTime? fecha,
    String? cliente,
    String? notas,
    EstadoVenta? estado,
    // Los tres envueltos por la misma razon: `null` es un valor con sentido
    // -sin cliente, sin carpeta, sin entregar- y no "deja el que ya tenias".
    ({String? valor})? clienteId,
    ({String? valor})? carpetaId,
    ({DateTime? valor})? entregadaEn,
  }) {
    return Venta(
      id: id,
      fecha: fecha ?? this.fecha,
      clienteId: clienteId == null ? this.clienteId : clienteId.valor,
      cliente: cliente ?? this.cliente,
      carpetaId: carpetaId == null ? this.carpetaId : carpetaId.valor,
      notas: notas ?? this.notas,
      estado: estado ?? this.estado,
      entregadaEn:
          entregadaEn == null ? this.entregadaEn : entregadaEn.valor,
    );
  }
}
