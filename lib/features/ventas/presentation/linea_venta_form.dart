import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets_comunes.dart';
import '../../../core/escala_decimal.dart';
import '../../inventario/domain/existencia.dart';
import '../domain/linea_venta.dart';
import '../domain/linea_venta_borrador.dart';
import 'venta_detalle_view_model.dart';

/// Formulario de un renglon de venta.
///
/// Es la pantalla donde el inventario y la venta se tocan: arriba se elige del
/// catalogo -se toca la marca y sale su rejilla, se toca el codigo y sale la
/// rejilla de productos de esa marca- y abajo se dice cuantas piezas y a que
/// precio. Elegir del catalogo copia marca, codigo y descripcion al renglon y
/// guarda el `productoId`, que es lo que despues permitira descontar
/// existencias al entregar.
///
/// Lo que ya existe en el catalogo no se teclea: se toca el campo y se elige
/// de una rejilla. El codigo es el que manda porque es como la propietaria
/// llama al articulo, y tecleado se equivoca: un codigo mal escrito deja el
/// renglon apuntando a nada, y eso es justo lo que despues no se puede cuadrar
/// contra el inventario. La descripcion viene sola con lo elegido. Lo que
/// cambia en cada venta -cantidad, precio unitario y descuento del renglon- si
/// se teclea, porque no hay de donde elegirlo.
///
/// Tambien se puede capturar a mano, sin producto: esa venta cobra pero no
/// mueve inventario, y sirve para lo que no esta dado de alta.
class LineaVentaForm extends ConsumerStatefulWidget {
  const LineaVentaForm({required this.ventaId, this.linea, super.key});

  final String ventaId;

  /// El renglon a editar, o `null` para agregar uno nuevo.
  final LineaVenta? linea;

  static Future<void> abrir(
    BuildContext context, {
    required String ventaId,
    LineaVenta? linea,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => LineaVentaForm(ventaId: ventaId, linea: linea),
    );
  }

  @override
  ConsumerState<LineaVentaForm> createState() => _LineaVentaFormState();
}

class _LineaVentaFormState extends ConsumerState<LineaVentaForm> {
  late final TextEditingController _marca;
  late final TextEditingController _codigo;
  late final TextEditingController _descripcion;
  late final TextEditingController _cantidad;
  late final TextEditingController _precio;
  late final TextEditingController _descuento;

  String? _productoId;

  /// Cierto cuando el renglon se captura tecleando, sin producto del catalogo.
  ///
  /// Un renglon ya guardado sin `productoId` se reabre asi: se capturo a mano
  /// en su momento, y mostrarlo como si viniera del catalogo esconderia lo que
  /// la propietaria tecleo.
  late bool _aMano;

  bool _guardando = false;

  bool get _esNueva => widget.linea == null;

  @override
  void initState() {
    super.initState();
    final l = widget.linea;
    _productoId = l?.productoId;
    _aMano = l != null && l.productoId == null;
    _marca = TextEditingController(text: l?.marca ?? '');
    _codigo = TextEditingController(text: l?.codigo ?? '');
    _descripcion = TextEditingController(text: l?.descripcion ?? '');
    _cantidad = TextEditingController(text: '${l?.cantidad ?? 1}');
    _precio = TextEditingController(
      text: l == null ? '' : dinero.aTexto(l.precioUnitario),
    );
    _descuento = TextEditingController(
      text: l == null || l.descuento == 0 ? '' : dinero.aTexto(l.descuento),
    );
  }

  @override
  void dispose() {
    _marca.dispose();
    _codigo.dispose();
    _descripcion.dispose();
    _cantidad.dispose();
    _precio.dispose();
    _descuento.dispose();
    super.dispose();
  }

  /// El articulo del catalogo al que apunta el renglon, si todavia existe.
  Existencia? _elegido(List<Existencia> existencias) {
    if (_productoId == null) return null;
    for (final e in existencias) {
      if (e.producto.id == _productoId) return e;
    }
    return null;
  }

  /// Deja el renglon sin producto. Va sin `setState`: lo llaman quienes ya
  /// estan dentro de uno.
  void _limpiarProducto() {
    _productoId = null;
    _codigo.clear();
    _descripcion.clear();
  }

  /// Abre la rejilla de marcas y filtra por la que se elija.
  ///
  /// Cambiar de marca suelta el producto que no le pertenece: un renglon no
  /// puede decir una marca y apuntar a un articulo de otra.
  Future<void> _abrirMarcas(List<Existencia> existencias) async {
    final marca = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _RejillaMarcas(
        existencias: existencias,
        elegida: _marca.text.trim(),
      ),
    );
    if (marca == null || !mounted) return;
    setState(() {
      final elegido = _elegido(existencias);
      if (marca.isNotEmpty &&
          elegido != null &&
          elegido.producto.marca.trim() != marca) {
        _limpiarProducto();
      }
      _marca.text = marca;
    });
  }

  /// Abre la rejilla del inventario y copia al renglon lo que se elija.
  ///
  /// Se copia y no se referencia porque la venta es un documento historico: si
  /// manana cambia la descripcion del producto, esta venta debe seguir
  /// diciendo lo de hoy.
  Future<void> _abrirProductos(List<Existencia> existencias) async {
    final elegido = await showModalBottomSheet<Existencia>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _RejillaProductos(
        existencias: existencias,
        marca: _marca.text.trim(),
      ),
    );
    if (elegido == null || !mounted) return;
    setState(() {
      _productoId = elegido.producto.id;
      _marca.text = elegido.producto.marca;
      _codigo.text = elegido.producto.codigo;
      _descripcion.text = elegido.producto.descripcion;
    });
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final vm =
        ref.read(ventaDetalleViewModelProvider(widget.ventaId).notifier);

    final cantidad = CampoEntero.leer(_cantidad);
    final precio = CampoDecimal.leer(_precio);
    final descuento = CampoDecimal.leer(_descuento);

    final String? mensaje;
    if (_esNueva) {
      mensaje = await vm.agregarLinea(
        LineaVentaBorrador(
          productoId: _productoId,
          marca: _marca.text,
          codigo: _codigo.text,
          descripcion: _descripcion.text,
          cantidad: cantidad,
          precioUnitario: precio,
          descuento: descuento,
        ),
      );
    } else {
      mensaje = await vm.guardarLinea(
        widget.linea!.copyWith(
          productoId: (valor: _productoId),
          marca: _marca.text,
          codigo: _codigo.text,
          descripcion: _descripcion.text,
          cantidad: cantidad,
          precioUnitario: precio,
          descuento: descuento,
        ),
      );
    }

    if (!mounted) return;
    setState(() => _guardando = false);

    // Un mensaje al agregar puede ser un rechazo (no se guardo) o un aviso de
    // sobreventa (si se guardo). Se distinguen por si el renglon existe ya:
    // el ViewModel solo avisa de sobreventa despues de haber guardado.
    final seGuardo = mensaje == null || mensaje.startsWith('Cuidado');
    avisar(context, mensaje, error: !seGuardo);
    if (seGuardo) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(ventaDetalleViewModelProvider(widget.ventaId));
    final existencias = estado.existencias;
    // Sin catalogo no hay de donde elegir: el formulario cae a captura a mano
    // aunque nadie se lo haya pedido.
    final aMano = _aMano || existencias.isEmpty;
    final relleno = MediaQuery.viewInsetsOf(context).bottom;
    final cantidad = CampoEntero.leer(_cantidad);
    final importe =
        (cantidad * CampoDecimal.leer(_precio)) - CampoDecimal.leer(_descuento);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, relleno + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _esNueva ? 'Agregar producto a la venta' : 'Editar renglon',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton.icon(
                  onPressed: existencias.isEmpty
                      ? null
                      : () => setState(() {
                            _aMano = !_aMano;
                            // Pasar a captura a mano desliga el renglon del
                            // inventario: de ahi en adelante es texto libre.
                            if (_aMano) _productoId = null;
                          }),
                  icon: Icon(
                    aMano ? Icons.grid_view_outlined : Icons.edit_outlined,
                    size: 18,
                  ),
                  label: Text(aMano ? 'Del inventario' : 'A mano'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (aMano)
              ..._camposAMano(existencias.isEmpty)
            else
              ..._camposDelCatalogo(existencias),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CampoEntero(
                    etiqueta: 'Cantidad',
                    controlador: _cantidad,
                    alCambiar: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CampoDecimal(
                    etiqueta: 'Precio unitario',
                    controlador: _precio,
                    alCambiar: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CampoDecimal(
              etiqueta: 'Descuento del renglon',
              controlador: _descuento,
              alCambiar: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Importe del renglon'),
                  Text(
                    dinero.formatear(importe < 0 ? 0 : importe),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.check),
              label: Text(_esNueva ? 'Agregar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Marca y codigo se tocan y abren su rejilla; la descripcion viene con el
  /// producto elegido.
  List<Widget> _camposDelCatalogo(List<Existencia> existencias) {
    final tema = Theme.of(context);
    final elegido = _elegido(existencias);

    return [
      CampoSelector(
        etiqueta: 'Marca',
        valor: _marca.text,
        pista: 'Toca para ver las marcas',
        icono: Icons.sell_outlined,
        alTocar: () => _abrirMarcas(existencias),
      ),
      const SizedBox(height: 12),
      CampoSelector(
        etiqueta: 'Codigo',
        valor: _codigo.text,
        // Se dice de donde saldra la rejilla, porque no es la misma lista si
        // ya hay marca elegida que si no.
        pista: _marca.text.trim().isEmpty
            ? 'Toca para elegir del inventario'
            : 'Toca para ver los productos ${_marca.text.trim()}',
        icono: Icons.qr_code_2,
        alTocar: () => _abrirProductos(existencias),
      ),
      if (elegido != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: Text(
            '${elegido.disponibles} disponibles de '
            '${elegido.producto.cantidadActual} en existencia',
            style: tema.textTheme.bodySmall?.copyWith(
              color: elegido.disponibles <= 0
                  ? tema.colorScheme.error
                  : tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      const SizedBox(height: 12),
      _CampoAutorrellenado(
        etiqueta: 'Descripcion',
        valor: _descripcion.text,
        pista: 'Se rellena al elegir el producto',
        icono: Icons.inventory_2_outlined,
      ),
    ];
  }

  /// Lo que no esta en el inventario se teclea entero.
  List<Widget> _camposAMano(bool catalogoVacio) {
    return [
      if (catalogoVacio)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Tu inventario esta vacio: captura el producto a mano. Esta venta '
            'cobra, pero no movera existencias.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      Row(
        children: [
          Expanded(
            child: CampoTexto(etiqueta: 'Marca', controlador: _marca),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CampoTexto(etiqueta: 'Codigo', controlador: _codigo),
          ),
        ],
      ),
      const SizedBox(height: 12),
      CampoTexto(
        etiqueta: 'Descripcion',
        controlador: _descripcion,
        lineas: 2,
      ),
    ];
  }
}

/// Un dato que llega solo desde el catalogo y por eso no se teclea.
///
/// Se muestra apagado en vez de esconderse: la propietaria necesita ver con
/// que codigo quedo el renglon, aunque no lo escriba ella.
class _CampoAutorrellenado extends StatelessWidget {
  const _CampoAutorrellenado({
    required this.etiqueta,
    required this.valor,
    required this.pista,
    required this.icono,
  });

  final String etiqueta;
  final String valor;
  final String pista;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final vacio = valor.trim().isEmpty;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: etiqueta,
        border: const OutlineInputBorder(),
        isDense: true,
        enabled: false,
        prefixIcon: Icon(icono, size: 20),
      ),
      child: Text(
        vacio ? pista : valor,
        style:
            vacio ? TextStyle(color: tema.colorScheme.onSurfaceVariant) : null,
      ),
    );
  }
}

/// Rejilla de marcas del inventario.
///
/// Se arma con lo que hay capturado y no con una lista fija: las marcas que
/// maneja la propietaria cambian, y una lista fija se queda corta el dia que
/// entra una nueva. La primera casilla quita el filtro, porque a veces se
/// busca por descripcion sin acordarse de la marca.
class _RejillaMarcas extends StatelessWidget {
  const _RejillaMarcas({required this.existencias, required this.elegida});

  final List<Existencia> existencias;
  final String elegida;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cuantos = <String, int>{};
    for (final e in existencias) {
      final marca = e.producto.marca.trim();
      if (marca.isEmpty) continue;
      cuantos[marca] = (cuantos[marca] ?? 0) + 1;
    }
    final marcas = cuantos.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text('Elige la marca', style: tema.textTheme.titleMedium),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 190,
                mainAxisExtent: 78,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: marcas.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return _Casilla(
                    activa: elegida.isEmpty,
                    alTocar: () => Navigator.pop(context, ''),
                    titulo: 'Todas las marcas',
                    detalle: '${existencias.length} productos',
                  );
                }
                final marca = marcas[i - 1];
                return _Casilla(
                  activa: marca == elegida,
                  alTocar: () => Navigator.pop(context, marca),
                  titulo: marca,
                  detalle: '${cuantos[marca]} productos',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Una casilla de la rejilla de marcas.
class _Casilla extends StatelessWidget {
  const _Casilla({
    required this.activa,
    required this.alTocar,
    required this.titulo,
    required this.detalle,
  });

  final bool activa;
  final VoidCallback alTocar;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: activa ? tema.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: alTocar,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                detalle,
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rejilla del catalogo dentro del formulario.
///
/// Cada casilla dice lo disponible -existencia menos apartado- y no lo que hay
/// en casa, porque lo que ya esta prometido a otro cliente no se puede volver
/// a prometer. Deja igualmente elegir un producto sin disponibles: la
/// propietaria a veces vende algo que sabe que llega en el proximo pedido, y
/// el aviso de sobreventa se lo recuerda al guardar.
class _RejillaProductos extends StatefulWidget {
  const _RejillaProductos({required this.existencias, required this.marca});

  final List<Existencia> existencias;

  /// Marca con la que entra filtrada, o vacio para ver todo el catalogo.
  final String marca;

  @override
  State<_RejillaProductos> createState() => _RejillaProductosState();
}

class _RejillaProductosState extends State<_RejillaProductos> {
  late String _marca;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _marca = widget.marca;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final texto = _busqueda.trim().toLowerCase();
    final lista = widget.existencias.where((e) {
      final p = e.producto;
      if (_marca.isNotEmpty && p.marca.trim() != _marca) return false;
      if (texto.isEmpty) return true;
      return p.marca.toLowerCase().contains(texto) ||
          p.codigo.toLowerCase().contains(texto) ||
          p.descripcion.toLowerCase().contains(texto);
    }).toList();

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              hintText: 'Buscar en el inventario',
              autoFocus: true,
              leading: const Icon(Icons.search),
              onChanged: (valor) => setState(() => _busqueda = valor),
            ),
          ),
          if (_marca.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  label: Text(_marca),
                  avatar: const Icon(Icons.sell_outlined, size: 18),
                  onDeleted: () => setState(() => _marca = ''),
                ),
              ),
            ),
          Expanded(
            child: lista.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Nada coincide con lo que buscas.',
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 230,
                      mainAxisExtent: 142,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: lista.length,
                    itemBuilder: (context, i) =>
                        _TarjetaProducto(existencia: lista[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Una casilla de la rejilla del catalogo.
class _TarjetaProducto extends StatelessWidget {
  const _TarjetaProducto({required this.existencia});

  final Existencia existencia;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final producto = existencia.producto;
    final agotado = existencia.disponibles <= 0;

    return Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pop(context, existencia),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      producto.marca.isEmpty ? 'Sin marca' : producto.marca,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.labelSmall?.copyWith(
                        color: tema.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    '${existencia.disponibles}',
                    style: tema.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: agotado ? tema.colorScheme.error : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  producto.descripcion.isEmpty
                      ? producto.titulo
                      : producto.descripcion,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                producto.codigo.isEmpty ? 'Sin codigo' : '#${producto.codigo}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
