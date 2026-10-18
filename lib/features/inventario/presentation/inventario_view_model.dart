import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../data/inventario_repository.dart';
import '../domain/existencia.dart';
import '../domain/producto.dart';
import '../domain/producto_borrador.dart';

/// Todo lo que la pantalla de inventario necesita pintar, y nada mas.
///
/// Es un dato inmutable: la vista lo recibe ya resuelto y no calcula nada por
/// su cuenta. Los filtros viven aqui y no en el widget para que la logica de
/// "que se ve" se pueda probar sin levantar la interfaz.
class InventarioEstado {
  const InventarioEstado({
    this.existencias = const AsyncValue.loading(),
    this.busqueda = '',
    this.soloConApartado = false,
    this.ocultarAgotados = false,
  });

  /// El catalogo cruzado con lo que las ventas ya comprometieron.
  ///
  /// Es `AsyncValue` porque la primera lectura de la base tarda un instante y
  /// la vista tiene que saber distinguir "cargando" de "no hay nada".
  final AsyncValue<List<Existencia>> existencias;

  final String busqueda;
  final bool soloConApartado;
  final bool ocultarAgotados;

  /// Lo que se muestra despues de aplicar busqueda y filtros.
  AsyncValue<List<Existencia>> get visibles =>
      existencias.whenData((lista) => lista.where(_pasaFiltros).toList());

  bool _pasaFiltros(Existencia existencia) {
    if (soloConApartado && !existencia.hayApartado) return false;
    if (ocultarAgotados && existencia.producto.agotado) return false;

    final texto = busqueda.trim().toLowerCase();
    if (texto.isEmpty) return true;
    final producto = existencia.producto;
    return producto.marca.toLowerCase().contains(texto) ||
        producto.codigo.toLowerCase().contains(texto) ||
        producto.descripcion.toLowerCase().contains(texto);
  }

  /// Piezas fisicas en todo el inventario, para el encabezado.
  int get piezasTotales => existencias.value
          ?.fold<int>(0, (suma, e) => suma + e.producto.cantidadActual) ??
      0;

  /// Piezas comprometidas en apartados sin entregar.
  int get piezasApartadas =>
      existencias.value?.fold<int>(0, (suma, e) => suma + e.apartadas) ?? 0;

  /// Articulos sin existencia. Es lo que hay que pedirle a la distribuidora.
  int get agotados =>
      existencias.value?.where((e) => e.producto.agotado).length ?? 0;

  InventarioEstado copyWith({
    AsyncValue<List<Existencia>>? existencias,
    String? busqueda,
    bool? soloConApartado,
    bool? ocultarAgotados,
  }) {
    return InventarioEstado(
      existencias: existencias ?? this.existencias,
      busqueda: busqueda ?? this.busqueda,
      soloConApartado: soloConApartado ?? this.soloConApartado,
      ocultarAgotados: ocultarAgotados ?? this.ocultarAgotados,
    );
  }
}

/// El ViewModel del inventario: la unica pieza que sabe como se arma la
/// pantalla y que hacer cuando la usuaria toca algo.
///
/// Cruza dos fuentes que no se conocen entre si -el catalogo de
/// `InventarioRepository` y el apartado que publica `VentasRepository`- y las
/// entrega como una lista de `Existencia`. Ese cruce ocurre aqui, en la capa
/// de presentacion, precisamente para que ninguno de los dos features tenga
/// que importar al otro.
///
/// La vista solo llama a sus metodos; nunca toca un repositorio.
class InventarioViewModel extends Notifier<InventarioEstado> {
  /// Los filtros se guardan en campos y no solo en `state` porque `build` se
  /// vuelve a ejecutar cada vez que llega una fila nueva de la base; sin esto,
  /// escribir en el buscador y que alguien registrara una venta al mismo
  /// tiempo borraria lo tecleado.
  String _busqueda = '';
  bool _soloConApartado = false;
  bool _ocultarAgotados = false;

  @override
  InventarioEstado build() {
    final productos = ref.watch(productosProvider);
    final apartados = ref.watch(apartadoPorProductoProvider).value ?? const {};

    return InventarioEstado(
      existencias: productos.whenData(
        (lista) => [
          for (final producto in lista)
            Existencia(
              producto: producto,
              apartadas: apartados[producto.id] ?? 0,
            ),
        ],
      ),
      busqueda: _busqueda,
      soloConApartado: _soloConApartado,
      ocultarAgotados: _ocultarAgotados,
    );
  }

  // --- Filtros -------------------------------------------------------------

  void buscar(String texto) {
    _busqueda = texto;
    state = state.copyWith(busqueda: texto);
  }

  void alternarSoloConApartado() {
    _soloConApartado = !_soloConApartado;
    state = state.copyWith(soloConApartado: _soloConApartado);
  }

  void alternarOcultarAgotados() {
    _ocultarAgotados = !_ocultarAgotados;
    state = state.copyWith(ocultarAgotados: _ocultarAgotados);
  }

  // --- Comandos ------------------------------------------------------------
  //
  // Devuelven `null` si todo salio bien y el mensaje a mostrar si no. Se
  // eligio esto en vez de dejar escapar la excepcion para que la vista no
  // tenga que saber que existe `ProductoDuplicadoException`: su trabajo es
  // pintar un aviso, no interpretar errores de la capa de datos.

  Future<String?> crear(ProductoBorrador borrador) async {
    final invalido = _validar(borrador);
    if (invalido != null) return invalido;
    try {
      await ref.read(inventarioRepositoryProvider).crearProducto(borrador);
      return null;
    } on ProductoDuplicadoException catch (e) {
      return e.toString();
    }
  }

  Future<String?> guardar(Producto producto) async {
    final invalido = _validar(ProductoBorrador.deProducto(producto));
    if (invalido != null) return invalido;
    try {
      await ref.read(inventarioRepositoryProvider).guardarProducto(producto);
      return null;
    } on ProductoDuplicadoException catch (e) {
      return e.toString();
    }
  }

  Future<void> eliminar(Producto producto) {
    return ref.read(inventarioRepositoryProvider).eliminarProducto(producto.id);
  }

  /// Corrige la existencia a mano: la propietaria conto las cajas.
  ///
  /// Si el conteo sube por encima de lo que se habia registrado como entrado,
  /// tambien sube `cantidadOriginal`; de lo contrario quedaria un producto con
  /// mas piezas de las que jamas entraron, que es una contradiccion.
  Future<String?> ajustarExistencia(Producto producto, int cantidadActual) {
    final corregido = cantidadActual < 0 ? 0 : cantidadActual;
    return guardar(
      producto.copyWith(
        cantidadActual: corregido,
        cantidadOriginal: corregido > producto.cantidadOriginal
            ? corregido
            : producto.cantidadOriginal,
      ),
    );
  }

  String? _validar(ProductoBorrador borrador) {
    if (borrador.codigo.trim().isEmpty && borrador.descripcion.trim().isEmpty) {
      return 'Captura al menos el codigo o la descripcion del producto.';
    }
    if (borrador.cantidadActual < 0) {
      return 'La cantidad actual no puede ser negativa.';
    }
    return null;
  }
}

final inventarioViewModelProvider =
    NotifierProvider<InventarioViewModel, InventarioEstado>(
  InventarioViewModel.new,
);
