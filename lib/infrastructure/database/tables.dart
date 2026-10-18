import 'package:drift/drift.dart';

/// Encabezado de una hoja de pedido.
///
/// La llave primaria es un UUID generado en el dispositivo, no un autoincrement:
/// cuando entre el backend, dos tablets que capturaron sin conexion deben poder
/// subir sus pedidos sin colisionar. Cambiar esto despues obligaria a migrar
/// datos reales, asi que se paga ahora aunque todavia no haya sincronizacion.
@DataClassName('PedidoRow')
class Pedidos extends Table {
  TextColumn get id => text()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get campana => text().withDefault(const Constant(''))();
  TextColumn get marcaPredeterminada =>
      text().withDefault(const Constant(''))();
  TextColumn get notas => text().withDefault(const Constant(''))();
  BoolColumn get cerrado => boolean().withDefault(const Constant(false))();

  /// Momento en que las piezas de este pedido entraron al inventario.
  ///
  /// Es la bisagra entre este flujo y `Productos`: mientras sea `null` el
  /// pedido es papel, y al surtirlo la `cantEnviada` de cada linea suma
  /// existencias. Guardar la fecha (y no un booleano) evita surtir dos veces
  /// y deja constancia de cuando llego la caja.
  DateTimeColumn get recibidoEn => dateTime().nullable()();

  DateTimeColumn get creadoEn => dateTime()();
  DateTimeColumn get actualizadoEn => dateTime()();

  /// Borrado logico. Nunca se hace DELETE fisico de un pedido: un registro que
  /// desaparece no se puede propagar a las demas tablets.
  DateTimeColumn get eliminadoEn => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Lineas capturadas de la hoja.
///
/// Los importes se guardan en centavos y los puntos en centesimas de punto,
/// siempre como enteros.
@DataClassName('LineaRow')
class LineasPedido extends Table {
  TextColumn get id => text()();
  TextColumn get pedidoId =>
      text().references(Pedidos, #id, onDelete: KeyAction.cascade)();

  /// Producto del inventario al que se le sumaran las piezas recibidas.
  ///
  /// Nullable porque una hoja se puede capturar antes de dar de alta el
  /// articulo; al recibir el pedido, esas lineas se ignoran o se enlazan por
  /// marca y codigo.
  TextColumn get productoId => text().nullable().references(Productos, #id)();

  TextColumn get marca => text().withDefault(const Constant(''))();

  /// Codigo de catalogo como texto: hay codigos con ceros a la izquierda y
  /// guardarlos como numero los perderia.
  TextColumn get codigo => text().withDefault(const Constant(''))();
  TextColumn get descripcion => text().withDefault(const Constant(''))();

  IntColumn get cantPedida => integer().withDefault(const Constant(0))();
  IntColumn get cantEnviada => integer().withDefault(const Constant(0))();

  IntColumn get valorTotalPuntos => integer().withDefault(const Constant(0))();

  /// Precio unitario de compra: lo que la propietaria le paga a la
  /// distribuidora por una pieza, en centavos.
  ///
  /// No confundir con [precioRevista], que es el precio de venta al publico
  /// que trae el catalogo. La diferencia entre los dos es el margen del
  /// negocio, y por eso los dos viven en la misma hoja.
  IntColumn get precioUnitario => integer().withDefault(const Constant(0))();

  /// Precio de revista unitario: lo que el catalogo le pide al cliente final.
  IntColumn get precioRevista => integer().withDefault(const Constant(0))();
  IntColumn get valorTotalPromocionado =>
      integer().withDefault(const Constant(0))();
  IntColumn get totalDescuentoCn => integer().withDefault(const Constant(0))();
  IntColumn get valorRegalos => integer().withDefault(const Constant(0))();

  /// Solo se guardan cuando la usuaria sobrescribe el valor calculado.
  IntColumn get valorPromSinIvaManual => integer().nullable()();
  IntColumn get tuPagasManual => integer().nullable()();

  /// Precio total de compra capturado a mano; `null` deja que se calcule como
  /// `precioUnitario * cantPedida`.
  IntColumn get precioTotalManual => integer().nullable()();

  IntColumn get orden => integer().withDefault(const Constant(0))();

  DateTimeColumn get creadoEn => dateTime()();
  DateTimeColumn get actualizadoEn => dateTime()();
  DateTimeColumn get eliminadoEn => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Catalogo de existencias de la propietaria: el inventario.
///
/// Es el centro del sistema y lo que conecta los dos flujos que lo rodean:
/// un [Pedidos] a la distribuidora *entra* piezas aqui cuando se recibe, y una
/// [Ventas] a un cliente las *saca* cuando se entrega. El producto no guarda
/// precio: el dinero de la compra vive en [LineasPedido] y el de la venta en
/// [LineasVenta], porque el mismo articulo se compra y se vende a precios que
/// cambian de campana en campana y la hoja de cada operacion debe conservar el
/// precio que se uso ese dia.
@DataClassName('ProductoRow')
class Productos extends Table {
  TextColumn get id => text()();

  TextColumn get marca => text().withDefault(const Constant(''))();

  /// Codigo de catalogo como texto, por la misma razon que en [LineasPedido]:
  /// hay codigos con ceros a la izquierda.
  TextColumn get codigo => text().withDefault(const Constant(''))();
  TextColumn get descripcion => text().withDefault(const Constant(''))();

  /// Piezas fisicamente en casa ahora mismo.
  ///
  /// Sube al recibir un pedido, baja al entregar una venta y tambien se puede
  /// corregir a mano: es un conteo real, no una cifra derivada.
  IntColumn get cantidadActual => integer().withDefault(const Constant(0))();

  /// Piezas que han entrado en total desde que se dio de alta el producto.
  ///
  /// Sirve de referencia para saber cuanto se ha desplazado; nunca baja por
  /// una venta.
  IntColumn get cantidadOriginal => integer().withDefault(const Constant(0))();

  DateTimeColumn get creadoEn => dateTime()();
  DateTimeColumn get actualizadoEn => dateTime()();

  /// Borrado logico, igual que en el resto del esquema: un producto dado de
  /// baja debe seguir existiendo porque hay lineas de venta que lo apuntan.
  DateTimeColumn get eliminadoEn => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Padron de clientes.
///
/// Nace con los adeudos. Mientras el cobro se cerraba dentro de cada venta,
/// el nombre tecleado en el encabezado bastaba: la venta se cobraba sola y
/// nadie tenia que sumar dos hojas. Un adeudo si obliga a decidir que el
/// "Tony" que debe dos mil de lo viejo y el "tony" que acaba de llevarse mil
/// pesos de producto son la misma persona, y eso no se puede resolver
/// comparando texto libre: un dedazo partiria la cuenta en dos y el abono
/// bajaria la deuda equivocada.
///
/// Por eso la propietaria elige al cliente de una lista en vez de escribirlo.
/// Lo que ya existe se elige y no se teclea, igual que un producto del
/// inventario en una linea de venta.
@DataClassName('ClienteRow')
class Clientes extends Table {
  TextColumn get id => text()();

  /// Como lo llama la propietaria. Es el nombre vivo: si aqui se corrige,
  /// se corrige en las ventas de esa persona.
  TextColumn get nombre => text().withDefault(const Constant(''))();

  /// A que numero se le marca.
  ///
  /// Se guarda como texto y no como numero por la misma razon que un codigo de
  /// catalogo: hay telefonos con lada entre parentesis, con espacios y con
  /// ceros al principio, y convertirlos a entero los deforma. Ademas nunca se
  /// suma ni se ordena por el, solo se lee y se marca.
  ///
  /// Nace separado de [notas] porque un telefono enterrado en texto libre no
  /// se puede tocar para llamar ni buscar por el; con columna propia, la venta
  /// puede mostrarlo como un boton.
  TextColumn get telefono => text().withDefault(const Constant(''))();

  /// Donde se le entrega la mercancia.
  ///
  /// Es del cliente y no de la venta a proposito: a la misma persona se le
  /// entrega siempre en el mismo lugar, y volverlo a teclear en cada venta es
  /// justo lo que produce direcciones que no coinciden entre dos hojas de la
  /// misma persona. Si algun dia una entrega va a otro lado, eso es una nota
  /// de esa venta.
  TextColumn get direccion => text().withDefault(const Constant(''))();

  /// Texto libre para lo demas que ayuda a ubicarlo: quien lo recomendo, a que
  /// horas esta, de quien es pariente.
  TextColumn get notas => text().withDefault(const Constant(''))();

  DateTimeColumn get creadoEn => dateTime()();
  DateTimeColumn get actualizadoEn => dateTime()();
  DateTimeColumn get eliminadoEn => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Separador del listado de ventas: la carpeta donde vive un grupo de ventas.
///
/// La propietaria vende en varios lugares y la lista corrida deja de servir
/// en cuanto pasan de unas pocas: no es lo mismo "cuanto me deben" que
/// "cuanto me deben en Xalisco", y esa segunda pregunta es la que se hace
/// antes de subirse al camion.
///
/// Es un solo nivel a proposito -no hay carpetas dentro de carpetas-: el
/// criterio real es el lugar, y un arbol obligaria a decidir en cual de dos
/// ramas va cada venta.
@DataClassName('CarpetaVentaRow')
class CarpetasVenta extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text().withDefault(const Constant(''))();
  TextColumn get notas => text().withDefault(const Constant(''))();

  DateTimeColumn get creadoEn => dateTime()();
  DateTimeColumn get actualizadoEn => dateTime()();

  /// Borrado logico, como todo. Al borrar una carpeta sus ventas no se van
  /// con ella: se quedan sueltas, porque la carpeta es una etiqueta y la
  /// venta es el documento.
  DateTimeColumn get eliminadoEn => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Encabezado de una venta a un cliente.
///
/// Es la contraparte de [Pedidos]: alli la propietaria le compra a la
/// distribuidora, aqui le vende a una persona. El nombre del cliente vive en
/// el encabezado y no en cada linea porque una venta es de un solo cliente;
/// al listar la tabla final la columna se repite en todos sus renglones.
///
/// El cobro casi nunca es de contado: el saldo se liquida con [Abonos] a lo
/// largo de semanas o meses, asi que la venta sigue viva despues de entregada.
@DataClassName('VentaRow')
class Ventas extends Table {
  TextColumn get id => text()();
  DateTimeColumn get fecha => dateTime()();

  /// Quien compra, del padron. Nullable porque las ventas capturadas antes de
  /// que el padron existiera no tienen a quien apuntar, y porque se permite
  /// abrir una venta sin ponerle nombre todavia.
  ///
  /// Es lo que permite que un abono sepa a que adeudo pegarle.
  TextColumn get clienteId => text().nullable().references(Clientes, #id)();

  /// El nombre tal como se lee en esta venta.
  ///
  /// Convive con [clienteId] y no lo sustituye: mientras la venta este
  /// enlazada, esta columna es una copia del nombre del padron que el
  /// repositorio refresca al renombrar, y sirve para que las ventas viejas
  /// -y las que se abrieron sin elegir cliente- sigan diciendo a quien se le
  /// vendio. Es la unica columna del sistema que se copia *y* se mantiene al
  /// dia, porque un cliente mal escrito se corrige y debe corregirse en todas
  /// partes; una descripcion de producto, en cambio, se congela.
  TextColumn get cliente => text().withDefault(const Constant(''))();

  /// Carpeta donde la propietaria guardo esta venta. `null` es "Sin carpeta",
  /// que no es una carpeta de verdad sino el monton de las que nunca se
  /// separaron.
  TextColumn get carpetaId =>
      text().nullable().references(CarpetasVenta, #id)();

  TextColumn get notas => text().withDefault(const Constant(''))();

  /// Estado del apartado: `apartada`, `entregada` o `cancelada`.
  ///
  /// Se guarda como texto y no como entero para que la base siga siendo
  /// legible si algun dia hay que revisarla a mano. El mapeo vive en
  /// `EstadoVenta`, del dominio.
  ///
  /// Mientras esta `apartada` las piezas quedan comprometidas pero siguen
  /// contadas en `cantidadActual` del producto; al pasar a `entregada` se
  /// descuentan de verdad.
  TextColumn get estado => text().withDefault(const Constant('apartada'))();

  /// Momento en que las piezas salieron del inventario. Es el seguro contra
  /// descontar dos veces: si ya tiene fecha, la entrega no se vuelve a aplicar.
  DateTimeColumn get entregadaEn => dateTime().nullable()();

  DateTimeColumn get creadoEn => dateTime()();
  DateTimeColumn get actualizadoEn => dateTime()();
  DateTimeColumn get eliminadoEn => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Renglon de una venta: un producto, su cantidad y su precio.
///
/// Copia marca, codigo y descripcion del producto en lugar de solo apuntarlo.
/// Es duplicacion deliberada: si manana se corrige la descripcion en el
/// inventario, la venta de hace tres meses debe seguir diciendo lo que decia
/// el dia que se hizo. `productoId` conserva el vinculo para mover existencias.
@DataClassName('LineaVentaRow')
class LineasVenta extends Table {
  TextColumn get id => text()();
  TextColumn get ventaId =>
      text().references(Ventas, #id, onDelete: KeyAction.cascade)();

  /// Producto del inventario del que salen las piezas.
  ///
  /// Nullable porque se permite vender algo que no estaba dado de alta (una
  /// muestra, un regalo de la distribuidora); esa linea simplemente no mueve
  /// existencias.
  TextColumn get productoId => text().nullable().references(Productos, #id)();

  TextColumn get marca => text().withDefault(const Constant(''))();
  TextColumn get codigo => text().withDefault(const Constant(''))();
  TextColumn get descripcion => text().withDefault(const Constant(''))();

  /// Piezas vendidas en este renglon.
  IntColumn get cantidad => integer().withDefault(const Constant(0))();

  /// Precio unitario cobrado al cliente, en centavos.
  IntColumn get precioUnitario => integer().withDefault(const Constant(0))();

  /// Rebaja aplicada al renglon completo, en centavos.
  IntColumn get descuento => integer().withDefault(const Constant(0))();

  IntColumn get orden => integer().withDefault(const Constant(0))();

  DateTimeColumn get creadoEn => dateTime()();
  DateTimeColumn get actualizadoEn => dateTime()();
  DateTimeColumn get eliminadoEn => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Un pago que entrega el cliente.
///
/// Existe porque el cobro se reparte: el cliente abona lo que puede cada
/// semana. El saldo nunca se guarda, se obtiene restando la suma de los
/// abonos al total de la venta, por la misma razon que `TotalesPedido` no se
/// almacena: un saldo guardado se desincroniza en cuanto se corrige un abono.
///
/// Un pago es **uno solo aunque tape dos cosas**. Cuando el cliente trae
/// quinientos pesos y arrastra un adeudo viejo, lo que ocurre en la vida real
/// es que entrego un billete, no dos pagos; por eso hay una sola fila y lo
/// que se guarda es como se repartio: [montoAdeudo] es la parte que bajo el
/// adeudo y el resto baja el saldo de la venta. Partirlo en dos filas
/// obligaria a borrar las dos para corregir un dedazo, y dejaria la puerta
/// abierta a que una sobreviva sin la otra.
@DataClassName('AbonoRow')
class Abonos extends Table {
  TextColumn get id => text()();

  /// Venta cuyo saldo baja con este pago.
  ///
  /// Nullable desde que existen los adeudos: un cliente puede venir a pagar
  /// pura deuda vieja, sin ninguna venta abierta contra la cual aplicar el
  /// pago.
  TextColumn get ventaId => text()
      .nullable()
      .references(Ventas, #id, onDelete: KeyAction.cascade)();

  /// Quien pago. Obligatorio en la practica cuando [montoAdeudo] es mayor que
  /// cero: sin cliente no habria de que adeudo descontarlo.
  TextColumn get clienteId => text().nullable().references(Clientes, #id)();

  DateTimeColumn get fecha => dateTime()();

  /// Importe total entregado por el cliente, en centavos.
  IntColumn get monto => integer().withDefault(const Constant(0))();

  /// Cuanto de [monto] se aplico al adeudo del cliente, en centavos.
  ///
  /// La diferencia (`monto - montoAdeudo`) es lo que bajo el saldo de la
  /// venta. Se guarda el reparto y no solo el total porque la propietaria lo
  /// puede mover: la propuesta es tapar primero lo viejo, pero a veces
  /// prefiere abonar a la venta del dia.
  IntColumn get montoAdeudo => integer().withDefault(const Constant(0))();

  TextColumn get nota => text().withDefault(const Constant(''))();

  DateTimeColumn get creadoEn => dateTime()();
  DateTimeColumn get actualizadoEn => dateTime()();
  DateTimeColumn get eliminadoEn => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Un cargo a la cuenta de un cliente: lo que debe y no cuelga de una venta
/// capturada.
///
/// Es la pieza que faltaba para poder cobrar lo de antes. La deuda vieja de un
/// cliente -mercancia que ya se llevo hace meses, cuando el sistema no
/// existia- no se puede meter como venta: una venta mueve inventario, y dar de
/// alta hoy productos que salieron el ano pasado dejaria las existencias
/// mintiendo justo en el numero que la propietaria usa para prometerle piezas
/// a alguien mas. Un adeudo, en cambio, es solo dinero: se captura la cantidad
/// y ya.
///
/// El otro origen es [ventaOrigenId]: una venta entregada que quedo con saldo
/// y que la propietaria decide mandar a la cuenta del cliente para dejar de
/// perseguirla venta por venta. Guardar de donde vino es lo que permite
/// deshacerlo y lo que explica, meses despues, por que ese cargo existe.
@DataClassName('AdeudoRow')
class Adeudos extends Table {
  TextColumn get id => text()();

  /// De quien es la deuda. Aqui no es nullable: un adeudo sin duenio no se le
  /// puede cobrar a nadie.
  TextColumn get clienteId => text().references(Clientes, #id)();

  DateTimeColumn get fecha => dateTime()();

  /// Que fue lo que se llevo: "productos de la campana 9", "lo de diciembre".
  TextColumn get concepto => text().withDefault(const Constant(''))();

  /// Importe del cargo, en centavos. Los pagos no se restan aqui: viven en
  /// [Abonos.montoAdeudo] y el saldo se calcula, nunca se guarda.
  IntColumn get monto => integer().withDefault(const Constant(0))();

  /// Venta cuyo saldo se traspaso a este cargo, o `null` si se capturo a mano.
  TextColumn get ventaOrigenId => text().nullable().references(Ventas, #id)();

  DateTimeColumn get creadoEn => dateTime()();
  DateTimeColumn get actualizadoEn => dateTime()();
  DateTimeColumn get eliminadoEn => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
