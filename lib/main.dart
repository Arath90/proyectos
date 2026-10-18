import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'features/respaldos/data/respaldos_repository.dart';

/// Punto de entrada.
///
/// Hace tres cosas, en este orden y no en otro:
///
///  1. Prepara los formatos de fecha en espanol.
///  2. **Respalda la base si esta version la va a migrar.** Va antes de
///     `runApp` porque tiene que ocurrir mientras nadie ha abierto todavia la
///     base: en cuanto Riverpod construye `AppDatabase`, Drift corre la
///     migracion, y una copia tomada despues ya seria copia de la base
///     migrada. Este es el unico momento del ciclo de vida en que se puede
///     copiar el archivo tal como estaba.
///  3. Envuelve la aplicacion en el `ProviderScope`, que es donde viven la
///     base de datos y los repositorios declarados en `app/providers.dart`.
///
/// El respaldo no bloquea el arranque si falla: la propietaria tiene que poder
/// abrir su aplicacion y vender aunque la tarjeta este llena. Lo que no puede
/// pasar es que una actualizacion toque la base sin haberlo intentado.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await prepararFormatos();
  await _respaldarAntesDeMigrar();
  runApp(const ProviderScope(child: App()));
}

Future<void> _respaldarAntesDeMigrar() async {
  try {
    final carpeta = await getApplicationDocumentsDirectory();
    await RespaldosRepository(carpeta).copiarSiVaAMigrar();
  } catch (_) {
    // Sin respaldo se sigue: negarse a abrir dejaria a la propietaria sin
    // sistema por un problema que ella no puede resolver desde aqui.
  }
}
