import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets_comunes.dart';
import '../../../core/escala_decimal.dart';
import '../../../core/formato.dart';
import '../../reportes/presentation/boton_exportar.dart';
import '../../reportes/presentation/exportacion_view_model.dart';
import '../domain/cuenta_cliente.dart';
import 'adeudo_form.dart';
import 'adeudos_view_model.dart';
import 'cuenta_cliente_page.dart';

/// La pantalla de adeudos: quien debe, cuanto, y de que.
///
/// Existe porque el cobro no cabia dentro de una venta. La deuda vieja de una
/// persona -mercancia que se llevo antes de que la aplicacion existiera- no se
/// puede capturar como venta sin ensuciar el inventario, y aunque se pudiera,
/// una persona que compro tres veces tenia su deuda repartida en tres hojas que
/// nadie sumaba.
///
/// Aqui esa suma esta hecha. Cada renglon es una persona y trae las dos
/// mitades por separado -lo que debe de antes y lo que debe en sus ventas
/// abiertas- porque se cobran en lugares distintos, mas el total, que es lo
/// que ella dice en voz alta.
class AdeudosPage extends ConsumerWidget {
  const AdeudosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(adeudosViewModelProvider);
    final vm = ref.read(adeudosViewModelProvider.notifier);
    final resumen = estado.resumen;
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adeudos'),
        actions: const [BotonExportar(reporte: Reporte.adeudos)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-adeudos',
        onPressed: () => AdeudoForm.abrir(context),
        icon: const Icon(Icons.account_balance_wallet_outlined),
        label: const Text('Adeudo'),
      ),
      body: Column(
        children: [
          BarraResumen(
            datos: [
              DatoResumen(
                etiqueta: 'Deuda anterior',
                valor: dinero.formatear(resumen.adeudo),
                destacado: true,
              ),
              DatoResumen(
                etiqueta: 'En ventas',
                valor: dinero.formatear(resumen.enVentas),
              ),
              DatoResumen(
                etiqueta: 'Total',
                valor: dinero.formatear(resumen.total),
                destacado: true,
                color: resumen.hayDeuda ? tema.colorScheme.error : null,
              ),
              DatoResumen(
                etiqueta: 'Deudores',
                valor: '${resumen.deudores}',
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              hintText: 'Buscar por nombre',
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
                for (final filtro in FiltroAdeudos.values)
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
              data: (cuentas) {
                if (cuentas.isEmpty) return _vacio(context, estado);
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: cuentas.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) => _Renglon(
                    cuenta: cuentas[i],
                    onAbrir: () => CuentaClientePage.abrir(
                      context,
                      cuentas[i].cliente.id,
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

  Widget _vacio(BuildContext context, AdeudosEstado estado) {
    if (estado.busqueda.trim().isNotEmpty) {
      return const EstadoVacio(
        icono: Icons.person_search,
        titulo: 'Nadie se llama asi',
        detalle: 'Cambia la busqueda, o quita el filtro para ver a todos.',
      );
    }
    if (estado.filtro == FiltroAdeudos.deben) {
      return EstadoVacio(
        icono: Icons.check_circle_outline,
        titulo: 'Nadie te debe nada',
        detalle: 'Cuando alguien quede a deber, aparece aqui. Tambien puedes '
            'anotar lo que te deben desde antes de usar la aplicacion.',
        accion: FilledButton.icon(
          onPressed: () => AdeudoForm.abrir(context),
          icon: const Icon(Icons.add),
          label: const Text('Anotar un adeudo'),
        ),
      );
    }
    return EstadoVacio(
      icono: Icons.people_outline,
      titulo: 'Todavia no hay clientes',
      detalle: 'Se dan de alta solos al abrir una venta, o desde aqui al '
          'anotar lo que alguien debe de antes.',
      accion: FilledButton.icon(
        onPressed: () => AdeudoForm.abrir(context),
        icon: const Icon(Icons.add),
        label: const Text('Anotar un adeudo'),
      ),
    );
  }
}

/// Una persona en la lista: cuanto debe y de donde viene esa deuda.
class _Renglon extends StatelessWidget {
  const _Renglon({required this.cuenta, required this.onAbrir});

  final CuentaCliente cuenta;
  final VoidCallback onAbrir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListTile(
      onTap: onAbrir,
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      title: Row(
        children: [
          Expanded(
            child: Text(
              cuenta.cliente.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            dinero.formatear(cuenta.deudaTotal),
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cuenta.debe
                  ? tema.colorScheme.error
                  : tema.colorScheme.primary,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (cuenta.tieneAdeudo)
              Insignia(
                'De antes ${dinero.formatear(cuenta.saldoAdeudo)}',
                color: tema.colorScheme.tertiary,
                icono: Icons.history,
              ),
            if (cuenta.saldoEnVentas > 0)
              Insignia(
                'En ventas ${dinero.formatear(cuenta.saldoEnVentas)}',
                color: tema.colorScheme.error,
                icono: Icons.receipt_long,
              ),
            if (!cuenta.debe)
              Insignia(
                'Al corriente',
                color: tema.colorScheme.primary,
                icono: Icons.check,
              ),
            if (cuenta.ultimoPago != null)
              Text(
                'Ultimo pago ${Formato.fechaCorta(cuenta.ultimoPago!)}',
                style: tema.textTheme.bodySmall,
              ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
