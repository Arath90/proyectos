import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../features/adeudos/data/adeudos_repository.dart';
import '../features/adeudos/domain/adeudo.dart';
import '../features/clientes/data/clientes_repository.dart';
import '../features/clientes/domain/cliente.dart';
import '../features/inventario/data/inventario_repository.dart';
import '../features/inventario/domain/producto.dart';
import '../features/pedidos/data/pedidos_repository.dart';
import '../features/pedidos/domain/linea_pedido.dart';
import '../features/pedidos/domain/pedido.dart';
import '../features/reportes/data/compartidor_reportes.dart';
import '../features/respaldos/data/compartidor_respaldo.dart';
import '../features/respaldos/data/respaldos_repository.dart';
import '../features/respaldos/data/selector_de_archivo.dart';
import '../features/ventas/data/ventas_repository.dart';
import '../features/ventas/domain/abono.dart';
import '../features/ventas/domain/carpeta_venta.dart';
import '../features/ventas/domain/linea_venta.dart';
import '../features/ventas/domain/venta.dart';
import '../infrastructure/database/app_database.dart';

/// El cableado de la aplicacion: quien construye a quien.
///
/// Es la "M" de MVVM vista desde afuera. Aqui viven los objetos de larga vida
/// (base de datos y repositorios) y las lecturas reactivas que los ViewModel
/// consumen; ningun ViewModel construye su propio repositorio ni ninguna
/// pantalla toca Drift. Cambiar el almacenamiento por un backend deberia
/// tocar solo este archivo y la capa `data`.
///
/// Las lecturas se publican como `StreamProvider` sueltos, uno por consulta,
/// en vez de un solo proveedor gordo por pantalla. Asi cada ViewModel combina
/// exactamente lo que necesita y Riverpod se encarga de mantener una sola
/// suscripcion a la base aunque tres pantallas pidan lo mismo. Es tambien lo
/// que permite unir inventario y ventas sin que ninguno de los dos features
/// dependa del otro: quien los cruza es el ViewModel, no el repositorio.

/// La base de datos local. Vive mientras viva la aplicacion.
///
/// Se puede invalidar: restaurar un respaldo reemplaza el archivo en disco y
/// entonces hay que volver a abrirlo. Es el unico caso en que este proveedor
/// se tira y se vuelve a construir con la aplicacion andando.
final baseDeDatosProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// La carpeta donde `drift_flutter` deja el `.sqlite`.
///
/// Se publica aparte porque el respaldo necesita esa ruta como archivo, no
/// como base abierta. Es tambien el punto por el que las pruebas meten una
/// carpeta temporal en vez de la del dispositivo.
final carpetaDeDatosProvider =
    FutureProvider<Directory>((ref) => getApplicationDocumentsDirectory());

/// Las copias de la base. No abre la base: copia archivos.
final respaldosRepositoryProvider =
    FutureProvider<RespaldosRepository>((ref) async {
  return RespaldosRepository(await ref.watch(carpetaDeDatosProvider.future));
});

/// Quien entrega un respaldo al menu de compartir de Android.
final compartidorRespaldoProvider = Provider<CompartidorRespaldo>((ref) {
  return const CompartidorRespaldo();
});

/// Quien abre el explorador de archivos para traer un respaldo de vuelta.
final selectorDeArchivoProvider = Provider<SelectorDeArchivo>((ref) {
  return const SelectorDeArchivo();
});

/// El inventario. Lo reciben los otros dos repositorios porque es el unico
/// autorizado para mover existencias.
final inventarioRepositoryProvider = Provider<InventarioRepository>((ref) {
  return InventarioRepository(ref.watch(baseDeDatosProvider));
});

/// Pedidos a la distribuidora: por donde entra la mercancia.
final pedidosRepositoryProvider = Provider<PedidosRepository>((ref) {
  return PedidosRepository(
    ref.watch(baseDeDatosProvider),
    ref.watch(inventarioRepositoryProvider),
  );
});

/// Ventas a clientes: por donde sale la mercancia y entra el dinero.
final ventasRepositoryProvider = Provider<VentasRepository>((ref) {
  return VentasRepository(
    ref.watch(baseDeDatosProvider),
    ref.watch(inventarioRepositoryProvider),
  );
});

/// El padron de clientes. No depende de nadie ni nadie depende de el: es una
/// lista de nombres a la que ventas y adeudos apuntan.
final clientesRepositoryProvider = Provider<ClientesRepository>((ref) {
  return ClientesRepository(ref.watch(baseDeDatosProvider));
});

/// Adeudos: dinero que se debe sin mercancia detras.
///
/// No recibe el inventario, y esa ausencia es la definicion del feature. Un
/// adeudo existe justamente para poder cobrar lo que se llevaron antes sin
/// tener que inventar movimientos de existencias que nunca ocurrieron hoy.
final adeudosRepositoryProvider = Provider<AdeudosRepository>((ref) {
  return AdeudosRepository(ref.watch(baseDeDatosProvider));
});

/// Quien convierte un reporte en archivo y lo entrega al menu de compartir.
///
/// No lee ni escribe la base: recibe un reporte ya armado. Vive aqui porque es
/// una dependencia de larga vida mas, y porque es el unico punto del sistema
/// que habla con el sistema de archivos y con Android.
final compartidorReportesProvider = Provider<CompartidorReportes>((ref) {
  return const CompartidorReportes();
});

// --- Lecturas del inventario ------------------------------------------------

final productosProvider = StreamProvider<List<Producto>>((ref) {
  return ref.watch(inventarioRepositoryProvider).observarProductos();
});

/// Piezas comprometidas por ventas apartadas, por producto.
///
/// Vive en el lado de ventas porque es ventas quien aparta, y lo consume el
/// inventario para calcular lo disponible.
final apartadoPorProductoProvider = StreamProvider<Map<String, int>>((ref) {
  return ref.watch(ventasRepositoryProvider).observarApartadoPorProducto();
});

// --- Lecturas de ventas -----------------------------------------------------

final ventasProvider = StreamProvider<List<Venta>>((ref) {
  return ref.watch(ventasRepositoryProvider).observarVentas();
});

final carpetasProvider = StreamProvider<List<CarpetaVenta>>((ref) {
  return ref.watch(ventasRepositoryProvider).observarCarpetas();
});

final lineasPorVentaProvider =
    StreamProvider<Map<String, List<LineaVenta>>>((ref) {
  return ref.watch(ventasRepositoryProvider).observarLineasPorVenta();
});

final abonosPorVentaProvider = StreamProvider<Map<String, List<Abono>>>((ref) {
  return ref.watch(ventasRepositoryProvider).observarAbonosPorVenta();
});

/// Los mismos abonos, vistos por cliente en vez de por venta.
///
/// Son dos lecturas de una sola tabla y no dos tablas: un pago que se repartio
/// entre la venta del dia y la deuda vieja aparece en las dos, y cada
/// consumidor se queda con la parte que le toca.
final abonosPorClienteProvider =
    StreamProvider<Map<String, List<Abono>>>((ref) {
  return ref.watch(ventasRepositoryProvider).observarAbonosPorCliente();
});

// --- Lecturas de clientes y adeudos -----------------------------------------

final clientesProvider = StreamProvider<List<Cliente>>((ref) {
  return ref.watch(clientesRepositoryProvider).observarClientes();
});

final adeudosProvider = StreamProvider<List<Adeudo>>((ref) {
  return ref.watch(adeudosRepositoryProvider).observarAdeudos();
});

/// Cuanto se saco de cada venta para mandarlo a la cuenta del cliente.
///
/// Es el enlace de vuelta que necesita el listado de ventas para dejar de
/// cobrar un saldo que ya se cobra en otro lado. Se deriva de [adeudosProvider]
/// en vez de consultarse aparte porque son los mismos cargos agrupados de otra
/// forma, y una segunda consulta podria contestar distinto que la primera
/// mientras las dos se ponen al dia.
final traspasadoPorVentaProvider = Provider<Map<String, int>>((ref) {
  final adeudos = ref.watch(adeudosProvider).value ?? const [];
  final mapa = <String, int>{};
  for (final adeudo in adeudos) {
    final origen = adeudo.ventaOrigenId;
    if (origen == null) continue;
    mapa[origen] = (mapa[origen] ?? 0) + adeudo.monto;
  }
  return mapa;
});

/// Los cargos de cada cliente, del mas reciente al mas viejo.
final adeudosPorClienteProvider = Provider<Map<String, List<Adeudo>>>((ref) {
  final adeudos = ref.watch(adeudosProvider).value ?? const [];
  final mapa = <String, List<Adeudo>>{};
  for (final adeudo in adeudos) {
    mapa.putIfAbsent(adeudo.clienteId, () => []).add(adeudo);
  }
  return mapa;
});

// --- Lecturas de pedidos ----------------------------------------------------

final pedidosProvider = StreamProvider<List<Pedido>>((ref) {
  return ref.watch(pedidosRepositoryProvider).observarPedidos();
});

final lineasPorPedidoProvider =
    StreamProvider<Map<String, List<LineaPedido>>>((ref) {
  return ref.watch(pedidosRepositoryProvider).observarLineasPorPedido();
});
