import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets_comunes.dart';
import '../domain/existencia.dart';
import 'inventario_view_model.dart';
import 'producto_form.dart';

/// La pantalla del inventario: el catalogo de lo que la propietaria tiene.
///
/// Es la "V" de MVVM y no hace nada mas que pintar: lee un
/// [InventarioEstado] ya resuelto y manda cada toque al
/// [InventarioViewModel]. No conoce Drift, ni los repositorios, ni como se
/// calcula lo apartado.
///
/// Muestra tres numeros por producto porque son tres cosas distintas y
/// confundirlas es el error clasico de un inventario: lo que hay fisicamente,
/// lo que ya esta comprometido en apartados, y lo que de verdad se le puede
/// prometer al siguiente cliente.
class InventarioPage extends ConsumerWidget {
  const InventarioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(inventarioViewModelProvider);
    final vm = ref.read(inventarioViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            tooltip: 'Solo con apartado',
            isSelected: estado.soloConApartado,
            onPressed: vm.alternarSoloConApartado,
            icon: const Icon(Icons.bookmark_border),
            selectedIcon: const Icon(Icons.bookmark),
          ),
          IconButton(
            tooltip: 'Ocultar agotados',
            isSelected: estado.ocultarAgotados,
            onPressed: vm.alternarOcultarAgotados,
            icon: const Icon(Icons.visibility_outlined),
            selectedIcon: const Icon(Icons.visibility_off),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-inventario',
        onPressed: () => ProductoForm.abrir(context),
        icon: const Icon(Icons.add),
        label: const Text('Producto'),
      ),
      body: Column(
        children: [
          BarraResumen(
            datos: [
              DatoResumen(
                etiqueta: 'En existencia',
                valor: '${estado.piezasTotales} pz',
                destacado: true,
              ),
              DatoResumen(
                etiqueta: 'Apartadas',
                valor: '${estado.piezasApartadas} pz',
              ),
              DatoResumen(etiqueta: 'Agotados', valor: '${estado.agotados}'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              hintText: 'Buscar por marca, codigo o descripcion',
              leading: const Icon(Icons.search),
              onChanged: vm.buscar,
            ),
          ),
          Expanded(
            child: estado.visibles.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('No se pudo leer: $e')),
              data: (existencias) {
                if (existencias.isEmpty) return _vacio(context, estado);
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: existencias.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) => _Renglon(
                    existencia: existencias[i],
                    onEditar: () => ProductoForm.abrir(
                      context,
                      producto: existencias[i].producto,
                    ),
                    onEliminar: () => _eliminar(context, ref, existencias[i]),
                    onAjustar: (delta) => vm.ajustarExistencia(
                      existencias[i].producto,
                      existencias[i].producto.cantidadActual + delta,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _vacio(BuildContext context, InventarioEstado estado) {
    final filtrando = estado.busqueda.trim().isNotEmpty ||
        estado.soloConApartado ||
        estado.ocultarAgotados;
    if (filtrando) {
      return const EstadoVacio(
        icono: Icons.filter_alt_off,
        titulo: 'Nada coincide',
        detalle: 'Cambia la busqueda o quita los filtros.',
      );
    }
    return EstadoVacio(
      icono: Icons.inventory_2_outlined,
      titulo: 'Tu inventario esta vacio',
      detalle: 'Da de alta lo que ya tienes en casa, o captura un pedido a la '
          'distribuidora y recibelo: sus piezas entran solas aqui.',
      accion: FilledButton.icon(
        onPressed: () => ProductoForm.abrir(context),
        icon: const Icon(Icons.add),
        label: const Text('Agregar producto'),
      ),
    );
  }

  Future<void> _eliminar(
    BuildContext context,
    WidgetRef ref,
    Existencia existencia,
  ) async {
    final aviso = existencia.hayApartado
        ? 'Tiene ${existencia.apartadas} piezas apartadas en ventas abiertas. '
            'Esas ventas seguiran guardadas.'
        : 'Las ventas que ya lo incluyen seguiran guardadas.';
    final seguro = await confirmar(
      context,
      titulo: 'Dar de baja',
      mensaje: '${existencia.producto.titulo}\n\n$aviso',
      aceptar: 'Dar de baja',
      peligroso: true,
    );
    if (!seguro || !context.mounted) return;
    await ref
        .read(inventarioViewModelProvider.notifier)
        .eliminar(existencia.producto);
  }
}

/// Un producto en la lista, con sus tres cantidades y los botones de ajuste
/// rapido para cuando la propietaria cuenta cajas.
class _Renglon extends StatelessWidget {
  const _Renglon({
    required this.existencia,
    required this.onEditar,
    required this.onEliminar,
    required this.onAjustar,
  });

  final Existencia existencia;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final ValueChanged<int> onAjustar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final producto = existencia.producto;

    return ListTile(
      onTap: onEditar,
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      title: Text(
        producto.descripcion.isEmpty ? producto.titulo : producto.descripcion,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (producto.marca.isNotEmpty)
              Text(producto.marca, style: tema.textTheme.labelMedium),
            if (producto.codigo.isNotEmpty)
              Text(
                '#${producto.codigo}',
                style: tema.textTheme.labelMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            if (existencia.hayApartado)
              Insignia(
                '${existencia.apartadas} apartadas',
                color: tema.colorScheme.tertiary,
                icono: Icons.bookmark,
              ),
            if (existencia.sobrevendido)
              Insignia(
                'Faltan ${-existencia.disponibles}',
                color: tema.colorScheme.error,
                icono: Icons.priority_high,
              )
            else if (producto.agotado)
              Insignia(
                'Agotado',
                color: tema.colorScheme.error,
                icono: Icons.remove_shopping_cart,
              ),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Quitar una pieza',
            onPressed:
                producto.cantidadActual > 0 ? () => onAjustar(-1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${producto.cantidadActual}',
                style: tema.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: producto.agotado ? tema.colorScheme.error : null,
                ),
              ),
              Text(
                'de ${producto.cantidadOriginal}',
                style: tema.textTheme.labelSmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Agregar una pieza',
            onPressed: () => onAjustar(1),
            icon: const Icon(Icons.add_circle_outline),
          ),
          IconButton(
            tooltip: 'Dar de baja',
            onPressed: onEliminar,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
