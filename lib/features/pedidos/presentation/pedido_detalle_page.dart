import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets_comunes.dart';
import '../../../core/escala_decimal.dart';
import '../../../core/formato.dart';
import '../domain/linea_pedido.dart';
import '../domain/pedido.dart';
import 'linea_pedido_form.dart';
import 'pedido_detalle_view_model.dart';
import 'pedidos_view_model.dart';

/// La hoja de pedido completa, con todas las columnas de la distribuidora.
///
/// Es el CRUD tabular original del sistema. Abajo de la tabla esta el boton
/// que le da sentido a todo: recibir, que convierte lo enviado en existencias
/// del inventario y a partir de ahi se puede vender.
class PedidoDetallePage extends ConsumerWidget {
  const PedidoDetallePage({required this.pedidoId, super.key});

  final String pedidoId;

  static Future<void> abrir(BuildContext context, String pedidoId) {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PedidoDetallePage(pedidoId: pedidoId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(pedidoDetalleViewModelProvider(pedidoId));
    final vm = ref.read(pedidoDetalleViewModelProvider(pedidoId).notifier);

    return estado.detalle.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('No se pudo leer el pedido: $e')),
      ),
      data: (detalle) {
        if (detalle == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EstadoVacio(
              icono: Icons.description_outlined,
              titulo: 'Este pedido ya no existe',
              detalle: 'Se elimino desde otra pantalla.',
            ),
          );
        }
        return _Contenido(
          detalle: detalle,
          vm: vm,
          editable: estado.editable,
        );
      },
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.detalle,
    required this.vm,
    required this.editable,
  });

  final PedidoDetallado detalle;
  final PedidoDetalleViewModel vm;
  final bool editable;

  @override
  Widget build(BuildContext context) {
    final pedido = detalle.pedido;

    return Scaffold(
      appBar: AppBar(
        title: Text(pedido.titulo),
        actions: [
          IconButton(
            tooltip: 'Editar encabezado',
            onPressed: () => _EditarEncabezado.abrir(context, pedido, vm),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      floatingActionButton: editable
          ? FloatingActionButton.extended(
              heroTag: 'fab-pedido-detalle',
              onPressed: () => LineaPedidoForm.abrir(
                context,
                pedidoId: pedido.id,
                marcaPredeterminada: pedido.marcaPredeterminada,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Linea'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          _Encabezado(detalle: detalle),
          const SizedBox(height: 8),
          if (detalle.lineas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                'Captura las lineas tal como vienen en la hoja de la '
                'distribuidora.',
              ),
            )
          else
            _Tabla(
              detalle: detalle,
              editable: editable,
              onEditar: (linea) => LineaPedidoForm.abrir(
                context,
                pedidoId: detalle.pedido.id,
                linea: linea,
              ),
              onEliminar: (linea) => _borrarLinea(context, linea),
            ),
          const SizedBox(height: 16),
          _Recepcion(detalle: detalle, vm: vm),
        ],
      ),
    );
  }

  Future<void> _borrarLinea(BuildContext context, LineaPedido linea) async {
    final seguro = await confirmar(
      context,
      titulo: 'Quitar linea',
      mensaje: 'Se quitara de la hoja.',
      aceptar: 'Quitar',
      peligroso: true,
    );
    if (seguro) await vm.eliminarLinea(linea);
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.detalle});

  final PedidoDetallado detalle;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final pedido = detalle.pedido;
    final totales = detalle.totales;

    return Container(
      width: double.infinity,
      color: tema.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(pedido.titulo, style: tema.textTheme.headlineSmall),
              ),
              if (pedido.recibido)
                Insignia(
                  'Recibido',
                  color: tema.colorScheme.primary,
                  icono: Icons.inventory,
                )
              else
                Insignia(
                  'En camino',
                  color: tema.colorScheme.tertiary,
                  icono: Icons.local_shipping_outlined,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            Formato.fecha(pedido.fecha) +
                (pedido.recibidoEn == null
                    ? ''
                    : '  ·  recibido ${Formato.fechaHora(pedido.recibidoEn!)}'),
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              DatoResumen(
                etiqueta: 'Tu pagas',
                valor: dinero.formatear(totales.tuPagas),
                destacado: true,
              ),
              DatoResumen(
                etiqueta: 'Costo de compra',
                valor: dinero.formatear(totales.precioTotal),
              ),
              DatoResumen(
                etiqueta: 'Promocionado',
                valor: dinero.formatear(totales.valorTotalPromocionado),
              ),
              DatoResumen(
                etiqueta: 'IVA',
                valor: dinero.formatear(totales.iva),
              ),
              DatoResumen(
                etiqueta: 'Puntos',
                valor: puntos.formatear(totales.valorTotalPuntos),
              ),
              DatoResumen(
                etiqueta: 'Pedidas / enviadas',
                valor: '${totales.cantPedida} / ${totales.cantEnviada}',
                color: totales.tieneFaltantes ? tema.colorScheme.error : null,
              ),
            ],
          ),
          if (pedido.notas.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(pedido.notas, style: tema.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// La tabla de la hoja, con todas sus columnas.
///
/// Se desplaza a lo ancho porque son trece columnas y ninguna sobra: la
/// propietaria compara este renglon contra el papel impreso, columna por
/// columna, y esconder una la obligaria a abrir cada linea para revisarla.
///
/// `Unitario` y `Total` son el precio de compra -lo que se le paga a la
/// distribuidora-; `Revista` es el precio de venta al publico. Van pegadas a
/// proposito para que la diferencia entre las dos se lea de un vistazo.
class _Tabla extends StatelessWidget {
  const _Tabla({
    required this.detalle,
    required this.editable,
    required this.onEditar,
    required this.onEliminar,
  });

  final PedidoDetallado detalle;
  final bool editable;
  final ValueChanged<LineaPedido> onEditar;
  final ValueChanged<LineaPedido> onEliminar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final totales = detalle.totales;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 18,
        headingRowHeight: 44,
        columns: const [
          DataColumn(label: Text('Marca')),
          DataColumn(label: Text('Codigo')),
          DataColumn(label: Text('Descripcion')),
          DataColumn(label: Text('Ped.'), numeric: true),
          DataColumn(label: Text('Env.'), numeric: true),
          DataColumn(label: Text('Falt.'), numeric: true),
          DataColumn(label: Text('Puntos'), numeric: true),
          DataColumn(label: Text('Unitario'), numeric: true),
          DataColumn(label: Text('Total'), numeric: true),
          DataColumn(label: Text('Revista'), numeric: true),
          DataColumn(label: Text('Promocionado'), numeric: true),
          DataColumn(label: Text('Sin IVA'), numeric: true),
          DataColumn(label: Text('Desc. CN'), numeric: true),
          DataColumn(label: Text('Regalos'), numeric: true),
          DataColumn(label: Text('Tu pagas'), numeric: true),
          DataColumn(label: Text('')),
        ],
        rows: [
          for (final linea in detalle.lineas)
            DataRow(
              cells: [
                DataCell(Text(linea.marca)),
                DataCell(Text(linea.codigo)),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            linea.descripcion,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (linea.tieneAjusteManual) ...[
                          const SizedBox(width: 4),
                          Tooltip(
                            message: 'Tiene columnas capturadas a mano',
                            child: Icon(
                              Icons.edit_note,
                              size: 16,
                              color: tema.colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  onTap: editable ? () => onEditar(linea) : null,
                ),
                DataCell(Text('${linea.cantPedida}')),
                DataCell(Text('${linea.cantEnviada}')),
                DataCell(
                  Text(
                    linea.faltantes == 0 ? '-' : '${linea.faltantes}',
                    style: TextStyle(
                      color:
                          linea.tieneFaltantes ? tema.colorScheme.error : null,
                      fontWeight:
                          linea.tieneFaltantes ? FontWeight.w700 : null,
                    ),
                  ),
                ),
                DataCell(Text(puntos.formatear(linea.valorTotalPuntos))),
                DataCell(Text(dinero.formatear(linea.precioUnitario))),
                DataCell(Text(dinero.formatear(linea.precioTotal))),
                DataCell(Text(dinero.formatear(linea.precioRevista))),
                DataCell(
                  Text(dinero.formatear(linea.valorTotalPromocionado)),
                ),
                DataCell(Text(dinero.formatear(linea.valorPromSinIva))),
                DataCell(Text(dinero.formatear(linea.totalDescuentoCn))),
                DataCell(Text(dinero.formatear(linea.valorRegalos))),
                DataCell(
                  Text(
                    dinero.formatear(linea.tuPagas),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(
                  editable
                      ? IconButton(
                          tooltip: 'Quitar',
                          onPressed: () => onEliminar(linea),
                          icon: const Icon(Icons.close, size: 18),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          // Renglon de totales, como el que trae la hoja al pie.
          DataRow(
            color: WidgetStatePropertyAll(
              tema.colorScheme.surfaceContainerHighest,
            ),
            cells: [
              const DataCell(
                Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const DataCell(Text('')),
              DataCell(Text('${totales.lineas} lineas')),
              DataCell(Text('${totales.cantPedida}')),
              DataCell(Text('${totales.cantEnviada}')),
              DataCell(
                Text(
                  totales.faltantes == 0 ? '-' : '${totales.faltantes}',
                  style: TextStyle(
                    color:
                        totales.tieneFaltantes ? tema.colorScheme.error : null,
                  ),
                ),
              ),
              DataCell(Text(puntos.formatear(totales.valorTotalPuntos))),
              // El precio unitario no se suma: un precio por pieza sumado
              // entre renglones distintos no significa nada.
              const DataCell(Text('')),
              DataCell(Text(dinero.formatear(totales.precioTotal))),
              const DataCell(Text('')),
              DataCell(
                Text(dinero.formatear(totales.valorTotalPromocionado)),
              ),
              DataCell(Text(dinero.formatear(totales.valorPromSinIva))),
              DataCell(Text(dinero.formatear(totales.totalDescuentoCn))),
              DataCell(Text(dinero.formatear(totales.valorRegalos))),
              DataCell(
                Text(
                  dinero.formatear(totales.tuPagas),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const DataCell(Text('')),
            ],
          ),
        ],
      ),
    );
  }
}

/// El boton que surte el pedido al inventario.
class _Recepcion extends StatelessWidget {
  const _Recepcion({required this.detalle, required this.vm});

  final PedidoDetallado detalle;
  final PedidoDetalleViewModel vm;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    if (detalle.pedido.recibido) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: tema.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ya recibido: ${detalle.piezasAlInventario} piezas entraron '
                'al inventario. La hoja queda cerrada para no descuadrar las '
                'existencias.',
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: detalle.sePuedeRecibir
                ? () => _recibir(context)
                : null,
            icon: const Icon(Icons.move_to_inbox),
            label: Text(
              detalle.sePuedeRecibir
                  ? 'Recibir ${detalle.piezasAlInventario} piezas al inventario'
                  : 'Captura la cantidad enviada para poder recibir',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los productos que todavia no existan en el inventario se dan de '
            'alta solos con la marca, el codigo y la descripcion de la hoja.',
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _recibir(BuildContext context) async {
    final seguro = await confirmar(
      context,
      titulo: 'Recibir el pedido',
      mensaje: '${detalle.piezasAlInventario} piezas entraran al inventario y '
          'la hoja quedara cerrada. Esto no se puede deshacer desde aqui.',
      aceptar: 'Recibir',
    );
    if (seguro) await vm.recibir();
  }
}

/// Hoja para editar el catalogo, la marca, la fecha y las notas del pedido.
class _EditarEncabezado extends StatefulWidget {
  const _EditarEncabezado({required this.pedido, required this.vm});

  final Pedido pedido;
  final PedidoDetalleViewModel vm;

  static Future<void> abrir(
    BuildContext context,
    Pedido pedido,
    PedidoDetalleViewModel vm,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EditarEncabezado(pedido: pedido, vm: vm),
    );
  }

  @override
  State<_EditarEncabezado> createState() => _EditarEncabezadoState();
}

class _EditarEncabezadoState extends State<_EditarEncabezado> {
  late final TextEditingController _campana;
  late final TextEditingController _marca;
  late final TextEditingController _notas;
  late DateTime _fecha;

  @override
  void initState() {
    super.initState();
    _campana = TextEditingController(text: widget.pedido.campana);
    _marca = TextEditingController(text: widget.pedido.marcaPredeterminada);
    _notas = TextEditingController(text: widget.pedido.notas);
    _fecha = widget.pedido.fecha;
  }

  @override
  void dispose() {
    _campana.dispose();
    _marca.dispose();
    _notas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final relleno = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, relleno + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Datos del pedido',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          CampoTexto(
            etiqueta: 'Nombre del catalogo',
            controlador: _campana,
            pista: 'Catalogo 9, C-14, Navidad...',
          ),
          const SizedBox(height: 12),
          CampoTexto(
            etiqueta: 'Marca predeterminada',
            controlador: _marca,
            pista: 'Se propone al capturar cada linea',
          ),
          const SizedBox(height: 12),
          CampoTexto(etiqueta: 'Notas', controlador: _notas, lineas: 2),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final elegida = await showDatePicker(
                context: context,
                initialDate: _fecha,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                helpText: 'Fecha del pedido',
              );
              if (elegida != null) setState(() => _fecha = elegida);
            },
            icon: const Icon(Icons.event),
            label: Text('Fecha: ${Formato.fecha(_fecha)}'),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () async {
              await widget.vm.guardarEncabezado(
                campana: _campana.text,
                marcaPredeterminada: _marca.text,
                notas: _notas.text,
                fecha: _fecha,
              );
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
            label: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
