import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/respaldo.dart';

/// Lo que ve la pantalla de respaldos.
class RespaldosEstado {
  const RespaldosEstado({
    this.lista = const AsyncValue.loading(),
    this.trabajando = false,
  });

  /// Las copias que hay en la tablet, de la mas nueva a la mas vieja.
  final AsyncValue<List<Respaldo>> lista;

  /// Cierto mientras se esta copiando o restaurando.
  ///
  /// Apaga los botones. Copiar la base tarda lo que tarde el archivo, y en una
  /// tablet lenta eso alcanza para que alguien toque tres veces; tres
  /// restauraciones encimadas si podrian dejar la base a medias.
  final bool trabajando;

  RespaldosEstado copyWith({
    AsyncValue<List<Respaldo>>? lista,
    bool? trabajando,
  }) {
    return RespaldosEstado(
      lista: lista ?? this.lista,
      trabajando: trabajando ?? this.trabajando,
    );
  }
}

/// ViewModel de los respaldos.
///
/// Es el unico ViewModel que no habla de negocio: no sabe de ventas ni de
/// deudas, solo de archivos. Aun asi vive aqui y no en la capa de datos porque
/// las tres acciones que ofrece -copiar, enviar, restaurar- necesitan decidir
/// cosas de pantalla: cual apaga los botones, cual pide confirmacion y que
/// mensaje se le devuelve a la propietaria cuando algo no se pudo.
class RespaldosViewModel extends Notifier<RespaldosEstado> {
  @override
  RespaldosEstado build() {
    // La primera lectura se dispara sola y aterriza despues de este `build`,
    // que es cuando Riverpod ya deja escribir `state`.
    _cargar();
    return const RespaldosEstado();
  }

  Future<void> _cargar() async {
    try {
      final repo = await ref.read(respaldosRepositoryProvider.future);
      final copias = await repo.listar();
      state = state.copyWith(lista: AsyncValue.data(copias));
    } catch (e, s) {
      state = state.copyWith(lista: AsyncValue.error(e, s));
    }
  }

  /// Hace una copia y abre el menu de compartir con ella.
  ///
  /// Las dos cosas van juntas y no en dos botones porque son un solo gesto:
  /// una copia que se queda en la tablet no protege de que la tablet se
  /// pierda, que es la forma mas probable de perderlo todo. Si el envio se
  /// cancela, la copia local ya quedo hecha de todos modos.
  Future<String?> respaldarYEnviar() async {
    if (state.trabajando) return null;
    state = state.copyWith(trabajando: true);
    try {
      final repo = await ref.read(respaldosRepositoryProvider.future);
      final respaldo = await repo.respaldarAhora(ref.read(baseDeDatosProvider));
      await _cargar();
      await ref.read(compartidorRespaldoProvider).compartir(respaldo);
      return null;
    } catch (e) {
      return 'No se pudo respaldar: $e';
    } finally {
      state = state.copyWith(trabajando: false);
    }
  }

  /// Manda una copia que ya existe al menu de compartir.
  Future<String?> enviar(Respaldo respaldo) async {
    try {
      await ref.read(compartidorRespaldoProvider).compartir(respaldo);
      return null;
    } catch (e) {
      return 'No se pudo enviar el respaldo: $e';
    }
  }

  /// Trae un respaldo de afuera: de WhatsApp, de Drive, de una USB.
  ///
  /// Solo lo copia a la lista. Restaurarlo es el paso siguiente y se pide
  /// aparte, con su confirmacion: traer un archivo no puede ser lo mismo que
  /// borrar lo que hay.
  Future<String?> traerDeAfuera() async {
    if (state.trabajando) return null;
    try {
      final archivo = await ref.read(selectorDeArchivoProvider).elegirRespaldo();
      if (archivo == null) return null;

      state = state.copyWith(trabajando: true);
      final repo = await ref.read(respaldosRepositoryProvider.future);
      final falla = await repo.importar(archivo);
      if (falla != null) return falla;

      await _cargar();
      return null;
    } catch (e) {
      return 'No se pudo abrir el archivo: $e';
    } finally {
      state = state.copyWith(trabajando: false);
    }
  }

  /// Vuelve al estado que guarda [respaldo].
  ///
  /// Despues de reemplazar el archivo invalida la base: la que estaba abierta
  /// quedo cerrada, y todas las pantallas cuelgan de ella. Al invalidarla,
  /// Riverpod construye una `AppDatabase` nueva sobre el archivo restaurado y
  /// cada listado se vuelve a suscribir solo -incluida la migracion, si el
  /// respaldo venia de una version anterior-.
  Future<String?> restaurar(Respaldo respaldo) async {
    if (state.trabajando) return null;
    state = state.copyWith(trabajando: true);
    try {
      final repo = await ref.read(respaldosRepositoryProvider.future);
      final falla = await repo.restaurar(
        respaldo,
        db: ref.read(baseDeDatosProvider),
      );
      if (falla != null) return falla;

      ref.invalidate(baseDeDatosProvider);
      await _cargar();
      return null;
    } catch (e) {
      return 'No se pudo restaurar: $e';
    } finally {
      state = state.copyWith(trabajando: false);
    }
  }

  Future<String?> eliminar(Respaldo respaldo) async {
    try {
      final repo = await ref.read(respaldosRepositoryProvider.future);
      await repo.eliminar(respaldo);
      await _cargar();
      return null;
    } catch (e) {
      return 'No se pudo borrar: $e';
    }
  }

  Future<void> refrescar() => _cargar();
}

final respaldosViewModelProvider =
    NotifierProvider<RespaldosViewModel, RespaldosEstado>(
  RespaldosViewModel.new,
);
