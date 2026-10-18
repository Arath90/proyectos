import 'package:flutter/material.dart';

import '../domain/carpeta_venta.dart';

/// La hoja para escoger en que carpeta se guarda una venta.
///
/// Se abre desde el listado -manteniendo el dedo sobre un renglon- y desde el
/// detalle de la venta, porque separar el trabajo pasa en los dos momentos: al
/// ordenar lo que ya estaba y al capturar algo nuevo que nacio en el lugar
/// equivocado.
///
/// Es un widget tonto: recibe las carpetas ya cargadas y devuelve la elegida.
/// No lee nada ni escribe nada.
class SelectorCarpeta {
  const SelectorCarpeta._();

  /// Devuelve `null` si se cerro sin elegir, y `(valor: null)` si se eligio
  /// dejarla suelta. Cancelar no es lo mismo que sacarla de su carpeta, y
  /// confundirlos desordenaria el trabajo cada vez que alguien abre la hoja
  /// por error.
  static Future<({String? valor})?> elegir(
    BuildContext context, {
    required List<CarpetaVenta> carpetas,
    String? elegida,
  }) {
    return showModalBottomSheet<({String? valor})>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Mover a',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder_off_outlined),
              title: const Text('Sin carpeta'),
              selected: elegida == null,
              onTap: () => Navigator.pop(context, (valor: null)),
            ),
            const Divider(height: 1),
            Flexible(
              child: carpetas.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Todavia no has creado ninguna carpeta.'),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        for (final carpeta in carpetas)
                          ListTile(
                            leading: const Icon(Icons.folder),
                            title: Text(carpeta.titulo),
                            selected: carpeta.id == elegida,
                            trailing: carpeta.id == elegida
                                ? const Icon(Icons.check)
                                : null,
                            onTap: () =>
                                Navigator.pop(context, (valor: carpeta.id)),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
