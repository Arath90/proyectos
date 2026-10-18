import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets_comunes.dart';
import '../../../core/escala_decimal.dart';
import '../../../core/formato.dart';
import '../../clientes/domain/cliente.dart';
import '../../clientes/presentation/selector_cliente.dart';
import '../domain/abono.dart';
import '../domain/linea_venta.dart';
import '../domain/venta.dart';
import '../domain/venta_detallada.dart';
import 'abono_form.dart';
import 'linea_venta_form.dart';
import 'selector_carpeta.dart';
import 'venta_detalle_view_model.dart';

/// La tabla final del sistema: una venta completa.
///
/// Aqui aparece junto todo lo que el resto de la aplicacion prepara. El
/// producto viene del inventario, que se lleno con un pedido a la
/// distribuidora; el cliente y la fecha vienen del encabezado; los importes
/// salen de cada renglon; y abajo la cobranza, que es lo que convierte una
/// venta en algo que sigue vivo despues de entregada.
///
/// La pantalla no calcula ni guarda nada: pinta un [VentaDetallada] ya armado
/// y manda cada accion al [VentaDetalleViewModel].
class VentaDetallePage extends ConsumerWidget {
  const VentaDetallePage({required this.ventaId, super.key});

  final String ventaId;

  static Future<void> abrir(BuildContext context, String ventaId) {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => VentaDetallePage(ventaId: ventaId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(ventaDetalleViewModelProvider(ventaId));
    final vm = ref.read(ventaDetalleViewModelProvider(ventaId).notifier);

    return estado.detalle.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('No se pudo leer la venta: $e')),
      ),
      data: (detalle) {
        if (detalle == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EstadoVacio(
              icono: Icons.receipt_long,
              titulo: 'Esta venta ya no existe',
              detalle: 'Se elimino desde otra pantalla.',
            ),
          );
        }
        return _Contenido(estado: estado, detalle: detalle, vm: vm);
      },
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.estado,
    required this.detalle,
    required this.vm,
  });

  final VentaDetalleEstado estado;
  final VentaDetallada detalle;
  final VentaDetalleViewModel vm;

  bool get editable => estado.editable;

  /// El nombre de la carpeta donde esta guardada, o `null` si esta suelta.
  String? get carpeta {
    for (final c in estado.carpetas) {
      if (c.id == detalle.venta.carpetaId) return c.titulo;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final venta = detalle.venta;

    return Scaffold(
      appBar: AppBar(
        title: Text(venta.titulo),
        actions: [
          PopupMenuButton<String>(
            onSelected: (opcion) => _menu(context, opcion),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'editar',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Editar datos de la venta y del cliente'),
                ),
              ),
              const PopupMenuItem(
                value: 'carpeta',
                child: ListTile(
                  leading: Icon(Icons.drive_file_move_outline),
                  title: Text('Mover a otra carpeta'),
                ),
              ),
              if (estado.puedeTraspasar)
                const PopupMenuItem(
                  value: 'a-adeudos',
                  child: ListTile(
                    leading: Icon(Icons.account_balance_wallet_outlined),
                    title: Text('Pasar el saldo a adeudos'),
                  ),
                ),
              if (detalle.traspasadaAAdeudo)
                const PopupMenuItem(
                  value: 'regresar-saldo',
                  child: ListTile(
                    leading: Icon(Icons.undo),
                    title: Text('Regresar el saldo a esta venta'),
                  ),
                ),
              if (venta.estado != EstadoVenta.apartada)
                const PopupMenuItem(
                  value: 'reabrir',
                  child: ListTile(
                    leading: Icon(Icons.undo),
                    title: Text('Regresar a apartada'),
                  ),
                ),
              if (venta.estado != EstadoVenta.cancelada)
                const PopupMenuItem(
                  value: 'cancelar',
                  child: ListTile(
                    leading: Icon(Icons.cancel_outlined),
                    title: Text('Cancelar venta'),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: editable
          ? FloatingActionButton.extended(
              heroTag: 'fab-venta-detalle',
              onPressed: () => LineaVentaForm.abrir(
                context,
                ventaId: venta.id,
              ),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Producto'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          _Encabezado(
            detalle: detalle,
            cliente: estado.cliente,
            carpeta: carpeta,
          ),
          const SizedBox(height: 8),
          _TituloSeccion(
            texto: 'Productos vendidos',
            detalle: '${detalle.piezas} pz',
          ),
          if (detalle.lineas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                'Todavia no hay renglones. Agrega productos del inventario '
                'para que la venta tenga que cobrar.',
              ),
            )
          else
            _TablaLineas(
              detalle: detalle,
              editable: editable,
              onEditar: (linea) => LineaVentaForm.abrir(
                context,
                ventaId: detalle.venta.id,
                linea: linea,
              ),
              onEliminar: (linea) => _borrarLinea(context, linea),
            ),
          const SizedBox(height: 8),
          _Totales(detalle: detalle),
          const SizedBox(height: 8),
          _AccionEntrega(detalle: detalle, vm: vm),
          const SizedBox(height: 8),
          _TituloSeccion(
            texto: 'Cobranza',
            detalle: dinero.formatear(detalle.abonado),
          ),
          _Cobranza(
            detalle: detalle,
            vm: vm,
            saldoAdeudo: estado.saldoAdeudo,
          ),
        ],
      ),
    );
  }

  Future<void> _menu(BuildContext context, String opcion) async {
    switch (opcion) {
      case 'editar':
        await _EditarEncabezado.abrir(
          context,
          venta: detalle.venta,
          cliente: estado.cliente,
          vm: vm,
        );
      case 'carpeta':
        final elegida = await SelectorCarpeta.elegir(
          context,
          carpetas: estado.carpetas,
          elegida: detalle.venta.carpetaId,
        );
        if (elegida != null) await vm.moverACarpeta(elegida.valor);
      case 'a-adeudos':
        final seguro = await confirmar(
          context,
          titulo: 'Pasar el saldo a adeudos',
          mensaje:
              'Los ${dinero.formatear(detalle.saldo)} que faltan dejaran de '
              'cobrarse en esta venta y se le cargaran a la cuenta de '
              '${detalle.venta.titulo}. No entra ni sale dinero: la deuda '
              'cambia de lugar.',
          aceptar: 'Pasar a adeudos',
        );
        if (!seguro || !context.mounted) return;
        final falla = await vm.pasarSaldoAAdeudo();
        if (context.mounted) avisar(context, falla, error: true);
      case 'regresar-saldo':
        final seguro = await confirmar(
          context,
          titulo: 'Regresar el saldo',
          mensaje: 'El cargo de ${dinero.formatear(detalle.traspasado)} sale '
              'de la cuenta del cliente y vuelve a cobrarse en esta venta.',
          aceptar: 'Regresar',
        );
        if (seguro) await vm.deshacerTraspaso();
      case 'reabrir':
        await vm.reabrir();
      case 'cancelar':
        final seguro = await confirmar(
          context,
          titulo: 'Cancelar la venta',
          mensaje: detalle.venta.entregada
              ? 'Las piezas entregadas regresaran al inventario y la venta '
                  'dejara de cobrarse.'
              : 'Se liberara el apartado y la venta dejara de cobrarse.',
          aceptar: 'Cancelar venta',
          peligroso: true,
        );
        if (seguro) await vm.cancelar();
    }
  }

  Future<void> _borrarLinea(BuildContext context, LineaVenta linea) async {
    final seguro = await confirmar(
      context,
      titulo: 'Quitar renglon',
      mensaje: detalle.venta.entregada
          ? 'Sus ${linea.cantidad} piezas regresaran al inventario.'
          : 'Se quitara de la venta.',
      aceptar: 'Quitar',
      peligroso: true,
    );
    if (seguro) await vm.eliminarLinea(linea);
  }
}

/// Los datos del cliente y el estado del apartado.
class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.detalle, this.cliente, this.carpeta});

  final VentaDetallada detalle;

  /// La ficha de quien compro, de donde salen el telefono y la direccion.
  ///
  /// Se pintan en el encabezado y no escondidos en el formulario porque son
  /// datos que se leen en voz alta -para marcarle o para decirle al que lleva
  /// la caja a donde va- y tenerlos que ir a buscar en un menu es lo mismo que
  /// no tenerlos.
  final Cliente? cliente;

  /// Donde esta guardada. Se muestra aqui y no solo en el menu porque al abrir
  /// una venta desde una busqueda no hay forma de saber de que carpeta salio.
  final String? carpeta;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final venta = detalle.venta;
    final color = switch (venta.estado) {
      EstadoVenta.apartada => tema.colorScheme.tertiary,
      EstadoVenta.entregada => tema.colorScheme.primary,
      EstadoVenta.cancelada => tema.colorScheme.error,
    };

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
                child: Text(venta.titulo, style: tema.textTheme.headlineSmall),
              ),
              Insignia(venta.estado.etiqueta, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [
              Formato.fecha(venta.fecha),
              if (venta.entregadaEn != null)
                'entregada ${Formato.fecha(venta.entregadaEn!)}',
              ?carpeta,
            ].join('  ·  '),
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
          if (venta.clienteId == null && venta.cliente.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Este nombre esta escrito a mano. Elige a la persona de tu lista '
              'para poder llevarle adeudos y guardarle telefono y direccion.',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (cliente != null) ...[
            const SizedBox(height: 10),
            _Contacto(cliente: cliente!),
          ],
          if (venta.notas.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(venta.notas, style: tema.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Telefono y direccion de quien compro, listos para usarse.
///
/// El telefono se copia al tocarlo. No se marca desde aqui a proposito: abrir
/// el marcador sacaria de la venta a media captura, y lo que ella hace de
/// verdad es pasarle el numero a alguien por mensaje.
///
/// Los renglones que faltan no se dibujan en blanco: un hueco vacio en la
/// pantalla se lee como un error del programa. Lo que hay es una sola linea
/// discreta que invita a capturarlos, y solo mientras no haya ninguno de los
/// dos.
class _Contacto extends StatelessWidget {
  const _Contacto({required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    if (!cliente.tieneTelefono && !cliente.tieneDireccion) {
      return Text(
        'Sin telefono ni direccion. Se capturan en "Editar datos de la venta '
        'y del cliente" y quedan guardados para sus proximas ventas.',
        style: tema.textTheme.bodySmall?.copyWith(
          color: tema.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cliente.tieneTelefono)
          InkWell(
            onTap: () async {
              await Clipboard.setData(
                ClipboardData(text: cliente.telefono.trim()),
              );
              if (context.mounted) avisar(context, 'Telefono copiado.');
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 18,
                    color: tema.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cliente.telefono.trim(),
                    style: tema.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.copy_all_outlined,
                    size: 14,
                    color: tema.colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
        if (cliente.tieneDireccion)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 18,
                  color: tema.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cliente.direccion.trim(),
                    style: tema.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion({required this.texto, this.detalle});

  final String texto;
  final String? detalle;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            texto,
            style: tema.textTheme.titleSmall?.copyWith(
              color: tema.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (detalle != null)
            Text(detalle!, style: tema.textTheme.labelLarge),
        ],
      ),
    );
  }
}

/// Los renglones de la venta, en forma de tabla.
///
/// Se desplaza a lo ancho dentro de su propio contenedor: en una tablet en
/// vertical no caben las cinco columnas, y recortarlas escondería justo el
/// importe, que es lo que la propietaria va a leer en voz alta.
class _TablaLineas extends StatelessWidget {
  const _TablaLineas({
    required this.detalle,
    required this.editable,
    required this.onEditar,
    required this.onEliminar,
  });

  final VentaDetallada detalle;
  final bool editable;
  final ValueChanged<LineaVenta> onEditar;
  final ValueChanged<LineaVenta> onEliminar;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Producto')),
          DataColumn(label: Text('Cant.'), numeric: true),
          DataColumn(label: Text('Precio'), numeric: true),
          DataColumn(label: Text('Desc.'), numeric: true),
          DataColumn(label: Text('Importe'), numeric: true),
          DataColumn(label: Text('')),
        ],
        rows: [
          for (final linea in detalle.lineas)
            DataRow(
              cells: [
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          linea.descripcion.isEmpty
                              ? '(sin descripcion)'
                              : linea.descripcion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          [
                            if (linea.marca.isNotEmpty) linea.marca,
                            if (linea.codigo.isNotEmpty) '#${linea.codigo}',
                            if (!linea.mueveInventario) 'sin inventario',
                          ].join('  '),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  onTap: editable ? () => onEditar(linea) : null,
                ),
                DataCell(Text('${linea.cantidad}')),
                DataCell(Text(dinero.formatear(linea.precioUnitario))),
                DataCell(
                  Text(
                    linea.descuento == 0
                        ? '-'
                        : dinero.formatear(linea.descuento),
                  ),
                ),
                DataCell(
                  Text(
                    dinero.formatear(linea.importe),
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
        ],
      ),
    );
  }
}

class _Totales extends StatelessWidget {
  const _Totales({required this.detalle});

  final VentaDetallada detalle;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card.filled(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _fila(context, 'Subtotal', dinero.formatear(detalle.subtotal)),
              if (detalle.descuento > 0)
                _fila(
                  context,
                  'Descuentos',
                  '- ${dinero.formatear(detalle.descuento)}',
                ),
              const Divider(),
              _fila(
                context,
                'Total de la venta',
                dinero.formatear(detalle.total),
                destacado: true,
              ),
              _fila(context, 'Abonado', dinero.formatear(detalle.abonado)),
              if (detalle.traspasadaAAdeudo)
                _fila(
                  context,
                  'Pasado a adeudos',
                  dinero.formatear(detalle.traspasado),
                ),
              _fila(
                context,
                'Saldo pendiente',
                dinero.formatear(detalle.saldo),
                destacado: true,
                color: detalle.saldo > 0
                    ? tema.colorScheme.error
                    : tema.colorScheme.primary,
              ),
              if (detalle.total > 0) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: detalle.avanceCobro,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _fila(
    BuildContext context,
    String etiqueta,
    String valor, {
    bool destacado = false,
    Color? color,
  }) {
    final tema = Theme.of(context);
    final estilo = destacado
        ? tema.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          )
        : tema.textTheme.bodyMedium?.copyWith(color: color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: estilo),
          Text(valor, style: estilo),
        ],
      ),
    );
  }
}

/// El boton que mueve el inventario de verdad.
class _AccionEntrega extends StatelessWidget {
  const _AccionEntrega({required this.detalle, required this.vm});

  final VentaDetallada detalle;
  final VentaDetalleViewModel vm;

  @override
  Widget build(BuildContext context) {
    final venta = detalle.venta;
    if (venta.estado == EstadoVenta.cancelada) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Venta cancelada. Regresala a apartada si quieres volver a '
          'trabajarla.',
        ),
      );
    }

    if (venta.entregada) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Entregada: ${detalle.piezas} piezas ya salieron del '
                'inventario.',
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FilledButton.tonalIcon(
        onPressed: detalle.lineas.isEmpty
            ? null
            : () async {
                final seguro = await confirmar(
                  context,
                  titulo: 'Entregar la venta',
                  mensaje: '${detalle.piezas} piezas saldran del inventario. '
                      'El saldo de ${dinero.formatear(detalle.saldo)} se '
                      'sigue cobrando aparte.',
                  aceptar: 'Entregar',
                );
                if (seguro) await vm.entregar();
              },
        icon: const Icon(Icons.local_shipping_outlined),
        label: const Text('Entregar y descontar del inventario'),
      ),
    );
  }
}

/// Los abonos, que es donde se ve como va el pago a plazos.
///
/// Cuando quien compro arrastra deuda vieja, cada renglon dice ademas como se
/// repartio el pago. Es informacion que en otra pantalla seria de mas, pero
/// aqui contesta la pregunta que salta sola al ver los numeros: "dejo
/// quinientos, por que la venta solo bajo doscientos".
class _Cobranza extends StatelessWidget {
  const _Cobranza({
    required this.detalle,
    required this.vm,
    required this.saldoAdeudo,
  });

  final VentaDetallada detalle;
  final VentaDetalleViewModel vm;

  /// Lo que el cliente debe de antes, para proponer el reparto al cobrar.
  final int saldoAdeudo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (saldoAdeudo > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                  color: tema.colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ademas te debe ${dinero.formatear(saldoAdeudo)} de antes. '
                    'Lo que abone se propone contra eso primero.',
                    style: tema.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        for (final abono in detalle.abonos)
          ListTile(
            dense: true,
            leading: const Icon(Icons.payments_outlined),
            title: Text(dinero.formatear(abono.monto)),
            subtitle: Text(
              [
                Formato.fechaCorta(abono.fecha),
                if (abono.tocaAdeudo)
                  '${dinero.formatear(abono.montoVenta)} a esta venta, '
                      '${dinero.formatear(abono.montoAdeudo)} a su adeudo',
                if (abono.nota.isNotEmpty) abono.nota,
              ].join('  ·  '),
            ),
            onTap: () => _abrirForm(context, abono: abono),
            trailing: IconButton(
              tooltip: 'Borrar abono',
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => _borrar(context, abono),
            ),
          ),
        if (detalle.abonos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Sin pagos registrados.'),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: OutlinedButton.icon(
            onPressed: detalle.venta.estado.cobrable
                ? () => _abrirForm(context)
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Registrar abono'),
          ),
        ),
      ],
    );
  }

  /// Abre el formulario de cobro con los dos saldos que necesita para
  /// proponer el reparto, y le entrega el pago ya repartido al ViewModel.
  Future<void> _abrirForm(BuildContext context, {Abono? abono}) {
    return AbonoForm.abrir(
      context,
      titulo: detalle.venta.titulo,
      abono: abono,
      saldoVenta: detalle.saldo,
      saldoAdeudo: saldoAdeudo,
      onGuardar: ({
        required int monto,
        required int montoAdeudo,
        required DateTime fecha,
        required String nota,
      }) {
        if (abono == null) {
          return vm.abonar(
            monto,
            montoAdeudo: montoAdeudo,
            nota: nota,
            fecha: fecha,
          );
        }
        return vm.guardarAbono(
          abono.copyWith(
            monto: monto,
            montoAdeudo: montoAdeudo,
            fecha: fecha,
            nota: nota,
          ),
        );
      },
    );
  }

  Future<void> _borrar(BuildContext context, Abono abono) async {
    final seguro = await confirmar(
      context,
      titulo: 'Borrar abono',
      mensaje: 'El saldo volvera a subir ${dinero.formatear(abono.monto)}.',
      aceptar: 'Borrar',
      peligroso: true,
    );
    if (seguro) await vm.eliminarAbono(abono);
  }
}

/// El formulario de la venta: quien compro, como se le localiza, cuando fue.
///
/// Mezcla dos cosas que en la base viven separadas -la hoja de la venta y la
/// ficha del cliente- y lo hace a proposito. Ella no piensa "voy a editar el
/// padron": esta cerrando una venta, le pregunta el telefono a la senora y lo
/// apunta. Obligarla a salirse a otra pantalla para eso es lo que termina en
/// telefonos que nunca se capturan.
///
/// Lo que se guarda donde si esta claro por dentro: el cliente, la fecha y las
/// notas son de esta venta; el telefono y la direccion son de la persona, y se
/// quedan puestos para todas sus ventas siguientes.
class _EditarEncabezado extends StatefulWidget {
  const _EditarEncabezado({
    required this.venta,
    required this.cliente,
    required this.vm,
  });

  final Venta venta;

  /// La ficha del padron de quien compro, o `null` si la venta trae el nombre
  /// escrito a mano.
  final Cliente? cliente;

  final VentaDetalleViewModel vm;

  static Future<void> abrir(
    BuildContext context, {
    required Venta venta,
    required Cliente? cliente,
    required VentaDetalleViewModel vm,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditarEncabezado(
        venta: venta,
        cliente: cliente,
        vm: vm,
      ),
    );
  }

  @override
  State<_EditarEncabezado> createState() => _EditarEncabezadoState();
}

class _EditarEncabezadoState extends State<_EditarEncabezado> {
  late final TextEditingController _notas;
  late final TextEditingController _telefono;
  late final TextEditingController _direccion;
  late DateTime _fecha;
  bool _guardando = false;

  /// Lo elegido en esta sesion de la hoja, junto con la bandera que dice si
  /// llego a elegirse algo.
  ///
  /// Hacen falta las dos: "no toco el cliente" y "lo dejo sin cliente" son
  /// cosas distintas, y sin la bandera abrir la hoja y guardar las notas
  /// borraria a quien compro.
  Cliente? _cliente;
  bool _clienteTocado = false;

  /// La ficha cuyos datos se estan editando: la que se acaba de elegir, o la
  /// que la venta ya traia.
  Cliente? get _fichaActual => _clienteTocado ? _cliente : widget.cliente;

  @override
  void initState() {
    super.initState();
    _notas = TextEditingController(text: widget.venta.notas);
    _telefono = TextEditingController(text: widget.cliente?.telefono ?? '');
    _direccion = TextEditingController(text: widget.cliente?.direccion ?? '');
    _fecha = widget.venta.fecha;
  }

  @override
  void dispose() {
    _notas.dispose();
    _telefono.dispose();
    _direccion.dispose();
    super.dispose();
  }

  String get _nombreCliente =>
      _clienteTocado ? (_cliente?.nombre ?? '') : widget.venta.cliente;

  /// Cambiar de cliente trae consigo su telefono y su direccion.
  ///
  /// Es lo unico que puede pasar sin sorprender a nadie: los campos de
  /// contacto son de la persona, y dejar en pantalla el numero del cliente
  /// anterior mientras arriba dice otro nombre acabaria guardandoselo al que
  /// no es.
  Future<void> _elegirCliente() async {
    final elegido = await SelectorCliente.elegir(
      context,
      elegido: _fichaActual?.id ?? widget.venta.clienteId,
    );
    if (elegido == null) return;
    setState(() {
      _cliente = elegido.valor;
      _clienteTocado = true;
      _telefono.text = elegido.valor?.telefono ?? '';
      _direccion.text = elegido.valor?.direccion ?? '';
    });
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Fecha de la venta',
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final aviso = await widget.vm.guardarEncabezado(
      cliente: _clienteTocado ? (valor: _cliente) : null,
      notas: _notas.text,
      fecha: _fecha,
      telefono: _telefono.text,
      direccion: _direccion.text,
    );
    if (!mounted) return;
    setState(() => _guardando = false);

    // El aviso solo aparece cuando habia contacto que no se pudo guardar por
    // falta de ficha. La venta si se guardo, asi que la hoja se cierra igual:
    // dejarla abierta haria pensar que no se guardo nada.
    avisar(context, aviso, error: true);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final relleno = MediaQuery.viewInsetsOf(context).bottom;
    final ficha = _fichaActual;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, relleno + 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Datos de la venta', style: tema.textTheme.titleLarge),
              const SizedBox(height: 16),
              CampoSelector(
                etiqueta: 'Cliente',
                valor: _nombreCliente,
                pista: 'A quien le vendiste',
                icono: Icons.person_outline,
                ayuda: 'Se elige de tu lista para poder llevarle adeudos',
                alTocar: _elegirCliente,
              ),
              const SizedBox(height: 16),
              _Apartado(
                titulo: ficha == null
                    ? 'Datos del cliente'
                    : 'Datos de ${ficha.titulo}',
                detalle: ficha == null
                    ? 'Elige antes al cliente de tu lista: el telefono y la '
                        'direccion se guardan en su ficha, no en esta hoja.'
                    : 'Se guardan en su ficha: no hay que volver a '
                        'escribirlos en su proxima venta.',
              ),
              const SizedBox(height: 10),
              CampoTexto(
                etiqueta: 'Telefono',
                controlador: _telefono,
                icono: Icons.phone_outlined,
                teclado: TextInputType.phone,
                capitalizacion: TextCapitalization.none,
                pista: '311 123 4567',
              ),
              const SizedBox(height: 12),
              CampoTexto(
                etiqueta: 'Direccion',
                controlador: _direccion,
                icono: Icons.place_outlined,
                lineas: 2,
                capitalizacion: TextCapitalization.words,
                pista: 'Calle, numero, colonia y como llegar',
              ),
              const SizedBox(height: 20),
              const _Apartado(
                titulo: 'De esta venta',
                detalle: 'Lo que solo aplica a esta hoja.',
              ),
              const SizedBox(height: 10),
              CampoTexto(etiqueta: 'Notas', controlador: _notas, lineas: 2),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _elegirFecha,
                icon: const Icon(Icons.event),
                label: Text('Fecha: ${Formato.fecha(_fecha)}'),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: const Icon(Icons.check),
                label: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Encabezado de un bloque dentro de un formulario largo.
///
/// El formulario de la venta guarda en dos lugares distintos -la hoja y la
/// ficha del cliente- y sin decirlo parece que todo se queda en la venta. Un
/// renglon de titulo cuesta poco y evita la pregunta de "por que el telefono
/// aparecio solo en la otra venta".
class _Apartado extends StatelessWidget {
  const _Apartado({required this.titulo, required this.detalle});

  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: tema.textTheme.titleSmall?.copyWith(
            color: tema.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          detalle,
          style: tema.textTheme.bodySmall?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
