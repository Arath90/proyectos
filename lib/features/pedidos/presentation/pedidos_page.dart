import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets_comunes.dart';
import '../../../core/escala_decimal.dart';
import '../../../core/formato.dart';
import '../../reportes/presentation/boton_exportar.dart';
import '../../reportes/presentation/exportacion_view_model.dart';
import 'pedido_detalle_page.dart';
import 'pedidos_view_model.dart';

/// El listado de pedidos a la distribuidora: por donde entra la mercancia.
///
/// Es el primer eslabon de la cadena. Cada renglon es una hoja de pedido; al
/// recibirla, sus piezas aparecen en el inventario y de ahi pasan a las
/// ventas. El filtro "por recibir" existe porque esa es la accion pendiente
/// mas comun: llego la caja y hay que darla de alta.
class PedidosPage extends ConsumerWidget {
  const PedidosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(pedidosViewModelProvider);
    final vm = ref.read(pedidosViewModelProvider.notifier);
    final totales = estado.totales;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos a distribuidora'),
        actions: const [BotonExportar(reporte: Reporte.pedidos)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-pedidos',
        onPressed: () => _nuevoPedido(context, ref),
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('Pedido'),
      ),
      body: Column(
        children: [
          BarraResumen(
            datos: [
              DatoResumen(
                etiqueta: 'Tu pagas',
                valor: dinero.formatear(totales.tuPagas),
                destacado: true,
              ),
              DatoResumen(
                etiqueta: 'Puntos',
                valor: puntos.formatear(totales.valorTotalPuntos),
              ),
              DatoResumen(
                etiqueta: 'Piezas enviadas',
                valor: '${totales.cantEnviada}',
              ),
              DatoResumen(
                etiqueta: 'Faltantes',
                valor: '${totales.faltantes}',
                color: totales.tieneFaltantes
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              hintText: 'Buscar por catalogo, marca o producto',
              leading: const Icon(Icons.search),
              onChanged: vm.buscar,
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final filtro in FiltroPedidos.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filtro.etiqueta),
                      selected: estado.filtro == filtro,
                      onSelected: (_) => vm.filtrar(filtro),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: estado.visibles.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('No se pudo leer: $e')),
              data: (pedidos) {
                if (pedidos.isEmpty) return _vacio(context, ref, estado);
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: pedidos.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) => _Renglon(
                    detalle: pedidos[i],
                    onAbrir: () =>
                        PedidoDetallePage.abrir(context, pedidos[i].pedido.id),
                    onRecibir: () => _recibir(context, ref, pedidos[i]),
                    onEliminar: () => _eliminar(context, ref, pedidos[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _vacio(BuildContext context, WidgetRef ref, PedidosEstado estado) {
    if (estado.busqueda.trim().isNotEmpty ||
        estado.filtro != FiltroPedidos.todos) {
      return const EstadoVacio(
        icono: Icons.filter_alt_off,
        titulo: 'Nada coincide',
        detalle: 'Cambia la busqueda o el filtro.',
      );
    }
    return EstadoVacio(
      icono: Icons.local_shipping_outlined,
      titulo: 'Sin pedidos capturados',
      detalle: 'Captura la hoja que le mandas a la distribuidora. Cuando '
          'llegue la caja, recibela y sus piezas entran a tu inventario.',
      accion: FilledButton.icon(
        onPressed: () => _nuevoPedido(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo pedido'),
      ),
    );
  }

  Future<void> _nuevoPedido(BuildContext context, WidgetRef ref) async {
    final hoja = await showDialog<({String campana, String marca})>(
      context: context,
      builder: (context) => const _DialogoNuevoPedido(),
    );
    if (hoja == null || !context.mounted) return;

    final id = await ref.read(pedidosViewModelProvider.notifier).crearPedido(
          campana: hoja.campana,
          marcaPredeterminada: hoja.marca,
        );
    if (context.mounted) await PedidoDetallePage.abrir(context, id);
  }

  Future<void> _recibir(
    BuildContext context,
    WidgetRef ref,
    PedidoDetallado detalle,
  ) async {
    final seguro = await confirmar(
      context,
      titulo: 'Recibir el pedido',
      mensaje: '${detalle.piezasAlInventario} piezas entraran al inventario y '
          'la hoja quedara cerrada.',
      aceptar: 'Recibir',
    );
    if (!seguro || !context.mounted) return;
    await ref.read(pedidosViewModelProvider.notifier).recibir(detalle.pedido);
  }

  Future<void> _eliminar(
    BuildContext context,
    WidgetRef ref,
    PedidoDetallado detalle,
  ) async {
    final seguro = await confirmar(
      context,
      titulo: 'Borrar pedido',
      mensaje: detalle.pedido.recibido
          ? 'La hoja se borrara, pero las piezas que ya entraron se quedan en '
              'el inventario.'
          : 'Se borrara la hoja con todas sus lineas.',
      aceptar: 'Borrar',
      peligroso: true,
    );
    if (!seguro || !context.mounted) return;
    await ref.read(pedidosViewModelProvider.notifier).eliminar(detalle.pedido);
  }
}

/// El dialogo que abre una hoja nueva: catalogo y marca de arranque.
///
/// Es un StatefulWidget nada mas para que los controladores vivan y mueran
/// con el dialogo: si se destruyen en cuanto `showDialog` devuelve, los campos
/// siguen dibujandose durante la animacion de salida y usan controladores ya
/// muertos.
class _DialogoNuevoPedido extends StatefulWidget {
  const _DialogoNuevoPedido();

  @override
  State<_DialogoNuevoPedido> createState() => _DialogoNuevoPedidoState();
}

class _DialogoNuevoPedidoState extends State<_DialogoNuevoPedido> {
  final _campana = TextEditingController();
  final _marca = TextEditingController();

  @override
  void dispose() {
    _campana.dispose();
    _marca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo pedido'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _campana,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nombre del catalogo',
              hintText: 'Catalogo 9, C-14, Navidad...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _marca,
            decoration: const InputDecoration(
              labelText: 'Marca',
              hintText: 'Se propone al capturar cada linea',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            (campana: _campana.text, marca: _marca.text),
          ),
          child: const Text('Abrir hoja'),
        ),
      ],
    );
  }
}

/// Una hoja de pedido en la lista.
class _Renglon extends StatelessWidget {
  const _Renglon({
    required this.detalle,
    required this.onAbrir,
    required this.onRecibir,
    required this.onEliminar,
  });

  final PedidoDetallado detalle;
  final VoidCallback onAbrir;
  final VoidCallback onRecibir;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final pedido = detalle.pedido;
    final totales = detalle.totales;

    return ListTile(
      onTap: onAbrir,
      onLongPress: onEliminar,
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      title: Row(
        children: [
          Expanded(
            child: Text(
              pedido.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          if (pedido.recibido)
            Insignia(
              'Recibido',
              color: tema.colorScheme.primary,
              icono: Icons.inventory,
            )
          else
            Insignia(
              'En camino',
              color: tema.colorScheme.tertiary,
              icono: Icons.local_shipping_outlined,
            ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${Formato.fecha(pedido.fecha)}  ·  ${totales.lineas} lineas  ·  '
              '${totales.cantPedida} pedidas / ${totales.cantEnviada} enviadas',
              style: tema.textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Pagas ${dinero.formatear(totales.tuPagas)}',
                  style: tema.textTheme.titleSmall,
                ),
                if (totales.tieneFaltantes)
                  Insignia(
                    '${totales.faltantes} faltantes',
                    color: tema.colorScheme.error,
                    icono: Icons.priority_high,
                  ),
              ],
            ),
          ],
        ),
      ),
      trailing: detalle.sePuedeRecibir
          ? IconButton.filledTonal(
              tooltip: 'Recibir al inventario',
              onPressed: onRecibir,
              icon: const Icon(Icons.move_to_inbox),
            )
          : const Icon(Icons.chevron_right),
    );
  }
}
