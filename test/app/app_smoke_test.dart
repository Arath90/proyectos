import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/app/app.dart';
import 'package:punto_venta_madre/app/providers.dart';
import 'package:punto_venta_madre/features/inventario/data/inventario_repository.dart';
import 'package:punto_venta_madre/features/inventario/domain/producto_borrador.dart';
import 'package:punto_venta_madre/features/ventas/data/ventas_repository.dart';
import 'package:punto_venta_madre/features/ventas/domain/linea_venta_borrador.dart';
import 'package:punto_venta_madre/infrastructure/database/app_database.dart';

/// Prueba de humo del cableado completo: base en memoria, providers, ViewModel
/// y pantalla.
///
/// No verifica reglas de negocio -de eso se encargan las pruebas de los
/// repositorios y del dominio- sino que las capas encajan: que la pantalla
/// pinta lo que el ViewModel armo a partir de lo que hay en la base. Es lo que
/// se rompe al mover un provider de lugar.
void main() {
  late AppDatabase db;
  late Directory carpeta;

  setUpAll(prepararFormatos);

  setUp(() async {
    db = AppDatabase.paraPruebas(NativeDatabase.memory());
    // La pestana de respaldo pregunta por la carpeta de documentos, que en una
    // prueba no existe: sin este reemplazo saldria con un error de plugin en
    // pantalla en vez de con su lista vacia.
    carpeta = await Directory.systemTemp.createTemp('pvm_humo');
  });

  tearDown(() async {
    await db.close();
    try {
      await carpeta.delete(recursive: true);
    } on FileSystemException {
      // Sin ruido: es una carpeta temporal.
    }
  });

  /// Monta la aplicacion y espera a que llegue la primera lectura de la base.
  ///
  /// No se usa `pumpAndSettle`: mientras el `AsyncValue` esta en `loading` hay
  /// un `CircularProgressIndicator` girando, y eso agenda cuadros para
  /// siempre. Dos `pump` bastan para que el stream de Drift emita.
  Future<void> montar(WidgetTester tester) async {
    // La ventana de prueba mide 800x600 por omision, mas baja que cualquier
    // tablet real; con ese alto los listados desbordan y el arnes lo reporta
    // como error. Se usa el tamano de la tablet de la propietaria.
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          baseDeDatosProvider.overrideWithValue(db),
          carpetaDeDatosProvider.overrideWith((ref) async => carpeta),
        ],
        child: const App(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  /// Desmonta la aplicacion y deja correr el temporizador con el que Drift
  /// cierra sus streams al perder el ultimo suscriptor.
  ///
  /// Sin esto el arnes de pruebas aborta con "A Timer is still pending even
  /// after the widget tree was disposed": el `Timer.run` de
  /// `stream_queries.dart` queda agendado cuando el arbol ya se fue.
  Future<void> desmontar(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    // Riverpod tira sus providers despues del cuadro, y solo entonces Drift
    // agenda el cierre de los streams: hacen falta varios cuadros para que ese
    // temporizador nazca y muera dentro de la prueba.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
  }

  testWidgets('arranca en el inventario y ofrece los cuatro apartados',
      (tester) async {
    await montar(tester);

    expect(find.text('Inventario'), findsWidgets);
    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('Ventas'), findsOneWidget);
    expect(find.text('Adeudos'), findsOneWidget);
    expect(find.text('Tu inventario esta vacio'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('un producto de la base aparece en la lista', (tester) async {
    await InventarioRepository(db).crearProducto(
      const ProductoBorrador(
        marca: 'Jafra',
        codigo: '0123',
        descripcion: 'Crema de noche',
        cantidadActual: 7,
      ),
    );

    await montar(tester);

    expect(find.text('Crema de noche'), findsOneWidget);
    expect(find.text('Jafra'), findsOneWidget);
    expect(find.text('#0123'), findsOneWidget);
    expect(find.text('de 7'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('una venta apartada se ve en el inventario', (tester) async {
    final inventario = InventarioRepository(db);
    final ventas = VentasRepository(db, inventario);

    final producto = await inventario.crearProducto(
      const ProductoBorrador(
        codigo: '0123',
        descripcion: 'Crema de noche',
        cantidadActual: 10,
      ),
    );
    final venta = await ventas.crearVenta(cliente: 'Rosa');
    await ventas.agregarLinea(
      venta.id,
      LineaVentaBorrador.deProducto(producto, cantidad: 4),
    );

    await montar(tester);

    // La existencia fisica no bajo, pero el apartado ya se ve.
    expect(find.text('de 10'), findsOneWidget);
    expect(find.text('4 apartadas'), findsOneWidget);
    expect(find.text('4 pz'), findsOneWidget);

    await desmontar(tester);
  });

  testWidgets('se puede cambiar entre los cuatro apartados', (tester) async {
    await montar(tester);

    await tester.tap(find.text('Ventas'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Todavia no hay ventas'), findsOneWidget);

    await tester.tap(find.text('Adeudos'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Nadie te debe nada'), findsOneWidget);

    await tester.tap(find.text('Pedidos'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Sin pedidos capturados'), findsOneWidget);

    await desmontar(tester);
  });

  /// Los dialogos y las hojas de captura son duenos de sus controladores.
  ///
  /// El campo de texto se sigue dibujando durante la animacion de salida, asi
  /// que destruir su controlador en cuanto `showDialog` devuelve hace estallar
  /// el cuadro siguiente con "A TextEditingController was used after being
  /// disposed". Cerrar y dejar correr la animacion lo detecta.

  /// Deja correr la animacion de salida cuadro a cuadro: el error aparece
  /// mientras la hoja se sigue pintando, no al terminar.
  Future<void> dejarCerrar(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(tester.takeException(), isNull);
  }

  testWidgets('cancelar el dialogo de un pedido no rompe la animacion',
      (tester) async {
    await montar(tester);

    await tester.tap(find.text('Pedidos'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Pedido'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Cancelar'));
    await dejarCerrar(tester);

    await desmontar(tester);
  });

  /// Abrir una venta ya no pide el nombre en un dialogo: abre el selector del
  /// padron, que es una hoja y se cierra tocando fuera de ella.
  testWidgets('cerrar el selector de cliente no rompe la animacion',
      (tester) async {
    await montar(tester);

    await tester.tap(find.text('Ventas'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Venta'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Sin cliente'), findsOneWidget);

    // Tocar el velo de arriba, que es como se cierra una hoja sin elegir nada.
    await tester.tapAt(const Offset(10, 10));
    await dejarCerrar(tester);

    await desmontar(tester);
  });
}
