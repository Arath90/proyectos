import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/escala_decimal.dart';

/// Piezas de interfaz que las tres pantallas comparten.
///
/// Existen para que la captura se comporte igual en todo el sistema: un
/// importe se teclea del mismo modo en una linea de pedido, en un renglon de
/// venta y en un abono. Todas son widgets tontos: no conocen ningun ViewModel
/// ni ningun repositorio, solo reciben valores y avisan cuando cambian.

/// Campo de texto con etiqueta, del alto que usan todos los formularios.
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    required this.etiqueta,
    required this.controlador,
    this.pista,
    this.lineas = 1,
    this.autofoco = false,
    this.alCambiar,
    this.icono,
    this.teclado,
    this.capitalizacion = TextCapitalization.sentences,
    super.key,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final String? pista;
  final int lineas;
  final bool autofoco;
  final ValueChanged<String>? alCambiar;

  /// Icono al principio del campo. Lo usan los formularios largos, donde la
  /// silueta del icono localiza el renglon mas rapido que leer la etiqueta.
  final IconData? icono;

  /// Que teclado levanta el sistema. Un telefono pide
  /// [TextInputType.phone] para que salgan los numeros de una vez y no haya
  /// que cambiar de teclado a media captura.
  final TextInputType? teclado;

  /// Como se ponen las mayusculas solas. Un telefono no lleva ninguna, una
  /// direccion lleva las de cada palabra.
  final TextCapitalization capitalizacion;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controlador,
      autofocus: autofoco,
      minLines: lineas,
      maxLines: lineas,
      keyboardType: teclado,
      textCapitalization: capitalizacion,
      onChanged: alCambiar,
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: pista,
        prefixIcon: icono == null ? null : Icon(icono, size: 20),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

/// Un campo que no se teclea: se toca y se elige de una lista.
///
/// Se ve igual que un [CampoTexto] a proposito -mismo borde, misma etiqueta,
/// misma altura- para que un formulario que mezcla datos escritos y datos
/// elegidos se siga leyendo como una sola columna. Lo que ya existe en el
/// catalogo se elige y no se escribe: tecleado se equivoca, y un codigo mal
/// tecleado es justo lo que despues nadie puede cuadrar.
class CampoSelector extends StatelessWidget {
  const CampoSelector({
    required this.etiqueta,
    required this.valor,
    required this.alTocar,
    this.pista = '',
    this.icono,
    this.ayuda,
    super.key,
  });

  final String etiqueta;

  /// Lo elegido, o vacio para que se vea la [pista].
  final String valor;

  /// `null` deja el campo apagado, como un campo de texto deshabilitado.
  final VoidCallback? alTocar;

  final String pista;
  final IconData? icono;
  final String? ayuda;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final vacio = valor.trim().isEmpty;
    return InkWell(
      onTap: alTocar,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          helperText: ayuda,
          border: const OutlineInputBorder(),
          isDense: true,
          enabled: alTocar != null,
          prefixIcon: icono == null ? null : Icon(icono, size: 20),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          vacio ? pista : valor,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: vacio
              ? TextStyle(color: tema.colorScheme.onSurfaceVariant)
              : null,
        ),
      ),
    );
  }
}

/// Campo para capturar un numero entero de piezas.
///
/// Filtra la entrada a digitos desde el teclado en vez de validar al guardar:
/// es mas facil no dejar teclear una letra que explicar despues por que la
/// linea no se guardo.
class CampoEntero extends StatelessWidget {
  const CampoEntero({
    required this.etiqueta,
    required this.controlador,
    this.autofoco = false,
    this.alCambiar,
    super.key,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final bool autofoco;
  final ValueChanged<String>? alCambiar;

  /// Lee el texto del campo como entero. Vacio vale cero, para que dejar una
  /// columna en blanco signifique "nada" y no "error".
  static int leer(TextEditingController controlador) =>
      int.tryParse(controlador.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controlador,
      autofocus: autofoco,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: alCambiar,
      decoration: InputDecoration(
        labelText: etiqueta,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

/// Campo para capturar un importe o unos puntos.
///
/// Delega en [EscalaDecimal] la conversion a entero escalado, que es la unica
/// forma en que el dinero viaja por el sistema: la interfaz nunca produce un
/// `double`.
class CampoDecimal extends StatelessWidget {
  const CampoDecimal({
    required this.etiqueta,
    required this.controlador,
    this.escala = dinero,
    this.autofoco = false,
    this.alCambiar,
    super.key,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final EscalaDecimal escala;
  final bool autofoco;
  final ValueChanged<String>? alCambiar;

  /// Lee el campo como entero escalado. Texto invalido vale cero: el filtro
  /// del teclado ya impide casi todo lo demas.
  static int leer(TextEditingController controlador, [EscalaDecimal e = dinero]) =>
      e.parse(controlador.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controlador,
      autofocus: autofoco,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
      ],
      onChanged: alCambiar,
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixText: escala.simbolo.isEmpty ? null : '${escala.simbolo} ',
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

/// Un dato con su etiqueta encima, para las tarjetas de resumen.
class DatoResumen extends StatelessWidget {
  const DatoResumen({
    required this.etiqueta,
    required this.valor,
    this.destacado = false,
    this.color,
    super.key,
  });

  final String etiqueta;
  final String valor;
  final bool destacado;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          etiqueta.toUpperCase(),
          style: tema.textTheme.labelSmall?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: (destacado
                  ? tema.textTheme.titleMedium
                  : tema.textTheme.bodyLarge)
              ?.copyWith(
            color: color,
            fontWeight: destacado ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }
}

/// Franja de datos que corona un listado o un detalle.
class BarraResumen extends StatelessWidget {
  const BarraResumen({required this.datos, super.key});

  final List<Widget> datos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      width: double.infinity,
      color: tema.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(spacing: 24, runSpacing: 12, children: datos),
    );
  }
}

/// Lo que se ve cuando todavia no hay nada capturado.
///
/// Siempre lleva una accion: una lista vacia sin salida es un callejon, y la
/// propietaria abre la aplicacion por primera vez justo en este estado.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    required this.icono,
    required this.titulo,
    required this.detalle,
    this.accion,
    super.key,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56, color: tema.colorScheme.outline),
            const SizedBox(height: 16),
            Text(titulo, style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              detalle,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            if (accion != null) ...[const SizedBox(height: 20), accion!],
          ],
        ),
      ),
    );
  }
}

/// Etiqueta corta de color para estados: apartada, recibido, agotado.
class Insignia extends StatelessWidget {
  const Insignia(this.texto, {required this.color, this.icono, super.key});

  final String texto;
  final Color color;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Muestra un aviso al pie de la pantalla.
///
/// Los ViewModel devuelven el mensaje de error en vez de lanzarlo; esta
/// funcion es el otro extremo de esa decision: el unico lugar donde ese texto
/// se convierte en algo visible.
void avisar(BuildContext context, String? mensaje, {bool error = false}) {
  if (mensaje == null || !context.mounted) return;
  final tema = Theme.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? tema.colorScheme.error : null,
      ),
    );
}

/// Pregunta de si o no antes de algo que no se puede deshacer.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String aceptar = 'Aceptar',
  bool peligroso = false,
}) async {
  final respuesta = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: peligroso
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                )
              : null,
          child: Text(aceptar),
        ),
      ],
    ),
  );
  return respuesta ?? false;
}

/// Pide una sola linea de texto: el nombre de una carpeta, un concepto.
///
/// Es un dialogo y no una pantalla porque lo que pide cabe en una palabra. Es
/// `StatefulWidget` por dentro nada mas para que el controlador viva y muera
/// con el dialogo: si se destruye en cuanto `showDialog` devuelve, el campo
/// sigue dibujandose durante la animacion de salida con un controlador ya
/// muerto.
Future<String?> pedirTexto(
  BuildContext context, {
  required String titulo,
  required String etiqueta,
  String valor = '',
  String pista = '',
  String aceptar = 'Guardar',
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _DialogoTexto(
      titulo: titulo,
      etiqueta: etiqueta,
      valor: valor,
      pista: pista,
      aceptar: aceptar,
    ),
  );
}

class _DialogoTexto extends StatefulWidget {
  const _DialogoTexto({
    required this.titulo,
    required this.etiqueta,
    required this.valor,
    required this.pista,
    required this.aceptar,
  });

  final String titulo;
  final String etiqueta;
  final String valor;
  final String pista;
  final String aceptar;

  @override
  State<_DialogoTexto> createState() => _DialogoTextoState();
}

class _DialogoTextoState extends State<_DialogoTexto> {
  late final TextEditingController _texto =
      TextEditingController(text: widget.valor);

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: TextField(
        controller: _texto,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: widget.etiqueta,
          hintText: widget.pista.isEmpty ? null : widget.pista,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (valor) => Navigator.pop(context, valor),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _texto.text),
          child: Text(widget.aceptar),
        ),
      ],
    );
  }
}

/// Una opcion del menu que se abre al mantener el dedo sobre un renglon.
class AccionHoja {
  const AccionHoja({
    required this.valor,
    required this.icono,
    required this.titulo,
    this.detalle,
    this.peligroso = false,
  });

  final String valor;
  final IconData icono;
  final String titulo;
  final String? detalle;

  /// Se pinta en rojo. No confirma nada por su cuenta: quien la reciba decide
  /// si ademas pregunta.
  final bool peligroso;
}

/// Menu de acciones sobre un renglon de una lista.
///
/// Sustituye al gesto de "manten el dedo y se borra", que era la unica accion
/// posible cuando las listas no hacian mas que eso. Con carpetas hay dos cosas
/// que se le pueden hacer a una venta sin abrirla -moverla y borrarla- y un
/// gesto que a veces mueve y a veces borra seria una trampa.
Future<String?> menuDeAcciones(
  BuildContext context, {
  required String titulo,
  required List<AccionHoja> acciones,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final tema = Theme.of(context);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                titulo,
                style: tema.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(height: 1),
            for (final accion in acciones)
              ListTile(
                leading: Icon(
                  accion.icono,
                  color: accion.peligroso ? tema.colorScheme.error : null,
                ),
                title: Text(
                  accion.titulo,
                  style: accion.peligroso
                      ? TextStyle(color: tema.colorScheme.error)
                      : null,
                ),
                subtitle:
                    accion.detalle == null ? null : Text(accion.detalle!),
                onTap: () => Navigator.pop(context, accion.valor),
              ),
          ],
        ),
      );
    },
  );
}
