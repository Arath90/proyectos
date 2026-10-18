import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/carpeta_venta.dart';
import '../domain/venta.dart';
import '../domain/venta_detallada.dart';

/// Que subconjunto de ventas quiere ver la propietaria.
///
/// No es lo mismo que `EstadoVenta`: aqui hay opciones que cruzan estados,
/// como "las que me deben", que es la pregunta que mas se hace cuando el cobro
/// va por abonos.
enum FiltroVentas {
  todas,
  apartadas,
  porCobrar,
  liquidadas;

  String get etiqueta => switch (this) {
        FiltroVentas.todas => 'Todas',
        FiltroVentas.apartadas => 'Apartadas',
        FiltroVentas.porCobrar => 'Me deben',
        FiltroVentas.liquidadas => 'Liquidadas',
      };

  bool aplica(VentaDetallada detalle) => switch (this) {
        FiltroVentas.todas => true,
        FiltroVentas.apartadas => detalle.venta.estado.aparta,
        FiltroVentas.porCobrar =>
          detalle.venta.estado.cobrable && detalle.saldo > 0,
        FiltroVentas.liquidadas => detalle.liquidada,
      };
}

/// Lo que pinta el listado de ventas.
///
/// La pantalla tiene dos caras y este estado decide cual toca. Mientras no
/// haya ninguna carpeta se comporta como siempre, una lista corrida: separar
/// no le sirve a quien todavia tiene diez ventas. En cuanto la propietaria
/// crea la primera carpeta, la pantalla se vuelve una estanteria -carpetas
/// primero, se entra a una y ahi si aparecen las ventas- porque a partir de
/// ahi la pregunta ya no es "cuanto me deben" sino "cuanto me deben aqui".
class VentasEstado {
  const VentasEstado({
    this.ventas = const AsyncValue.loading(),
    this.carpetas = const [],
    this.busqueda = '',
    this.filtro = FiltroVentas.todas,
    this.enRaiz = true,
    this.carpetaAbierta,
  });

  /// Las ventas ya armadas con sus renglones y sus abonos.
  final AsyncValue<List<VentaDetallada>> ventas;

  final List<CarpetaVenta> carpetas;

  final String busqueda;
  final FiltroVentas filtro;

  /// Cierto cuando se esta viendo la estanteria y no el interior de una
  /// carpeta.
  final bool enRaiz;

  /// La carpeta abierta. `null` con [enRaiz] en falso es "Sin carpeta", el
  /// monton de las ventas que nunca se separaron: se ve como una carpeta pero
  /// no es una fila de la tabla, es el resto.
  final String? carpetaAbierta;

  bool get hayCarpetas => carpetas.isNotEmpty;

  bool get buscando => busqueda.trim().isNotEmpty;

  /// Cierto cuando toca pintar carpetas en vez de ventas.
  ///
  /// Buscar rompe la estanteria a proposito: quien teclea "tony" esta buscando
  /// a una persona, no un lugar, y obligarla a acertar la carpeta antes de
  /// encontrarlo convertiria la separacion en un estorbo.
  bool get mostrarEstanteria => enRaiz && hayCarpetas && !buscando;

  CarpetaVenta? get carpeta {
    if (enRaiz || carpetaAbierta == null) return null;
    for (final c in carpetas) {
      if (c.id == carpetaAbierta) return c;
    }
    return null;
  }

  /// Como se llama lo que se esta viendo, para la barra de arriba.
  String get titulo => enRaiz ? 'Ventas' : (carpeta?.titulo ?? 'Sin carpeta');

  AsyncValue<List<VentaDetallada>> get visibles =>
      ventas.whenData((lista) => lista.where(_pasaFiltros).toList());

  /// Las carpetas con lo que guardan, para pintar la estanteria.
  ///
  /// Se listan todas aunque esten vacias -una carpeta recien creada tiene que
  /// aparecer para poder meterle algo- y "Sin carpeta" solo cuando hay ventas
  /// sueltas, porque un monton vacio no es un lugar al que entrar.
  ///
  /// Los totales de cada carpeta ignoran los chips de estado: la estanteria
  /// contesta que hay en cada lugar, y un filtro encendido que vaciara
  /// carpetas se leeria como que la carpeta se quedo sin ventas.
  List<ResumenCarpeta> get estanteria {
    final lista = ventas.value ?? const <VentaDetallada>[];
    final porCarpeta = <String, List<VentaDetallada>>{};
    final sueltas = <VentaDetallada>[];

    for (final detalle in lista) {
      final id = detalle.venta.carpetaId;
      if (id == null) {
        sueltas.add(detalle);
      } else {
        porCarpeta.putIfAbsent(id, () => []).add(detalle);
      }
    }

    return [
      for (final c in carpetas)
        ResumenCarpeta(
          carpeta: c,
          resumen: ResumenVentas.de(porCarpeta[c.id] ?? const []),
        ),
      if (sueltas.isNotEmpty)
        ResumenCarpeta(carpeta: null, resumen: ResumenVentas.de(sueltas)),
    ];
  }

  bool _pasaFiltros(VentaDetallada detalle) {
    if (!_esDeLaCarpetaAbierta(detalle)) return false;
    if (!filtro.aplica(detalle)) return false;
    final texto = busqueda.trim().toLowerCase();
    if (texto.isEmpty) return true;
    return detalle.venta.cliente.toLowerCase().contains(texto) ||
        detalle.lineas.any(
          (linea) =>
              linea.descripcion.toLowerCase().contains(texto) ||
              linea.codigo.toLowerCase().contains(texto),
        );
  }

  /// En la raiz no filtra por carpeta: ahi se esta viendo todo, ya sea porque
  /// no hay carpetas o porque se esta buscando a alguien a traves de ellas.
  bool _esDeLaCarpetaAbierta(VentaDetallada detalle) {
    if (enRaiz) return true;
    return detalle.venta.carpetaId == carpetaAbierta;
  }

  /// Totales de lo que se esta viendo, no de todo el historico: si la
  /// propietaria abrio una carpeta y filtro "me deben", el resumen debe
  /// contestar cuanto le deben ahi.
  ResumenVentas get resumen =>
      ResumenVentas.de(visibles.value ?? const <VentaDetallada>[]);

  VentasEstado copyWith({
    AsyncValue<List<VentaDetallada>>? ventas,
    List<CarpetaVenta>? carpetas,
    String? busqueda,
    FiltroVentas? filtro,
    bool? enRaiz,
    ({String? valor})? carpetaAbierta,
  }) {
    return VentasEstado(
      ventas: ventas ?? this.ventas,
      carpetas: carpetas ?? this.carpetas,
      busqueda: busqueda ?? this.busqueda,
      filtro: filtro ?? this.filtro,
      enRaiz: enRaiz ?? this.enRaiz,
      carpetaAbierta:
          carpetaAbierta == null ? this.carpetaAbierta : carpetaAbierta.valor,
    );
  }
}

/// ViewModel del listado de ventas.
///
/// Su trabajo es coser lecturas independientes -encabezados, renglones, abonos
/// y los cargos de adeudo que nacieron de cada venta- en la pieza que la
/// pantalla entiende: una lista de [VentaDetallada]. Se cosen aqui y no en SQL
/// porque los totales y el saldo son reglas de dominio que ya viven en
/// `VentaDetallada`; calcularlos otra vez en la consulta dejaria dos versiones
/// de la misma regla.
///
/// Que lo traspasado a adeudos entre por aqui es lo que permite que ventas y
/// adeudos no se conozcan: el feature de adeudos publica cuanto se saco de cada
/// venta y este ViewModel lo entrega ya sumado, igual que hace con los
/// renglones.
class VentasViewModel extends Notifier<VentasEstado> {
  String _busqueda = '';
  FiltroVentas _filtro = FiltroVentas.todas;
  bool _enRaiz = true;
  String? _carpetaAbierta;

  @override
  VentasEstado build() {
    final ventas = ref.watch(ventasProvider);
    final carpetas = ref.watch(carpetasProvider).value ?? const [];
    final lineas = ref.watch(lineasPorVentaProvider).value ?? const {};
    final abonos = ref.watch(abonosPorVentaProvider).value ?? const {};
    final traspasado = ref.watch(traspasadoPorVentaProvider);

    return VentasEstado(
      ventas: ventas.whenData(
        (lista) => [
          for (final venta in lista)
            VentaDetallada(
              venta: venta,
              lineas: lineas[venta.id] ?? const [],
              abonos: abonos[venta.id] ?? const [],
              traspasado: traspasado[venta.id] ?? 0,
            ),
        ],
      ),
      carpetas: carpetas,
      busqueda: _busqueda,
      filtro: _filtro,
      enRaiz: _enRaiz,
      carpetaAbierta: _carpetaAbierta,
    );
  }

  void buscar(String texto) {
    _busqueda = texto;
    state = state.copyWith(busqueda: texto);
  }

  void filtrar(FiltroVentas filtro) {
    _filtro = filtro;
    state = state.copyWith(filtro: filtro);
  }

  // --- Carpetas ------------------------------------------------------------

  /// Entra a una carpeta. `null` entra al monton de las ventas sueltas.
  void abrirCarpeta(String? carpetaId) {
    _enRaiz = false;
    _carpetaAbierta = carpetaId;
    state = state.copyWith(enRaiz: false, carpetaAbierta: (valor: carpetaId));
  }

  /// Regresa a la estanteria. Devuelve falso si ya se estaba en ella, para que
  /// el boton de atras del sistema sepa que esta vez si le toca cerrar la
  /// pantalla en lugar de subir un nivel.
  bool volver() {
    if (_enRaiz) return false;
    _enRaiz = true;
    _carpetaAbierta = null;
    state = state.copyWith(enRaiz: true, carpetaAbierta: (valor: null));
    return true;
  }

  /// Crea una carpeta y entra a ella. Devuelve el mensaje a mostrar si el
  /// nombre no sirve.
  Future<String?> crearCarpeta(String nombre) async {
    if (nombre.trim().isEmpty) return 'Ponle nombre a la carpeta.';
    final carpeta =
        await ref.read(ventasRepositoryProvider).crearCarpeta(nombre: nombre);
    abrirCarpeta(carpeta.id);
    return null;
  }

  Future<String?> renombrarCarpeta(CarpetaVenta carpeta, String nombre) async {
    if (nombre.trim().isEmpty) return 'Ponle nombre a la carpeta.';
    await ref
        .read(ventasRepositoryProvider)
        .guardarCarpeta(carpeta.copyWith(nombre: nombre));
    return null;
  }

  /// Borra la carpeta. Sus ventas no se van con ella: quedan sueltas.
  Future<void> eliminarCarpeta(CarpetaVenta carpeta) async {
    await ref.read(ventasRepositoryProvider).eliminarCarpeta(carpeta.id);
    if (_carpetaAbierta == carpeta.id) volver();
  }

  Future<void> moverVenta(Venta venta, String? carpetaId) {
    return ref.read(ventasRepositoryProvider).moverVenta(venta.id, carpetaId);
  }

  // --- Ventas --------------------------------------------------------------

  /// Abre una venta nueva y devuelve su id para que la vista navegue al
  /// detalle: una venta sin renglones no sirve de nada, asi que el flujo
  /// natural es crear y seguir capturando.
  ///
  /// Nace dentro de la carpeta abierta. Es lo unico que no obliga a corregir
  /// despues: quien esta viendo las ventas de un lugar y abre una nueva, la
  /// esta abriendo para ese lugar.
  Future<String> crearVenta({String cliente = '', String? clienteId}) async {
    final venta = await ref.read(ventasRepositoryProvider).crearVenta(
          cliente: cliente,
          clienteId: clienteId,
          carpetaId: state.enRaiz ? null : state.carpetaAbierta,
        );
    return venta.id;
  }

  Future<void> eliminar(Venta venta) {
    return ref.read(ventasRepositoryProvider).eliminarVenta(venta.id);
  }
}

final ventasViewModelProvider =
    NotifierProvider<VentasViewModel, VentasEstado>(VentasViewModel.new);
