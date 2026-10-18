import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets_comunes.dart';
import '../../../core/escala_decimal.dart';
import '../../../core/formato.dart';
import '../../clientes/domain/cliente.dart';
import '../../clientes/presentation/selector_cliente.dart';
import '../domain/adeudo.dart';
import 'adeudos_view_model.dart';

/// Formulario para anotar lo que alguien debe de antes.
///
/// Es la pantalla que hace que los adeudos existan. Lo que se captura es solo
/// dinero: cuanto debe, de que, y desde cuando. No hay renglones ni productos
/// a proposito, porque la mercancia de esa deuda salio de la casa hace meses y
/// darla de alta hoy en el inventario para volver a sacarla dejaria las
/// existencias mintiendo justo en el numero con el que se le promete mercancia
/// a alguien mas.
class AdeudoForm extends ConsumerStatefulWidget {
  const AdeudoForm({this.adeudo, this.clienteId, super.key});

  /// El cargo a corregir, o `null` para registrar uno nuevo.
  final Adeudo? adeudo;

  /// A quien se le carga, cuando ya se sabe -se abrio desde su cuenta-. Si
  /// falta, el formulario lo pide.
  final String? clienteId;

  static Future<void> abrir(
    BuildContext context, {
    Adeudo? adeudo,
    String? clienteId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AdeudoForm(adeudo: adeudo, clienteId: clienteId),
    );
  }

  @override
  ConsumerState<AdeudoForm> createState() => _AdeudoFormState();
}

class _AdeudoFormState extends ConsumerState<AdeudoForm> {
  late final TextEditingController _monto;
  late final TextEditingController _concepto;
  late DateTime _fecha;
  Cliente? _cliente;
  bool _guardando = false;

  bool get _esNuevo => widget.adeudo == null;

  /// A quien se le va a cargar. Al corregir no se puede cambiar: mover una
  /// deuda de una persona a otra no es corregir un dato, son dos operaciones,
  /// y verlas como dos es lo que deja rastro de que paso.
  String? get _clienteId =>
      widget.adeudo?.clienteId ?? widget.clienteId ?? _cliente?.id;

  @override
  void initState() {
    super.initState();
    final a = widget.adeudo;
    _monto = TextEditingController(
      text: a == null ? '' : dinero.aTexto(a.monto),
    );
    _concepto = TextEditingController(text: a?.concepto ?? '');
    _fecha = a?.fecha ?? DateTime.now();
  }

  @override
  void dispose() {
    _monto.dispose();
    _concepto.dispose();
    super.dispose();
  }

  Future<void> _elegirCliente() async {
    final elegido = await SelectorCliente.elegir(
      context,
      elegido: _cliente?.id,
      permiteNinguno: false,
    );
    if (elegido?.valor == null) return;
    setState(() => _cliente = elegido!.valor);
  }

  Future<void> _elegirFecha() async {
    // El calendario sale en espanol porque `MaterialApp` carga los delegados
    // de localizacion; lo unico que hay que poner aqui son los textos propios
    // de este cargo, que ningun idioma puede adivinar: no se esta eligiendo
    // "una fecha" sino desde cuando debe.
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Desde cuando debe',
      cancelText: 'Cancelar',
      confirmText: 'Elegir',
      fieldLabelText: 'Fecha del adeudo',
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  Future<void> _guardar() async {
    final clienteId = _clienteId;
    if (clienteId == null) {
      avisar(context, 'Elige de quien es la deuda.', error: true);
      return;
    }

    setState(() => _guardando = true);
    final vm = ref.read(adeudosViewModelProvider.notifier);
    final monto = CampoDecimal.leer(_monto);

    final mensaje = _esNuevo
        ? await vm.registrarAdeudo(
            clienteId: clienteId,
            monto: monto,
            concepto: _concepto.text,
            fecha: _fecha,
          )
        : await vm.guardarAdeudo(
            widget.adeudo!.copyWith(
              monto: monto,
              concepto: _concepto.text,
              fecha: _fecha,
            ),
          );

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
    final tema = Theme.of(context);
    final relleno = MediaQuery.viewInsetsOf(context).bottom;
    final pideCliente = _esNuevo && widget.clienteId == null;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, relleno + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _esNuevo ? 'Anotar un adeudo' : 'Editar el adeudo',
              style: tema.textTheme.titleLarge,
            ),
            const SizedBox(height: 2),
            Text(
              'Solo la cantidad que debe. Esto no toca tu inventario.',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (pideCliente) ...[
              CampoSelector(
                etiqueta: 'Cliente',
                valor: _cliente?.titulo ?? '',
                pista: 'Quien debe',
                icono: Icons.person_outline,
                alTocar: _elegirCliente,
              ),
              const SizedBox(height: 12),
            ],
            CampoDecimal(
              etiqueta: 'Cuanto debe',
              controlador: _monto,
              autofoco: !pideCliente,
            ),
            const SizedBox(height: 12),
            CampoTexto(
              etiqueta: 'De que',
              controlador: _concepto,
              pista: 'Productos de la campana 9, lo de diciembre...',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _elegirFecha,
              icon: const Icon(Icons.event),
              label: Text('Desde: ${Formato.fecha(_fecha)}'),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.check),
              label: const Text('Guardar adeudo'),
            ),
          ],
        ),
      ),
    );
  }
}
