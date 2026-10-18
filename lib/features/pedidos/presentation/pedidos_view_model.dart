import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/linea_pedido.dart';
import '../domain/pedido.dart';
import '../domain/totales_pedido.dart';

/// Un pedido con sus lineas y sus totales ya sumados.
///
/// Es al pedido lo que `VentaDetallada` es a la venta: la pieza que la
/// pantalla consume, con los totales calculados por `TotalesPedido` y no
/// guardados en la base.
class PedidoDetallado {
  const PedidoDetallado({required this.pedido, required this.lineas});

  final Pedido pedido;
  final List<LineaPedido> lineas;

  TotalesPedido get totales => TotalesPedido.de(lineas);

  /// Piezas que este pedido va a meter -o ya metio- al inventario.
  ///
  /// Es la `cantEnviada`, no la pedida: al inventario entra lo que llego en la
  /// caja, no lo que se solicito. La diferencia queda como faltante.
  int get piezasAlInventario =>
      lineas.fold<int>(0, (suma, linea) => suma + linea.cantEnviada);

  /// Cierto si la hoja ya se puede surtir: llego algo y todavia no se recibio.
  bool get sePuedeRecibir => !pedido.recibido && piezasAlInventario > 0;
}

/// Que pedidos quiere ver la propietaria.
enum FiltroPedidos {
  todos,
  porRecibir,
  recibidos,
  conFaltantes;

  String get etiqueta => switch (this) {
        FiltroPedidos.todos => 'Todos',
        FiltroPedidos.porRecibir => 'Por recibir',
        FiltroPedidos.recibidos => 'Recibidos',
        FiltroPedidos.conFaltantes => 'Con faltantes',
      };

  bool aplica(PedidoDetallado detalle) => switch (this) {
        FiltroPedidos.todos => true,
        FiltroPedidos.porRecibir => !detalle.pedido.recibido,
        FiltroPedidos.recibidos => detalle.pedido.recibido,
        FiltroPedidos.conFaltantes => detalle.totales.tieneFaltantes,
      };
}

/// Lo que pinta el listado de pedidos a la distribuidora.
class PedidosEstado {
  const PedidosEstado({
    this.pedidos = const AsyncValue.loading(),
    this.busqueda = '',
    this.filtro = FiltroPedidos.todos,
  });

  final AsyncValue<List<PedidoDetallado>> pedidos;
  final String busqueda;
  final FiltroPedidos filtro;

  AsyncValue<List<PedidoDetallado>> get visibles =>
      pedidos.whenData((lista) => lista.where(_pasaFiltros).toList());

  bool _pasaFiltros(PedidoDetallado detalle) {
    if (!filtro.aplica(detalle)) return false;
    final texto = busqueda.trim().toLowerCase();
    if (texto.isEmpty) return true;
    return detalle.pedido.campana.toLowerCase().contains(texto) ||
        detalle.pedido.marcaPredeterminada.toLowerCase().contains(texto) ||
        detalle.lineas.any(
          (linea) =>
              linea.descripcion.toLowerCase().contains(texto) ||
              linea.codigo.toLowerCase().contains(texto),
        );
  }

  /// Suma de lo que se esta viendo, para el encabezado.
  TotalesPedido get totales => TotalesPedido.de(
        (visibles.value ?? const <PedidoDetallado>[])
            .expand((detalle) => detalle.lineas),
      );

  PedidosEstado copyWith({
    AsyncValue<List<PedidoDetallado>>? pedidos,
    String? busqueda,
    FiltroPedidos? filtro,
  }) {
    return PedidosEstado(
      pedidos: pedidos ?? this.pedidos,
      busqueda: busqueda ?? this.busqueda,
      filtro: filtro ?? this.filtro,
    );
  }
}

/// ViewModel del listado de pedidos a la distribuidora.
///
/// Cose los encabezados con sus lineas, igual que `VentasViewModel`, y expone
/// la operacion que conecta este feature con el inventario: [recibir].
class PedidosViewModel extends Notifier<PedidosEstado> {
  String _busqueda = '';
  FiltroPedidos _filtro = FiltroPedidos.todos;

  @override
  PedidosEstado build() {
    final pedidos = ref.watch(pedidosProvider);
    final lineas = ref.watch(lineasPorPedidoProvider).value ?? const {};

    return PedidosEstado(
      pedidos: pedidos.whenData(
        (lista) => [
          for (final pedido in lista)
            PedidoDetallado(
              pedido: pedido,
              lineas: lineas[pedido.id] ?? const [],
            ),
        ],
      ),
      busqueda: _busqueda,
      filtro: _filtro,
    );
  }

  void buscar(String texto) {
    _busqueda = texto;
    state = state.copyWith(busqueda: texto);
  }

  void filtrar(FiltroPedidos filtro) {
    _filtro = filtro;
    state = state.copyWith(filtro: filtro);
  }

  Future<String> crearPedido({
    String campana = '',
    String marcaPredeterminada = '',
  }) async {
    final pedido = await ref.read(pedidosRepositoryProvider).crearPedido(
          campana: campana,
          marcaPredeterminada: marcaPredeterminada,
        );
    return pedido.id;
  }

  Future<void> eliminar(Pedido pedido) =>
      ref.read(pedidosRepositoryProvider).eliminarPedido(pedido.id);

  /// Surte el pedido: lo enviado por la distribuidora entra al inventario.
  ///
  /// Es el punto donde este feature le entrega el control al de inventario, y
  /// la unica forma de que un producto gane existencias sin capturarlas a
  /// mano.
  Future<void> recibir(Pedido pedido) =>
      ref.read(pedidosRepositoryProvider).recibirPedido(pedido.id);
}

final pedidosViewModelProvider =
    NotifierProvider<PedidosViewModel, PedidosEstado>(PedidosViewModel.new);
