import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets_comunes.dart';
import '../../../core/escala_decimal.dart';
import '../../inventario/domain/existencia.dart';
import '../domain/calculo_linea.dart';
import '../domain/linea_borrador.dart';
import '../domain/linea_pedido.dart';
import 'pedido_detalle_view_model.dart';

/// Captura de una linea de la hoja de pedido, columna por columna.
///
/// Es el formulario del CRUD original: reproduce la hoja impresa que manda la
/// distribuidora, con sus puntos, su precio de revista, su descuento de
/// consultora y sus regalos. Se captura tal cual viene el papel.
///
/// Tres columnas son especiales: `precio total`, `valor prom sin IVA` y `tu
/// pagas` se calculan solas -por `CalculoLinea`- pero se pueden sobrescribir.
/// Cuando la hoja impresa trae otra cifra gana el papel, y el ajuste queda
/// guardado aparte para poder auditarlo. En la interfaz eso se ve como un
/// candado: mientras esta cerrado el campo sigue al calculo, y al abrirlo la
/// usuaria manda.
///
/// Los dos precios de la hoja se parecen y hay que no confundirlos al
/// capturar, asi que el formulario lo dice con todas sus letras: el `precio
/// unitario` es lo que se le paga a la distribuidora, y el `precio revista` lo
/// que se le cobra al cliente.
class LineaPedidoForm extends ConsumerStatefulWidget {
  const LineaPedidoForm({
    required this.pedidoId,
    this.linea,
    this.marcaPredeterminada = '',
    super.key,
  });

  final String pedidoId;

  /// La linea a editar, o `null` para capturar una nueva.
  final LineaPedido? linea;

  /// Marca que propone el encabezado del pedido, para no teclearla en cada
  /// linea cuando toda la hoja es de la misma marca.
  final String marcaPredeterminada;

  static Future<void> abrir(
    BuildContext context, {
    required String pedidoId,
    LineaPedido? linea,
    String marcaPredeterminada = '',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => LineaPedidoForm(
        pedidoId: pedidoId,
        linea: linea,
        marcaPredeterminada: marcaPredeterminada,
      ),
    );
  }

  @override
  ConsumerState<LineaPedidoForm> createState() => _LineaPedidoFormState();
}

class _LineaPedidoFormState extends ConsumerState<LineaPedidoForm> {
  late final TextEditingController _marca;
  late final TextEditingController _codigo;
  late final TextEditingController _descripcion;
  late final TextEditingController _cantPedida;
  late final TextEditingController _cantEnviada;
  late final TextEditingController _puntos;
  late final TextEditingController _precioUnitario;
  late final TextEditingController _precioRevista;
  late final TextEditingController _promocionado;
  late final TextEditingController _descuentoCn;
  late final TextEditingController _regalos;
  late final TextEditingController _precioTotalManual;
  late final TextEditingController _sinIvaManual;
  late final TextEditingController _tuPagasManual;

  String? _productoId;
  bool _precioTotalBloqueado = true;
  bool _sinIvaBloqueado = true;
  bool _tuPagasBloqueado = true;
  bool _guardando = false;

  bool get _esNueva => widget.linea == null;

  @override
  void initState() {
    super.initState();
    final l = widget.linea;
    _productoId = l?.productoId;
    _marca = TextEditingController(text: l?.marca ?? widget.marcaPredeterminada);
    _codigo = TextEditingController(text: l?.codigo ?? '');
    _descripcion = TextEditingController(text: l?.descripcion ?? '');
    _cantPedida = TextEditingController(text: '${l?.cantPedida ?? 1}');
    _cantEnviada = TextEditingController(text: '${l?.cantEnviada ?? 0}');
    _puntos = TextEditingController(
      text: l == null ? '' : puntos.aTexto(l.valorTotalPuntos),
    );
    _precioUnitario = TextEditingController(
      text: l == null ? '' : dinero.aTexto(l.precioUnitario),
    );
    _precioRevista = TextEditingController(
      text: l == null ? '' : dinero.aTexto(l.precioRevista),
    );
    _promocionado = TextEditingController(
      text: l == null ? '' : dinero.aTexto(l.valorTotalPromocionado),
    );
    _descuentoCn = TextEditingController(
      text: l == null ? '' : dinero.aTexto(l.totalDescuentoCn),
    );
    _regalos = TextEditingController(
      text: l == null ? '' : dinero.aTexto(l.valorRegalos),
    );

    _precioTotalBloqueado = l?.precioTotalManual == null;
    _precioTotalManual = TextEditingController(
      text: l?.precioTotalManual == null
          ? ''
          : dinero.aTexto(l!.precioTotalManual!),
    );

    _sinIvaBloqueado = l?.valorPromSinIvaManual == null;
    _tuPagasBloqueado = l?.tuPagasManual == null;
    _sinIvaManual = TextEditingController(
      text: l?.valorPromSinIvaManual == null
          ? ''
          : dinero.aTexto(l!.valorPromSinIvaManual!),
    );
    _tuPagasManual = TextEditingController(
      text: l?.tuPagasManual == null ? '' : dinero.aTexto(l!.tuPagasManual!),
    );
  }

  @override
  void dispose() {
    for (final c in [
      _marca,
      _codigo,
      _descripcion,
      _cantPedida,
      _cantEnviada,
      _puntos,
      _precioUnitario,
      _precioRevista,
      _promocionado,
      _descuentoCn,
      _regalos,
      _precioTotalManual,
      _sinIvaManual,
      _tuPagasManual,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int get _precioUnitarioValor => CampoDecimal.leer(_precioUnitario);
  int get _precioTotalCalculado => CalculoLinea.precioTotal(
        precioUnitario: _precioUnitarioValor,
        cantPedida: CampoEntero.leer(_cantPedida),
      );
  int get _promocionadoValor => CampoDecimal.leer(_promocionado);
  int get _descuentoValor => CampoDecimal.leer(_descuentoCn);
  int get _sinIvaCalculado => CalculoLinea.promSinIva(_promocionadoValor);
  int get _tuPagasCalculado => CalculoLinea.tuPagas(
        valorTotalPromocionado: _promocionadoValor,
        totalDescuentoCn: _descuentoValor,
      );

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final vm = ref.read(pedidoDetalleViewModelProvider(widget.pedidoId).notifier);

    final precioTotal =
        _precioTotalBloqueado ? null : CampoDecimal.leer(_precioTotalManual);
    final sinIva = _sinIvaBloqueado ? null : CampoDecimal.leer(_sinIvaManual);
    final tuPagas =
        _tuPagasBloqueado ? null : CampoDecimal.leer(_tuPagasManual);

    final String? mensaje;
    if (_esNueva) {
      mensaje = await vm.agregarLinea(
        LineaBorrador(
          marca: _marca.text,
          codigo: _codigo.text,
          descripcion: _descripcion.text,
          cantPedida: CampoEntero.leer(_cantPedida),
          cantEnviada: CampoEntero.leer(_cantEnviada),
          valorTotalPuntos: CampoDecimal.leer(_puntos, puntos),
          precioUnitario: _precioUnitarioValor,
          precioRevista: CampoDecimal.leer(_precioRevista),
          valorTotalPromocionado: _promocionadoValor,
          totalDescuentoCn: _descuentoValor,
          valorRegalos: CampoDecimal.leer(_regalos),
          precioTotalManual: precioTotal,
          valorPromSinIvaManual: sinIva,
          tuPagasManual: tuPagas,
          productoId: _productoId,
        ),
      );
    } else {
      mensaje = await vm.guardarLinea(
        widget.linea!.copyWith(
          marca: _marca.text,
          codigo: _codigo.text,
          descripcion: _descripcion.text,
          cantPedida: CampoEntero.leer(_cantPedida),
          cantEnviada: CampoEntero.leer(_cantEnviada),
          valorTotalPuntos: CampoDecimal.leer(_puntos, puntos),
          precioUnitario: _precioUnitarioValor,
          precioRevista: CampoDecimal.leer(_precioRevista),
          valorTotalPromocionado: _promocionadoValor,
          totalDescuentoCn: _descuentoValor,
          valorRegalos: CampoDecimal.leer(_regalos),
          precioTotalManual: (valor: precioTotal),
          valorPromSinIvaManual: (valor: sinIva),
          tuPagasManual: (valor: tuPagas),
          productoId: (valor: _productoId),
        ),
      );
    }

    if (!mounted) return;
    setState(() => _guardando = false);
    if (mensaje != null) {
      avisar(context, mensaje, error: true);
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(pedidoDetalleViewModelProvider(widget.pedidoId));
    final relleno = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, relleno + 16),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.85,
        child: ListView(
          children: [
            Text(
              _esNueva ? 'Nueva linea del pedido' : 'Editar linea',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _SelectorCatalogo(
              existencias: estado.existencias,
              productoId: _productoId,
              onElegir: (existencia) => setState(() {
                _productoId = existencia.producto.id;
                _marca.text = existencia.producto.marca;
                _codigo.text = existencia.producto.codigo;
                _descripcion.text = existencia.producto.descripcion;
              }),
              onSoltar: () => setState(() => _productoId = null),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            _Subtitulo('Cantidades'),
            Row(
              children: [
                Expanded(
                  child: CampoEntero(
                    etiqueta: 'Cant. pedida',
                    controlador: _cantPedida,
                    alCambiar: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoEntero(
                    etiqueta: 'Cant. enviada',
                    controlador: _cantEnviada,
                    alCambiar: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Al recibir el pedido, la cantidad enviada es la que entra al '
              'inventario. La diferencia queda como faltante.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            _Subtitulo('Precios'),
            Row(
              children: [
                Expanded(
                  child: CampoDecimal(
                    etiqueta: 'Precio unitario',
                    controlador: _precioUnitario,
                    alCambiar: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoDecimal(
                    etiqueta: 'Precio revista',
                    controlador: _precioRevista,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'El precio unitario es lo que le pagas a la distribuidora por '
              'una pieza. El de revista es lo que trae el catalogo para el '
              'cliente.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            _Subtitulo('Importes de la hoja'),
            Row(
              children: [
                Expanded(
                  child: CampoDecimal(
                    etiqueta: 'Valor total puntos',
                    controlador: _puntos,
                    escala: puntos,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoDecimal(
                    etiqueta: 'Valor total promocionado',
                    controlador: _promocionado,
                    alCambiar: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CampoDecimal(
                    etiqueta: 'Total descuento CN',
                    controlador: _descuentoCn,
                    alCambiar: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoDecimal(
                    etiqueta: 'Valor regalos',
                    controlador: _regalos,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Subtitulo('Columnas calculadas'),
            _CampoConCandado(
              etiqueta: 'Precio total',
              controlador: _precioTotalManual,
              bloqueado: _precioTotalBloqueado,
              calculado: _precioTotalCalculado,
              pista: 'Precio unitario x cantidad pedida',
              alAlternar: () => setState(() {
                _precioTotalBloqueado = !_precioTotalBloqueado;
                if (!_precioTotalBloqueado && _precioTotalManual.text.isEmpty) {
                  _precioTotalManual.text = dinero.aTexto(_precioTotalCalculado);
                }
              }),
            ),
            const SizedBox(height: 12),
            _CampoConCandado(
              etiqueta: 'Valor prom. sin IVA',
              controlador: _sinIvaManual,
              bloqueado: _sinIvaBloqueado,
              calculado: _sinIvaCalculado,
              alAlternar: () => setState(() {
                _sinIvaBloqueado = !_sinIvaBloqueado;
                if (!_sinIvaBloqueado && _sinIvaManual.text.isEmpty) {
                  _sinIvaManual.text = dinero.aTexto(_sinIvaCalculado);
                }
              }),
            ),
            const SizedBox(height: 12),
            _CampoConCandado(
              etiqueta: 'Tu pagas',
              controlador: _tuPagasManual,
              bloqueado: _tuPagasBloqueado,
              calculado: _tuPagasCalculado,
              alAlternar: () => setState(() {
                _tuPagasBloqueado = !_tuPagasBloqueado;
                if (!_tuPagasBloqueado && _tuPagasManual.text.isEmpty) {
                  _tuPagasManual.text = dinero.aTexto(_tuPagasCalculado);
                }
              }),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.check),
              label: Text(_esNueva ? 'Agregar linea' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Subtitulo extends StatelessWidget {
  const _Subtitulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
      ),
    );
  }
}

/// Un campo derivado que se puede sobrescribir.
///
/// Cerrado muestra lo que da la formula y no se puede teclear; abierto acepta
/// lo que diga el papel. Es la traduccion visual de los campos
/// `valorPromSinIvaManual` y `tuPagasManual` del dominio, donde `null`
/// significa "sigue el calculo".
class _CampoConCandado extends StatelessWidget {
  const _CampoConCandado({
    required this.etiqueta,
    required this.controlador,
    required this.bloqueado,
    required this.calculado,
    required this.alAlternar,
    this.pista = 'Calculado',
  });

  final String etiqueta;
  final TextEditingController controlador;
  final bool bloqueado;
  final int calculado;
  final VoidCallback alAlternar;

  /// Que dice el pie del campo mientras esta cerrado: de donde sale la cifra.
  final String pista;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: bloqueado
              ? InputDecorator(
                  decoration: InputDecoration(
                    labelText: etiqueta,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    helperText: pista,
                  ),
                  child: Text(dinero.formatear(calculado)),
                )
              : CampoDecimal(etiqueta: etiqueta, controlador: controlador),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: bloqueado ? 'Capturar a mano' : 'Volver al calculo',
          onPressed: alAlternar,
          icon: Icon(bloqueado ? Icons.lock_outline : Icons.lock_open),
        ),
      ],
    );
  }
}

/// Selector del catalogo para resurtir sin volver a teclear los datos.
class _SelectorCatalogo extends StatelessWidget {
  const _SelectorCatalogo({
    required this.existencias,
    required this.productoId,
    required this.onElegir,
    required this.onSoltar,
  });

  final List<Existencia> existencias;
  final String? productoId;
  final ValueChanged<Existencia> onElegir;
  final VoidCallback onSoltar;

  @override
  Widget build(BuildContext context) {
    Existencia? elegido;
    for (final e in existencias) {
      if (e.producto.id == productoId) elegido = e;
    }

    if (elegido != null) {
      return Card.filled(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: const Icon(Icons.inventory_2),
          title: Text(elegido.producto.titulo),
          subtitle: Text(
            'Quedan ${elegido.producto.cantidadActual} en inventario',
          ),
          trailing: IconButton(
            tooltip: 'Capturar a mano',
            onPressed: onSoltar,
            icon: const Icon(Icons.link_off),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: existencias.isEmpty
          ? null
          : () async {
              final elegido = await showModalBottomSheet<Existencia>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => _ListaResurtido(existencias: existencias),
              );
              if (elegido != null) onElegir(elegido);
            },
      icon: const Icon(Icons.replay),
      label: Text(
        existencias.isEmpty
            ? 'Todavia no hay inventario: captura a mano'
            : 'Resurtir algo del inventario',
      ),
    );
  }
}

class _ListaResurtido extends StatelessWidget {
  const _ListaResurtido({required this.existencias});

  final List<Existencia> existencias;

  @override
  Widget build(BuildContext context) {
    // Lo agotado primero: es justo lo que hay que volver a pedir.
    final lista = [...existencias]
      ..sort((a, b) => a.producto.cantidadActual
          .compareTo(b.producto.cantidadActual));

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: ListView.separated(
        itemCount: lista.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final existencia = lista[i];
          return ListTile(
            onTap: () => Navigator.pop(context, existencia),
            title: Text(
              existencia.producto.descripcion.isEmpty
                  ? existencia.producto.titulo
                  : existencia.producto.descripcion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              [
                if (existencia.producto.marca.isNotEmpty)
                  existencia.producto.marca,
                if (existencia.producto.codigo.isNotEmpty)
                  '#${existencia.producto.codigo}',
              ].join('  '),
            ),
            trailing: existencia.producto.agotado
                ? Insignia(
                    'Agotado',
                    color: Theme.of(context).colorScheme.error,
                  )
                : Text('${existencia.producto.cantidadActual}'),
          );
        },
      ),
    );
  }
}
