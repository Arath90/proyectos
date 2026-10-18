import 'package:flutter/material.dart';

/// El aspecto de la aplicacion: crema y naranja, con la letra en negro.
///
/// La paleta no se elige por gusto sino por cuanto tiempo se mira. La tablet
/// se usa en sesiones largas de captura -una tarde entera dando de alta
/// pedidos y ventas-, y una pantalla blanca pura con acentos saturados cansa
/// la vista mucho antes de que se acabe el trabajo. Por eso:
///
///  * **El fondo es crema, no blanco.** Un blanco de verdad refleja todo y
///    obliga a la pupila a cerrarse; el crema baja ese golpe sin perder
///    contraste contra la tinta.
///  * **El naranja no es fondo, es senal.** Vive en el boton que se toca, en
///    la pestana activa y en los titulos de seccion. Rellenar pantallas
///    enteras de naranja saturado es lo que produce fatiga, y ademas le quita
///    al color su poder de aviso: si todo es naranja, nada resalta.
///  * **La letra es negra.** [_tinta] es un negro apenas entibiado, no un
///    gris: sobre crema pasa de 13:1 de contraste, muy por encima de lo que
///    pide la accesibilidad, y se sigue leyendo con el sol de la ventana
///    encima.
///  * **Los campos de captura son blancos.** Son la unica excepcion al crema,
///    y a proposito: mientras el fondo descansa, la casilla donde va el dedo
///    tiene que saltar sola. En un formulario de doce campos eso es lo que
///    evita teclear en el renglon equivocado.
///
/// No hay tema oscuro. La aplicacion se pinta siempre asi aunque la tablet
/// este en modo noche: el negocio se captura de dia, y dejar que el sistema
/// cambie la piel significa que la misma pantalla se ve de dos maneras segun
/// una preferencia que nadie recuerda haber tocado.

/// Naranja natura para lo que se toca: botones, pestana activa, insignias.
///
/// Es el naranja cremoso -claro y algo lavado, no fluorescente- porque encima
/// lleva letra negra: un naranja mas oscuro obligaria a ponerla blanca, que es
/// justo lo contrario de lo que se busca aqui.
const _naranjaCremoso = Color(0xFFF3A05A);

/// El mismo naranja llevado a tono de tinta, para cuando el color tiene que
/// *leerse* en vez de rellenar: titulos de seccion, iconos, saldo liquidado.
const _naranjaQuemado = Color(0xFFA8500A);

/// El negro de la letra. Entibiado con un resto de cafe para que no choque
/// contra el crema, pero negro a todos los efectos.
const _tinta = Color(0xFF1C1512);

/// El fondo de todas las pantallas.
const _crema = Color(0xFFFFF8F1);

/// Tema unico de la aplicacion.
ThemeData temaNatura() {
  const esquema = ColorScheme(
    brightness: Brightness.light,

    // `primary` se usa como *tinta* en mas lugares de los que se usa como
    // relleno -titulos de seccion, saldo liquidado, barras de avance-, asi que
    // es el naranja oscuro. El claro entra por `primaryContainer`, que es lo
    // que pinta el boton flotante.
    primary: _naranjaQuemado,
    onPrimary: Colors.white,
    primaryContainer: _naranjaCremoso,
    onPrimaryContainer: _tinta,

    secondary: Color(0xFF8A5A2B),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFDCC0),
    onSecondaryContainer: _tinta,

    // El tercer color es el de "apartada" y el de los adeudos. Se va a mostaza
    // y no a otro naranja para que se distinga de un vistazo del estado
    // normal: dos naranjas parecidos en la misma lista no informan nada.
    tertiary: Color(0xFF7C6212),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFFE9A8),
    onTertiaryContainer: Color(0xFF241B00),

    error: Color(0xFFB3261E),
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD5),
    onErrorContainer: Color(0xFF410E0B),

    surface: _crema,
    onSurface: _tinta,

    // Las bandas de resumen y el encabezado de una venta usan
    // `surfaceContainerHighest`: es el crema mas tostado de la escala, apenas
    // separado del fondo. Suficiente para que se lea como franja aparte, no
    // tanto como para partir la pantalla en dos.
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Color(0xFFFFF3E7),
    surfaceContainer: Color(0xFFFCEDDD),
    surfaceContainerHigh: Color(0xFFF8E5D1),
    surfaceContainerHighest: Color(0xFFF4DDC4),

    onSurfaceVariant: Color(0xFF574539),
    outline: Color(0xFF8B7461),
    outlineVariant: Color(0xFFE2CFBA),

    inverseSurface: Color(0xFF32281F),
    onInverseSurface: Color(0xFFFFF0E0),
    inversePrimary: _naranjaCremoso,

    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: _naranjaQuemado,
  );

  final base = ThemeData(colorScheme: esquema, useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: _crema,

    // La barra superior no se tine de naranja: esta arriba de todas las
    // pantallas todo el dia, y una franja de color saturado permanente es el
    // tipo de cosa que cansa sin que se note por que.
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFF3E7),
      foregroundColor: _tinta,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: _tinta,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFFFBE8D6),
      indicatorColor: _naranjaCremoso,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (estados) => TextStyle(
          fontSize: 12,
          color: _tinta,
          fontWeight: estados.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        ),
      ),
      iconTheme: WidgetStateProperty.all(const IconThemeData(color: _tinta)),
    ),

    // Blanco dentro del crema: la casilla que recibe el dedo es lo unico que
    // se aclara respecto al fondo.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      labelStyle: const TextStyle(color: Color(0xFF574539)),
      floatingLabelStyle: const TextStyle(
        color: _naranjaQuemado,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(color: Color(0xFF8B7461)),
      border: _borde(const Color(0xFFE2CFBA)),
      enabledBorder: _borde(const Color(0xFFE2CFBA)),
      focusedBorder: _borde(_naranjaQuemado, grosor: 2),
      errorBorder: _borde(const Color(0xFFB3261E)),
      focusedErrorBorder: _borde(const Color(0xFFB3261E), grosor: 2),
    ),

    // Naranja cremoso con letra negra: el boton mas apretado del dia se ve de
    // lejos y se lee de cerca.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _naranjaCremoso,
        foregroundColor: _tinta,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _naranjaCremoso,
      foregroundColor: _tinta,
      elevation: 3,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _tinta,
        side: const BorderSide(color: Color(0xFFD9BE9F)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _naranjaQuemado,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: _naranjaCremoso,
      side: const BorderSide(color: Color(0xFFE2CFBA)),
      labelStyle: const TextStyle(color: _tinta, fontWeight: FontWeight.w600),
      secondaryLabelStyle: const TextStyle(color: _tinta),
      checkmarkColor: _tinta,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),

    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(Colors.white),
      surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
      elevation: WidgetStateProperty.all(0),
      side: WidgetStateProperty.all(
        const BorderSide(color: Color(0xFFE2CFBA)),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textStyle: WidgetStateProperty.all(const TextStyle(color: _tinta)),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFFFCEDDD),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFECD8C0)),
      ),
    ),

    dividerTheme: const DividerThemeData(color: Color(0xFFEBD9C4), space: 1),

    // Las hojas que suben desde abajo -selector de cliente, formulario de
    // abono, menu de acciones- son donde mas se captura, asi que van en el
    // crema mas claro y no en el mismo tono del fondo: tienen que verse encima
    // de la pantalla, no fundidas con ella.
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFFFFFBF6),
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: Color(0xFFD9BE9F),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFFFFFBF6),
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF32281F),
      contentTextStyle: TextStyle(color: Color(0xFFFFF0E0)),
      behavior: SnackBarBehavior.floating,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Color(0xFFFFFBF6),
      surfaceTintColor: Colors.transparent,
    ),

    listTileTheme: const ListTileThemeData(
      textColor: _tinta,
      iconColor: Color(0xFF6B5647),
      selectedColor: _naranjaQuemado,
      selectedTileColor: Color(0xFFFBE8D6),
    ),

    dataTableTheme: const DataTableThemeData(
      headingTextStyle: TextStyle(
        color: Color(0xFF574539),
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      dataTextStyle: TextStyle(color: _tinta, fontSize: 14),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _naranjaQuemado,
      linearTrackColor: Color(0xFFEBD9C4),
    ),

    // El calendario, en crema y con el dia elegido en naranja sobre letra
    // negra. Sin esto sale con el azul de Material, que seria el unico rincon
    // de la aplicacion que no es de esta casa.
    datePickerTheme: DatePickerThemeData(
      backgroundColor: const Color(0xFFFFFBF6),
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: _naranjaCremoso,
      headerForegroundColor: _tinta,
      todayBorder: const BorderSide(color: _naranjaQuemado),
      todayForegroundColor: WidgetStateProperty.all(_naranjaQuemado),
      dayForegroundColor: WidgetStateProperty.resolveWith(
        (estados) => estados.contains(WidgetState.disabled)
            ? const Color(0xFF8B7461)
            : _tinta,
      ),
      dayBackgroundColor: WidgetStateProperty.resolveWith(
        (estados) =>
            estados.contains(WidgetState.selected) ? _naranjaCremoso : null,
      ),
      yearForegroundColor: WidgetStateProperty.all(_tinta),
      yearBackgroundColor: WidgetStateProperty.resolveWith(
        (estados) =>
            estados.contains(WidgetState.selected) ? _naranjaCremoso : null,
      ),
    ),

    // Un punto mas grande que el estandar de Material en todo lo que se lee de
    // corrido: en una tablet apoyada en el mostrador la distancia al ojo es
    // mayor que la de un telefono en la mano.
    textTheme: base.textTheme
        .apply(bodyColor: _tinta, displayColor: _tinta)
        .copyWith(
          bodyLarge: base.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            height: 1.35,
          ),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            height: 1.35,
          ),
          bodySmall: base.textTheme.bodySmall?.copyWith(fontSize: 13),
          labelLarge: base.textTheme.labelLarge?.copyWith(fontSize: 15),
        ),
  );
}

OutlineInputBorder _borde(Color color, {double grosor = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color, width: grosor),
  );
}
