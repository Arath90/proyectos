import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/formato.dart';
import '../../adeudos/domain/adeudo.dart';
import '../../adeudos/domain/cuenta_cliente.dart';
import '../../clientes/domain/cliente.dart';
import '../../inventario/domain/existencia.dart';
import '../../inventario/presentation/inventario_view_model.dart';
import '../domain/abono.dart';
import '../domain/carpeta_venta.dart';
import '../domain/linea_venta.dart';
import '../domain/linea_venta_borrador.dart';
import '../domain/venta.dart';
import '../domain/venta_detallada.dart';
import 'ventas_view_model.dart';

/// Lo que pinta la pantalla de una venta: la tabla final del sistema.
///
/// Trae varias cosas a la vez porque la pantalla las necesita juntas: la venta
/// con todo su detalle, el inventario disponible para agregar renglones sin
/// salirse a consultar cuantas piezas quedan, las carpetas para poder moverla,
/// y -desde que existen los adeudos- cuanto arrastra de antes quien compro,
/// que es lo que decide como se propone repartir el siguiente pago.
class VentaDetalleEstado {
  const VentaDetalleEstado({
    this.detalle = const AsyncValue.loading(),
    this.existencias = const [],
    this.carpetas = const [],
    this.cliente,
    this.saldoAdeudo = 0,
    this.traspasos = const [],
  });

  /// La venta con sus renglones y sus abonos. `null` dentro del `AsyncValue`
  /// cuando la venta ya no existe: se borro desde otra pantalla.
  final AsyncValue<VentaDetallada?> detalle;

  /// El catalogo con lo disponible, para el selector de productos.
  final List<Existencia> existencias;

  /// Las carpetas a las que se puede mover esta venta.
  final List<CarpetaVenta> carpetas;

  /// La ficha de quien compro, del padron. `null` cuando la venta trae el
  /// nombre escrito a mano y no esta enlazada a nadie.
  ///
  /// Es de donde salen el telefono y la direccion que la pantalla muestra y
  /// que su formulario deja corregir. No se copian a la venta: se leen de aqui
  /// cada vez, para que corregir un numero mal apuntado lo corrija en todas
  /// las hojas de esa persona y no solo en la que se tenia abierta.
  final Cliente? cliente;

  /// Lo que el cliente de esta venta debe de antes, en centavos.
  ///
  /// Es cero cuando la venta no esta enlazada a nadie del padron, y entonces
  /// el cobro se comporta como siempre: todo el pago baja el saldo de la hoja.
  final int saldoAdeudo;

  /// Los cargos de adeudo que nacieron de esta venta.
  ///
  /// Normalmente hay uno o ninguno. Se guardan en lista y no como un solo
  /// cargo porque nada impide traspasar dos veces -entregar mas mercancia
  /// despues de haber traspasado, y volver a traspasar-, y quedarse solo con
  /// el ultimo esconderia dinero.
  final List<Adeudo> traspasos;

  VentaDetallada? get venta => detalle.value;

  /// Cierto mientras la venta se pueda seguir capturando.
  ///
  /// Una venta entregada si se puede editar -a veces el cliente regresa una
  /// pieza-, pero una cancelada no: si se va a corregir, primero se reabre.
  bool get editable => venta?.venta.estado != EstadoVenta.cancelada;

  /// Existencias que todavia se le pueden prometer a alguien, para no ofrecer
  /// en el selector algo que ya esta comprometido en otro apartado.
  List<Existencia> get disponibles =>
      existencias.where((e) => e.disponibles > 0).toList();

  /// Cierto cuando el saldo de esta venta se puede mandar a la cuenta del
  /// cliente.
  ///
  /// Pide venta entregada porque traspasar es dejar de perseguir una hoja que
  /// ya se cumplio: mientras la mercancia no salga, lo que hay es un apartado,
  /// y un apartado se cancela, no se cobra aparte.
  bool get puedeTraspasar {
    final actual = venta;
    if (actual == null) return false;
    return actual.venta.clienteId != null &&
        actual.venta.entregada &&
        actual.saldo > 0;
  }

  /// Cuanto de un pago de [monto] se propone aplicar al adeudo.
  int repartoAAdeudo(int monto) =>
      repartoPropuesto(monto: monto, saldoAdeudo: saldoAdeudo);

  VentaDetalleEstado copyWith({
    AsyncValue<VentaDetallada?>? detalle,
    List<Existencia>? existencias,
    List<CarpetaVenta>? carpetas,
    Cliente? cliente,
    int? saldoAdeudo,
    List<Adeudo>? traspasos,
  }) {
    return VentaDetalleEstado(
      detalle: detalle ?? this.detalle,
      existencias: existencias ?? this.existencias,
      carpetas: carpetas ?? this.carpetas,
      cliente: cliente ?? this.cliente,
      saldoAdeudo: saldoAdeudo ?? this.saldoAdeudo,
      traspasos: traspasos ?? this.traspasos,
    );
  }
}

/// ViewModel de una venta concreta.
///
/// Es `family` porque hay uno por venta abierta; Riverpod se encarga de
/// tirarlo cuando la pantalla se cierra.
///
/// Concentra los verbos que mueven el negocio y que la vista solo dispara:
/// capturar renglones, entregar (que es cuando el inventario baja de verdad),
/// abonar (que es cuando el saldo baja) y, desde que existen los adeudos,
/// pasar a la cuenta del cliente lo que esta hoja ya no va a cobrar. Ninguno
/// hace su trabajo aqui: los delega en los repositorios, que son quienes saben
/// coordinarlos dentro de una transaccion.
class VentaDetalleViewModel
    extends FamilyNotifier<VentaDetalleEstado, String> {
  @override
  VentaDetalleEstado build(String ventaId) {
    final estadoVentas = ref.watch(ventasViewModelProvider);
    final existencias =
        ref.watch(inventarioViewModelProvider).existencias.value ?? const [];

    final detalle = estadoVentas.ventas.whenData((lista) {
      for (final d in lista) {
        if (d.venta.id == ventaId) return d;
      }
      return null;
    });

    final clienteId = detalle.value?.venta.clienteId;

    return VentaDetalleEstado(
      detalle: detalle,
      existencias: existencias,
      carpetas: estadoVentas.carpetas,
      cliente: _fichaDe(clienteId),
      saldoAdeudo: _saldoAdeudoDe(clienteId),
      traspasos: [
        for (final adeudo in ref.watch(adeudosProvider).value ?? const [])
          if (adeudo.ventaOrigenId == ventaId) adeudo,
      ],
    );
  }

  // --- Encabezado ----------------------------------------------------------

  /// Guarda los datos del encabezado.
  ///
  /// El cliente va envuelto porque `null` es un valor con sentido -quitarle el
  /// cliente a la venta- y no "deja el que ya tenias". Elegirlo escribe a la
  /// vez el enlace al padron y el nombre copiado que la venta muestra, para
  /// que las dos columnas nunca digan cosas distintas.
  ///
  /// [telefono] y [direccion] no son de la venta aunque se capturen en su
  /// formulario: se guardan en la ficha del cliente. Se teclean aqui porque
  /// aqui es donde ella los pregunta -mientras cierra la venta y le apunta a
  /// donde le lleva la caja-, pero guardarlos en la hoja los condenaria a
  /// volver a teclearse en la siguiente venta de la misma persona, que es
  /// exactamente como acaban existiendo dos direcciones distintas del mismo
  /// cliente sin que nadie sepa cual vale.
  Future<String?> guardarEncabezado({
    ({Cliente? valor})? cliente,
    String? notas,
    DateTime? fecha,
    String? telefono,
    String? direccion,
  }) async {
    final actual = state.venta?.venta;
    if (actual == null) return null;

    var venta = actual.copyWith(notas: notas, fecha: fecha);
    if (cliente != null) {
      venta = venta.copyWith(
        clienteId: (valor: cliente.valor?.id),
        cliente: cliente.valor?.nombre ?? '',
      );
    }
    await ref.read(ventasRepositoryProvider).guardarVenta(venta);

    return _guardarContacto(
      clienteId: venta.clienteId,
      telefono: telefono,
      direccion: direccion,
    );
  }

  /// Escribe telefono y direccion en la ficha del cliente de la venta.
  ///
  /// Devuelve el aviso a mostrar cuando hay algo que guardar y no hay a quien:
  /// una venta con el nombre escrito a mano no tiene ficha donde ponerlo, y
  /// tragarse el dato en silencio seria peor que no dejarlo capturar -ella lo
  /// teclearia, lo daria por guardado y lo buscaria en vano la proxima vez.
  Future<String?> _guardarContacto({
    required String? clienteId,
    required String? telefono,
    required String? direccion,
  }) async {
    if (telefono == null && direccion == null) return null;

    final hayAlgo = (telefono ?? '').trim().isNotEmpty ||
        (direccion ?? '').trim().isNotEmpty;

    if (clienteId == null) {
      if (!hayAlgo) return null;
      return 'El telefono y la direccion se guardan en la ficha de la '
          'persona. Elige al cliente de tu lista y se guardan solos.';
    }

    final repo = ref.read(clientesRepositoryProvider);
    final ficha = await repo.obtenerCliente(clienteId);
    if (ficha == null) return null;

    final actualizada = ficha.copyWith(
      telefono: telefono,
      direccion: direccion,
    );
    if (actualizada.telefono == ficha.telefono &&
        actualizada.direccion == ficha.direccion) {
      return null;
    }
    await repo.guardarCliente(actualizada);
    return null;
  }

  /// Mueve la venta a otra carpeta. `null` la deja suelta.
  Future<void> moverACarpeta(String? carpetaId) =>
      ref.read(ventasRepositoryProvider).moverVenta(arg, carpetaId);

  /// Entrega la mercancia: aqui es donde el inventario baja de verdad.
  Future<void> entregar() =>
      ref.read(ventasRepositoryProvider).entregarVenta(arg);

  /// Cancela el apartado y devuelve al inventario lo que hubiera salido.
  Future<void> cancelar() =>
      ref.read(ventasRepositoryProvider).cancelarVenta(arg);

  /// Regresa la venta a apartada, deshaciendo una entrega o una cancelacion.
  Future<void> reabrir() => ref.read(ventasRepositoryProvider).reabrirVenta(arg);

  // --- Renglones -----------------------------------------------------------

  /// Agrega un renglon. Devuelve el mensaje a mostrar si algo no cuadra.
  ///
  /// Vender mas piezas de las disponibles no se bloquea, se avisa: la
  /// propietaria a veces vende algo que sabe que va a llegar en el proximo
  /// pedido, y el sistema no puede decidir por ella. Lo que si hace es dejar
  /// el faltante visible en `Existencia.sobrevendido`.
  Future<String?> agregarLinea(LineaVentaBorrador borrador) async {
    final invalido = _validarLinea(borrador);
    if (invalido != null) return invalido;
    await ref.read(ventasRepositoryProvider).agregarLinea(arg, borrador);
    return _avisoDeSobreventa(borrador.productoId, borrador.cantidad);
  }

  Future<String?> guardarLinea(LineaVenta linea) async {
    final invalido = _validarLinea(LineaVentaBorrador.deLinea(linea));
    if (invalido != null) return invalido;
    await ref.read(ventasRepositoryProvider).guardarLinea(linea);
    return null;
  }

  Future<void> eliminarLinea(LineaVenta linea) =>
      ref.read(ventasRepositoryProvider).eliminarLinea(linea);

  // --- Cobranza ------------------------------------------------------------

  /// Registra un pago a cuenta.
  ///
  /// [montoAdeudo] es la parte que tapa la deuda vieja del cliente; el resto
  /// baja el saldo de esta venta. Llega ya decidido desde el formulario, que
  /// propone tapar primero lo viejo y deja moverlo.
  ///
  /// Acepta abonar de mas sin quejarse -el cliente deja un billete redondo y
  /// se le debe cambio-, pero rechaza montos vacios o negativos, que siempre
  /// son un error de captura.
  Future<String?> abonar(
    int monto, {
    int montoAdeudo = 0,
    String nota = '',
    DateTime? fecha,
  }) async {
    final invalido = _validarPago(monto, montoAdeudo);
    if (invalido != null) return invalido;

    await ref.read(ventasRepositoryProvider).registrarAbono(
          monto: monto,
          ventaId: arg,
          clienteId: state.venta?.venta.clienteId,
          montoAdeudo: montoAdeudo,
          nota: nota,
          fecha: fecha,
        );
    return null;
  }

  Future<String?> guardarAbono(Abono abono) async {
    final invalido = _validarPago(abono.monto, abono.montoAdeudo);
    if (invalido != null) return invalido;
    await ref.read(ventasRepositoryProvider).guardarAbono(abono);
    return null;
  }

  Future<void> eliminarAbono(Abono abono) =>
      ref.read(ventasRepositoryProvider).eliminarAbono(abono);

  // --- Traspaso a adeudos --------------------------------------------------

  /// Manda a la cuenta del cliente lo que esta venta todavia debe.
  ///
  /// No se cobra nada ni se mueve mercancia: la deuda cambia de lugar. Se hace
  /// cuando la venta ya se entrego y seguir persiguiendola hoja por hoja dejo
  /// de tener sentido, para que el dinero se cobre junto con lo demas que esa
  /// persona arrastra.
  Future<String?> pasarSaldoAAdeudo() async {
    final detalle = state.venta;
    if (detalle == null) return null;

    final clienteId = detalle.venta.clienteId;
    if (clienteId == null) {
      return 'Elige de la lista a quien le vendiste: un adeudo se le carga a '
          'una persona, no a un nombre suelto.';
    }
    if (!detalle.venta.entregada) {
      return 'Entrega la venta antes de pasar su saldo a adeudos.';
    }
    if (detalle.saldo <= 0) return 'Esta venta ya no tiene saldo que pasar.';

    await ref.read(adeudosRepositoryProvider).crearAdeudo(
          clienteId: clienteId,
          monto: detalle.saldo,
          concepto: 'Venta del ${Formato.fecha(detalle.venta.fecha)}',
          ventaOrigenId: arg,
        );
    return null;
  }

  /// Deshace el traspaso: los cargos que nacieron de esta venta desaparecen y
  /// el saldo vuelve a aparecer aqui.
  Future<void> deshacerTraspaso() async {
    final repo = ref.read(adeudosRepositoryProvider);
    for (final adeudo in state.traspasos) {
      await repo.eliminarAdeudo(adeudo.id);
    }
  }

  // --- Apoyos --------------------------------------------------------------

  /// La ficha del padron de quien compro, para leer su telefono y su
  /// direccion sin que la pantalla tenga que ir a buscarlos por su cuenta.
  Cliente? _fichaDe(String? clienteId) {
    if (clienteId == null) return null;
    for (final cliente in ref.watch(clientesProvider).value ?? const []) {
      if (cliente.id == clienteId) return cliente;
    }
    return null;
  }

  /// Lo que el cliente debe de antes, sin contar sus ventas abiertas.
  ///
  /// Se arma una [CuentaCliente] a medias -sin saldo en ventas- porque esta
  /// pantalla ya muestra el saldo de la venta que tiene enfrente y lo unico
  /// que le falta saber es cuanto arrastra de mas atras. La suma de las dos
  /// mitades es asunto de la pantalla de adeudos.
  int _saldoAdeudoDe(String? clienteId) {
    if (clienteId == null) return 0;
    final cuenta = CuentaCliente(
      cliente: Cliente(id: clienteId, nombre: ''),
      adeudos: ref.watch(adeudosPorClienteProvider)[clienteId] ?? const [],
      pagos: ref.watch(abonosPorClienteProvider).value?[clienteId] ?? const [],
    );
    return cuenta.saldoAdeudo;
  }

  String? _validarPago(int monto, int montoAdeudo) {
    if (monto <= 0) return 'El abono tiene que ser mayor que cero.';
    if (montoAdeudo < 0) return 'La parte del adeudo no puede ser negativa.';
    if (montoAdeudo > monto) {
      return 'No puedes mandar al adeudo mas de lo que el cliente entrego.';
    }
    if (montoAdeudo > 0 && state.venta?.venta.clienteId == null) {
      return 'Elige de la lista a quien le vendiste para poder abonarle a su '
          'adeudo.';
    }
    return null;
  }

  String? _validarLinea(LineaVentaBorrador borrador) {
    if (borrador.cantidad <= 0) {
      return 'La cantidad tiene que ser al menos una pieza.';
    }
    if (borrador.codigo.trim().isEmpty && borrador.descripcion.trim().isEmpty) {
      return 'Elige un producto o captura al menos su descripcion.';
    }
    if (borrador.descuento > borrador.cantidad * borrador.precioUnitario) {
      return 'El descuento no puede ser mayor que el importe del renglon.';
    }
    return null;
  }

  /// Arma el aviso de "vendiste mas de lo que tienes", o `null` si alcanza.
  String? _avisoDeSobreventa(String? productoId, int cantidad) {
    if (productoId == null) return null;
    for (final existencia in state.existencias) {
      if (existencia.producto.id != productoId) continue;
      if (existencia.disponibles >= cantidad) return null;
      return 'Cuidado: solo hay ${existencia.disponibles} '
          'disponibles de ${existencia.producto.titulo}.';
    }
    return null;
  }
}

final ventaDetalleViewModelProvider =
    NotifierProvider.family<VentaDetalleViewModel, VentaDetalleEstado, String>(
  VentaDetalleViewModel.new,
);
