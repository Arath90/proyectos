import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets_comunes.dart';
import '../../../core/escala_decimal.dart';
import '../../../core/formato.dart';
import '../../clientes/presentation/selector_cliente.dart';
import '../../reportes/presentation/boton_exportar.dart';
import '../../reportes/presentation/exportacion_view_model.dart';
import '../domain/carpeta_venta.dart';
import '../domain/venta.dart';
import '../domain/venta_detallada.dart';
import 'selector_carpeta.dart';
import 'venta_detalle_page.dart';
import 'ventas_view_model.dart';

/// El listado de ventas: quien compro que, y quien todavia debe.
///
/// Es la pantalla que la propietaria abre para contestar la pregunta que mas
/// se hace: "de quien tengo que cobrar". Por eso el filtro "me deben" es de
/// primera clase y el saldo se muestra en cada renglon, no escondido en el
/// detalle.
///
/// Tiene dos caras. Mientras no haya carpetas es la lista corrida de siempre,
/// porque separar no le sirve a quien tiene diez ventas. En cuanto crea la
/// primera carpeta se vuelve una estanteria: primero los lugares, y se entra a
/// uno para ver sus ventas, su resumen y su boton de exportar. Buscar salta
/// por encima de las carpetas, porque quien teclea un nombre esta buscando a
/// una persona y no un lugar.
class VentasPage extends ConsumerWidget {
  const VentasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(ventasViewModelProvider);
    final vm = ref.read(ventasViewModelProvider.notifier);
    final resumen = estado.resumen;

    return PopScope(
      // Dentro de una carpeta, el boton de atras del sistema sube un nivel en
      // vez de salirse de la aplicacion: es lo que hace cualquier explorador de
      // archivos y es lo que la mano espera.
      canPop: estado.enRaiz,
      onPopInvokedWithResult: (hecho, _) {
        if (!hecho) vm.volver();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: estado.enRaiz
              ? null
              : IconButton(
                  tooltip: 'Todas las carpetas',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: vm.volver,
                ),
          title: Text(estado.titulo),
          actions: [
            const BotonExportar(reporte: Reporte.ventas),
            PopupMenuButton<String>(
              onSelected: (opcion) => _menu(context, ref, estado, opcion),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'nueva-carpeta',
                  child: ListTile(
                    leading: Icon(Icons.create_new_folder_outlined),
                    title: Text('Nueva carpeta'),
                  ),
                ),
                if (estado.carpeta != null) ...[
                  const PopupMenuItem(
                    value: 'renombrar-carpeta',
                    child: ListTile(
                      leading: Icon(Icons.drive_file_rename_outline),
                      title: Text('Renombrar esta carpeta'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'borrar-carpeta',
                    child: ListTile(
                      leading: Icon(Icons.folder_delete_outlined),
                      title: Text('Borrar esta carpeta'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'fab-ventas',
          onPressed: () => _nuevaVenta(context, ref),
          icon: const Icon(Icons.point_of_sale),
          label: const Text('Venta'),
        ),
        body: Column(
          children: [
            BarraResumen(
              datos: [
                DatoResumen(
                  etiqueta: 'Vendido',
                  valor: dinero.formatear(resumen.total),
                  destacado: true,
                ),
                DatoResumen(
                  etiqueta: 'Cobrado',
                  valor: dinero.formatear(resumen.abonado),
                ),
                DatoResumen(
                  etiqueta: 'Me deben',
                  valor: dinero.formatear(resumen.saldo),
                  destacado: true,
                  color: resumen.hayPorCobrar
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
                if (resumen.hayTraspasado)
                  DatoResumen(
                    etiqueta: 'En adeudos',
                    valor: dinero.formatear(resumen.traspasado),
                  ),
                DatoResumen(
                  etiqueta: 'Apartadas',
                  valor: '${resumen.apartadas}',
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SearchBar(
                hintText: estado.mostrarEstanteria
                    ? 'Buscar en todas las carpetas'
                    : 'Buscar por cliente o producto',
                leading: const Icon(Icons.search),
                onChanged: vm.buscar,
              ),
            ),
            if (!estado.mostrarEstanteria)
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final filtro in FiltroVentas.values)
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
              child: estado.mostrarEstanteria
                  ? _Estanteria(estado: estado, vm: vm)
                  : _ListaVentas(estado: estado, ref: ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _menu(
    BuildContext context,
    WidgetRef ref,
    VentasEstado estado,
    String opcion,
  ) async {
    final vm = ref.read(ventasViewModelProvider.notifier);
    switch (opcion) {
      case 'nueva-carpeta':
        final nombre = await pedirTexto(
          context,
          titulo: 'Nueva carpeta',
          etiqueta: 'Nombre',
          pista: 'El lugar o el grupo: Tepic, Xalisco, la fabrica...',
          aceptar: 'Crear',
        );
        if (nombre == null) return;
        final falla = await vm.crearCarpeta(nombre);
        if (context.mounted) avisar(context, falla, error: true);
      case 'renombrar-carpeta':
        final carpeta = estado.carpeta;
        if (carpeta == null) return;
        final nombre = await pedirTexto(
          context,
          titulo: 'Renombrar carpeta',
          etiqueta: 'Nombre',
          valor: carpeta.nombre,
          aceptar: 'Guardar',
        );
        if (nombre == null) return;
        final falla = await vm.renombrarCarpeta(carpeta, nombre);
        if (context.mounted) avisar(context, falla, error: true);
      case 'borrar-carpeta':
        final carpeta = estado.carpeta;
        if (carpeta == null) return;
        final seguro = await confirmar(
          context,
          titulo: 'Borrar la carpeta',
          mensaje: 'Sus ventas no se borran: quedan sueltas, en "Sin '
              'carpeta".',
          aceptar: 'Borrar carpeta',
          peligroso: true,
        );
        if (seguro) await vm.eliminarCarpeta(carpeta);
    }
  }

  /// Pide el cliente y abre la venta.
  ///
  /// Se elige de la lista en vez de teclearlo, y si no esta se da de alta ahi
  /// mismo: es lo que permite que su deuda vieja y esta venta acaben en la
  /// misma cuenta. Se pide de entrada porque una venta sin cliente no se puede
  /// cobrar despues, que es el caso normal aqui: casi nadie paga completo el
  /// mismo dia.
  Future<void> _nuevaVenta(BuildContext context, WidgetRef ref) async {
    final elegido = await SelectorCliente.elegir(context);
    if (elegido == null || !context.mounted) return;

    final id = await ref.read(ventasViewModelProvider.notifier).crearVenta(
          cliente: elegido.valor?.nombre ?? '',
          clienteId: elegido.valor?.id,
        );
    if (context.mounted) await VentaDetallePage.abrir(context, id);
  }
}

/// Las carpetas, que es lo primero que se ve cuando ya hay trabajo separado.
class _Estanteria extends StatelessWidget {
  const _Estanteria({required this.estado, required this.vm});

  final VentasEstado estado;
  final VentasViewModel vm;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estanteria = estado.estanteria;

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: estanteria.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final fila = estanteria[i];
        final resumen = fila.resumen;
        return ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          leading: Icon(
            fila.esSinCarpeta ? Icons.folder_off_outlined : Icons.folder,
            color: fila.esSinCarpeta
                ? tema.colorScheme.outline
                : tema.colorScheme.primary,
          ),
          title: Text(
            fila.titulo,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text(
                  resumen.ventas == 1
                      ? '1 venta'
                      : '${resumen.ventas} ventas',
                  style: tema.textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Text(
                  dinero.formatear(resumen.total),
                  style: tema.textTheme.bodySmall,
                ),
                if (resumen.hayPorCobrar) ...[
                  const SizedBox(width: 12),
                  Insignia(
                    'Te deben ${dinero.formatear(resumen.saldo)}',
                    color: tema.colorScheme.error,
                    icono: Icons.schedule,
                  ),
                ],
              ],
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => vm.abrirCarpeta(fila.carpeta?.id),
          onLongPress: fila.esSinCarpeta
              ? null
              : () => _acciones(context, fila.carpeta!),
        );
      },
    );
  }

  Future<void> _acciones(BuildContext context, CarpetaVenta carpeta) async {
    final accion = await menuDeAcciones(
      context,
      titulo: carpeta.titulo,
      acciones: const [
        AccionHoja(
          valor: 'renombrar',
          icono: Icons.drive_file_rename_outline,
          titulo: 'Renombrar',
        ),
        AccionHoja(
          valor: 'borrar',
          icono: Icons.folder_delete_outlined,
          titulo: 'Borrar carpeta',
          detalle: 'Sus ventas quedan sueltas',
          peligroso: true,
        ),
      ],
    );
    if (accion == null || !context.mounted) return;

    if (accion == 'renombrar') {
      final nombre = await pedirTexto(
        context,
        titulo: 'Renombrar carpeta',
        etiqueta: 'Nombre',
        valor: carpeta.nombre,
        aceptar: 'Guardar',
      );
      if (nombre == null) return;
      final falla = await vm.renombrarCarpeta(carpeta, nombre);
      if (context.mounted) avisar(context, falla, error: true);
      return;
    }

    final seguro = await confirmar(
      context,
      titulo: 'Borrar la carpeta',
      mensaje: 'Sus ventas no se borran: quedan sueltas, en "Sin carpeta".',
      aceptar: 'Borrar carpeta',
      peligroso: true,
    );
    if (seguro) await vm.eliminarCarpeta(carpeta);
  }
}

/// Las ventas: la lista de siempre, dentro de una carpeta o a traves de todas.
class _ListaVentas extends StatelessWidget {
  const _ListaVentas({required this.estado, required this.ref});

  final VentasEstado estado;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return estado.visibles.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('No se pudo leer: $e')),
      data: (ventas) {
        if (ventas.isEmpty) return _vacio(context);
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: ventas.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) => _Renglon(
            detalle: ventas[i],
            // El nombre de la carpeta solo hace falta cuando se esta viendo a
            // traves de varias: dentro de una, repetirlo en cada renglon es
            // ruido.
            carpeta: estado.enRaiz ? _nombreDeCarpeta(ventas[i].venta) : null,
            onAbrir: () => VentaDetallePage.abrir(context, ventas[i].venta.id),
            onAcciones: () => _acciones(context, ventas[i]),
          ),
        );
      },
    );
  }

  String? _nombreDeCarpeta(Venta venta) {
    if (venta.carpetaId == null) return null;
    for (final carpeta in estado.carpetas) {
      if (carpeta.id == venta.carpetaId) return carpeta.titulo;
    }
    return null;
  }

  Widget _vacio(BuildContext context) {
    if (estado.buscando || estado.filtro != FiltroVentas.todas) {
      return const EstadoVacio(
        icono: Icons.filter_alt_off,
        titulo: 'Nada coincide',
        detalle: 'Cambia la busqueda o el filtro.',
      );
    }
    if (!estado.enRaiz) {
      return EstadoVacio(
        icono: Icons.folder_open,
        titulo: 'Esta carpeta esta vacia',
        detalle: 'Abre una venta aqui, o mueve a esta carpeta una que ya '
            'tengas: manten el dedo sobre ella en la lista.',
        accion: FilledButton.icon(
          onPressed: () => _nuevaVentaAqui(context),
          icon: const Icon(Icons.add),
          label: const Text('Nueva venta'),
        ),
      );
    }
    return EstadoVacio(
      icono: Icons.point_of_sale,
      titulo: 'Todavia no hay ventas',
      detalle: 'Abre una venta, elige productos de tu inventario y registra '
          'los abonos conforme te vayan pagando.',
      accion: FilledButton.icon(
        onPressed: () => _nuevaVentaAqui(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva venta'),
      ),
    );
  }

  Future<void> _nuevaVentaAqui(BuildContext context) async {
    final elegido = await SelectorCliente.elegir(context);
    if (elegido == null || !context.mounted) return;
    final id = await ref.read(ventasViewModelProvider.notifier).crearVenta(
          cliente: elegido.valor?.nombre ?? '',
          clienteId: elegido.valor?.id,
        );
    if (context.mounted) await VentaDetallePage.abrir(context, id);
  }

  Future<void> _acciones(BuildContext context, VentaDetallada detalle) async {
    final accion = await menuDeAcciones(
      context,
      titulo: detalle.venta.titulo,
      acciones: const [
        AccionHoja(
          valor: 'mover',
          icono: Icons.drive_file_move_outline,
          titulo: 'Mover a otra carpeta',
        ),
        AccionHoja(
          valor: 'borrar',
          icono: Icons.delete_outline,
          titulo: 'Borrar venta',
          peligroso: true,
        ),
      ],
    );
    if (accion == null || !context.mounted) return;

    final vm = ref.read(ventasViewModelProvider.notifier);
    if (accion == 'mover') {
      final elegida = await SelectorCarpeta.elegir(
        context,
        carpetas: estado.carpetas,
        elegida: detalle.venta.carpetaId,
      );
      if (elegida == null) return;
      await vm.moverVenta(detalle.venta, elegida.valor);
      return;
    }

    final seguro = await confirmar(
      context,
      titulo: 'Borrar venta',
      mensaje: detalle.venta.entregada
          ? 'Sus ${detalle.piezas} piezas regresaran al inventario y se '
              'perdera el registro de los abonos.'
          : 'Se liberara el apartado y se perdera el registro de los abonos.',
      aceptar: 'Borrar',
      peligroso: true,
    );
    if (seguro) await vm.eliminar(detalle.venta);
  }
}

/// Una venta en la lista: cliente, estado, total y sobre todo el saldo.
class _Renglon extends StatelessWidget {
  const _Renglon({
    required this.detalle,
    required this.carpeta,
    required this.onAbrir,
    required this.onAcciones,
  });

  final VentaDetallada detalle;
  final String? carpeta;
  final VoidCallback onAbrir;
  final VoidCallback onAcciones;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final venta = detalle.venta;
    final color = switch (venta.estado) {
      EstadoVenta.apartada => tema.colorScheme.tertiary,
      EstadoVenta.entregada => tema.colorScheme.primary,
      EstadoVenta.cancelada => tema.colorScheme.error,
    };

    return ListTile(
      onTap: onAbrir,
      onLongPress: onAcciones,
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      title: Row(
        children: [
          Expanded(
            child: Text(
              venta.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Insignia(venta.estado.etiqueta, color: color),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [
                Formato.fecha(venta.fecha),
                '${detalle.lineas.length} renglones',
                '${detalle.piezas} pz',
                ?carpeta,
              ].join('  ·  '),
              style: tema.textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  dinero.formatear(detalle.total),
                  style: tema.textTheme.titleSmall,
                ),
                const SizedBox(width: 12),
                if (detalle.traspasadaAAdeudo)
                  Insignia(
                    'En adeudos ${dinero.formatear(detalle.traspasado)}',
                    color: tema.colorScheme.tertiary,
                    icono: Icons.account_balance_wallet_outlined,
                  )
                else if (detalle.liquidada)
                  Insignia(
                    'Liquidada',
                    color: tema.colorScheme.primary,
                    icono: Icons.check,
                  )
                else if (detalle.saldo > 0)
                  Insignia(
                    'Debe ${dinero.formatear(detalle.saldo)}',
                    color: tema.colorScheme.error,
                    icono: Icons.schedule,
                  ),
              ],
            ),
            if (detalle.pagoParcial) ...[
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: detalle.avanceCobro,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
