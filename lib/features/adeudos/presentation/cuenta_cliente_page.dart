import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets_comunes.dart';
import '../../../core/escala_decimal.dart';
import '../../../core/formato.dart';
import '../../clientes/domain/cliente.dart';
import '../../clientes/presentation/clientes_view_model.dart';
import '../../ventas/domain/abono.dart';
import '../../ventas/domain/venta_detallada.dart';
import '../../ventas/presentation/abono_form.dart';
import '../../ventas/presentation/venta_detalle_page.dart';
import '../domain/adeudo.dart';
import '../domain/cuenta_cliente.dart';
import 'adeudo_form.dart';
import 'adeudos_view_model.dart';

/// El estado de cuenta de una persona: todo lo que debe, junto.
///
/// Es la pantalla que contesta "cuanto me debe Tony" de una sola vez, que era
/// justo lo que el sistema no podia contestar cuando la deuda vivia repartida
/// en hojas de venta sueltas. Tiene tres secciones porque son tres cosas
/// distintas y se corrigen en lugares distintos: los cargos de deuda vieja, los
/// pagos que ha dejado contra esa deuda, y sus ventas, que se siguen cobrando
/// en su propia hoja.
class CuentaClientePage extends ConsumerWidget {
  const CuentaClientePage({required this.clienteId, super.key});

  final String clienteId;

  static Future<void> abrir(BuildContext context, String clienteId) {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CuentaClientePage(clienteId: clienteId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuenta = ref.watch(cuentaClienteProvider(clienteId));
    if (cuenta == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EstadoVacio(
          icono: Icons.person_off_outlined,
          titulo: 'Este cliente ya no existe',
          detalle: 'Se dio de baja desde otra pantalla.',
        ),
      );
    }

    final ventas = ref.watch(ventasDelClienteProvider(clienteId));
    final vm = ref.read(adeudosViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(cuenta.cliente.titulo),
        actions: [
          PopupMenuButton<String>(
            onSelected: (opcion) => _menu(context, ref, cuenta, opcion),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'renombrar',
                child: ListTile(
                  leading: Icon(Icons.drive_file_rename_outline),
                  title: Text('Corregir el nombre'),
                ),
              ),
              const PopupMenuItem(
                value: 'contacto',
                child: ListTile(
                  leading: Icon(Icons.contact_phone_outlined),
                  title: Text('Telefono, direccion y nota'),
                ),
              ),
              const PopupMenuItem(
                value: 'borrar',
                child: ListTile(
                  leading: Icon(Icons.person_remove_outlined),
                  title: Text('Dar de baja'),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-cuenta-cliente',
        onPressed: () => _abonar(context, vm, cuenta),
        icon: const Icon(Icons.payments_outlined),
        label: const Text('Abonar'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          _Encabezado(cuenta: cuenta),
          const SizedBox(height: 8),
          _Titulo(
            texto: 'Deuda anterior',
            detalle: dinero.formatear(cuenta.saldoAdeudo),
          ),
          _Cargos(cuenta: cuenta, vm: vm),
          const SizedBox(height: 8),
          _Titulo(
            texto: 'Pagos a la deuda',
            detalle: dinero.formatear(cuenta.pagado),
          ),
          _Pagos(cuenta: cuenta, vm: vm),
          const SizedBox(height: 8),
          _Titulo(
            texto: 'Sus ventas',
            detalle: dinero.formatear(cuenta.saldoEnVentas),
          ),
          _Ventas(ventas: ventas),
        ],
      ),
    );
  }

  Future<void> _abonar(
    BuildContext context,
    AdeudosViewModel vm,
    CuentaCliente cuenta,
  ) {
    return AbonoForm.abrir(
      context,
      titulo: '${cuenta.cliente.titulo}  ·  deuda anterior',
      // Sin venta enfrente: este cobro va entero contra lo de antes. Cuando hay
      // una venta abierta, el pago se captura ahi y se reparte, para que quede
      // una sola fila por billete entregado.
      hayVenta: false,
      saldoAdeudo: cuenta.saldoAdeudo,
      onGuardar: ({
        required int monto,
        required int montoAdeudo,
        required DateTime fecha,
        required String nota,
      }) =>
          vm.abonarAAdeudo(
        clienteId: cuenta.cliente.id,
        monto: monto,
        nota: nota,
        fecha: fecha,
      ),
    );
  }

  Future<void> _menu(
    BuildContext context,
    WidgetRef ref,
    CuentaCliente cuenta,
    String opcion,
  ) async {
    final vm = ref.read(clientesViewModelProvider.notifier);
    switch (opcion) {
      case 'renombrar':
        final nombre = await pedirTexto(
          context,
          titulo: 'Corregir el nombre',
          etiqueta: 'Nombre',
          valor: cuenta.cliente.nombre,
        );
        if (nombre == null) return;
        final falla = await vm.guardar(cuenta.cliente.copyWith(nombre: nombre));
        if (context.mounted) avisar(context, falla, error: true);
      case 'contacto':
        await _DatosCliente.abrir(context, cliente: cuenta.cliente, vm: vm);
      case 'borrar':
        final seguro = await confirmar(
          context,
          titulo: 'Dar de baja',
          mensaje: 'Solo se puede si no tiene ventas ni adeudos. Si el nombre '
              'esta mal escrito, corrigelo en vez de borrarlo.',
          aceptar: 'Dar de baja',
          peligroso: true,
        );
        if (!seguro || !context.mounted) return;
        final falla = await vm.eliminar(cuenta.cliente);
        if (!context.mounted) return;
        if (falla != null) {
          avisar(context, falla, error: true);
          return;
        }
        Navigator.pop(context);
    }
  }
}

/// Lo que debe, con las dos mitades separadas.
class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.cuenta});

  final CuentaCliente cuenta;

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
            dinero.formatear(cuenta.deudaTotal),
            style: tema.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cuenta.debe
                  ? tema.colorScheme.error
                  : tema.colorScheme.primary,
            ),
          ),
          Text(
            cuenta.debe ? 'te debe en total' : 'esta al corriente',
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              DatoResumen(
                etiqueta: 'Deuda anterior',
                valor: dinero.formatear(cuenta.saldoAdeudo),
              ),
              DatoResumen(
                etiqueta: 'En ventas',
                valor: dinero.formatear(cuenta.saldoEnVentas),
              ),
              DatoResumen(
                etiqueta: 'Ventas abiertas',
                valor: '${cuenta.ventasAbiertas}',
              ),
            ],
          ),
          // Telefono y direccion van en el estado de cuenta porque es la
          // pantalla que se abre para ir a cobrar: lo primero que hace falta
          // ahi es a que numero marcarle y a donde ir.
          if (cuenta.cliente.tieneTelefono || cuenta.cliente.tieneDireccion)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  if (cuenta.cliente.tieneTelefono)
                    _Dato(
                      icono: Icons.phone_outlined,
                      texto: cuenta.cliente.telefono.trim(),
                    ),
                  if (cuenta.cliente.tieneDireccion)
                    _Dato(
                      icono: Icons.place_outlined,
                      texto: cuenta.cliente.direccion.trim(),
                    ),
                ],
              ),
            ),
          if (cuenta.cliente.notas.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(cuenta.cliente.notas, style: tema.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo({required this.texto, this.detalle});

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
          if (detalle != null) Text(detalle!, style: tema.textTheme.labelLarge),
        ],
      ),
    );
  }
}

/// Los cargos: lo que se llevo y no ha pagado.
class _Cargos extends StatelessWidget {
  const _Cargos({required this.cuenta, required this.vm});

  final CuentaCliente cuenta;
  final AdeudosViewModel vm;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final adeudo in cuenta.adeudos)
          ListTile(
            dense: true,
            leading: Icon(
              adeudo.vieneDeVenta ? Icons.receipt_long : Icons.history,
            ),
            title: Text(dinero.formatear(adeudo.monto)),
            subtitle: Text(
              '${Formato.fechaCorta(adeudo.fecha)}  ·  ${adeudo.titulo}',
            ),
            // Los que nacieron de una venta se corrigen deshaciendo el traspaso
            // desde esa venta, no aqui: cambiarles el monto a mano dejaria la
            // hoja de origen diciendo que ya no debe algo que si debe.
            onTap: adeudo.vieneDeVenta
                ? () => avisar(
                      context,
                      'Este cargo salio de una venta. Para cambiarlo, abre la '
                      'venta y regresale el saldo.',
                    )
                : () => AdeudoForm.abrir(context, adeudo: adeudo),
            trailing: IconButton(
              tooltip: 'Borrar cargo',
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => _borrar(context, adeudo),
            ),
          ),
        if (cuenta.adeudos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'No arrastra nada de antes.',
              style: tema.textTheme.bodyMedium,
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: OutlinedButton.icon(
            onPressed: () =>
                AdeudoForm.abrir(context, clienteId: cuenta.cliente.id),
            icon: const Icon(Icons.add),
            label: const Text('Anotar lo que debe de antes'),
          ),
        ),
      ],
    );
  }

  Future<void> _borrar(BuildContext context, Adeudo adeudo) async {
    final seguro = await confirmar(
      context,
      titulo: 'Borrar el cargo',
      mensaje: adeudo.vieneDeVenta
          ? 'Salio de una venta: al borrarlo, ese saldo vuelve a cobrarse en '
              'su hoja.'
          : 'Su deuda bajara ${dinero.formatear(adeudo.monto)}.',
      aceptar: 'Borrar',
      peligroso: true,
    );
    if (seguro) await vm.eliminarAdeudo(adeudo);
  }
}

/// Los pagos que han bajado la deuda vieja, vengan de donde vengan.
class _Pagos extends StatelessWidget {
  const _Pagos({required this.cuenta, required this.vm});

  final CuentaCliente cuenta;
  final AdeudosViewModel vm;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final pagos = [...cuenta.pagos.where((p) => p.tocaAdeudo)]
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    if (pagos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'Todavia no ha abonado a la deuda anterior.',
          style: tema.textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final pago in pagos)
          ListTile(
            dense: true,
            leading: const Icon(Icons.payments_outlined),
            title: Text(dinero.formatear(pago.montoAdeudo)),
            subtitle: Text(
              [
                Formato.fechaCorta(pago.fecha),
                // Un pago que ademas bajo una venta se capturo alla y alla se
                // corrige: es una sola fila y ensenarla como dos cosas
                // editables invitaria a dejarla a medias.
                if (pago.ventaId != null)
                  'parte de un pago de ${dinero.formatear(pago.monto)} en una '
                      'venta',
                if (pago.nota.isNotEmpty) pago.nota,
              ].join('  ·  '),
            ),
            onTap: pago.ventaId != null
                ? () => VentaDetallePage.abrir(context, pago.ventaId!)
                : () => _editar(context, pago),
            trailing: pago.ventaId != null
                ? const Icon(Icons.chevron_right)
                : IconButton(
                    tooltip: 'Borrar abono',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => _borrar(context, pago),
                  ),
          ),
      ],
    );
  }

  Future<void> _editar(BuildContext context, Abono pago) {
    return AbonoForm.abrir(
      context,
      titulo: '${cuenta.cliente.titulo}  ·  deuda anterior',
      abono: pago,
      hayVenta: false,
      saldoAdeudo: cuenta.saldoAdeudo,
      onGuardar: ({
        required int monto,
        required int montoAdeudo,
        required DateTime fecha,
        required String nota,
      }) =>
          vm.guardarAbono(
        pago.copyWith(
          monto: monto,
          montoAdeudo: monto,
          fecha: fecha,
          nota: nota,
        ),
      ),
    );
  }

  Future<void> _borrar(BuildContext context, Abono pago) async {
    final seguro = await confirmar(
      context,
      titulo: 'Borrar abono',
      mensaje: 'Su deuda volvera a subir '
          '${dinero.formatear(pago.montoAdeudo)}.',
      aceptar: 'Borrar',
      peligroso: true,
    );
    if (seguro) await vm.eliminarAbono(pago);
  }
}

/// Sus ventas, que se siguen cobrando en su propia hoja.
class _Ventas extends StatelessWidget {
  const _Ventas({required this.ventas});

  final List<VentaDetallada> ventas;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    if (ventas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'No tiene ventas capturadas a su nombre.',
          style: tema.textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final detalle in ventas)
          ListTile(
            dense: true,
            leading: const Icon(Icons.receipt_long),
            title: Text(
              '${Formato.fecha(detalle.venta.fecha)}  ·  '
              '${dinero.formatear(detalle.total)}',
            ),
            subtitle: Text(
              detalle.saldo > 0
                  ? 'Debe ${dinero.formatear(detalle.saldo)}'
                  : detalle.traspasadaAAdeudo
                      ? 'Su saldo paso a la deuda anterior'
                      : detalle.venta.estado.etiqueta,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => VentaDetallePage.abrir(context, detalle.venta.id),
          ),
      ],
    );
  }
}

/// Un dato de contacto con su icono, para el encabezado de la cuenta.
class _Dato extends StatelessWidget {
  const _Dato({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 17, color: tema.colorScheme.primary),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width - 96,
          ),
          child: Text(texto, style: tema.textTheme.bodyMedium),
        ),
      ],
    );
  }
}

/// La ficha de contacto de una persona: a que numero se le marca, donde vive y
/// lo demas que ayuda a ubicarla.
///
/// Los tres campos viven en la misma hoja y no en tres dialogos encadenados
/// porque se preguntan de corrido: cuando alguien esta dictando sus datos, lo
/// hace de una vez. Es la misma ficha que se captura desde el formulario de
/// una venta; esta es la puerta de entrada cuando no hay ninguna venta abierta
/// -por ejemplo al ir a cobrarle una deuda vieja-.
class _DatosCliente extends StatefulWidget {
  const _DatosCliente({required this.cliente, required this.vm});

  final Cliente cliente;
  final ClientesViewModel vm;

  static Future<void> abrir(
    BuildContext context, {
    required Cliente cliente,
    required ClientesViewModel vm,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DatosCliente(cliente: cliente, vm: vm),
    );
  }

  @override
  State<_DatosCliente> createState() => _DatosClienteState();
}

class _DatosClienteState extends State<_DatosCliente> {
  late final TextEditingController _telefono =
      TextEditingController(text: widget.cliente.telefono);
  late final TextEditingController _direccion =
      TextEditingController(text: widget.cliente.direccion);
  late final TextEditingController _notas =
      TextEditingController(text: widget.cliente.notas);
  bool _guardando = false;

  @override
  void dispose() {
    _telefono.dispose();
    _direccion.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final falla = await widget.vm.guardar(
      widget.cliente.copyWith(
        telefono: _telefono.text,
        direccion: _direccion.text,
        notas: _notas.text,
      ),
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    if (falla != null) {
      avisar(context, falla, error: true);
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final relleno = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, relleno + 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Datos de ${widget.cliente.titulo}',
                style: tema.textTheme.titleLarge,
              ),
              const SizedBox(height: 2),
              Text(
                'Quedan en su ficha: se ven en todas sus ventas y no hay que '
                'volver a escribirlos.',
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              CampoTexto(
                etiqueta: 'Telefono',
                controlador: _telefono,
                icono: Icons.phone_outlined,
                teclado: TextInputType.phone,
                capitalizacion: TextCapitalization.none,
                pista: '311 123 4567',
                autofoco: true,
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
              const SizedBox(height: 12),
              CampoTexto(
                etiqueta: 'Nota',
                controlador: _notas,
                icono: Icons.sticky_note_2_outlined,
                lineas: 2,
                pista: 'Quien lo recomendo, a que horas esta...',
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
