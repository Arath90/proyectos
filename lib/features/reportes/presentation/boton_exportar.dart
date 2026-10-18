import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets_comunes.dart';
import 'exportacion_view_model.dart';

/// El boton de exportar que corona los listados de pedidos y de ventas.
///
/// Es el mismo widget en las dos pantallas porque es la misma accion: sacar en
/// Excel lo que se esta viendo y mandarlo. Mientras trabaja se apaga y muestra
/// una rueda en su lugar, para que quede claro que el menu de compartir viene
/// en camino y no se toque tres veces.
class BotonExportar extends ConsumerWidget {
  const BotonExportar({required this.reporte, super.key});

  final Reporte reporte;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportando = ref.watch(exportacionViewModelProvider);

    return IconButton(
      tooltip: 'Exportar a Excel y enviar',
      onPressed: exportando ? null : () => _exportar(context, ref),
      icon: exportando
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.share_outlined),
    );
  }

  Future<void> _exportar(BuildContext context, WidgetRef ref) async {
    final mensaje =
        await ref.read(exportacionViewModelProvider.notifier).exportar(reporte);
    if (!context.mounted) return;
    avisar(context, mensaje, error: true);
  }
}
