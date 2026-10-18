import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../features/adeudos/presentation/adeudos_page.dart';
import '../features/inventario/presentation/inventario_page.dart';
import '../features/pedidos/presentation/pedidos_page.dart';
import '../features/respaldos/presentation/respaldos_page.dart';
import '../features/ventas/presentation/ventas_page.dart';
import 'tema.dart';

/// La aplicacion y su navegacion.
///
/// Las primeras tres pestanas son los tres momentos del negocio, en el orden
/// en que ocurren:
///
///  1. **Pedidos**: la propietaria le compra a la distribuidora. Al recibir la
///     caja, las piezas entran al inventario.
///  2. **Inventario**: lo que tiene en casa. Es el centro; los otros dos lo
///     mueven.
///  3. **Ventas**: le vende a un cliente. Al entregar, las piezas salen del
///     inventario, y el cobro sigue vivo despues con los abonos.
///
/// El inventario queda al centro porque es el que se consulta a media
/// conversacion con un cliente, y porque es lo que une a los otros dos.
///
/// La cuarta, **Adeudos**, no es un cuarto momento sino lo que queda cuando el
/// tercero no se cierra: el dinero que la gente sigue debiendo. Va al final
/// porque se abre al terminar la ronda, y esta separada de Ventas porque la
/// deuda vieja no puede vivir dentro de una venta sin ensuciar el inventario
/// -habria que dar de alta hoy productos que salieron hace meses-.
///
/// La quinta, **Respaldo**, no es del negocio sino del programa, y aun asi es
/// una pestana y no una opcion de menu. La razon es que un respaldo escondido
/// no se hace nunca: aqui no hay servidor ni nube, y lo unico que separa un
/// ano de ventas de perderse es que la propietaria mande el archivo a su
/// WhatsApp de vez en cuando. Eso tiene que estar a la vista.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Punto de venta',
      debugShowCheckedModeBanner: false,

      // Espanol de Mexico en toda la aplicacion, y no solo en los textos que
      // se escribieron aqui: los dialogos que pone Material -el calendario de
      // los adeudos y de las ventas, sobre todo- traen sus meses, sus dias y
      // sus botones de estos delegados. Sin ellos salen en ingles aunque
      // alrededor todo este en espanol, que es de las cosas que mas hacen
      // dudar a quien esta capturando: si la pantalla cambia de idioma a
      // medias, parece que se toco algo que no se debia.
      //
      // `locale` se fija en vez de seguir al sistema porque este es un
      // programa de una sola casa: la tablet puede venir configurada en
      // ingles de fabrica y aun asi la aplicacion tiene que hablar el idioma
      // de quien la usa.
      locale: const Locale('es', 'MX'),
      supportedLocales: const [Locale('es', 'MX'), Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Un solo tema, siempre claro. La razon esta en `tema.dart`.
      theme: temaNatura(),
      themeMode: ThemeMode.light,

      home: const Inicio(),
    );
  }
}

/// Carga los nombres de meses en espanol antes de pintar nada.
///
/// `Formato` usa `DateFormat` con locale `es`, y sin esta inicializacion
/// lanzaria en tiempo de ejecucion la primera vez que se muestre una fecha.
Future<void> prepararFormatos() => initializeDateFormatting('es');

/// El armazon con la barra de navegacion.
///
/// Mantiene las cuatro pantallas vivas con un [IndexedStack] en vez de
/// reconstruirlas al cambiar de pestana: la propietaria salta constantemente
/// entre inventario y venta mientras atiende, y perder la busqueda que tenia
/// tecleada -o la carpeta en la que iba- cada vez seria insoportable.
class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  int _pestana = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _pestana,
        children: const [
          PedidosPage(),
          InventarioPage(),
          VentasPage(),
          AdeudosPage(),
          RespaldosPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (i) => setState(() => _pestana = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventario',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Ventas',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Adeudos',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Respaldo',
          ),
        ],
      ),
    );
  }
}
