import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../inventario/domain/existencia.dart';
import '../../inventario/presentation/inventario_view_model.dart';
import '../domain/linea_borrador.dart';
import '../domain/linea_pedido.dart';
import 'pedidos_view_model.dart';

/// Lo que pinta la pantalla de un pedido: la hoja tal como viene de la
/// distribuidora, con todas sus columnas.
class PedidoDetalleEstado {
  const PedidoDetalleEstado({
    this.detalle = const AsyncValue.loading(),
    this.existencias = const [],
  });

  /// El pedido con sus lineas. `null` dentro del `AsyncValue` si ya se borro.
  final AsyncValue<PedidoDetallado?> detalle;

  /// El catalogo, para poder resurtir eligiendo de lo que ya se maneja en vez
  /// de volver a teclear marca, codigo y descripcion.
  final List<Existencia> existencias;

  PedidoDetallado? get pedido => detalle.value;

  /// Un pedido ya recibido no se edita: sus piezas ya entraron al inventario y
  /// cambiar una `cantEnviada` despues dejaria la existencia mintiendo.
  bool get editable => pedido != null && !pedido!.pedido.recibido;

  PedidoDetalleEstado copyWith({
    AsyncValue<PedidoDetallado?>? detalle,
    List<Existencia>? existencias,
  }) {
    return PedidoDetalleEstado(
      detalle: detalle ?? this.detalle,
      existencias: existencias ?? this.existencias,
    );
  }
}

/// ViewModel de un pedido concreto a la distribuidora.
///
/// Maneja la captura de la hoja -que es el CRUD de la tabla original, con sus
/// puntos, su descuento de consultora y sus regalos- y el momento en que esa
/// hoja deja de ser papel: [recibir], que convierte lo enviado en existencias.
class PedidoDetalleViewModel
    extends FamilyNotifier<PedidoDetalleEstado, String> {
  @override
  PedidoDetalleEstado build(String pedidoId) {
    final pedidos = ref.watch(pedidosViewModelProvider).pedidos;
    final existencias =
        ref.watch(inventarioViewModelProvider).existencias.value ?? const [];

    return PedidoDetalleEstado(
      detalle: pedidos.whenData((lista) {
        for (final detalle in lista) {
          if (detalle.pedido.id == pedidoId) return detalle;
        }
        return null;
      }),
      existencias: existencias,
    );
  }

  // --- Encabezado ----------------------------------------------------------

  Future<void> guardarEncabezado({
    String? campana,
    String? marcaPredeterminada,
    String? notas,
    DateTime? fecha,
  }) async {
    final actual = state.pedido?.pedido;
    if (actual == null) return;
    await ref.read(pedidosRepositoryProvider).guardarPedido(
          actual.copyWith(
            campana: campana,
            marcaPredeterminada: marcaPredeterminada,
            notas: notas,
            fecha: fecha,
          ),
        );
  }

  /// Surte el pedido al inventario. Es irreversible desde la interfaz a
  /// proposito: deshacerlo significaria sacar piezas que quiza ya se vendieron.
  Future<void> recibir() =>
      ref.read(pedidosRepositoryProvider).recibirPedido(arg);

  // --- Lineas --------------------------------------------------------------

  Future<String?> agregarLinea(LineaBorrador borrador) async {
    final invalido = _validar(borrador.cantPedida, borrador.cantEnviada);
    if (invalido != null) return invalido;
    await ref.read(pedidosRepositoryProvider).agregarLinea(arg, borrador);
    return null;
  }

  Future<String?> guardarLinea(LineaPedido linea) async {
    final invalido = _validar(linea.cantPedida, linea.cantEnviada);
    if (invalido != null) return invalido;
    await ref.read(pedidosRepositoryProvider).guardarLinea(linea);
    return null;
  }

  Future<void> eliminarLinea(LineaPedido linea) =>
      ref.read(pedidosRepositoryProvider).eliminarLinea(linea);

  /// Las cantidades negativas siempre son un dedazo. Que la enviada supere a
  /// la pedida no lo es: la distribuidora a veces manda de mas, y eso tambien
  /// hay que poder capturarlo tal como llego.
  String? _validar(int cantPedida, int cantEnviada) {
    if (cantPedida < 0 || cantEnviada < 0) {
      return 'Las cantidades no pueden ser negativas.';
    }
    return null;
  }
}

final pedidoDetalleViewModelProvider =
    NotifierProvider.family<PedidoDetalleViewModel, PedidoDetalleEstado,
        String>(
  PedidoDetalleViewModel.new,
);
