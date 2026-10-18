import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/inventario/data/inventario_repository.dart';
import 'package:punto_venta_madre/features/ventas/data/ventas_repository.dart';
import 'package:punto_venta_madre/infrastructure/database/app_database.dart';

/// Pruebas de las carpetas del listado de ventas.
///
/// Una carpeta es una etiqueta -donde la propietaria decidio guardar la hoja- y
/// la venta es el documento. Todo lo que se prueba aqui sale de esa diferencia:
/// mover, sacar y borrar carpetas nunca puede tocar una venta.
void main() {
  late AppDatabase db;
  late VentasRepository repo;

  setUp(() {
    db = AppDatabase.paraPruebas(NativeDatabase.memory());
    repo = VentasRepository(db, InventarioRepository(db));
  });

  tearDown(() => db.close());

  test('las carpetas salen en orden alfabetico', () async {
    await repo.crearCarpeta(nombre: 'Xalisco');
    await repo.crearCarpeta(nombre: 'Compostela');
    await repo.crearCarpeta(nombre: 'Tepic');

    final carpetas = await repo.observarCarpetas().first;
    expect(
      carpetas.map((c) => c.nombre),
      ['Compostela', 'Tepic', 'Xalisco'],
      reason: 'se leen para encontrar un lugar por su nombre',
    );
  });

  test('una venta nace donde se le diga y se puede mover', () async {
    final tepic = await repo.crearCarpeta(nombre: 'Tepic');
    final xalisco = await repo.crearCarpeta(nombre: 'Xalisco');

    final venta = await repo.crearVenta(cliente: 'Tony', carpetaId: tepic.id);
    expect((await repo.observarVenta(venta.id).first)!.carpetaId, tepic.id);

    await repo.moverVenta(venta.id, xalisco.id);
    expect((await repo.observarVenta(venta.id).first)!.carpetaId, xalisco.id);

    await repo.moverVenta(venta.id, null);
    expect(
      (await repo.observarVenta(venta.id).first)!.carpetaId,
      null,
      reason: 'sacarla de la carpeta la deja suelta, no la borra',
    );
  });

  test('una venta abierta sin carpeta queda suelta', () async {
    final venta = await repo.crearVenta(cliente: 'Rosa');
    expect((await repo.observarVenta(venta.id).first)!.carpetaId, null);
  });

  /// Lo que mas facil se rompe: borrar la etiqueta no se puede llevar el
  /// documento. Una venta perdida al ordenar carpetas seria mercancia y saldo
  /// que desaparecen sin que nadie lo pidiera.
  test('borrar una carpeta deja sus ventas sueltas, no las borra', () async {
    final tepic = await repo.crearCarpeta(nombre: 'Tepic');
    final unaVenta = await repo.crearVenta(cliente: 'Tony', carpetaId: tepic.id);
    final otra = await repo.crearVenta(cliente: 'Maru', carpetaId: tepic.id);

    await repo.eliminarCarpeta(tepic.id);

    expect(await repo.observarCarpetas().first, isEmpty);
    final ventas = await repo.observarVentas().first;
    expect(ventas, hasLength(2));
    expect(
      ventas.every((v) => v.carpetaId == null),
      isTrue,
      reason: 'quedan en "Sin carpeta"',
    );
    expect(
      ventas.map((v) => v.id).toSet(),
      {unaVenta.id, otra.id},
    );
  });

  test('borrar una carpeta no mueve las ventas de otra', () async {
    final tepic = await repo.crearCarpeta(nombre: 'Tepic');
    final xalisco = await repo.crearCarpeta(nombre: 'Xalisco');
    final deXalisco =
        await repo.crearVenta(cliente: 'Maru', carpetaId: xalisco.id);

    await repo.eliminarCarpeta(tepic.id);

    expect(
      (await repo.observarVenta(deXalisco.id).first)!.carpetaId,
      xalisco.id,
    );
  });

  test('renombrar una carpeta no toca sus ventas', () async {
    final carpeta = await repo.crearCarpeta(nombre: 'Tepik');
    final venta = await repo.crearVenta(cliente: 'Tony', carpetaId: carpeta.id);

    await repo.guardarCarpeta(carpeta.copyWith(nombre: 'Tepic'));

    final carpetas = await repo.observarCarpetas().first;
    expect(carpetas.single.nombre, 'Tepic');
    expect((await repo.observarVenta(venta.id).first)!.carpetaId, carpeta.id);
  });
}
