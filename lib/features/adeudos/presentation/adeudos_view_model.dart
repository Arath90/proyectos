import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../clientes/domain/cliente.dart';
import '../../ventas/domain/abono.dart';
import '../../ventas/domain/venta_detallada.dart';
import '../../ventas/presentation/ventas_view_model.dart';
import '../domain/adeudo.dart';
import '../domain/cuenta_cliente.dart';

/// A quien quiere ver la propietaria en la lista de adeudos.
enum FiltroAdeudos {
  deben,
  todos;

  String get etiqueta => switch (this) {
        FiltroAdeudos.deben => 'Me deben',
        FiltroAdeudos.todos => 'Todos',
      };

  bool aplica(CuentaCliente cuenta) => switch (this) {
        FiltroAdeudos.deben => cuenta.debe,
        FiltroAdeudos.todos => true,
      };
}

/// Lo que pinta la pantalla de adeudos.
///
/// Arranca filtrada en "me deben" y no en "todos" porque la pantalla se abre
/// para cobrar, no para hojear el padron: quien ya quedo a mano estorba en esa
/// lista.
class AdeudosEstado {
  const AdeudosEstado({
    this.cuentas = const AsyncValue.loading(),
    this.busqueda = '',
    this.filtro = FiltroAdeudos.deben,
  });

  final AsyncValue<List<CuentaCliente>> cuentas;
  final String busqueda;
  final FiltroAdeudos filtro;

  AsyncValue<List<CuentaCliente>> get visibles =>
      cuentas.whenData((lista) => lista.where(_pasaFiltros).toList());

  bool _pasaFiltros(CuentaCliente cuenta) {
    if (!filtro.aplica(cuenta)) return false;
    final clave = claveDeNombre(busqueda);
    if (clave.isEmpty) return true;
    return cuenta.cliente.clave.contains(clave);
  }

  /// Totales de lo que se esta viendo, igual que en el listado de ventas: si
  /// la propietaria busco a alguien, el resumen habla de esa persona.
  ResumenAdeudos get resumen =>
      ResumenAdeudos.de(visibles.value ?? const <CuentaCliente>[]);

  AdeudosEstado copyWith({
    AsyncValue<List<CuentaCliente>>? cuentas,
    String? busqueda,
    FiltroAdeudos? filtro,
  }) {
    return AdeudosEstado(
      cuentas: cuentas ?? this.cuentas,
      busqueda: busqueda ?? this.busqueda,
      filtro: filtro ?? this.filtro,
    );
  }
}

/// ViewModel de la pantalla de adeudos.
///
/// Es el unico lugar del sistema que suma las dos deudas de una persona, y por
/// eso cruza dos features: los cargos vienen de adeudos y el saldo de las
/// ventas abiertas viene del listado de ventas, ya calculado por
/// `VentaDetallada`. Se cruzan aqui y no en un repositorio para que ninguno de
/// los dos features tenga que importar al otro, que es el mismo arreglo con el
/// que el inventario conoce lo apartado sin conocer las ventas.
///
/// No vuelve a decidir que es saldo ni que es adeudo: esas reglas ya viven en
/// `VentaDetallada` y `CuentaCliente`. Lo suyo es juntar las piezas.
class AdeudosViewModel extends Notifier<AdeudosEstado> {
  String _busqueda = '';
  FiltroAdeudos _filtro = FiltroAdeudos.deben;

  @override
  AdeudosEstado build() {
    final clientes = ref.watch(clientesProvider);
    final adeudos = ref.watch(adeudosPorClienteProvider);
    final pagos = ref.watch(abonosPorClienteProvider).value ?? const {};
    final ventas = ref.watch(ventasViewModelProvider).ventas.value ?? const [];

    final saldos = <String, ({int saldo, int abiertas})>{};
    for (final detalle in ventas) {
      final clienteId = detalle.venta.clienteId;
      if (clienteId == null) continue;
      if (!detalle.venta.estado.cobrable) continue;
      final previo = saldos[clienteId] ?? (saldo: 0, abiertas: 0);
      saldos[clienteId] = (
        saldo: previo.saldo + detalle.saldo,
        abiertas: previo.abiertas + (detalle.saldo > 0 ? 1 : 0),
      );
    }

    return AdeudosEstado(
      cuentas: clientes.whenData(
        (lista) => [
          for (final cliente in lista)
            CuentaCliente(
              cliente: cliente,
              adeudos: adeudos[cliente.id] ?? const [],
              pagos: pagos[cliente.id] ?? const [],
              saldoEnVentas: saldos[cliente.id]?.saldo ?? 0,
              ventasAbiertas: saldos[cliente.id]?.abiertas ?? 0,
            ),
        ]..sort(_porDeuda),
      ),
      busqueda: _busqueda,
      filtro: _filtro,
    );
  }

  /// Primero quien mas debe, y a igualdad de deuda en orden alfabetico.
  ///
  /// La lista se lee para decidir a quien perseguir esta semana, y ese es el
  /// orden en que se toma esa decision.
  static int _porDeuda(CuentaCliente a, CuentaCliente b) {
    final porMonto = b.deudaTotal.compareTo(a.deudaTotal);
    if (porMonto != 0) return porMonto;
    return a.cliente.clave.compareTo(b.cliente.clave);
  }

  void buscar(String texto) {
    _busqueda = texto;
    state = state.copyWith(busqueda: texto);
  }

  void filtrar(FiltroAdeudos filtro) {
    _filtro = filtro;
    state = state.copyWith(filtro: filtro);
  }

  // --- Cargos --------------------------------------------------------------

  /// Registra lo que alguien debe de antes.
  ///
  /// Es la captura que existe para no tener que mentirle al inventario: la
  /// mercancia de esa deuda salio de la casa hace meses y darla de alta hoy
  /// para volver a sacarla dejaria las existencias sin sentido. Aqui solo se
  /// anota el dinero.
  Future<String?> registrarAdeudo({
    required String clienteId,
    required int monto,
    String concepto = '',
    DateTime? fecha,
  }) async {
    if (monto <= 0) return 'El adeudo tiene que ser mayor que cero.';
    await ref.read(adeudosRepositoryProvider).crearAdeudo(
          clienteId: clienteId,
          monto: monto,
          concepto: concepto,
          fecha: fecha,
        );
    return null;
  }

  Future<String?> guardarAdeudo(Adeudo adeudo) async {
    if (adeudo.monto <= 0) return 'El adeudo tiene que ser mayor que cero.';
    await ref.read(adeudosRepositoryProvider).guardarAdeudo(adeudo);
    return null;
  }

  Future<void> eliminarAdeudo(Adeudo adeudo) =>
      ref.read(adeudosRepositoryProvider).eliminarAdeudo(adeudo.id);

  // --- Cobranza ------------------------------------------------------------

  /// Registra un pago que va entero contra la deuda vieja.
  ///
  /// Es el cobro sin venta enfrente: el cliente pasa a dejar algo a cuenta de
  /// lo de antes. Cuando si hay una venta abierta, el pago se captura ahi y se
  /// reparte, para que quede una sola fila por billete entregado.
  Future<String?> abonarAAdeudo({
    required String clienteId,
    required int monto,
    String nota = '',
    DateTime? fecha,
  }) async {
    if (monto <= 0) return 'El abono tiene que ser mayor que cero.';
    await ref.read(ventasRepositoryProvider).registrarAbono(
          monto: monto,
          clienteId: clienteId,
          montoAdeudo: monto,
          nota: nota,
          fecha: fecha,
        );
    return null;
  }

  /// Corrige un pago hecho contra la deuda.
  ///
  /// Solo los que no tocan ninguna venta: los repartidos se corrigen en la
  /// venta donde se capturaron, que es donde se ven las dos mitades juntas.
  Future<String?> guardarAbono(Abono abono) async {
    if (abono.monto <= 0) return 'El abono tiene que ser mayor que cero.';
    await ref.read(ventasRepositoryProvider).guardarAbono(abono);
    return null;
  }

  Future<void> eliminarAbono(Abono abono) =>
      ref.read(ventasRepositoryProvider).eliminarAbono(abono);
}

final adeudosViewModelProvider =
    NotifierProvider<AdeudosViewModel, AdeudosEstado>(AdeudosViewModel.new);

/// La cuenta de una persona, para su pantalla de detalle.
///
/// Sale del mismo calculo que la lista en vez de rehacerse, para que las dos
/// pantallas no puedan contestar cifras distintas mientras los streams se
/// ponen al dia.
final cuentaClienteProvider =
    Provider.family<CuentaCliente?, String>((ref, clienteId) {
  final cuentas = ref.watch(adeudosViewModelProvider).cuentas.value;
  if (cuentas == null) return null;
  for (final cuenta in cuentas) {
    if (cuenta.cliente.id == clienteId) return cuenta;
  }
  return null;
});

/// Las ventas de una persona, de la mas reciente a la mas antigua.
final ventasDelClienteProvider =
    Provider.family<List<VentaDetallada>, String>((ref, clienteId) {
  final ventas = ref.watch(ventasViewModelProvider).ventas.value ?? const [];
  return [
    for (final detalle in ventas)
      if (detalle.venta.clienteId == clienteId) detalle,
  ];
});
