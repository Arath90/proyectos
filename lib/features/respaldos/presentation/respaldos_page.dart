import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets_comunes.dart';
import '../../../core/formato.dart';
import '../domain/respaldo.dart';
import 'respaldos_view_model.dart';

/// La pantalla del respaldo: donde se saca una copia y donde se vuelve a una.
///
/// Es una pestana visible y no una opcion escondida en un menu por una razon
/// practica: un respaldo que hay que ir a buscar no se hace nunca. La
/// propietaria tiene que poder verlo, tocarlo y mandarselo por WhatsApp sin
/// que nadie le explique donde estaba.
///
/// La pantalla dice antes que nada lo unico que de verdad importa entender: la
/// copia que sirve es la que sale de la tablet. Las que se quedan aqui salvan
/// de una actualizacion que salga mal; ninguna salva de que la tablet se caiga
/// al agua.
class RespaldosPage extends ConsumerWidget {
  const RespaldosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(respaldosViewModelProvider);
    final vm = ref.read(respaldosViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Respaldo'),
        actions: [
          IconButton(
            tooltip: 'Volver a revisar',
            onPressed: vm.refrescar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-respaldos',
        onPressed: estado.trabajando
            ? null
            : () async {
                final falla = await vm.respaldarYEnviar();
                if (context.mounted) avisar(context, falla, error: true);
              },
        icon: estado.trabajando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.ios_share),
        label: const Text('Respaldar y enviar'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          const _Explicacion(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: OutlinedButton.icon(
              onPressed: estado.trabajando
                  ? null
                  : () async {
                      final falla = await vm.traerDeAfuera();
                      if (context.mounted) avisar(context, falla, error: true);
                    },
              icon: const Icon(Icons.folder_open_outlined),
              label: const Text('Traer un respaldo de afuera'),
            ),
          ),
          const SizedBox(height: 8),
          const _Titulo(texto: 'Copias en esta tablet'),
          estado.lista.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('No se pudo leer la carpeta de respaldos: $e'),
            ),
            data: (copias) => copias.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Todavia no hay ninguna. Toca "Respaldar y enviar" para '
                      'hacer la primera y mandartela a tu WhatsApp.',
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final copia in copias)
                        _Renglon(
                          respaldo: copia,
                          apagado: estado.trabajando,
                          onEnviar: () async {
                            final falla = await vm.enviar(copia);
                            if (context.mounted) {
                              avisar(context, falla, error: true);
                            }
                          },
                          onRestaurar: () => _restaurar(context, vm, copia),
                          onBorrar: () => _borrar(context, vm, copia),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _restaurar(
    BuildContext context,
    RespaldosViewModel vm,
    Respaldo respaldo,
  ) async {
    final seguro = await confirmar(
      context,
      titulo: 'Volver a este respaldo',
      mensaje: 'Todo lo que capturaste despues del '
          '${Formato.fechaHora(respaldo.fecha)} desaparece: ventas, abonos, '
          'productos y deudas.\n\nAntes de cambiar nada se guarda una copia de '
          'como esta ahora, por si te arrepientes.',
      aceptar: 'Restaurar',
      peligroso: true,
    );
    if (!seguro) return;

    final falla = await vm.restaurar(respaldo);
    if (!context.mounted) return;
    if (falla != null) {
      avisar(context, falla, error: true);
      return;
    }
    avisar(context, 'Listo: tus datos son los del respaldo.');
  }

  Future<void> _borrar(
    BuildContext context,
    RespaldosViewModel vm,
    Respaldo respaldo,
  ) async {
    final seguro = await confirmar(
      context,
      titulo: 'Borrar esta copia',
      mensaje: 'Se borra el archivo de la tablet. Si ya te lo habias mandado '
          'por WhatsApp, esa copia se queda donde este.',
      aceptar: 'Borrar',
      peligroso: true,
    );
    if (!seguro) return;
    final falla = await vm.eliminar(respaldo);
    if (context.mounted) avisar(context, falla, error: true);
  }
}

/// Lo que hay que entender antes de tocar nada.
class _Explicacion extends StatelessWidget {
  const _Explicacion();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      width: double.infinity,
      color: tema.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manda el respaldo fuera de la tablet',
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Con "Respaldar y enviar" se hace una copia de todo -ventas, '
            'clientes, deudas e inventario- y se abre el menu de compartir. '
            'Mandatela a tu WhatsApp o a tu Drive: si la tablet se pierde o se '
            'rompe, ese archivo es lo unico que trae tus datos de vuelta. Con '
            '"Traer un respaldo de afuera" se vuelve a meter aqui.',
            style: tema.textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 18,
                color: tema.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'La aplicacion tambien guarda una copia sola cada vez que se '
                  'actualiza, antes de tocar nada. Esas son las que dicen '
                  '"Antes de actualizar".',
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        texto,
        style: tema.textTheme.titleSmall?.copyWith(
          color: tema.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Una copia en la lista.
class _Renglon extends StatelessWidget {
  const _Renglon({
    required this.respaldo,
    required this.apagado,
    required this.onEnviar,
    required this.onRestaurar,
    required this.onBorrar,
  });

  final Respaldo respaldo;
  final bool apagado;
  final VoidCallback onEnviar;
  final VoidCallback onRestaurar;
  final VoidCallback onBorrar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      leading: Icon(
        switch (respaldo.motivo) {
          MotivoRespaldo.aMano => Icons.save_outlined,
          MotivoRespaldo.antesDeActualizar => Icons.system_update_alt,
          MotivoRespaldo.antesDeRestaurar => Icons.history_toggle_off,
        },
        color: tema.colorScheme.primary,
      ),
      title: Text(
        Formato.fechaHora(respaldo.fecha),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Insignia(
              respaldo.motivo.etiqueta,
              color: respaldo.motivo == MotivoRespaldo.aMano
                  ? tema.colorScheme.primary
                  : tema.colorScheme.tertiary,
            ),
            const SizedBox(width: 10),
            Text(respaldo.tamano, style: tema.textTheme.bodySmall),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Enviar este respaldo',
            onPressed: apagado ? null : onEnviar,
            icon: const Icon(Icons.ios_share),
          ),
          PopupMenuButton<String>(
            enabled: !apagado,
            onSelected: (opcion) =>
                opcion == 'restaurar' ? onRestaurar() : onBorrar(),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'restaurar',
                child: ListTile(
                  leading: Icon(Icons.restore),
                  title: Text('Volver a este respaldo'),
                ),
              ),
              const PopupMenuItem(
                value: 'borrar',
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Borrar esta copia'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
