import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punto_venta_madre/features/respaldos/data/respaldos_repository.dart';
import 'package:punto_venta_madre/features/respaldos/domain/respaldo.dart';
import 'package:punto_venta_madre/infrastructure/database/app_database.dart';

/// Las copias de la base.
///
/// Es la prueba de la red de seguridad, asi que lo que verifica no es que se
/// creen archivos sino que **sirvan**: que la copia se pueda volver a abrir con
/// los datos dentro, que la que se toma antes de migrar se tome antes y no
/// despues, y que restaurar no deje un `-wal` viejo pegado a una base nueva
/// -que es la unica forma en que este codigo podria corromper datos-.
void main() {
  late Directory carpeta;
  late RespaldosRepository respaldos;
  late DateTime ahora;

  /// Un reloj que se mueve a mano: dos respaldos en el mismo segundo se
  /// llamarian igual y el segundo pisaria al primero. En la tablet no pasa
  /// -nadie respalda dos veces en el mismo segundo-, pero una prueba si.
  DateTime reloj() => ahora;

  setUp(() async {
    carpeta = await Directory.systemTemp.createTemp('pvm_respaldos');
    ahora = DateTime(2026, 9, 8, 11, 30);
    respaldos = RespaldosRepository(carpeta, reloj: reloj);
  });

  // Windows no deja borrar un archivo que sqlite todavia tiene abierto, y una
  // prueba que falla dejaria a las demas fallando por la limpieza en vez de
  // por lo suyo. La carpeta es temporal: si queda, el sistema la barre.
  tearDown(() async {
    try {
      await carpeta.delete(recursive: true);
    } on FileSystemException {
      // Sin ruido.
    }
  });

  /// Abre la base en el mismo archivo que el respaldo va a copiar.
  AppDatabase abrirBase() =>
      AppDatabase.paraPruebas(NativeDatabase(respaldos.archivoDeLaBase));

  Future<void> darDeAlta(AppDatabase db, String id, String nombre) {
    return db.into(db.clientes).insert(
          ClientesCompanion.insert(
            id: id,
            nombre: Value(nombre),
            creadoEn: DateTime(2026),
            actualizadoEn: DateTime(2026),
          ),
        );
  }

  Future<List<String>> nombresEn(AppDatabase db) async {
    final filas = await db.select(db.clientes).get();
    return filas.map((f) => f.nombre).toList()..sort();
  }

  group('leer la version sin abrir la base', () {
    test('lee el user_version de la cabecera', () async {
      final db = abrirBase();
      await db.customSelect('SELECT 1').getSingle();
      await db.close();

      expect(
        RespaldosRepository.versionDeEsquemaDe(respaldos.archivoDeLaBase),
        AppDatabase.versionDeEsquema,
      );
    });

    test('un archivo que no es SQLite no se confunde con una base', () async {
      final basura = File('${carpeta.path}/no-es-una-base.sqlite');
      await basura.writeAsString('esto lo dejo alguien desde la computadora');
      expect(RespaldosRepository.versionDeEsquemaDe(basura), isNull);
    });

    test('un archivo que no existe devuelve null y no revienta', () {
      expect(
        RespaldosRepository.versionDeEsquemaDe(File('${carpeta.path}/nada')),
        isNull,
      );
    });
  });

  group('la copia de antes de migrar', () {
    /// Deja en disco una base como la que traeria una tablet en la v4.
    ///
    /// Se construye con el esquema de hoy y se le quitan las dos columnas que
    /// agrego la v5, en vez de bajarle el `user_version` a secas: una base que
    /// dice v4 pero ya tiene las columnas de la v5 no existe en ninguna
    /// tablet, y probar contra ella no probaria nada.
    Future<void> dejarBaseVieja() async {
      // Se parte de cero cada vez: la prueba de rotacion la llama varias
      // veces seguidas sobre el mismo archivo.
      for (final sufijo in ['', '-wal', '-shm']) {
        final archivo = File('${respaldos.archivoDeLaBase.path}$sufijo');
        if (archivo.existsSync()) await archivo.delete();
      }

      final db = AppDatabase.paraPruebas(
        NativeDatabase(respaldos.archivoDeLaBase),
      );
      await darDeAlta(db, 'cli-1', 'Tony');
      await db.customStatement('ALTER TABLE clientes DROP COLUMN telefono');
      await db.customStatement('ALTER TABLE clientes DROP COLUMN direccion');
      await db.customStatement('PRAGMA user_version = 4');
      await db.close();
    }

    test('copia cuando la base viene de una version anterior', () async {
      await dejarBaseVieja();

      final copia = await respaldos.copiarSiVaAMigrar();

      expect(copia, isNotNull);
      expect(copia!.motivo, MotivoRespaldo.antesDeActualizar);
      expect(copia.versionEsquema, 4, reason: 'guarda de que version venia');
      expect(copia.archivo.existsSync(), isTrue);
      expect(copia.bytes, greaterThan(0));
    });

    test('la copia se puede abrir y trae los datos', () async {
      await dejarBaseVieja();
      final copia = await respaldos.copiarSiVaAMigrar();

      final db = AppDatabase.paraPruebas(NativeDatabase(copia!.archivo));
      addTearDown(db.close);
      expect(await nombresEn(db), ['Tony']);
    });

    test('no copia cuando la base ya esta en la version del codigo', () async {
      final db = abrirBase();
      await db.customSelect('SELECT 1').getSingle();
      await db.close();

      expect(await respaldos.copiarSiVaAMigrar(), isNull);
      expect(await respaldos.listar(), isEmpty);
    });

    test('no copia la primera vez, cuando todavia no hay base', () async {
      expect(await respaldos.copiarSiVaAMigrar(), isNull);
    });

    test('se lleva el -wal, que es donde puede estar lo ultimo capturado',
        () async {
      await dejarBaseVieja();
      await File('${respaldos.archivoDeLaBase.path}-wal')
          .writeAsString('transacciones sin volcar');

      final copia = await respaldos.copiarSiVaAMigrar();

      expect(
        File('${copia!.archivo.path}-wal').existsSync(),
        isTrue,
        reason: 'un -wal que se queda atras es una copia incompleta',
      );
    });

    test('conserva solo las tres copias automaticas mas recientes', () async {
      for (var i = 0; i < 5; i++) {
        ahora = DateTime(2026, 9, 8, 11, 30, i);
        await dejarBaseVieja();
        await respaldos.copiarSiVaAMigrar();
      }

      final lista = await respaldos.listar();
      expect(lista, hasLength(3));
      expect(
        lista.first.fecha.second,
        4,
        reason: 'se queda con las mas nuevas, no con las primeras',
      );
    });
  });

  group('respaldar a mano', () {
    test('escribe una copia consistente de la base abierta', () async {
      final db = abrirBase();
      addTearDown(db.close);
      await darDeAlta(db, 'cli-1', 'Tony');

      final copia = await respaldos.respaldarAhora(db);

      expect(copia.motivo, MotivoRespaldo.aMano);
      expect(copia.versionEsquema, AppDatabase.versionDeEsquema);

      final leida = AppDatabase.paraPruebas(NativeDatabase(copia.archivo));
      addTearDown(leida.close);
      expect(await nombresEn(leida), ['Tony']);
    });

    test('las copias a mano no se van al rotar', () async {
      final db = abrirBase();
      addTearDown(db.close);

      for (var i = 0; i < 5; i++) {
        ahora = DateTime(2026, 9, 8, 12, 0, i);
        await respaldos.respaldarAhora(db);
      }

      expect(
        await respaldos.listar(),
        hasLength(5),
        reason: 'las hizo ella a proposito: solo ella las borra',
      );
    });
  });

  group('restaurar', () {
    test('deja la base como estaba en el respaldo', () async {
      var db = abrirBase();
      await darDeAlta(db, 'cli-1', 'Tony');

      final copia = await respaldos.respaldarAhora(db);

      // Lo capturado despues del respaldo es justo lo que se va a perder.
      await darDeAlta(db, 'cli-2', 'Chuy');
      expect(await nombresEn(db), ['Chuy', 'Tony']);

      ahora = DateTime(2026, 9, 8, 13, 0);
      expect(await respaldos.restaurar(copia, db: db), isNull);

      db = abrirBase();
      addTearDown(db.close);
      expect(await nombresEn(db), ['Tony']);
    });

    test('guarda antes una copia de como estaba, por si se arrepiente',
        () async {
      final db = abrirBase();
      await darDeAlta(db, 'cli-1', 'Tony');
      final copia = await respaldos.respaldarAhora(db);
      await darDeAlta(db, 'cli-2', 'Chuy');

      ahora = DateTime(2026, 9, 8, 13, 0);
      await respaldos.restaurar(copia, db: db);

      final previo = (await respaldos.listar())
          .where((r) => r.motivo == MotivoRespaldo.antesDeRestaurar)
          .single;

      final leida = AppDatabase.paraPruebas(NativeDatabase(previo.archivo));
      addTearDown(leida.close);
      expect(
        await nombresEn(leida),
        ['Chuy', 'Tony'],
        reason: 'la vuelta atras de la vuelta atras',
      );
    });

    test('borra el -wal viejo antes de poner el archivo restaurado', () async {
      final db = abrirBase();
      await darDeAlta(db, 'cli-1', 'Tony');
      final copia = await respaldos.respaldarAhora(db);

      ahora = DateTime(2026, 9, 8, 13, 0);
      await respaldos.restaurar(copia, db: db);

      // El respaldo a mano sale de `VACUUM INTO` y no trae `-wal`, asi que
      // despues de restaurar no debe quedar ninguno: uno viejo se le aplicaria
      // encima a la base restaurada y mezclaria dos estados distintos.
      expect(
        File('${respaldos.archivoDeLaBase.path}-wal').existsSync(),
        isFalse,
      );
    });

    test('se niega a restaurar una copia de una version mas nueva', () async {
      final db = abrirBase();
      addTearDown(db.close);
      final copia = await respaldos.respaldarAhora(db);

      final falla = await respaldos.restaurar(
        copia,
        db: db,
        versionDelCodigo: AppDatabase.versionDeEsquema - 1,
      );

      expect(falla, contains('version mas nueva'));
    });

    test('avisa cuando el archivo ya no esta', () async {
      final db = abrirBase();
      addTearDown(db.close);
      final copia = await respaldos.respaldarAhora(db);
      await respaldos.eliminar(copia);

      expect(await respaldos.restaurar(copia, db: db), contains('ya no esta'));
    });
  });

  group('traer un respaldo de afuera', () {
    /// Un archivo como el que llega de vuelta desde WhatsApp: fuera de la
    /// carpeta de la aplicacion y con cualquier nombre.
    Future<File> archivoDeAfuera() async {
      final db = abrirBase();
      addTearDown(db.close);
      await darDeAlta(db, 'cli-1', 'Tony');

      final copia = await respaldos.respaldarAhora(db);
      final afuera = File('${carpeta.path}/Descargas/respaldo (1).sqlite');
      await afuera.parent.create(recursive: true);
      await copia.archivo.copy(afuera.path);
      await respaldos.eliminar(copia);
      return afuera;
    }

    test('lo copia a la lista y queda listo para restaurar', () async {
      final afuera = await archivoDeAfuera();

      ahora = DateTime(2026, 9, 9, 9);
      expect(await respaldos.importar(afuera), isNull);

      final traido = (await respaldos.listar()).single;
      expect(traido.motivo, MotivoRespaldo.aMano);

      final leida = AppDatabase.paraPruebas(NativeDatabase(traido.archivo));
      addTearDown(leida.close);
      expect(await nombresEn(leida), ['Tony']);
    });

    test('traer no restaura: la base no se toca', () async {
      final afuera = await archivoDeAfuera();
      final db = abrirBase();
      addTearDown(db.close);
      await darDeAlta(db, 'cli-2', 'Chuy');

      ahora = DateTime(2026, 9, 9, 9);
      await respaldos.importar(afuera);

      expect(
        await nombresEn(db),
        ['Chuy', 'Tony'],
        reason: 'importar es copiar un archivo, no reemplazar la base',
      );
    });

    test('rechaza lo que no es una base', () async {
      final foto = File('${carpeta.path}/foto.jpg');
      await foto.writeAsString('esto es una foto del recibo');

      expect(
        await respaldos.importar(foto),
        contains('no es un respaldo'),
      );
      expect(await respaldos.listar(), isEmpty);
    });

    test('rechaza un respaldo de una version mas nueva', () async {
      final afuera = await archivoDeAfuera();

      final falla = await respaldos.importar(
        afuera,
        versionDelCodigo: AppDatabase.versionDeEsquema - 1,
      );

      expect(falla, contains('version mas nueva'));
    });
  });

  group('la lista', () {
    test('ignora los archivos que no son respaldos nuestros', () async {
      await respaldos.carpeta.create(recursive: true);
      await File('${respaldos.carpeta.path}/foto.jpg').writeAsString('x');
      await File('${respaldos.carpeta.path}/respaldo-raro.sqlite')
          .writeAsString('x');

      expect(await respaldos.listar(), isEmpty);
    });

    test('van de la mas nueva a la mas vieja', () async {
      final db = abrirBase();
      addTearDown(db.close);

      ahora = DateTime(2026, 9, 1, 8);
      await respaldos.respaldarAhora(db);
      ahora = DateTime(2026, 9, 8, 8);
      await respaldos.respaldarAhora(db);

      final lista = await respaldos.listar();
      expect(lista.first.fecha.day, 8);
      expect(lista.last.fecha.day, 1);
    });
  });
}
