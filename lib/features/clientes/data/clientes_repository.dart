import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../infrastructure/database/app_database.dart';
import '../domain/cliente.dart';

/// Traduce entre las filas de `Clientes` y el modelo de dominio.
///
/// Es el repositorio mas simple del sistema y el que menos reglas concentra,
/// con una excepcion que si vale la pena leer: al renombrar a alguien tambien
/// reescribe el nombre copiado en sus ventas.
///
/// Esa copia existe porque una venta debe seguir diciendo a quien se le
/// vendio aunque el padron no exista o el enlace se pierda -es la misma razon
/// por la que una linea de venta copia la descripcion del producto-, pero a
/// diferencia de aquella, esta si se mantiene al dia: una descripcion cambia
/// porque el articulo cambio, mientras que un nombre cambia porque estaba mal
/// escrito, y dejar el error congelado en veinte ventas viejas no le sirve a
/// nadie.
class ClientesRepository {
  ClientesRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  // --- Lectura -------------------------------------------------------------

  /// El padron vigente, en orden alfabetico, que es como se busca a alguien
  /// en una lista.
  Stream<List<Cliente>> observarClientes() {
    final consulta = _db.select(_db.clientes)
      ..where((t) => t.eliminadoEn.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.nombre)]);
    return consulta.watch().map((filas) => filas.map(_aCliente).toList());
  }

  Future<Cliente?> obtenerCliente(String clienteId) async {
    final consulta = _db.select(_db.clientes)
      ..where((t) => t.id.equals(clienteId));
    final fila = await consulta.getSingleOrNull();
    return fila == null ? null : _aCliente(fila);
  }

  /// Busca a alguien por como se escribe su nombre, ignorando mayusculas,
  /// acentos y espacios de mas.
  ///
  /// La comparacion se hace en Dart y no en SQL porque la regla de que dos
  /// nombres son el mismo vive en `claveDeNombre`, del dominio, y traducirla a
  /// un `LIKE` dejaria dos versiones de la misma regla. El padron cabe de
  /// sobra en memoria: son los clientes de una persona, no de una cadena.
  Future<Cliente?> buscarPorNombre(String nombre) async {
    final clave = claveDeNombre(nombre);
    if (clave.isEmpty) return null;
    for (final cliente in await observarClientes().first) {
      if (cliente.clave == clave) return cliente;
    }
    return null;
  }

  // --- Escritura -----------------------------------------------------------

  Future<Cliente> crearCliente({
    String nombre = '',
    String telefono = '',
    String direccion = '',
    String notas = '',
  }) async {
    final ahora = DateTime.now();
    final cliente = Cliente(
      id: _uuid.v4(),
      nombre: nombre.trim(),
      telefono: telefono.trim(),
      direccion: direccion.trim(),
      notas: notas.trim(),
    );
    await _db.into(_db.clientes).insert(
          ClientesCompanion.insert(
            id: cliente.id,
            nombre: Value(cliente.nombre),
            telefono: Value(cliente.telefono),
            direccion: Value(cliente.direccion),
            notas: Value(cliente.notas),
            creadoEn: ahora,
            actualizadoEn: ahora,
          ),
        );
    return cliente;
  }

  /// Devuelve el cliente que se llama asi, dandolo de alta si no existia.
  ///
  /// Es lo que usa el selector cuando la propietaria teclea un nombre nuevo:
  /// alta y busqueda en un solo paso, para que dar de alta a alguien no sea
  /// una pantalla aparte a la que hay que ir antes de poder vender.
  Future<Cliente> asegurarCliente(String nombre) async {
    final existente = await buscarPorNombre(nombre);
    if (existente != null) return existente;
    return crearCliente(nombre: nombre);
  }

  /// Guarda los datos del cliente, y refresca el nombre copiado en las ventas
  /// de esa persona.
  ///
  /// El telefono y la direccion no se copian a ninguna venta: se leen siempre
  /// del padron, asi que corregir un numero mal apuntado lo corrige de una vez
  /// en todas las hojas de esa persona. El nombre es la excepcion y por eso es
  /// el unico que hay que ir a reescribir.
  ///
  /// Las dos escrituras van en una transaccion: un padron corregido con
  /// ventas que siguen diciendo el nombre viejo es peor que no haberlo
  /// corregido, porque la busqueda encontraria unas si y otras no.
  Future<void> guardarCliente(Cliente cliente) {
    return _db.transaction(() async {
      final ahora = DateTime.now();
      final nombre = cliente.nombre.trim();

      await (_db.update(_db.clientes)..where((t) => t.id.equals(cliente.id)))
          .write(
        ClientesCompanion(
          nombre: Value(nombre),
          telefono: Value(cliente.telefono.trim()),
          direccion: Value(cliente.direccion.trim()),
          notas: Value(cliente.notas.trim()),
          actualizadoEn: Value(ahora),
        ),
      );

      await (_db.update(_db.ventas)
            ..where((t) =>
                t.clienteId.equals(cliente.id) & t.eliminadoEn.isNull()))
          .write(
        VentasCompanion(cliente: Value(nombre), actualizadoEn: Value(ahora)),
      );
    });
  }

  /// Da de baja a un cliente del padron.
  ///
  /// Es borrado logico y ademas suelta sus ventas: dejarlas apuntando a
  /// alguien que ya no esta en la lista las volveria invisibles en el listado
  /// de adeudos sin que nada lo explique. El nombre copiado se queda, asi que
  /// las ventas siguen diciendo a quien se le vendio.
  ///
  /// Quien decide si esta baja tiene sentido es el ViewModel: aqui no se sabe
  /// si la persona debe dinero, y borrar a un deudor es justo lo que no se
  /// debe poder hacer de un toque.
  Future<void> eliminarCliente(String clienteId) {
    return _db.transaction(() async {
      final ahora = DateTime.now();
      await (_db.update(_db.ventas)
            ..where((t) => t.clienteId.equals(clienteId)))
          .write(
        const VentasCompanion(clienteId: Value(null)),
      );
      await (_db.update(_db.clientes)..where((t) => t.id.equals(clienteId)))
          .write(
        ClientesCompanion(
          eliminadoEn: Value(ahora),
          actualizadoEn: Value(ahora),
        ),
      );
    });
  }

  // --- Mapeo ---------------------------------------------------------------

  Cliente _aCliente(ClienteRow fila) => Cliente(
        id: fila.id,
        nombre: fila.nombre,
        telefono: fila.telefono,
        direccion: fila.direccion,
        notas: fila.notas,
      );
}
