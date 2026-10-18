import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../infrastructure/database/app_database.dart';
import '../domain/adeudo.dart';

/// Traduce entre las filas de `Adeudos` y el modelo de dominio.
///
/// No toca el inventario, y esa es toda su razon de ser: los adeudos existen
/// justamente para poder registrar dinero que se debe sin fingir que hoy
/// salieron piezas de la casa. Tampoco toca los abonos, que siguen viviendo
/// en `VentasRepository` porque son una sola tabla y un pago es un pago venga
/// de donde venga.
///
/// Es decir: escribe una sola tabla. Lo unico que cruza dos features es
/// [crearAdeudo] cuando recibe un `ventaOrigenId`, y ni asi escribe en
/// `ventas`: el saldo traspasado no es una columna de la venta sino la suma de
/// los cargos que nacieron de ella, por la misma razon por la que ningun total
/// del sistema se guarda.
class AdeudosRepository {
  AdeudosRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  // --- Lectura -------------------------------------------------------------

  /// Los cargos vigentes, del mas reciente al mas viejo.
  ///
  /// Sale una lista plana y no un mapa por cliente porque quien la consume
  /// necesita agruparla de dos maneras distintas -por cliente para la cuenta,
  /// por venta de origen para saber cuanto se traspaso- y agrupar dos veces en
  /// Dart una lista de unos cuantos cargos es mas barato que sostener dos
  /// consultas.
  Stream<List<Adeudo>> observarAdeudos() {
    final consulta = _db.select(_db.adeudos)
      ..where((t) => t.eliminadoEn.isNull())
      ..orderBy([
        (t) => OrderingTerm(expression: t.fecha, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.creadoEn, mode: OrderingMode.desc),
      ]);
    return consulta.watch().map((filas) => filas.map(_aAdeudo).toList());
  }

  Future<Adeudo?> obtenerAdeudo(String adeudoId) async {
    final consulta = _db.select(_db.adeudos)
      ..where((t) => t.id.equals(adeudoId));
    final fila = await consulta.getSingleOrNull();
    return fila == null ? null : _aAdeudo(fila);
  }

  // --- Escritura -----------------------------------------------------------

  /// Da de alta un cargo.
  ///
  /// Con [ventaOrigenId] es el traspaso del saldo de una venta entregada; sin
  /// el, es la deuda vieja que la propietaria captura a mano.
  Future<Adeudo> crearAdeudo({
    required String clienteId,
    required int monto,
    String concepto = '',
    DateTime? fecha,
    String? ventaOrigenId,
  }) async {
    final ahora = DateTime.now();
    final adeudo = Adeudo(
      id: _uuid.v4(),
      clienteId: clienteId,
      fecha: fecha ?? ahora,
      monto: monto,
      concepto: concepto.trim(),
      ventaOrigenId: ventaOrigenId,
    );
    await _db.into(_db.adeudos).insert(
          AdeudosCompanion.insert(
            id: adeudo.id,
            clienteId: adeudo.clienteId,
            fecha: adeudo.fecha,
            concepto: Value(adeudo.concepto),
            monto: Value(adeudo.monto),
            ventaOrigenId: Value(adeudo.ventaOrigenId),
            creadoEn: ahora,
            actualizadoEn: ahora,
          ),
        );
    return adeudo;
  }

  /// Guarda la correccion de un cargo.
  ///
  /// A proposito no deja cambiar de cliente ni de venta de origen: mover una
  /// deuda de una persona a otra no es corregir un dato, es dos operaciones
  /// -bajarsela a uno y cargarsela al otro- y verlas como dos es lo que deja
  /// rastro de que paso.
  Future<void> guardarAdeudo(Adeudo adeudo) {
    return (_db.update(_db.adeudos)..where((t) => t.id.equals(adeudo.id)))
        .write(
      AdeudosCompanion(
        fecha: Value(adeudo.fecha),
        monto: Value(adeudo.monto),
        concepto: Value(adeudo.concepto.trim()),
        actualizadoEn: Value(DateTime.now()),
      ),
    );
  }

  /// Borrado logico del cargo. Es tambien lo que deshace un traspaso: al
  /// desaparecer el cargo, el saldo vuelve a aparecer en su venta.
  Future<void> eliminarAdeudo(String adeudoId) {
    final ahora = DateTime.now();
    return (_db.update(_db.adeudos)..where((t) => t.id.equals(adeudoId))).write(
      AdeudosCompanion(
        eliminadoEn: Value(ahora),
        actualizadoEn: Value(ahora),
      ),
    );
  }

  // --- Mapeo ---------------------------------------------------------------

  Adeudo _aAdeudo(AdeudoRow fila) => Adeudo(
        id: fila.id,
        clienteId: fila.clienteId,
        fecha: fila.fecha,
        concepto: fila.concepto,
        monto: fila.monto,
        ventaOrigenId: fila.ventaOrigenId,
      );
}
