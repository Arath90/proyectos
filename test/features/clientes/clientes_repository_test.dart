import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/clientes/data/clientes_repository.dart';
import 'package:punto_venta_madre/features/clientes/domain/cliente.dart';
import 'package:punto_venta_madre/features/inventario/data/inventario_repository.dart';
import 'package:punto_venta_madre/features/ventas/data/ventas_repository.dart';
import 'package:punto_venta_madre/infrastructure/database/app_database.dart';

/// Pruebas del padron de clientes.
///
/// Lo que se ejercita aqui es lo unico que este repositorio decide: que dos
/// nombres son la misma persona -para no partir su cuenta en dos- y que
/// corregir un nombre lo corrige tambien en sus ventas.
void main() {
  late AppDatabase db;
  late ClientesRepository repo;
  late VentasRepository ventas;

  setUp(() {
    db = AppDatabase.paraPruebas(NativeDatabase.memory());
    repo = ClientesRepository(db);
    ventas = VentasRepository(db, InventarioRepository(db));
  });

  tearDown(() => db.close());

  group('la clave con la que se comparan dos nombres', () {
    test('ignora mayusculas, acentos y espacios de mas', () {
      expect(claveDeNombre('  TONY  '), 'tony');
      expect(claveDeNombre('Maria Jose'), claveDeNombre('maría  josé'));
      expect(claveDeNombre('Toño'), claveDeNombre('tono'));
    });

    test('un nombre vacio no vale como clave', () {
      expect(claveDeNombre('   '), '');
    });
  });

  group('dar de alta', () {
    test('no duplica a quien ya existe aunque se escriba distinto', () async {
      final primero = await repo.asegurarCliente('Tony');
      final segundo = await repo.asegurarCliente('  TONY ');

      expect(segundo.id, primero.id);
      expect(await repo.observarClientes().first, hasLength(1));
    });

    test('dos personas distintas si son dos', () async {
      await repo.asegurarCliente('Tony');
      await repo.asegurarCliente('Rosa');
      expect(await repo.observarClientes().first, hasLength(2));
    });

    test('el padron sale en orden alfabetico', () async {
      await repo.asegurarCliente('Rosa');
      await repo.asegurarCliente('Ana');
      await repo.asegurarCliente('Maru');

      final lista = await repo.observarClientes().first;
      expect(lista.map((c) => c.nombre), ['Ana', 'Maru', 'Rosa']);
    });
  });

  /// El nombre de un cliente se corrige porque estaba mal escrito, no porque
  /// la persona cambio. Dejar el error congelado en sus ventas viejas -como si
  /// fuera la descripcion historica de un producto- no le sirve a nadie: la
  /// busqueda encontraria unas ventas y otras no.
  test('renombrar arregla tambien el nombre copiado en sus ventas', () async {
    final tony = await repo.asegurarCliente('Toni');
    final venta = await ventas.crearVenta(
      cliente: tony.nombre,
      clienteId: tony.id,
    );

    await repo.guardarCliente(tony.copyWith(nombre: 'Tony'));

    final guardada = await ventas.observarVenta(venta.id).first;
    expect(guardada!.cliente, 'Tony');
    expect(guardada.clienteId, tony.id);
  });

  test('renombrar no toca las ventas de otra persona', () async {
    final tony = await repo.asegurarCliente('Tony');
    final rosa = await repo.asegurarCliente('Rosa');
    final deRosa = await ventas.crearVenta(
      cliente: rosa.nombre,
      clienteId: rosa.id,
    );

    await repo.guardarCliente(tony.copyWith(nombre: 'Antonio'));

    final guardada = await ventas.observarVenta(deRosa.id).first;
    expect(guardada!.cliente, 'Rosa');
  });

  test('dar de baja suelta sus ventas pero les deja el nombre', () async {
    final tony = await repo.asegurarCliente('Tony');
    final venta = await ventas.crearVenta(
      cliente: tony.nombre,
      clienteId: tony.id,
    );

    await repo.eliminarCliente(tony.id);

    expect(await repo.observarClientes().first, isEmpty);
    final guardada = await ventas.observarVenta(venta.id).first;
    expect(guardada!.clienteId, null, reason: 'ya no apunta a nadie');
    expect(
      guardada.cliente,
      'Tony',
      reason: 'la venta sigue diciendo a quien se le vendio',
    );
  });
}
