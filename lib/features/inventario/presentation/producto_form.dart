import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets_comunes.dart';
import '../domain/producto.dart';
import '../domain/producto_borrador.dart';
import 'inventario_view_model.dart';

/// Formulario de alta y edicion de un producto: el CRUD del inventario.
///
/// Es una hoja modal y no una pantalla completa porque la captura es corta -
/// cinco campos - y conviene no perder de vista la lista de atras.
///
/// La vista no guarda nada por su cuenta: arma un [ProductoBorrador] o un
/// [Producto] y se lo entrega a [InventarioViewModel]. Si el ViewModel
/// devuelve un mensaje, la hoja se queda abierta con el aviso; si devuelve
/// `null`, se cierra.
class ProductoForm extends ConsumerStatefulWidget {
  const ProductoForm({this.producto, super.key});

  /// El producto a editar, o `null` para dar de alta uno nuevo.
  final Producto? producto;

  /// Abre la hoja. Devuelve `true` si se guardo algo.
  static Future<bool> abrir(BuildContext context, {Producto? producto}) async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ProductoForm(producto: producto),
    );
    return guardado ?? false;
  }

  @override
  ConsumerState<ProductoForm> createState() => _ProductoFormState();
}

class _ProductoFormState extends ConsumerState<ProductoForm> {
  late final TextEditingController _marca;
  late final TextEditingController _codigo;
  late final TextEditingController _descripcion;
  late final TextEditingController _actual;
  late final TextEditingController _original;
  bool _guardando = false;

  bool get _esNuevo => widget.producto == null;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _marca = TextEditingController(text: p?.marca ?? '');
    _codigo = TextEditingController(text: p?.codigo ?? '');
    _descripcion = TextEditingController(text: p?.descripcion ?? '');
    _actual = TextEditingController(text: '${p?.cantidadActual ?? 0}');
    _original = TextEditingController(text: '${p?.cantidadOriginal ?? 0}');
  }

  @override
  void dispose() {
    _marca.dispose();
    _codigo.dispose();
    _descripcion.dispose();
    _actual.dispose();
    _original.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final vm = ref.read(inventarioViewModelProvider.notifier);

    final actual = CampoEntero.leer(_actual);
    final original = CampoEntero.leer(_original);

    final String? error;
    if (_esNuevo) {
      error = await vm.crear(
        ProductoBorrador(
          marca: _marca.text,
          codigo: _codigo.text,
          descripcion: _descripcion.text,
          cantidadActual: actual,
          // Al dar de alta, lo que hay es lo que entro: si la usuaria no
          // captura la original, se toma la actual.
          cantidadOriginal: original == 0 ? actual : original,
        ),
      );
    } else {
      error = await vm.guardar(
        widget.producto!.copyWith(
          marca: _marca.text,
          codigo: _codigo.text,
          descripcion: _descripcion.text,
          cantidadActual: actual,
          cantidadOriginal: original,
        ),
      );
    }

    if (!mounted) return;
    setState(() => _guardando = false);
    if (error != null) {
      avisar(context, error, error: true);
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final relleno = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, relleno + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _esNuevo ? 'Nuevo producto' : 'Editar producto',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CampoTexto(
              etiqueta: 'Marca',
              controlador: _marca,
              autofoco: _esNuevo,
              pista: 'Jafra, Avon, Andrea...',
            ),
            const SizedBox(height: 12),
            CampoTexto(
              etiqueta: 'Codigo',
              controlador: _codigo,
              pista: 'Como viene en el catalogo',
            ),
            const SizedBox(height: 12),
            CampoTexto(
              etiqueta: 'Descripcion',
              controlador: _descripcion,
              lineas: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CampoEntero(
                    etiqueta: 'Cantidad actual',
                    controlador: _actual,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoEntero(
                    etiqueta: 'Cantidad original',
                    controlador: _original,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'La cantidad original es todo lo que ha entrado; la actual es lo '
              'que queda hoy. Al recibir un pedido las dos suben solas.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.check),
              label: Text(_esNuevo ? 'Agregar al inventario' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
