import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/adeudos/data/adeudos_repository.dart';
import 'package:punto_venta_madre/features/inventario/data/inventario_repository.dart';
import 'package:punto_venta_madre/features/ventas/data/ventas_repository.dart';
import 'package:punto_venta_madre/infrastructure/database/app_database.dart';

/// La migracion a la v4 sobre una base que ya trae datos.
///
/// Es la prueba mas cara del archivo y la que mas importa: la tablet de la
/// propietaria tiene una base v3 con ventas y abonos capturados, no hay
/// respaldo, y la v4 no solo agrega columnas -recrea `abonos` para que
/// `venta_id` deje de ser obligatorio-. Si ese paso pierde una fila, se pierde
/// dinero cobrado que nadie puede reconstruir.
///
/// El esquema v3 se levanta tal como lo escribia esa version, con `setup` de
/// `NativeDatabase`, y solo entonces se abre `AppDatabase`, que ve
/// `user_version = 3` y corre `onUpgrade`.
void main() {
  late Directory carpeta;
  late File archivo;

  setUp(() async {
    carpeta = await Directory.systemTemp.createTemp('pvm_migracion');
    archivo = File('${carpeta.path}/v3.sqlite');
  });

  tearDown(() => carpeta.delete(recursive: true));

  AppDatabase abrirDesdeV3() {
    return AppDatabase.paraPruebas(
      NativeDatabase(archivo, setup: (raw) => raw.execute(_esquemaV3)),
    );
  }

  test('una base v3 con ventas y abonos llega completa a la version de hoy',
      () async {
    final db = abrirDesdeV3();
    addTearDown(db.close);

    final inventario = InventarioRepository(db);
    final ventas = VentasRepository(db, inventario);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(
      version.data.values.first,
      db.schemaVersion,
      reason: 'la base recorrio todos los escalones hasta el ultimo',
    );

    final lista = await ventas.observarVentas().first;
    expect(lista, hasLength(1));
    expect(lista.single.cliente, 'Tony');
    expect(
      lista.single.clienteId,
      isNull,
      reason: 'las ventas viejas no se enlazan solas: el padron lo llena ella',
    );
    expect(lista.single.carpetaId, isNull, reason: 'quedan sueltas');

    final lineas = await ventas.observarLineas('venta-1').first;
    expect(lineas.single.descripcion, 'Crema de noche');
  });

  test('los abonos sobreviven a que se recree su tabla', () async {
    final db = abrirDesdeV3();
    addTearDown(db.close);
    final ventas = VentasRepository(db, InventarioRepository(db));

    final abonos = await ventas.observarAbonos('venta-1').first;
    expect(abonos, hasLength(2));
    expect(abonos.map((a) => a.monto), [40000, 25000]);
    expect(
      abonos.every((a) => a.montoAdeudo == 0),
      isTrue,
      reason: 'se cobraron cuando los adeudos no existian: ninguno tapo deuda',
    );
    expect(abonos.every((a) => a.ventaId == 'venta-1'), isTrue);
    expect(abonos.first.nota, 'efectivo');
  });

  test('el borrado logico de la v3 se sigue respetando', () async {
    final db = abrirDesdeV3();
    addTearDown(db.close);
    final ventas = VentasRepository(db, InventarioRepository(db));

    // La base de prueba trae una venta borrada y un abono borrado. Copiarlos
    // sin su `eliminado_en` los resucitaria, y con ellos un saldo que ya no
    // existe.
    expect(await ventas.observarVentas().first, hasLength(1));
    expect(await ventas.observarAbonos('venta-1').first, hasLength(2));
  });

  test('las tablas nuevas llegan vacias y listas para usarse', () async {
    final db = abrirDesdeV3();
    addTearDown(db.close);

    expect(await AdeudosRepository(db).observarAdeudos().first, isEmpty);
    expect(
      await VentasRepository(db, InventarioRepository(db))
          .observarCarpetas()
          .first,
      isEmpty,
    );

    // Y la base vuelve a tener las llaves foraneas encendidas: la migracion
    // las apaga para poder recrear `abonos`, y `beforeOpen` tiene que
    // devolverlas antes de que nadie escriba.
    final fk = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(fk.data.values.first, 1);
  });
}

/// El esquema tal como lo dejaba la v3, con unos datos capturados.
///
/// Va escrito a mano y no generado a proposito: es el retrato de una version
/// que ya no existe en el codigo, y tiene que quedarse quieto aunque las
/// tablas de hoy sigan cambiando.
const _esquemaV3 = '''
CREATE TABLE "pedidos" ("id" TEXT NOT NULL, "fecha" INTEGER NOT NULL, "campana" TEXT NOT NULL DEFAULT '', "marca_predeterminada" TEXT NOT NULL DEFAULT '', "notas" TEXT NOT NULL DEFAULT '', "cerrado" INTEGER NOT NULL DEFAULT 0 CHECK ("cerrado" IN (0, 1)), "recibido_en" INTEGER NULL, "creado_en" INTEGER NOT NULL, "actualizado_en" INTEGER NOT NULL, "eliminado_en" INTEGER NULL, PRIMARY KEY ("id"));
CREATE TABLE "productos" ("id" TEXT NOT NULL, "marca" TEXT NOT NULL DEFAULT '', "codigo" TEXT NOT NULL DEFAULT '', "descripcion" TEXT NOT NULL DEFAULT '', "cantidad_actual" INTEGER NOT NULL DEFAULT 0, "cantidad_original" INTEGER NOT NULL DEFAULT 0, "creado_en" INTEGER NOT NULL, "actualizado_en" INTEGER NOT NULL, "eliminado_en" INTEGER NULL, PRIMARY KEY ("id"));
CREATE TABLE "lineas_pedido" ("id" TEXT NOT NULL, "pedido_id" TEXT NOT NULL REFERENCES pedidos (id) ON DELETE CASCADE, "producto_id" TEXT NULL REFERENCES productos (id), "marca" TEXT NOT NULL DEFAULT '', "codigo" TEXT NOT NULL DEFAULT '', "descripcion" TEXT NOT NULL DEFAULT '', "cant_pedida" INTEGER NOT NULL DEFAULT 0, "cant_enviada" INTEGER NOT NULL DEFAULT 0, "valor_total_puntos" INTEGER NOT NULL DEFAULT 0, "precio_unitario" INTEGER NOT NULL DEFAULT 0, "precio_revista" INTEGER NOT NULL DEFAULT 0, "valor_total_promocionado" INTEGER NOT NULL DEFAULT 0, "total_descuento_cn" INTEGER NOT NULL DEFAULT 0, "valor_regalos" INTEGER NOT NULL DEFAULT 0, "valor_prom_sin_iva_manual" INTEGER NULL, "tu_pagas_manual" INTEGER NULL, "precio_total_manual" INTEGER NULL, "orden" INTEGER NOT NULL DEFAULT 0, "creado_en" INTEGER NOT NULL, "actualizado_en" INTEGER NOT NULL, "eliminado_en" INTEGER NULL, PRIMARY KEY ("id"));
CREATE TABLE "ventas" ("id" TEXT NOT NULL, "fecha" INTEGER NOT NULL, "cliente" TEXT NOT NULL DEFAULT '', "notas" TEXT NOT NULL DEFAULT '', "estado" TEXT NOT NULL DEFAULT 'apartada', "entregada_en" INTEGER NULL, "creado_en" INTEGER NOT NULL, "actualizado_en" INTEGER NOT NULL, "eliminado_en" INTEGER NULL, PRIMARY KEY ("id"));
CREATE TABLE "lineas_venta" ("id" TEXT NOT NULL, "venta_id" TEXT NOT NULL REFERENCES ventas (id) ON DELETE CASCADE, "producto_id" TEXT NULL REFERENCES productos (id), "marca" TEXT NOT NULL DEFAULT '', "codigo" TEXT NOT NULL DEFAULT '', "descripcion" TEXT NOT NULL DEFAULT '', "cantidad" INTEGER NOT NULL DEFAULT 0, "precio_unitario" INTEGER NOT NULL DEFAULT 0, "descuento" INTEGER NOT NULL DEFAULT 0, "orden" INTEGER NOT NULL DEFAULT 0, "creado_en" INTEGER NOT NULL, "actualizado_en" INTEGER NOT NULL, "eliminado_en" INTEGER NULL, PRIMARY KEY ("id"));
CREATE TABLE "abonos" ("id" TEXT NOT NULL, "venta_id" TEXT NOT NULL REFERENCES ventas (id) ON DELETE CASCADE, "fecha" INTEGER NOT NULL, "monto" INTEGER NOT NULL DEFAULT 0, "nota" TEXT NOT NULL DEFAULT '', "creado_en" INTEGER NOT NULL, "actualizado_en" INTEGER NOT NULL, "eliminado_en" INTEGER NULL, PRIMARY KEY ("id"));
PRAGMA user_version = 3;

INSERT INTO productos VALUES ('prod-1', 'Jafra', '0123', 'Crema de noche', 10, 12, 1700000000, 1700000000, NULL);
INSERT INTO ventas VALUES ('venta-1', 1700000000, 'Tony', '', 'entregada', 1700003600, 1700000000, 1700000000, NULL);
INSERT INTO ventas VALUES ('venta-borrada', 1700000000, 'Nadie', '', 'apartada', NULL, 1700000000, 1700000000, 1700009000);
INSERT INTO lineas_venta VALUES ('linea-1', 'venta-1', 'prod-1', 'Jafra', '0123', 'Crema de noche', 2, 50000, 0, 0, 1700000000, 1700000000, NULL);
INSERT INTO abonos VALUES ('abono-1', 'venta-1', 1700000100, 40000, 'efectivo', 1700000100, 1700000100, NULL);
INSERT INTO abonos VALUES ('abono-2', 'venta-1', 1700000200, 25000, '', 1700000200, 1700000200, NULL);
INSERT INTO abonos VALUES ('abono-borrado', 'venta-1', 1700000300, 9900, 'mal capturado', 1700000300, 1700000300, 1700000400);
''';
