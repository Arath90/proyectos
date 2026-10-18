import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/cliente.dart';

/// ViewModel del padron de clientes.
///
/// Es el mas chico del sistema y a proposito no guarda estado de pantalla: ni
/// busqueda ni filtros. El padron se consulta desde dos lugares a la vez -el
/// selector que se abre encima de una venta y la pantalla de adeudos-, y una
/// busqueda compartida haria que teclear en uno cambiara lo que el otro
/// muestra por debajo. Cada pantalla filtra la lista que recibe.
class ClientesViewModel extends Notifier<AsyncValue<List<Cliente>>> {
  @override
  AsyncValue<List<Cliente>> build() => ref.watch(clientesProvider);

  /// Da de alta a alguien, o devuelve al que ya se llamaba asi.
  ///
  /// No se queja de un nombre repetido: contesta con el que ya existia. Es lo
  /// que hace que dar de alta a una persona no sea una pantalla aparte a la
  /// que hay que ir antes de poder venderle, y es tambien la unica defensa
  /// contra el duplicado, que es el error que mas dano hace aqui -dos "Tony"
  /// son dos cuentas y ningun abono cuadra.
  Future<Cliente?> crear(String nombre) async {
    if (nombre.trim().isEmpty) return null;
    return ref.read(clientesRepositoryProvider).asegurarCliente(nombre);
  }

  /// Guarda el nombre corregido. El repositorio lo propaga a las ventas de esa
  /// persona, para que un nombre mal escrito no sobreviva en las hojas viejas.
  Future<String?> guardar(Cliente cliente) async {
    if (cliente.nombre.trim().isEmpty) {
      return 'El cliente necesita un nombre.';
    }
    await ref.read(clientesRepositoryProvider).guardarCliente(cliente);
    return null;
  }

  /// Da de baja a alguien del padron.
  ///
  /// Se niega si tiene ventas o adeudos. Borrar a un deudor de un toque es
  /// justo lo que no debe poder pasar: la deuda no se iria con el, solo se
  /// volveria invisible. Para el caso normal -un nombre mal capturado- lo que
  /// corresponde es renombrarlo, que ademas arregla las ventas que lo apuntan.
  Future<String?> eliminar(Cliente cliente) async {
    final ventas = ref.read(ventasProvider).value ?? const [];
    if (ventas.any((v) => v.clienteId == cliente.id)) {
      return 'No se puede borrar a ${cliente.titulo}: tiene ventas a su '
          'nombre. Si el nombre esta mal escrito, corrigelo.';
    }
    final adeudos = ref.read(adeudosPorClienteProvider)[cliente.id];
    if (adeudos != null && adeudos.isNotEmpty) {
      return 'No se puede borrar a ${cliente.titulo}: tiene adeudos '
          'registrados.';
    }
    await ref.read(clientesRepositoryProvider).eliminarCliente(cliente.id);
    return null;
  }
}

final clientesViewModelProvider =
    NotifierProvider<ClientesViewModel, AsyncValue<List<Cliente>>>(
  ClientesViewModel.new,
);
