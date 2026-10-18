import 'package:flutter/material.dart';

import '../../../app/widgets_comunes.dart';
import '../../../core/escala_decimal.dart';
import '../../../core/formato.dart';
import '../../adeudos/domain/cuenta_cliente.dart';
import '../domain/abono.dart';

/// Lo que el formulario devuelve cuando se guarda: un mensaje de error, o
/// `null` si todo salio bien.
typedef GuardarAbono = Future<String?> Function({
  required int monto,
  required int montoAdeudo,
  required DateTime fecha,
  required String nota,
});

/// Formulario para registrar o corregir un pago.
///
/// Es la pantalla que existe porque el cobro no es de contado: cada vez que el
/// cliente deja algo, se abre esto. Propone de entrada el saldo completo, que
/// es el caso comun -el cliente liquida-, y deja bajarlo cuando solo trae una
/// parte.
///
/// Cuando quien paga arrastra deuda vieja, el formulario ademas **reparte**.
/// Un pago sigue siendo uno solo -el cliente entrego un billete, no dos-, y lo
/// que se captura es a que le pega: primero a lo viejo, y lo que sobre a la
/// venta del dia. Esa es la propuesta; la propietaria la puede mover, porque a
/// veces prefiere abonar todo a la venta y el sistema no tiene por que decidir
/// eso por ella.
///
/// No conoce ningun ViewModel: recibe los saldos ya calculados y devuelve el
/// pago por [onGuardar]. Es lo que permite que el mismo formulario sirva para
/// cobrar desde una venta y desde la cuenta de un cliente, que son la misma
/// operacion vista desde dos lados.
class AbonoForm extends StatefulWidget {
  const AbonoForm({
    required this.titulo,
    required this.onGuardar,
    this.abono,
    this.saldoVenta = 0,
    this.saldoAdeudo = 0,
    this.hayVenta = true,
    super.key,
  });

  /// Que se esta cobrando: el nombre de la venta o el del cliente.
  final String titulo;

  /// El abono a corregir, o `null` para registrar uno nuevo.
  final Abono? abono;

  /// Lo que falta por cobrar de la venta, en centavos. Solo se usa como
  /// propuesta.
  final int saldoVenta;

  /// Lo que el cliente debe de antes, en centavos.
  final int saldoAdeudo;

  /// Si el pago puede aplicarse a una venta. En falso -se esta cobrando desde
  /// la cuenta del cliente, sin ninguna venta enfrente- todo el pago va al
  /// adeudo y no hay nada que repartir.
  final bool hayVenta;

  final GuardarAbono onGuardar;

  static Future<void> abrir(
    BuildContext context, {
    required String titulo,
    required GuardarAbono onGuardar,
    Abono? abono,
    int saldoVenta = 0,
    int saldoAdeudo = 0,
    bool hayVenta = true,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AbonoForm(
        titulo: titulo,
        onGuardar: onGuardar,
        abono: abono,
        saldoVenta: saldoVenta,
        saldoAdeudo: saldoAdeudo,
        hayVenta: hayVenta,
      ),
    );
  }

  @override
  State<AbonoForm> createState() => _AbonoFormState();
}

class _AbonoFormState extends State<AbonoForm> {
  late final TextEditingController _monto;
  late final TextEditingController _adeudo;
  late final TextEditingController _nota;
  late DateTime _fecha;
  bool _guardando = false;

  /// Cierto en cuanto la propietaria mueve el reparto a mano.
  ///
  /// A partir de ahi el formulario deja de reproponerlo al cambiar el monto:
  /// pisarle lo que acaba de escribir seria pelearse con ella, y el reparto es
  /// justamente lo que se le dejo decidir.
  bool _repartoTocado = false;

  bool get _esNuevo => widget.abono == null;

  /// Cierto cuando hay algo que repartir: deuda vieja y una venta a la cual
  /// aplicar el resto.
  bool get _reparte =>
      widget.hayVenta && (widget.saldoAdeudo > 0 || _adeudoCapturado > 0);

  int get _montoCapturado => CampoDecimal.leer(_monto);

  int get _adeudoCapturado =>
      widget.hayVenta ? CampoDecimal.leer(_adeudo) : _montoCapturado;

  int get _aLaVenta {
    final resto = _montoCapturado - _adeudoCapturado;
    return resto < 0 ? 0 : resto;
  }

  @override
  void initState() {
    super.initState();
    final a = widget.abono;

    // Se propone el saldo completo porque el caso comun es que el cliente
    // liquide. Cuando ademas arrastra deuda vieja, el total propuesto es lo
    // que se necesita para quedar a mano de una vez.
    final propuesto = widget.saldoAdeudo + widget.saldoVenta;
    _monto = TextEditingController(text: dinero.aTexto(a?.monto ?? propuesto));
    _adeudo = TextEditingController(
      text: dinero.aTexto(a?.montoAdeudo ?? _propuestaAdeudo(a?.monto ?? propuesto)),
    );
    _repartoTocado = a != null;
    _nota = TextEditingController(text: a?.nota ?? '');
    _fecha = a?.fecha ?? DateTime.now();
  }

  int _propuestaAdeudo(int monto) => repartoPropuesto(
        monto: monto,
        saldoAdeudo: widget.saldoAdeudo,
      );

  @override
  void dispose() {
    _monto.dispose();
    _adeudo.dispose();
    _nota.dispose();
    super.dispose();
  }

  /// Vuelve a repartir al cambiar el monto, mientras nadie haya tocado el
  /// reparto a mano.
  void _alCambiarMonto(String _) {
    if (!_repartoTocado) {
      _adeudo.text = dinero.aTexto(_propuestaAdeudo(_montoCapturado));
    }
    setState(() {});
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Cuando pago',
      fieldLabelText: 'Fecha del abono',
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final mensaje = await widget.onGuardar(
      monto: _montoCapturado,
      montoAdeudo: _adeudoCapturado,
      fecha: _fecha,
      nota: _nota.text,
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

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, relleno + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _esNuevo ? 'Registrar abono' : 'Editar abono',
              style: tema.textTheme.titleLarge,
            ),
            const SizedBox(height: 2),
            Text(
              widget.titulo,
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            CampoDecimal(
              etiqueta: 'Monto que entrego',
              controlador: _monto,
              autofoco: true,
              alCambiar: _alCambiarMonto,
            ),
            if (_reparte) ...[
              const SizedBox(height: 16),
              _Reparto(
                controlador: _adeudo,
                saldoAdeudo: widget.saldoAdeudo,
                aLaVenta: _aLaVenta,
                sobra: _adeudoCapturado > _montoCapturado,
                alCambiar: (_) => setState(() => _repartoTocado = true),
                alRestablecer: () => setState(() {
                  _repartoTocado = false;
                  _adeudo.text =
                      dinero.aTexto(_propuestaAdeudo(_montoCapturado));
                }),
              ),
            ] else if (!widget.hayVenta && widget.saldoAdeudo > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Se descuenta de su adeudo, que hoy es de '
                '${dinero.formatear(widget.saldoAdeudo)}.',
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            CampoTexto(
              etiqueta: 'Nota',
              controlador: _nota,
              pista: 'Efectivo, transferencia...',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _elegirFecha,
              icon: const Icon(Icons.event),
              label: Text('Fecha del pago: ${Formato.fecha(_fecha)}'),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.check),
              label: const Text('Guardar abono'),
            ),
          ],
        ),
      ),
    );
  }
}

/// El reparto del pago entre la deuda vieja y la venta que se tiene enfrente.
///
/// Se captura una sola mitad -lo que va al adeudo- y la otra se muestra
/// calculada. Capturar las dos dejaria que no sumaran el total, y entonces
/// habria que decidir cual de las tres cifras gana.
class _Reparto extends StatelessWidget {
  const _Reparto({
    required this.controlador,
    required this.saldoAdeudo,
    required this.aLaVenta,
    required this.sobra,
    required this.alCambiar,
    required this.alRestablecer,
  });

  final TextEditingController controlador;
  final int saldoAdeudo;
  final int aLaVenta;

  /// Cierto cuando se mando al adeudo mas de lo que el cliente entrego.
  final bool sobra;

  final ValueChanged<String> alCambiar;
  final VoidCallback alRestablecer;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Debe ${dinero.formatear(saldoAdeudo)} de antes',
                    style: tema.textTheme.labelLarge,
                  ),
                ),
                TextButton(
                  onPressed: alRestablecer,
                  child: const Text('Repartir solo'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CampoDecimal(
              etiqueta: 'A su adeudo',
              controlador: controlador,
              alCambiar: alCambiar,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('A esta venta', style: tema.textTheme.bodyMedium),
                Text(
                  dinero.formatear(aLaVenta),
                  style: tema.textTheme.titleSmall,
                ),
              ],
            ),
            if (sobra) ...[
              const SizedBox(height: 8),
              Text(
                'Estas mandando al adeudo mas de lo que entrego.',
                style: tema.textTheme.bodySmall
                    ?.copyWith(color: tema.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
