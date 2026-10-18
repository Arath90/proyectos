import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cliente.dart';
import 'clientes_view_model.dart';

/// La hoja donde se elige a quien se le vende o a quien se le carga una deuda.
///
/// Es el equivalente, para personas, del selector de productos del inventario:
/// lo que ya existe se elige y no se teclea. Un producto mal tecleado no se
/// puede cuadrar despues; un cliente mal tecleado es peor todavia, porque
/// parte su deuda en dos cuentas y ninguna de las dos cuadra.
///
/// Pero no obliga a ir antes a otra pantalla a dar de alta a nadie: si lo que
/// se teclea no existe, la primera opcion de la lista es crearlo. Buscar y dar
/// de alta son el mismo gesto, que es como funciona en la cabeza de quien esta
/// atendiendo a alguien.
class SelectorCliente extends ConsumerStatefulWidget {
  const SelectorCliente({this.elegido, this.permiteNinguno = true, super.key});

  /// Quien esta elegido ahora, para marcarlo en la lista.
  final String? elegido;

  /// Si se ofrece la opcion de dejarlo sin nadie. Una venta si puede quedarse
  /// sin cliente -se abre y se le pone nombre despues-; un adeudo no, porque
  /// una deuda sin duenio no se le cobra a nadie.
  final bool permiteNinguno;

  /// Abre la hoja y devuelve lo elegido.
  ///
  /// Devuelve `null` si se cerro sin elegir, y `(valor: null)` si se eligio
  /// dejarlo sin cliente. Son dos cosas distintas -cancelar no es lo mismo que
  /// quitar- y confundirlas borraria el cliente de una venta cada vez que
  /// alguien abre la hoja por error.
  static Future<({Cliente? valor})?> elegir(
    BuildContext context, {
    String? elegido,
    bool permiteNinguno = true,
  }) {
    return showModalBottomSheet<({Cliente? valor})>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SelectorCliente(
        elegido: elegido,
        permiteNinguno: permiteNinguno,
      ),
    );
  }

  @override
  ConsumerState<SelectorCliente> createState() => _SelectorClienteState();
}

class _SelectorClienteState extends ConsumerState<SelectorCliente> {
  final _busqueda = TextEditingController();
  bool _creando = false;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  /// Los clientes que coinciden con lo tecleado.
  ///
  /// Compara con la misma clave que usa el padron para decidir si dos nombres
  /// son el mismo, asi que buscar "tono" encuentra a "Toño": el teclado de la
  /// tablet pone acentos o no segun la prisa.
  List<Cliente> _coincidencias(List<Cliente> todos) {
    final clave = claveDeNombre(_busqueda.text);
    if (clave.isEmpty) return todos;
    return todos.where((c) => c.clave.contains(clave)).toList();
  }

  bool _yaExiste(List<Cliente> todos) {
    final clave = claveDeNombre(_busqueda.text);
    return clave.isEmpty || todos.any((c) => c.clave == clave);
  }

  Future<void> _crear() async {
    setState(() => _creando = true);
    final cliente =
        await ref.read(clientesViewModelProvider.notifier).crear(_busqueda.text);
    if (!mounted) return;
    setState(() => _creando = false);
    if (cliente != null) Navigator.pop(context, (valor: cliente));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final relleno = MediaQuery.viewInsetsOf(context).bottom;
    final todos = ref.watch(clientesViewModelProvider).value ?? const <Cliente>[];
    final coincidencias = _coincidencias(todos);
    final tecleado = _busqueda.text.trim();

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, relleno + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Cliente', style: tema.textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _busqueda,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Buscar o escribir un nombre nuevo',
              prefixIcon: Icon(Icons.person_search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          if (tecleado.isNotEmpty && !_yaExiste(todos))
            ListTile(
              leading: _creando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add_alt),
              title: Text('Dar de alta a "$tecleado"'),
              subtitle: const Text('Se agrega al padron y queda elegido'),
              onTap: _creando ? null : _crear,
            ),
          if (widget.permiteNinguno)
            ListTile(
              leading: const Icon(Icons.person_off_outlined),
              title: const Text('Sin cliente'),
              subtitle: const Text('La venta queda sin nombre por ahora'),
              selected: widget.elegido == null,
              onTap: () => Navigator.pop(context, (valor: null)),
            ),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.45,
            ),
            child: coincidencias.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      todos.isEmpty
                          ? 'Todavia no hay clientes. Escribe un nombre para '
                              'dar de alta al primero.'
                          : 'Ninguno se llama asi.',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: coincidencias.length,
                    itemBuilder: (context, i) {
                      final cliente = coincidencias[i];
                      return ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(cliente.titulo),
                        // Debajo del nombre va el telefono y la direccion, no
                        // solo la nota: cuando hay dos personas que se llaman
                        // casi igual, eso es lo que las distingue de un
                        // vistazo sin tener que abrir ninguna ficha.
                        subtitle: cliente.contacto.isEmpty
                            ? null
                            : Text(
                                cliente.contacto,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                        selected: cliente.id == widget.elegido,
                        trailing: cliente.id == widget.elegido
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () => Navigator.pop(context, (valor: cliente)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
