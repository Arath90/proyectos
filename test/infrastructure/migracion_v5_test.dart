import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/clientes/data/clientes_repository.dart';
import 'package:punto_venta_madre/features/ventas/data/ventas_repository.dart';
import 'package:punto_venta_madre/features/inventario/data/inventario_repository.dart';
import 'package:punto_venta_madre/infrastructure/database/app_database.dart';

/// La migracion a la v5 sobre la base que la propietaria trae hoy.
///
/// La v5 le cuelga al cliente su telefono y su direccion. Es el tipo de cambio
/// que parece que no puede salir mal -dos columnas de texto con default vacio-
/// y por el que justamente conviene tener prueba: lo que se esta arriesgando
/// es el padron completo, con las deudas colgadas de el.
///
/// La prueba de verdad no es que las columnas aparezcan, sino que los clientes
/// que ya existian sigan ahi, con su nombre, sus adeudos y sus ventas
/// enlazadas, y que las columnas nuevas lleguen vacias en vez de con basura.
void main() {
  late Directory carpeta;
  late File archivo;

  setUp(() async {
    carpeta = await Directory.systemTemp.createTemp('pvm_migracion_v5');
    archivo = File('${carpeta.path}/v4.sqlite');
  });

  tearDown(() => carpeta.delete(recursive: true));

  AppDatabase abrirDesdeV4() {
    return AppDatabase.paraPruebas(
      NativeDatabase(archivo, setup: (raw) => raw.execute(_esquemaV4)),
    );
  }

  test('el padron de una base v4 llega completo a la v5', () async {
    final db = abrirDesdeV4();
    addTearDown(db.close);

    final clientes = ClientesRepository(db);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, db.schemaVersion);

    final padron = await clientes.observarClientes().first;
    expect(padron, hasLength(2), reason: 'nadie se perdio en el camino');

    final tony = padron.firstWhere((c) => c.id == 'cli-1');
    expect(tony.nombre, 'Tony');
    expect(tony.notas, 'la del mercado');

    // Las columnas nuevas nacen vacias: no se inventa un telefono a partir de
    // la nota, aunque la nota parezca traerlo.
    expect(tony.telefono, isEmpty);
    expect(tony.direccion, isEmpty);
  });

  test('el cliente conserva sus ventas y sus adeudos', () async {
    final db = abrirDesdeV4();
    addTearDown(db.close);

    final ventas = VentasRepository(db, InventarioRepository(db));

    final lista = await ventas.observarVentas().first;
    expect(lista, hasLength(1));
    expect(lista.single.clienteId, 'cli-1', reason: 'el enlace al padron vive');

    final adeudos = await db.customSelect('SELECT * FROM adeudos').get();
    expect(adeudos, hasLength(1));
    expect(adeudos.single.data['monto'], 200000);
  });

  test('lo capturado despues de migrar si guarda telefono y direccion',
      () async {
    final db = abrirDesdeV4();
    addTearDown(db.close);

    final clientes = ClientesRepository(db);
    final tony = (await clientes.observarClientes().first)
        .firstWhere((c) => c.id == 'cli-1');

    await clientes.guardarCliente(
      tony.copyWith(telefono: '311 123 4567', direccion: 'Hidalgo 12, Centro'),
    );

    final guardado = await clientes.obtenerCliente('cli-1');
    expect(guardado!.telefono, '311 123 4567');
    expect(guardado.direccion, 'Hidalgo 12, Centro');

    // Y el nombre copiado en su venta sigue intacto: guardar contacto no toca
    // lo que la hoja de la venta dice.
    final venta = await db
        .customSelect("SELECT cliente FROM ventas WHERE id = 'venta-1'")
        .getSingle();
    expect(venta.data['cliente'], 'Tony');
  });
}

/// El esquema tal como lo dejaba la v4, con el padron ya poblado.
///
/// Va escrito a mano por la misma razon que el de la v3: es el retrato de una
/// version que ya no existe en el codigo y tiene que quedarse quieto aunque
/// las tablas de hoy sigan cambiando. `clientes` es la unica que aparece
/// distinta de la actual: le faltan las dos columnas que agrega la v5.
const _esquemaV4 = '''
CREATE TABLE "productos" ("id" TEXT NOT NULL, "marca" TEXT NOT NULL DEFAULT '', "codigo" TEXT NOT NULL DEFAULT '', "descripcion" TEXT NOT NULL DEFAULT '', "cantidad_actual" INTEGER NOT NULL DEFAULT 0, "cantidad_original" INTEGER NOT NULL DEFAULT 0, "creado_en" INTEGER NOT NULL, "actualizado_en" INTEGER NOT NULL, "eliminado_en" INTEGER NULL, PRIMARY KEY ("id"));
CREATE TABLE "clientes" ("id" TEXT NOT NULL, "nombre" TEXT NOT NULL DEFAULT '', "notas" TEXT NOT NULL DEFAULT '', "creado_en" INTEGER NOT NULL, "actualizado_en" INTEGER NOT NULL, "eliminado_en" INTEGER NULL, PRIMARY KEY ("id"));
CREATE TABLE "carpetas_venta" ("id" TEXT NOT NULL, "nombre" TEXT NOT NULL DEFAULT '', "notas" TEXT NOT NULL DEFAULT '', "creado_en" INTEGER NOT NULL, "actualizado_en" INTEGER NOT NULL, "eliminado_en" INTEGER NULL, PRIMARY KEY ("id"));
CREATE TABLE "ventas" ("id" TEXT NOT NULL, "fecha" INTEGER NOT NULL, "cliente_id" TEXT NULL REFERENCES clientes (id), "cliente" TEXT NOT NULL DEFAULT '', "carpeta_id" TEXT NULL REFERENCES carpetas_venta (id), "notas" TEXT NOT NULL DEFAULT '', "estado" TEXT NOT NULL DEFAULT 'apartada', "entregada_en" INTEGER NULL, "creado_en" INTEGER NOT NULL, "actualizado_en" INTEGER NOT NULL, "eliminado_en" INTEGER NULL, PRIMARY KEY ("id"));
CREATE TABLE "lineas_venta" ("id" TEXT NOT NULL, "venta_id" TEXT NOT NULL REFERENCES ventas (id) ON DELETE CASCADE, "producto_id" TEXT NULL REFERENCES productos (id), "marca" TEXT NOT NULL DEFAULT '', "codigo" TEXT NOT NULL DEFAULT '', "descripcion" TEXT NOT NULL DEFAULT '', "cantidad" INTEGER NOT NULL DEFAULT 0, "precio_unitario" INTEGER NOT NULL DEFAULT 0, "descuento" INTEGER NOT NULL DEFAULT 0, "orden" INTEGER NOT NULL DEFAULT 0, "creado_en" INTEGER NOT NULL, "actualizado_en" INTEGER NOT NULL, "eliminado_en" INTEGER NULL, PRIMARY KEY ("id"));
CREATE TABLE "abonos" ("id" TEXT NOT NULL, "venta_id" TEXT NULL REFERENCES ventas (id) ON DELETE CASCADE, "cliente_id" TEXT NULL REFERENCES clientes (id), "fecha" INTEGER NOT NULL, "monto" INTEGER NOT NULL DEFAULT 0, "monto_adeudo" INTEGER NOT NULL DEFAULT 0, "nota" TEXT NOT NULL DEFAULT '', "creado_en" INTEGER NOT NULL, "actualizado_en" INTEGER NOT NULL, "eliminado_en" INTEGER NULL, PRIMARY KEY ("id"));
CREATE TABLE "adeudos" ("id" TEXT NOT NULL, "cliente_id" TEXT NOT NULL REFERENCES clientes (id), "fecha" INTEGER NOT NULL, "concepto" TEXT NOT NULL DEFAULT '', "monto" INTEGER NOT NULL DEFAULT 0, "venta_origen_id" TEXT NULL REFERENCES ventas (id), "creado_en" INTEGER NOT NULL, "actualizado_en" INTEGER NOT NULL, "eliminado_en" INTEGER NULL, PRIMARY KEY ("id"));
CREATE TABLE "pedidos" ("id" TEXT NOT NULL, "fecha" INTEGER NOT NULL, "campana" TEXT NOT NULL DEFAULT '', "marca_predeterminada" TEXT NOT NULL DEFAULT '', "notas" TEXT NOT NULL DEFAULT '', "cerrado" INTEGER NOT NULL DEFAULT 0 CHECK ("cerrado" IN (0, 1)), "recibido_en" INTEGER NULL, "creado_en" INTEGER NOT NULL, "actualizado_en" INTEGER NOT NULL, "eliminado_en" INTEGER NULL, PRIMARY KEY ("id"));
CREATE TABLE "lineas_pedido" ("id" TEXT NOT NULL, "pedido_id" TEXT NOT NULL REFERENCES pedidos (id) ON DELETE CASCADE, "producto_id" TEXT NULL REFERENCES productos (id), "marca" TEXT NOT NULL DEFAULT '', "codigo" TEXT NOT NULL DEFAULT '', "descripcion" TEXT NOT NULL DEFAULT '', "cant_pedida" INTEGER NOT NULL DEFAULT 0, "cant_enviada" INTEGER NOT NULL DEFAULT 0, "valor_total_puntos" INTEGER NOT NULL DEFAULT 0, "precio_unitario" INTEGER NOT NULL DEFAULT 0, "precio_revista" INTEGER NOT NULL DEFAULT 0, "valor_total_promocionado" INTEGER NOT NULL DEFAULT 0, "total_descuento_cn" INTEGER NOT NULL DEFAULT 0, "valor_regalos" INTEGER NOT NULL DEFAULT 0, "valor_prom_sin_iva_manual" INTEGER NULL, "tu_pagas_manual" INTEGER NULL, "precio_total_manual" INTEGER NULL, "orden" INTEGER NOT NULL DEFAULT 0, "creado_en" INTEGER NOT NULL, "actualizado_en" INTEGER NOT NULL, "eliminado_en" INTEGER NULL, PRIMARY KEY ("id"));
PRAGMA user_version = 4;

INSERT INTO clientes VALUES ('cli-1', 'Tony', 'la del mercado', 1700000000, 1700000000, NULL);
INSERT INTO clientes VALUES ('cli-2', 'Chuy', '', 1700000000, 1700000000, NULL);
INSERT INTO productos VALUES ('prod-1', 'Jafra', '0123', 'Crema de noche', 10, 12, 1700000000, 1700000000, NULL);
INSERT INTO ventas VALUES ('venta-1', 1700000000, 'cli-1', 'Tony', NULL, '', 'entregada', 1700003600, 1700000000, 1700000000, NULL);
INSERT INTO lineas_venta VALUES ('linea-1', 'venta-1', 'prod-1', 'Jafra', '0123', 'Crema de noche', 2, 50000, 0, 0, 1700000000, 1700000000, NULL);
INSERT INTO abonos VALUES ('abono-1', 'venta-1', 'cli-1', 1700000100, 40000, 0, 'efectivo', 1700000100, 1700000100, NULL);
INSERT INTO adeudos VALUES ('adeudo-1', 'cli-1', 1690000000, 'lo de diciembre', 200000, NULL, 1690000000, 1690000000, NULL);
''';
