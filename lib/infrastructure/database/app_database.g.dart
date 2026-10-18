// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PedidosTable extends Pedidos with TableInfo<$PedidosTable, PedidoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PedidosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campanaMeta = const VerificationMeta(
    'campana',
  );
  @override
  late final GeneratedColumn<String> campana = GeneratedColumn<String>(
    'campana',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _marcaPredeterminadaMeta =
      const VerificationMeta('marcaPredeterminada');
  @override
  late final GeneratedColumn<String> marcaPredeterminada =
      GeneratedColumn<String>(
        'marca_predeterminada',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cerradoMeta = const VerificationMeta(
    'cerrado',
  );
  @override
  late final GeneratedColumn<bool> cerrado = GeneratedColumn<bool>(
    'cerrado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cerrado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recibidoEnMeta = const VerificationMeta(
    'recibidoEn',
  );
  @override
  late final GeneratedColumn<DateTime> recibidoEn = GeneratedColumn<DateTime>(
    'recibido_en',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _eliminadoEnMeta = const VerificationMeta(
    'eliminadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> eliminadoEn = GeneratedColumn<DateTime>(
    'eliminado_en',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fecha,
    campana,
    marcaPredeterminada,
    notas,
    cerrado,
    recibidoEn,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pedidos';
  @override
  VerificationContext validateIntegrity(
    Insertable<PedidoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('campana')) {
      context.handle(
        _campanaMeta,
        campana.isAcceptableOrUnknown(data['campana']!, _campanaMeta),
      );
    }
    if (data.containsKey('marca_predeterminada')) {
      context.handle(
        _marcaPredeterminadaMeta,
        marcaPredeterminada.isAcceptableOrUnknown(
          data['marca_predeterminada']!,
          _marcaPredeterminadaMeta,
        ),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('cerrado')) {
      context.handle(
        _cerradoMeta,
        cerrado.isAcceptableOrUnknown(data['cerrado']!, _cerradoMeta),
      );
    }
    if (data.containsKey('recibido_en')) {
      context.handle(
        _recibidoEnMeta,
        recibidoEn.isAcceptableOrUnknown(data['recibido_en']!, _recibidoEnMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    if (data.containsKey('eliminado_en')) {
      context.handle(
        _eliminadoEnMeta,
        eliminadoEn.isAcceptableOrUnknown(
          data['eliminado_en']!,
          _eliminadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PedidoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PedidoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      campana: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campana'],
      )!,
      marcaPredeterminada: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marca_predeterminada'],
      )!,
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      )!,
      cerrado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cerrado'],
      )!,
      recibidoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recibido_en'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
      eliminadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}eliminado_en'],
      ),
    );
  }

  @override
  $PedidosTable createAlias(String alias) {
    return $PedidosTable(attachedDatabase, alias);
  }
}

class PedidoRow extends DataClass implements Insertable<PedidoRow> {
  final String id;
  final DateTime fecha;
  final String campana;
  final String marcaPredeterminada;
  final String notas;
  final bool cerrado;

  /// Momento en que las piezas de este pedido entraron al inventario.
  ///
  /// Es la bisagra entre este flujo y `Productos`: mientras sea `null` el
  /// pedido es papel, y al surtirlo la `cantEnviada` de cada linea suma
  /// existencias. Guardar la fecha (y no un booleano) evita surtir dos veces
  /// y deja constancia de cuando llego la caja.
  final DateTime? recibidoEn;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  /// Borrado logico. Nunca se hace DELETE fisico de un pedido: un registro que
  /// desaparece no se puede propagar a las demas tablets.
  final DateTime? eliminadoEn;
  const PedidoRow({
    required this.id,
    required this.fecha,
    required this.campana,
    required this.marcaPredeterminada,
    required this.notas,
    required this.cerrado,
    this.recibidoEn,
    required this.creadoEn,
    required this.actualizadoEn,
    this.eliminadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fecha'] = Variable<DateTime>(fecha);
    map['campana'] = Variable<String>(campana);
    map['marca_predeterminada'] = Variable<String>(marcaPredeterminada);
    map['notas'] = Variable<String>(notas);
    map['cerrado'] = Variable<bool>(cerrado);
    if (!nullToAbsent || recibidoEn != null) {
      map['recibido_en'] = Variable<DateTime>(recibidoEn);
    }
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    if (!nullToAbsent || eliminadoEn != null) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn);
    }
    return map;
  }

  PedidosCompanion toCompanion(bool nullToAbsent) {
    return PedidosCompanion(
      id: Value(id),
      fecha: Value(fecha),
      campana: Value(campana),
      marcaPredeterminada: Value(marcaPredeterminada),
      notas: Value(notas),
      cerrado: Value(cerrado),
      recibidoEn: recibidoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(recibidoEn),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
      eliminadoEn: eliminadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(eliminadoEn),
    );
  }

  factory PedidoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PedidoRow(
      id: serializer.fromJson<String>(json['id']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      campana: serializer.fromJson<String>(json['campana']),
      marcaPredeterminada: serializer.fromJson<String>(
        json['marcaPredeterminada'],
      ),
      notas: serializer.fromJson<String>(json['notas']),
      cerrado: serializer.fromJson<bool>(json['cerrado']),
      recibidoEn: serializer.fromJson<DateTime?>(json['recibidoEn']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
      eliminadoEn: serializer.fromJson<DateTime?>(json['eliminadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fecha': serializer.toJson<DateTime>(fecha),
      'campana': serializer.toJson<String>(campana),
      'marcaPredeterminada': serializer.toJson<String>(marcaPredeterminada),
      'notas': serializer.toJson<String>(notas),
      'cerrado': serializer.toJson<bool>(cerrado),
      'recibidoEn': serializer.toJson<DateTime?>(recibidoEn),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
      'eliminadoEn': serializer.toJson<DateTime?>(eliminadoEn),
    };
  }

  PedidoRow copyWith({
    String? id,
    DateTime? fecha,
    String? campana,
    String? marcaPredeterminada,
    String? notas,
    bool? cerrado,
    Value<DateTime?> recibidoEn = const Value.absent(),
    DateTime? creadoEn,
    DateTime? actualizadoEn,
    Value<DateTime?> eliminadoEn = const Value.absent(),
  }) => PedidoRow(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    campana: campana ?? this.campana,
    marcaPredeterminada: marcaPredeterminada ?? this.marcaPredeterminada,
    notas: notas ?? this.notas,
    cerrado: cerrado ?? this.cerrado,
    recibidoEn: recibidoEn.present ? recibidoEn.value : this.recibidoEn,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    eliminadoEn: eliminadoEn.present ? eliminadoEn.value : this.eliminadoEn,
  );
  PedidoRow copyWithCompanion(PedidosCompanion data) {
    return PedidoRow(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      campana: data.campana.present ? data.campana.value : this.campana,
      marcaPredeterminada: data.marcaPredeterminada.present
          ? data.marcaPredeterminada.value
          : this.marcaPredeterminada,
      notas: data.notas.present ? data.notas.value : this.notas,
      cerrado: data.cerrado.present ? data.cerrado.value : this.cerrado,
      recibidoEn: data.recibidoEn.present
          ? data.recibidoEn.value
          : this.recibidoEn,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
      eliminadoEn: data.eliminadoEn.present
          ? data.eliminadoEn.value
          : this.eliminadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PedidoRow(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('campana: $campana, ')
          ..write('marcaPredeterminada: $marcaPredeterminada, ')
          ..write('notas: $notas, ')
          ..write('cerrado: $cerrado, ')
          ..write('recibidoEn: $recibidoEn, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fecha,
    campana,
    marcaPredeterminada,
    notas,
    cerrado,
    recibidoEn,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PedidoRow &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.campana == this.campana &&
          other.marcaPredeterminada == this.marcaPredeterminada &&
          other.notas == this.notas &&
          other.cerrado == this.cerrado &&
          other.recibidoEn == this.recibidoEn &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn &&
          other.eliminadoEn == this.eliminadoEn);
}

class PedidosCompanion extends UpdateCompanion<PedidoRow> {
  final Value<String> id;
  final Value<DateTime> fecha;
  final Value<String> campana;
  final Value<String> marcaPredeterminada;
  final Value<String> notas;
  final Value<bool> cerrado;
  final Value<DateTime?> recibidoEn;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  final Value<DateTime?> eliminadoEn;
  final Value<int> rowid;
  const PedidosCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.campana = const Value.absent(),
    this.marcaPredeterminada = const Value.absent(),
    this.notas = const Value.absent(),
    this.cerrado = const Value.absent(),
    this.recibidoEn = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PedidosCompanion.insert({
    required String id,
    required DateTime fecha,
    this.campana = const Value.absent(),
    this.marcaPredeterminada = const Value.absent(),
    this.notas = const Value.absent(),
    this.cerrado = const Value.absent(),
    this.recibidoEn = const Value.absent(),
    required DateTime creadoEn,
    required DateTime actualizadoEn,
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fecha = Value(fecha),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<PedidoRow> custom({
    Expression<String>? id,
    Expression<DateTime>? fecha,
    Expression<String>? campana,
    Expression<String>? marcaPredeterminada,
    Expression<String>? notas,
    Expression<bool>? cerrado,
    Expression<DateTime>? recibidoEn,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
    Expression<DateTime>? eliminadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (campana != null) 'campana': campana,
      if (marcaPredeterminada != null)
        'marca_predeterminada': marcaPredeterminada,
      if (notas != null) 'notas': notas,
      if (cerrado != null) 'cerrado': cerrado,
      if (recibidoEn != null) 'recibido_en': recibidoEn,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (eliminadoEn != null) 'eliminado_en': eliminadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PedidosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? fecha,
    Value<String>? campana,
    Value<String>? marcaPredeterminada,
    Value<String>? notas,
    Value<bool>? cerrado,
    Value<DateTime?>? recibidoEn,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
    Value<DateTime?>? eliminadoEn,
    Value<int>? rowid,
  }) {
    return PedidosCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      campana: campana ?? this.campana,
      marcaPredeterminada: marcaPredeterminada ?? this.marcaPredeterminada,
      notas: notas ?? this.notas,
      cerrado: cerrado ?? this.cerrado,
      recibidoEn: recibidoEn ?? this.recibidoEn,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      eliminadoEn: eliminadoEn ?? this.eliminadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (campana.present) {
      map['campana'] = Variable<String>(campana.value);
    }
    if (marcaPredeterminada.present) {
      map['marca_predeterminada'] = Variable<String>(marcaPredeterminada.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (cerrado.present) {
      map['cerrado'] = Variable<bool>(cerrado.value);
    }
    if (recibidoEn.present) {
      map['recibido_en'] = Variable<DateTime>(recibidoEn.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (eliminadoEn.present) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PedidosCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('campana: $campana, ')
          ..write('marcaPredeterminada: $marcaPredeterminada, ')
          ..write('notas: $notas, ')
          ..write('cerrado: $cerrado, ')
          ..write('recibidoEn: $recibidoEn, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductosTable extends Productos
    with TableInfo<$ProductosTable, ProductoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marcaMeta = const VerificationMeta('marca');
  @override
  late final GeneratedColumn<String> marca = GeneratedColumn<String>(
    'marca',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cantidadActualMeta = const VerificationMeta(
    'cantidadActual',
  );
  @override
  late final GeneratedColumn<int> cantidadActual = GeneratedColumn<int>(
    'cantidad_actual',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cantidadOriginalMeta = const VerificationMeta(
    'cantidadOriginal',
  );
  @override
  late final GeneratedColumn<int> cantidadOriginal = GeneratedColumn<int>(
    'cantidad_original',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _eliminadoEnMeta = const VerificationMeta(
    'eliminadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> eliminadoEn = GeneratedColumn<DateTime>(
    'eliminado_en',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    marca,
    codigo,
    descripcion,
    cantidadActual,
    cantidadOriginal,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('marca')) {
      context.handle(
        _marcaMeta,
        marca.isAcceptableOrUnknown(data['marca']!, _marcaMeta),
      );
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('cantidad_actual')) {
      context.handle(
        _cantidadActualMeta,
        cantidadActual.isAcceptableOrUnknown(
          data['cantidad_actual']!,
          _cantidadActualMeta,
        ),
      );
    }
    if (data.containsKey('cantidad_original')) {
      context.handle(
        _cantidadOriginalMeta,
        cantidadOriginal.isAcceptableOrUnknown(
          data['cantidad_original']!,
          _cantidadOriginalMeta,
        ),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    if (data.containsKey('eliminado_en')) {
      context.handle(
        _eliminadoEnMeta,
        eliminadoEn.isAcceptableOrUnknown(
          data['eliminado_en']!,
          _eliminadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      marca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marca'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      )!,
      cantidadActual: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad_actual'],
      )!,
      cantidadOriginal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad_original'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
      eliminadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}eliminado_en'],
      ),
    );
  }

  @override
  $ProductosTable createAlias(String alias) {
    return $ProductosTable(attachedDatabase, alias);
  }
}

class ProductoRow extends DataClass implements Insertable<ProductoRow> {
  final String id;
  final String marca;

  /// Codigo de catalogo como texto, por la misma razon que en [LineasPedido]:
  /// hay codigos con ceros a la izquierda.
  final String codigo;
  final String descripcion;

  /// Piezas fisicamente en casa ahora mismo.
  ///
  /// Sube al recibir un pedido, baja al entregar una venta y tambien se puede
  /// corregir a mano: es un conteo real, no una cifra derivada.
  final int cantidadActual;

  /// Piezas que han entrado en total desde que se dio de alta el producto.
  ///
  /// Sirve de referencia para saber cuanto se ha desplazado; nunca baja por
  /// una venta.
  final int cantidadOriginal;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  /// Borrado logico, igual que en el resto del esquema: un producto dado de
  /// baja debe seguir existiendo porque hay lineas de venta que lo apuntan.
  final DateTime? eliminadoEn;
  const ProductoRow({
    required this.id,
    required this.marca,
    required this.codigo,
    required this.descripcion,
    required this.cantidadActual,
    required this.cantidadOriginal,
    required this.creadoEn,
    required this.actualizadoEn,
    this.eliminadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['marca'] = Variable<String>(marca);
    map['codigo'] = Variable<String>(codigo);
    map['descripcion'] = Variable<String>(descripcion);
    map['cantidad_actual'] = Variable<int>(cantidadActual);
    map['cantidad_original'] = Variable<int>(cantidadOriginal);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    if (!nullToAbsent || eliminadoEn != null) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn);
    }
    return map;
  }

  ProductosCompanion toCompanion(bool nullToAbsent) {
    return ProductosCompanion(
      id: Value(id),
      marca: Value(marca),
      codigo: Value(codigo),
      descripcion: Value(descripcion),
      cantidadActual: Value(cantidadActual),
      cantidadOriginal: Value(cantidadOriginal),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
      eliminadoEn: eliminadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(eliminadoEn),
    );
  }

  factory ProductoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductoRow(
      id: serializer.fromJson<String>(json['id']),
      marca: serializer.fromJson<String>(json['marca']),
      codigo: serializer.fromJson<String>(json['codigo']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      cantidadActual: serializer.fromJson<int>(json['cantidadActual']),
      cantidadOriginal: serializer.fromJson<int>(json['cantidadOriginal']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
      eliminadoEn: serializer.fromJson<DateTime?>(json['eliminadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'marca': serializer.toJson<String>(marca),
      'codigo': serializer.toJson<String>(codigo),
      'descripcion': serializer.toJson<String>(descripcion),
      'cantidadActual': serializer.toJson<int>(cantidadActual),
      'cantidadOriginal': serializer.toJson<int>(cantidadOriginal),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
      'eliminadoEn': serializer.toJson<DateTime?>(eliminadoEn),
    };
  }

  ProductoRow copyWith({
    String? id,
    String? marca,
    String? codigo,
    String? descripcion,
    int? cantidadActual,
    int? cantidadOriginal,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
    Value<DateTime?> eliminadoEn = const Value.absent(),
  }) => ProductoRow(
    id: id ?? this.id,
    marca: marca ?? this.marca,
    codigo: codigo ?? this.codigo,
    descripcion: descripcion ?? this.descripcion,
    cantidadActual: cantidadActual ?? this.cantidadActual,
    cantidadOriginal: cantidadOriginal ?? this.cantidadOriginal,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    eliminadoEn: eliminadoEn.present ? eliminadoEn.value : this.eliminadoEn,
  );
  ProductoRow copyWithCompanion(ProductosCompanion data) {
    return ProductoRow(
      id: data.id.present ? data.id.value : this.id,
      marca: data.marca.present ? data.marca.value : this.marca,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      cantidadActual: data.cantidadActual.present
          ? data.cantidadActual.value
          : this.cantidadActual,
      cantidadOriginal: data.cantidadOriginal.present
          ? data.cantidadOriginal.value
          : this.cantidadOriginal,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
      eliminadoEn: data.eliminadoEn.present
          ? data.eliminadoEn.value
          : this.eliminadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductoRow(')
          ..write('id: $id, ')
          ..write('marca: $marca, ')
          ..write('codigo: $codigo, ')
          ..write('descripcion: $descripcion, ')
          ..write('cantidadActual: $cantidadActual, ')
          ..write('cantidadOriginal: $cantidadOriginal, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    marca,
    codigo,
    descripcion,
    cantidadActual,
    cantidadOriginal,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductoRow &&
          other.id == this.id &&
          other.marca == this.marca &&
          other.codigo == this.codigo &&
          other.descripcion == this.descripcion &&
          other.cantidadActual == this.cantidadActual &&
          other.cantidadOriginal == this.cantidadOriginal &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn &&
          other.eliminadoEn == this.eliminadoEn);
}

class ProductosCompanion extends UpdateCompanion<ProductoRow> {
  final Value<String> id;
  final Value<String> marca;
  final Value<String> codigo;
  final Value<String> descripcion;
  final Value<int> cantidadActual;
  final Value<int> cantidadOriginal;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  final Value<DateTime?> eliminadoEn;
  final Value<int> rowid;
  const ProductosCompanion({
    this.id = const Value.absent(),
    this.marca = const Value.absent(),
    this.codigo = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.cantidadActual = const Value.absent(),
    this.cantidadOriginal = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductosCompanion.insert({
    required String id,
    this.marca = const Value.absent(),
    this.codigo = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.cantidadActual = const Value.absent(),
    this.cantidadOriginal = const Value.absent(),
    required DateTime creadoEn,
    required DateTime actualizadoEn,
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<ProductoRow> custom({
    Expression<String>? id,
    Expression<String>? marca,
    Expression<String>? codigo,
    Expression<String>? descripcion,
    Expression<int>? cantidadActual,
    Expression<int>? cantidadOriginal,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
    Expression<DateTime>? eliminadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (marca != null) 'marca': marca,
      if (codigo != null) 'codigo': codigo,
      if (descripcion != null) 'descripcion': descripcion,
      if (cantidadActual != null) 'cantidad_actual': cantidadActual,
      if (cantidadOriginal != null) 'cantidad_original': cantidadOriginal,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (eliminadoEn != null) 'eliminado_en': eliminadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductosCompanion copyWith({
    Value<String>? id,
    Value<String>? marca,
    Value<String>? codigo,
    Value<String>? descripcion,
    Value<int>? cantidadActual,
    Value<int>? cantidadOriginal,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
    Value<DateTime?>? eliminadoEn,
    Value<int>? rowid,
  }) {
    return ProductosCompanion(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      cantidadActual: cantidadActual ?? this.cantidadActual,
      cantidadOriginal: cantidadOriginal ?? this.cantidadOriginal,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      eliminadoEn: eliminadoEn ?? this.eliminadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (marca.present) {
      map['marca'] = Variable<String>(marca.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (cantidadActual.present) {
      map['cantidad_actual'] = Variable<int>(cantidadActual.value);
    }
    if (cantidadOriginal.present) {
      map['cantidad_original'] = Variable<int>(cantidadOriginal.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (eliminadoEn.present) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosCompanion(')
          ..write('id: $id, ')
          ..write('marca: $marca, ')
          ..write('codigo: $codigo, ')
          ..write('descripcion: $descripcion, ')
          ..write('cantidadActual: $cantidadActual, ')
          ..write('cantidadOriginal: $cantidadOriginal, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LineasPedidoTable extends LineasPedido
    with TableInfo<$LineasPedidoTable, LineaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineasPedidoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pedidoIdMeta = const VerificationMeta(
    'pedidoId',
  );
  @override
  late final GeneratedColumn<String> pedidoId = GeneratedColumn<String>(
    'pedido_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedidos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
    'producto_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES productos (id)',
    ),
  );
  static const VerificationMeta _marcaMeta = const VerificationMeta('marca');
  @override
  late final GeneratedColumn<String> marca = GeneratedColumn<String>(
    'marca',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cantPedidaMeta = const VerificationMeta(
    'cantPedida',
  );
  @override
  late final GeneratedColumn<int> cantPedida = GeneratedColumn<int>(
    'cant_pedida',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cantEnviadaMeta = const VerificationMeta(
    'cantEnviada',
  );
  @override
  late final GeneratedColumn<int> cantEnviada = GeneratedColumn<int>(
    'cant_enviada',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _valorTotalPuntosMeta = const VerificationMeta(
    'valorTotalPuntos',
  );
  @override
  late final GeneratedColumn<int> valorTotalPuntos = GeneratedColumn<int>(
    'valor_total_puntos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _precioUnitarioMeta = const VerificationMeta(
    'precioUnitario',
  );
  @override
  late final GeneratedColumn<int> precioUnitario = GeneratedColumn<int>(
    'precio_unitario',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _precioRevistaMeta = const VerificationMeta(
    'precioRevista',
  );
  @override
  late final GeneratedColumn<int> precioRevista = GeneratedColumn<int>(
    'precio_revista',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _valorTotalPromocionadoMeta =
      const VerificationMeta('valorTotalPromocionado');
  @override
  late final GeneratedColumn<int> valorTotalPromocionado = GeneratedColumn<int>(
    'valor_total_promocionado',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalDescuentoCnMeta = const VerificationMeta(
    'totalDescuentoCn',
  );
  @override
  late final GeneratedColumn<int> totalDescuentoCn = GeneratedColumn<int>(
    'total_descuento_cn',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _valorRegalosMeta = const VerificationMeta(
    'valorRegalos',
  );
  @override
  late final GeneratedColumn<int> valorRegalos = GeneratedColumn<int>(
    'valor_regalos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _valorPromSinIvaManualMeta =
      const VerificationMeta('valorPromSinIvaManual');
  @override
  late final GeneratedColumn<int> valorPromSinIvaManual = GeneratedColumn<int>(
    'valor_prom_sin_iva_manual',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tuPagasManualMeta = const VerificationMeta(
    'tuPagasManual',
  );
  @override
  late final GeneratedColumn<int> tuPagasManual = GeneratedColumn<int>(
    'tu_pagas_manual',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _precioTotalManualMeta = const VerificationMeta(
    'precioTotalManual',
  );
  @override
  late final GeneratedColumn<int> precioTotalManual = GeneratedColumn<int>(
    'precio_total_manual',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _eliminadoEnMeta = const VerificationMeta(
    'eliminadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> eliminadoEn = GeneratedColumn<DateTime>(
    'eliminado_en',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pedidoId,
    productoId,
    marca,
    codigo,
    descripcion,
    cantPedida,
    cantEnviada,
    valorTotalPuntos,
    precioUnitario,
    precioRevista,
    valorTotalPromocionado,
    totalDescuentoCn,
    valorRegalos,
    valorPromSinIvaManual,
    tuPagasManual,
    precioTotalManual,
    orden,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lineas_pedido';
  @override
  VerificationContext validateIntegrity(
    Insertable<LineaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pedido_id')) {
      context.handle(
        _pedidoIdMeta,
        pedidoId.isAcceptableOrUnknown(data['pedido_id']!, _pedidoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pedidoIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    }
    if (data.containsKey('marca')) {
      context.handle(
        _marcaMeta,
        marca.isAcceptableOrUnknown(data['marca']!, _marcaMeta),
      );
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('cant_pedida')) {
      context.handle(
        _cantPedidaMeta,
        cantPedida.isAcceptableOrUnknown(data['cant_pedida']!, _cantPedidaMeta),
      );
    }
    if (data.containsKey('cant_enviada')) {
      context.handle(
        _cantEnviadaMeta,
        cantEnviada.isAcceptableOrUnknown(
          data['cant_enviada']!,
          _cantEnviadaMeta,
        ),
      );
    }
    if (data.containsKey('valor_total_puntos')) {
      context.handle(
        _valorTotalPuntosMeta,
        valorTotalPuntos.isAcceptableOrUnknown(
          data['valor_total_puntos']!,
          _valorTotalPuntosMeta,
        ),
      );
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
        _precioUnitarioMeta,
        precioUnitario.isAcceptableOrUnknown(
          data['precio_unitario']!,
          _precioUnitarioMeta,
        ),
      );
    }
    if (data.containsKey('precio_revista')) {
      context.handle(
        _precioRevistaMeta,
        precioRevista.isAcceptableOrUnknown(
          data['precio_revista']!,
          _precioRevistaMeta,
        ),
      );
    }
    if (data.containsKey('valor_total_promocionado')) {
      context.handle(
        _valorTotalPromocionadoMeta,
        valorTotalPromocionado.isAcceptableOrUnknown(
          data['valor_total_promocionado']!,
          _valorTotalPromocionadoMeta,
        ),
      );
    }
    if (data.containsKey('total_descuento_cn')) {
      context.handle(
        _totalDescuentoCnMeta,
        totalDescuentoCn.isAcceptableOrUnknown(
          data['total_descuento_cn']!,
          _totalDescuentoCnMeta,
        ),
      );
    }
    if (data.containsKey('valor_regalos')) {
      context.handle(
        _valorRegalosMeta,
        valorRegalos.isAcceptableOrUnknown(
          data['valor_regalos']!,
          _valorRegalosMeta,
        ),
      );
    }
    if (data.containsKey('valor_prom_sin_iva_manual')) {
      context.handle(
        _valorPromSinIvaManualMeta,
        valorPromSinIvaManual.isAcceptableOrUnknown(
          data['valor_prom_sin_iva_manual']!,
          _valorPromSinIvaManualMeta,
        ),
      );
    }
    if (data.containsKey('tu_pagas_manual')) {
      context.handle(
        _tuPagasManualMeta,
        tuPagasManual.isAcceptableOrUnknown(
          data['tu_pagas_manual']!,
          _tuPagasManualMeta,
        ),
      );
    }
    if (data.containsKey('precio_total_manual')) {
      context.handle(
        _precioTotalManualMeta,
        precioTotalManual.isAcceptableOrUnknown(
          data['precio_total_manual']!,
          _precioTotalManualMeta,
        ),
      );
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    if (data.containsKey('eliminado_en')) {
      context.handle(
        _eliminadoEnMeta,
        eliminadoEn.isAcceptableOrUnknown(
          data['eliminado_en']!,
          _eliminadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LineaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pedidoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pedido_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_id'],
      ),
      marca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marca'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      )!,
      cantPedida: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cant_pedida'],
      )!,
      cantEnviada: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cant_enviada'],
      )!,
      valorTotalPuntos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_total_puntos'],
      )!,
      precioUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_unitario'],
      )!,
      precioRevista: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_revista'],
      )!,
      valorTotalPromocionado: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_total_promocionado'],
      )!,
      totalDescuentoCn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_descuento_cn'],
      )!,
      valorRegalos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_regalos'],
      )!,
      valorPromSinIvaManual: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_prom_sin_iva_manual'],
      ),
      tuPagasManual: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tu_pagas_manual'],
      ),
      precioTotalManual: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_total_manual'],
      ),
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
      eliminadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}eliminado_en'],
      ),
    );
  }

  @override
  $LineasPedidoTable createAlias(String alias) {
    return $LineasPedidoTable(attachedDatabase, alias);
  }
}

class LineaRow extends DataClass implements Insertable<LineaRow> {
  final String id;
  final String pedidoId;

  /// Producto del inventario al que se le sumaran las piezas recibidas.
  ///
  /// Nullable porque una hoja se puede capturar antes de dar de alta el
  /// articulo; al recibir el pedido, esas lineas se ignoran o se enlazan por
  /// marca y codigo.
  final String? productoId;
  final String marca;

  /// Codigo de catalogo como texto: hay codigos con ceros a la izquierda y
  /// guardarlos como numero los perderia.
  final String codigo;
  final String descripcion;
  final int cantPedida;
  final int cantEnviada;
  final int valorTotalPuntos;

  /// Precio unitario de compra: lo que la propietaria le paga a la
  /// distribuidora por una pieza, en centavos.
  ///
  /// No confundir con [precioRevista], que es el precio de venta al publico
  /// que trae el catalogo. La diferencia entre los dos es el margen del
  /// negocio, y por eso los dos viven en la misma hoja.
  final int precioUnitario;

  /// Precio de revista unitario: lo que el catalogo le pide al cliente final.
  final int precioRevista;
  final int valorTotalPromocionado;
  final int totalDescuentoCn;
  final int valorRegalos;

  /// Solo se guardan cuando la usuaria sobrescribe el valor calculado.
  final int? valorPromSinIvaManual;
  final int? tuPagasManual;

  /// Precio total de compra capturado a mano; `null` deja que se calcule como
  /// `precioUnitario * cantPedida`.
  final int? precioTotalManual;
  final int orden;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  final DateTime? eliminadoEn;
  const LineaRow({
    required this.id,
    required this.pedidoId,
    this.productoId,
    required this.marca,
    required this.codigo,
    required this.descripcion,
    required this.cantPedida,
    required this.cantEnviada,
    required this.valorTotalPuntos,
    required this.precioUnitario,
    required this.precioRevista,
    required this.valorTotalPromocionado,
    required this.totalDescuentoCn,
    required this.valorRegalos,
    this.valorPromSinIvaManual,
    this.tuPagasManual,
    this.precioTotalManual,
    required this.orden,
    required this.creadoEn,
    required this.actualizadoEn,
    this.eliminadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pedido_id'] = Variable<String>(pedidoId);
    if (!nullToAbsent || productoId != null) {
      map['producto_id'] = Variable<String>(productoId);
    }
    map['marca'] = Variable<String>(marca);
    map['codigo'] = Variable<String>(codigo);
    map['descripcion'] = Variable<String>(descripcion);
    map['cant_pedida'] = Variable<int>(cantPedida);
    map['cant_enviada'] = Variable<int>(cantEnviada);
    map['valor_total_puntos'] = Variable<int>(valorTotalPuntos);
    map['precio_unitario'] = Variable<int>(precioUnitario);
    map['precio_revista'] = Variable<int>(precioRevista);
    map['valor_total_promocionado'] = Variable<int>(valorTotalPromocionado);
    map['total_descuento_cn'] = Variable<int>(totalDescuentoCn);
    map['valor_regalos'] = Variable<int>(valorRegalos);
    if (!nullToAbsent || valorPromSinIvaManual != null) {
      map['valor_prom_sin_iva_manual'] = Variable<int>(valorPromSinIvaManual);
    }
    if (!nullToAbsent || tuPagasManual != null) {
      map['tu_pagas_manual'] = Variable<int>(tuPagasManual);
    }
    if (!nullToAbsent || precioTotalManual != null) {
      map['precio_total_manual'] = Variable<int>(precioTotalManual);
    }
    map['orden'] = Variable<int>(orden);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    if (!nullToAbsent || eliminadoEn != null) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn);
    }
    return map;
  }

  LineasPedidoCompanion toCompanion(bool nullToAbsent) {
    return LineasPedidoCompanion(
      id: Value(id),
      pedidoId: Value(pedidoId),
      productoId: productoId == null && nullToAbsent
          ? const Value.absent()
          : Value(productoId),
      marca: Value(marca),
      codigo: Value(codigo),
      descripcion: Value(descripcion),
      cantPedida: Value(cantPedida),
      cantEnviada: Value(cantEnviada),
      valorTotalPuntos: Value(valorTotalPuntos),
      precioUnitario: Value(precioUnitario),
      precioRevista: Value(precioRevista),
      valorTotalPromocionado: Value(valorTotalPromocionado),
      totalDescuentoCn: Value(totalDescuentoCn),
      valorRegalos: Value(valorRegalos),
      valorPromSinIvaManual: valorPromSinIvaManual == null && nullToAbsent
          ? const Value.absent()
          : Value(valorPromSinIvaManual),
      tuPagasManual: tuPagasManual == null && nullToAbsent
          ? const Value.absent()
          : Value(tuPagasManual),
      precioTotalManual: precioTotalManual == null && nullToAbsent
          ? const Value.absent()
          : Value(precioTotalManual),
      orden: Value(orden),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
      eliminadoEn: eliminadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(eliminadoEn),
    );
  }

  factory LineaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineaRow(
      id: serializer.fromJson<String>(json['id']),
      pedidoId: serializer.fromJson<String>(json['pedidoId']),
      productoId: serializer.fromJson<String?>(json['productoId']),
      marca: serializer.fromJson<String>(json['marca']),
      codigo: serializer.fromJson<String>(json['codigo']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      cantPedida: serializer.fromJson<int>(json['cantPedida']),
      cantEnviada: serializer.fromJson<int>(json['cantEnviada']),
      valorTotalPuntos: serializer.fromJson<int>(json['valorTotalPuntos']),
      precioUnitario: serializer.fromJson<int>(json['precioUnitario']),
      precioRevista: serializer.fromJson<int>(json['precioRevista']),
      valorTotalPromocionado: serializer.fromJson<int>(
        json['valorTotalPromocionado'],
      ),
      totalDescuentoCn: serializer.fromJson<int>(json['totalDescuentoCn']),
      valorRegalos: serializer.fromJson<int>(json['valorRegalos']),
      valorPromSinIvaManual: serializer.fromJson<int?>(
        json['valorPromSinIvaManual'],
      ),
      tuPagasManual: serializer.fromJson<int?>(json['tuPagasManual']),
      precioTotalManual: serializer.fromJson<int?>(json['precioTotalManual']),
      orden: serializer.fromJson<int>(json['orden']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
      eliminadoEn: serializer.fromJson<DateTime?>(json['eliminadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pedidoId': serializer.toJson<String>(pedidoId),
      'productoId': serializer.toJson<String?>(productoId),
      'marca': serializer.toJson<String>(marca),
      'codigo': serializer.toJson<String>(codigo),
      'descripcion': serializer.toJson<String>(descripcion),
      'cantPedida': serializer.toJson<int>(cantPedida),
      'cantEnviada': serializer.toJson<int>(cantEnviada),
      'valorTotalPuntos': serializer.toJson<int>(valorTotalPuntos),
      'precioUnitario': serializer.toJson<int>(precioUnitario),
      'precioRevista': serializer.toJson<int>(precioRevista),
      'valorTotalPromocionado': serializer.toJson<int>(valorTotalPromocionado),
      'totalDescuentoCn': serializer.toJson<int>(totalDescuentoCn),
      'valorRegalos': serializer.toJson<int>(valorRegalos),
      'valorPromSinIvaManual': serializer.toJson<int?>(valorPromSinIvaManual),
      'tuPagasManual': serializer.toJson<int?>(tuPagasManual),
      'precioTotalManual': serializer.toJson<int?>(precioTotalManual),
      'orden': serializer.toJson<int>(orden),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
      'eliminadoEn': serializer.toJson<DateTime?>(eliminadoEn),
    };
  }

  LineaRow copyWith({
    String? id,
    String? pedidoId,
    Value<String?> productoId = const Value.absent(),
    String? marca,
    String? codigo,
    String? descripcion,
    int? cantPedida,
    int? cantEnviada,
    int? valorTotalPuntos,
    int? precioUnitario,
    int? precioRevista,
    int? valorTotalPromocionado,
    int? totalDescuentoCn,
    int? valorRegalos,
    Value<int?> valorPromSinIvaManual = const Value.absent(),
    Value<int?> tuPagasManual = const Value.absent(),
    Value<int?> precioTotalManual = const Value.absent(),
    int? orden,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
    Value<DateTime?> eliminadoEn = const Value.absent(),
  }) => LineaRow(
    id: id ?? this.id,
    pedidoId: pedidoId ?? this.pedidoId,
    productoId: productoId.present ? productoId.value : this.productoId,
    marca: marca ?? this.marca,
    codigo: codigo ?? this.codigo,
    descripcion: descripcion ?? this.descripcion,
    cantPedida: cantPedida ?? this.cantPedida,
    cantEnviada: cantEnviada ?? this.cantEnviada,
    valorTotalPuntos: valorTotalPuntos ?? this.valorTotalPuntos,
    precioUnitario: precioUnitario ?? this.precioUnitario,
    precioRevista: precioRevista ?? this.precioRevista,
    valorTotalPromocionado:
        valorTotalPromocionado ?? this.valorTotalPromocionado,
    totalDescuentoCn: totalDescuentoCn ?? this.totalDescuentoCn,
    valorRegalos: valorRegalos ?? this.valorRegalos,
    valorPromSinIvaManual: valorPromSinIvaManual.present
        ? valorPromSinIvaManual.value
        : this.valorPromSinIvaManual,
    tuPagasManual: tuPagasManual.present
        ? tuPagasManual.value
        : this.tuPagasManual,
    precioTotalManual: precioTotalManual.present
        ? precioTotalManual.value
        : this.precioTotalManual,
    orden: orden ?? this.orden,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    eliminadoEn: eliminadoEn.present ? eliminadoEn.value : this.eliminadoEn,
  );
  LineaRow copyWithCompanion(LineasPedidoCompanion data) {
    return LineaRow(
      id: data.id.present ? data.id.value : this.id,
      pedidoId: data.pedidoId.present ? data.pedidoId.value : this.pedidoId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      marca: data.marca.present ? data.marca.value : this.marca,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      cantPedida: data.cantPedida.present
          ? data.cantPedida.value
          : this.cantPedida,
      cantEnviada: data.cantEnviada.present
          ? data.cantEnviada.value
          : this.cantEnviada,
      valorTotalPuntos: data.valorTotalPuntos.present
          ? data.valorTotalPuntos.value
          : this.valorTotalPuntos,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      precioRevista: data.precioRevista.present
          ? data.precioRevista.value
          : this.precioRevista,
      valorTotalPromocionado: data.valorTotalPromocionado.present
          ? data.valorTotalPromocionado.value
          : this.valorTotalPromocionado,
      totalDescuentoCn: data.totalDescuentoCn.present
          ? data.totalDescuentoCn.value
          : this.totalDescuentoCn,
      valorRegalos: data.valorRegalos.present
          ? data.valorRegalos.value
          : this.valorRegalos,
      valorPromSinIvaManual: data.valorPromSinIvaManual.present
          ? data.valorPromSinIvaManual.value
          : this.valorPromSinIvaManual,
      tuPagasManual: data.tuPagasManual.present
          ? data.tuPagasManual.value
          : this.tuPagasManual,
      precioTotalManual: data.precioTotalManual.present
          ? data.precioTotalManual.value
          : this.precioTotalManual,
      orden: data.orden.present ? data.orden.value : this.orden,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
      eliminadoEn: data.eliminadoEn.present
          ? data.eliminadoEn.value
          : this.eliminadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineaRow(')
          ..write('id: $id, ')
          ..write('pedidoId: $pedidoId, ')
          ..write('productoId: $productoId, ')
          ..write('marca: $marca, ')
          ..write('codigo: $codigo, ')
          ..write('descripcion: $descripcion, ')
          ..write('cantPedida: $cantPedida, ')
          ..write('cantEnviada: $cantEnviada, ')
          ..write('valorTotalPuntos: $valorTotalPuntos, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('precioRevista: $precioRevista, ')
          ..write('valorTotalPromocionado: $valorTotalPromocionado, ')
          ..write('totalDescuentoCn: $totalDescuentoCn, ')
          ..write('valorRegalos: $valorRegalos, ')
          ..write('valorPromSinIvaManual: $valorPromSinIvaManual, ')
          ..write('tuPagasManual: $tuPagasManual, ')
          ..write('precioTotalManual: $precioTotalManual, ')
          ..write('orden: $orden, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    pedidoId,
    productoId,
    marca,
    codigo,
    descripcion,
    cantPedida,
    cantEnviada,
    valorTotalPuntos,
    precioUnitario,
    precioRevista,
    valorTotalPromocionado,
    totalDescuentoCn,
    valorRegalos,
    valorPromSinIvaManual,
    tuPagasManual,
    precioTotalManual,
    orden,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineaRow &&
          other.id == this.id &&
          other.pedidoId == this.pedidoId &&
          other.productoId == this.productoId &&
          other.marca == this.marca &&
          other.codigo == this.codigo &&
          other.descripcion == this.descripcion &&
          other.cantPedida == this.cantPedida &&
          other.cantEnviada == this.cantEnviada &&
          other.valorTotalPuntos == this.valorTotalPuntos &&
          other.precioUnitario == this.precioUnitario &&
          other.precioRevista == this.precioRevista &&
          other.valorTotalPromocionado == this.valorTotalPromocionado &&
          other.totalDescuentoCn == this.totalDescuentoCn &&
          other.valorRegalos == this.valorRegalos &&
          other.valorPromSinIvaManual == this.valorPromSinIvaManual &&
          other.tuPagasManual == this.tuPagasManual &&
          other.precioTotalManual == this.precioTotalManual &&
          other.orden == this.orden &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn &&
          other.eliminadoEn == this.eliminadoEn);
}

class LineasPedidoCompanion extends UpdateCompanion<LineaRow> {
  final Value<String> id;
  final Value<String> pedidoId;
  final Value<String?> productoId;
  final Value<String> marca;
  final Value<String> codigo;
  final Value<String> descripcion;
  final Value<int> cantPedida;
  final Value<int> cantEnviada;
  final Value<int> valorTotalPuntos;
  final Value<int> precioUnitario;
  final Value<int> precioRevista;
  final Value<int> valorTotalPromocionado;
  final Value<int> totalDescuentoCn;
  final Value<int> valorRegalos;
  final Value<int?> valorPromSinIvaManual;
  final Value<int?> tuPagasManual;
  final Value<int?> precioTotalManual;
  final Value<int> orden;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  final Value<DateTime?> eliminadoEn;
  final Value<int> rowid;
  const LineasPedidoCompanion({
    this.id = const Value.absent(),
    this.pedidoId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.marca = const Value.absent(),
    this.codigo = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.cantPedida = const Value.absent(),
    this.cantEnviada = const Value.absent(),
    this.valorTotalPuntos = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.precioRevista = const Value.absent(),
    this.valorTotalPromocionado = const Value.absent(),
    this.totalDescuentoCn = const Value.absent(),
    this.valorRegalos = const Value.absent(),
    this.valorPromSinIvaManual = const Value.absent(),
    this.tuPagasManual = const Value.absent(),
    this.precioTotalManual = const Value.absent(),
    this.orden = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LineasPedidoCompanion.insert({
    required String id,
    required String pedidoId,
    this.productoId = const Value.absent(),
    this.marca = const Value.absent(),
    this.codigo = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.cantPedida = const Value.absent(),
    this.cantEnviada = const Value.absent(),
    this.valorTotalPuntos = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.precioRevista = const Value.absent(),
    this.valorTotalPromocionado = const Value.absent(),
    this.totalDescuentoCn = const Value.absent(),
    this.valorRegalos = const Value.absent(),
    this.valorPromSinIvaManual = const Value.absent(),
    this.tuPagasManual = const Value.absent(),
    this.precioTotalManual = const Value.absent(),
    this.orden = const Value.absent(),
    required DateTime creadoEn,
    required DateTime actualizadoEn,
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pedidoId = Value(pedidoId),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<LineaRow> custom({
    Expression<String>? id,
    Expression<String>? pedidoId,
    Expression<String>? productoId,
    Expression<String>? marca,
    Expression<String>? codigo,
    Expression<String>? descripcion,
    Expression<int>? cantPedida,
    Expression<int>? cantEnviada,
    Expression<int>? valorTotalPuntos,
    Expression<int>? precioUnitario,
    Expression<int>? precioRevista,
    Expression<int>? valorTotalPromocionado,
    Expression<int>? totalDescuentoCn,
    Expression<int>? valorRegalos,
    Expression<int>? valorPromSinIvaManual,
    Expression<int>? tuPagasManual,
    Expression<int>? precioTotalManual,
    Expression<int>? orden,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
    Expression<DateTime>? eliminadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pedidoId != null) 'pedido_id': pedidoId,
      if (productoId != null) 'producto_id': productoId,
      if (marca != null) 'marca': marca,
      if (codigo != null) 'codigo': codigo,
      if (descripcion != null) 'descripcion': descripcion,
      if (cantPedida != null) 'cant_pedida': cantPedida,
      if (cantEnviada != null) 'cant_enviada': cantEnviada,
      if (valorTotalPuntos != null) 'valor_total_puntos': valorTotalPuntos,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (precioRevista != null) 'precio_revista': precioRevista,
      if (valorTotalPromocionado != null)
        'valor_total_promocionado': valorTotalPromocionado,
      if (totalDescuentoCn != null) 'total_descuento_cn': totalDescuentoCn,
      if (valorRegalos != null) 'valor_regalos': valorRegalos,
      if (valorPromSinIvaManual != null)
        'valor_prom_sin_iva_manual': valorPromSinIvaManual,
      if (tuPagasManual != null) 'tu_pagas_manual': tuPagasManual,
      if (precioTotalManual != null) 'precio_total_manual': precioTotalManual,
      if (orden != null) 'orden': orden,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (eliminadoEn != null) 'eliminado_en': eliminadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LineasPedidoCompanion copyWith({
    Value<String>? id,
    Value<String>? pedidoId,
    Value<String?>? productoId,
    Value<String>? marca,
    Value<String>? codigo,
    Value<String>? descripcion,
    Value<int>? cantPedida,
    Value<int>? cantEnviada,
    Value<int>? valorTotalPuntos,
    Value<int>? precioUnitario,
    Value<int>? precioRevista,
    Value<int>? valorTotalPromocionado,
    Value<int>? totalDescuentoCn,
    Value<int>? valorRegalos,
    Value<int?>? valorPromSinIvaManual,
    Value<int?>? tuPagasManual,
    Value<int?>? precioTotalManual,
    Value<int>? orden,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
    Value<DateTime?>? eliminadoEn,
    Value<int>? rowid,
  }) {
    return LineasPedidoCompanion(
      id: id ?? this.id,
      pedidoId: pedidoId ?? this.pedidoId,
      productoId: productoId ?? this.productoId,
      marca: marca ?? this.marca,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      cantPedida: cantPedida ?? this.cantPedida,
      cantEnviada: cantEnviada ?? this.cantEnviada,
      valorTotalPuntos: valorTotalPuntos ?? this.valorTotalPuntos,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      precioRevista: precioRevista ?? this.precioRevista,
      valorTotalPromocionado:
          valorTotalPromocionado ?? this.valorTotalPromocionado,
      totalDescuentoCn: totalDescuentoCn ?? this.totalDescuentoCn,
      valorRegalos: valorRegalos ?? this.valorRegalos,
      valorPromSinIvaManual:
          valorPromSinIvaManual ?? this.valorPromSinIvaManual,
      tuPagasManual: tuPagasManual ?? this.tuPagasManual,
      precioTotalManual: precioTotalManual ?? this.precioTotalManual,
      orden: orden ?? this.orden,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      eliminadoEn: eliminadoEn ?? this.eliminadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pedidoId.present) {
      map['pedido_id'] = Variable<String>(pedidoId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (marca.present) {
      map['marca'] = Variable<String>(marca.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (cantPedida.present) {
      map['cant_pedida'] = Variable<int>(cantPedida.value);
    }
    if (cantEnviada.present) {
      map['cant_enviada'] = Variable<int>(cantEnviada.value);
    }
    if (valorTotalPuntos.present) {
      map['valor_total_puntos'] = Variable<int>(valorTotalPuntos.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<int>(precioUnitario.value);
    }
    if (precioRevista.present) {
      map['precio_revista'] = Variable<int>(precioRevista.value);
    }
    if (valorTotalPromocionado.present) {
      map['valor_total_promocionado'] = Variable<int>(
        valorTotalPromocionado.value,
      );
    }
    if (totalDescuentoCn.present) {
      map['total_descuento_cn'] = Variable<int>(totalDescuentoCn.value);
    }
    if (valorRegalos.present) {
      map['valor_regalos'] = Variable<int>(valorRegalos.value);
    }
    if (valorPromSinIvaManual.present) {
      map['valor_prom_sin_iva_manual'] = Variable<int>(
        valorPromSinIvaManual.value,
      );
    }
    if (tuPagasManual.present) {
      map['tu_pagas_manual'] = Variable<int>(tuPagasManual.value);
    }
    if (precioTotalManual.present) {
      map['precio_total_manual'] = Variable<int>(precioTotalManual.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (eliminadoEn.present) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineasPedidoCompanion(')
          ..write('id: $id, ')
          ..write('pedidoId: $pedidoId, ')
          ..write('productoId: $productoId, ')
          ..write('marca: $marca, ')
          ..write('codigo: $codigo, ')
          ..write('descripcion: $descripcion, ')
          ..write('cantPedida: $cantPedida, ')
          ..write('cantEnviada: $cantEnviada, ')
          ..write('valorTotalPuntos: $valorTotalPuntos, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('precioRevista: $precioRevista, ')
          ..write('valorTotalPromocionado: $valorTotalPromocionado, ')
          ..write('totalDescuentoCn: $totalDescuentoCn, ')
          ..write('valorRegalos: $valorRegalos, ')
          ..write('valorPromSinIvaManual: $valorPromSinIvaManual, ')
          ..write('tuPagasManual: $tuPagasManual, ')
          ..write('precioTotalManual: $precioTotalManual, ')
          ..write('orden: $orden, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClientesTable extends Clientes
    with TableInfo<$ClientesTable, ClienteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _direccionMeta = const VerificationMeta(
    'direccion',
  );
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
    'direccion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _eliminadoEnMeta = const VerificationMeta(
    'eliminadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> eliminadoEn = GeneratedColumn<DateTime>(
    'eliminado_en',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    telefono,
    direccion,
    notas,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClienteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    if (data.containsKey('direccion')) {
      context.handle(
        _direccionMeta,
        direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    if (data.containsKey('eliminado_en')) {
      context.handle(
        _eliminadoEnMeta,
        eliminadoEn.isAcceptableOrUnknown(
          data['eliminado_en']!,
          _eliminadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClienteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClienteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      )!,
      direccion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direccion'],
      )!,
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
      eliminadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}eliminado_en'],
      ),
    );
  }

  @override
  $ClientesTable createAlias(String alias) {
    return $ClientesTable(attachedDatabase, alias);
  }
}

class ClienteRow extends DataClass implements Insertable<ClienteRow> {
  final String id;

  /// Como lo llama la propietaria. Es el nombre vivo: si aqui se corrige,
  /// se corrige en las ventas de esa persona.
  final String nombre;

  /// A que numero se le marca.
  ///
  /// Se guarda como texto y no como numero por la misma razon que un codigo de
  /// catalogo: hay telefonos con lada entre parentesis, con espacios y con
  /// ceros al principio, y convertirlos a entero los deforma. Ademas nunca se
  /// suma ni se ordena por el, solo se lee y se marca.
  ///
  /// Nace separado de [notas] porque un telefono enterrado en texto libre no
  /// se puede tocar para llamar ni buscar por el; con columna propia, la venta
  /// puede mostrarlo como un boton.
  final String telefono;

  /// Donde se le entrega la mercancia.
  ///
  /// Es del cliente y no de la venta a proposito: a la misma persona se le
  /// entrega siempre en el mismo lugar, y volverlo a teclear en cada venta es
  /// justo lo que produce direcciones que no coinciden entre dos hojas de la
  /// misma persona. Si algun dia una entrega va a otro lado, eso es una nota
  /// de esa venta.
  final String direccion;

  /// Texto libre para lo demas que ayuda a ubicarlo: quien lo recomendo, a que
  /// horas esta, de quien es pariente.
  final String notas;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  final DateTime? eliminadoEn;
  const ClienteRow({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.direccion,
    required this.notas,
    required this.creadoEn,
    required this.actualizadoEn,
    this.eliminadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre'] = Variable<String>(nombre);
    map['telefono'] = Variable<String>(telefono);
    map['direccion'] = Variable<String>(direccion);
    map['notas'] = Variable<String>(notas);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    if (!nullToAbsent || eliminadoEn != null) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn);
    }
    return map;
  }

  ClientesCompanion toCompanion(bool nullToAbsent) {
    return ClientesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      telefono: Value(telefono),
      direccion: Value(direccion),
      notas: Value(notas),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
      eliminadoEn: eliminadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(eliminadoEn),
    );
  }

  factory ClienteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClienteRow(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      telefono: serializer.fromJson<String>(json['telefono']),
      direccion: serializer.fromJson<String>(json['direccion']),
      notas: serializer.fromJson<String>(json['notas']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
      eliminadoEn: serializer.fromJson<DateTime?>(json['eliminadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String>(nombre),
      'telefono': serializer.toJson<String>(telefono),
      'direccion': serializer.toJson<String>(direccion),
      'notas': serializer.toJson<String>(notas),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
      'eliminadoEn': serializer.toJson<DateTime?>(eliminadoEn),
    };
  }

  ClienteRow copyWith({
    String? id,
    String? nombre,
    String? telefono,
    String? direccion,
    String? notas,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
    Value<DateTime?> eliminadoEn = const Value.absent(),
  }) => ClienteRow(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    telefono: telefono ?? this.telefono,
    direccion: direccion ?? this.direccion,
    notas: notas ?? this.notas,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    eliminadoEn: eliminadoEn.present ? eliminadoEn.value : this.eliminadoEn,
  );
  ClienteRow copyWithCompanion(ClientesCompanion data) {
    return ClienteRow(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      notas: data.notas.present ? data.notas.value : this.notas,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
      eliminadoEn: data.eliminadoEn.present
          ? data.eliminadoEn.value
          : this.eliminadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClienteRow(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('direccion: $direccion, ')
          ..write('notas: $notas, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    telefono,
    direccion,
    notas,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClienteRow &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.telefono == this.telefono &&
          other.direccion == this.direccion &&
          other.notas == this.notas &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn &&
          other.eliminadoEn == this.eliminadoEn);
}

class ClientesCompanion extends UpdateCompanion<ClienteRow> {
  final Value<String> id;
  final Value<String> nombre;
  final Value<String> telefono;
  final Value<String> direccion;
  final Value<String> notas;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  final Value<DateTime?> eliminadoEn;
  final Value<int> rowid;
  const ClientesCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.telefono = const Value.absent(),
    this.direccion = const Value.absent(),
    this.notas = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientesCompanion.insert({
    required String id,
    this.nombre = const Value.absent(),
    this.telefono = const Value.absent(),
    this.direccion = const Value.absent(),
    this.notas = const Value.absent(),
    required DateTime creadoEn,
    required DateTime actualizadoEn,
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<ClienteRow> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<String>? telefono,
    Expression<String>? direccion,
    Expression<String>? notas,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
    Expression<DateTime>? eliminadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (telefono != null) 'telefono': telefono,
      if (direccion != null) 'direccion': direccion,
      if (notas != null) 'notas': notas,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (eliminadoEn != null) 'eliminado_en': eliminadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientesCompanion copyWith({
    Value<String>? id,
    Value<String>? nombre,
    Value<String>? telefono,
    Value<String>? direccion,
    Value<String>? notas,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
    Value<DateTime?>? eliminadoEn,
    Value<int>? rowid,
  }) {
    return ClientesCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      notas: notas ?? this.notas,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      eliminadoEn: eliminadoEn ?? this.eliminadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (eliminadoEn.present) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('direccion: $direccion, ')
          ..write('notas: $notas, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CarpetasVentaTable extends CarpetasVenta
    with TableInfo<$CarpetasVentaTable, CarpetaVentaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CarpetasVentaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _eliminadoEnMeta = const VerificationMeta(
    'eliminadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> eliminadoEn = GeneratedColumn<DateTime>(
    'eliminado_en',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    notas,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'carpetas_venta';
  @override
  VerificationContext validateIntegrity(
    Insertable<CarpetaVentaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    if (data.containsKey('eliminado_en')) {
      context.handle(
        _eliminadoEnMeta,
        eliminadoEn.isAcceptableOrUnknown(
          data['eliminado_en']!,
          _eliminadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CarpetaVentaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CarpetaVentaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
      eliminadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}eliminado_en'],
      ),
    );
  }

  @override
  $CarpetasVentaTable createAlias(String alias) {
    return $CarpetasVentaTable(attachedDatabase, alias);
  }
}

class CarpetaVentaRow extends DataClass implements Insertable<CarpetaVentaRow> {
  final String id;
  final String nombre;
  final String notas;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  /// Borrado logico, como todo. Al borrar una carpeta sus ventas no se van
  /// con ella: se quedan sueltas, porque la carpeta es una etiqueta y la
  /// venta es el documento.
  final DateTime? eliminadoEn;
  const CarpetaVentaRow({
    required this.id,
    required this.nombre,
    required this.notas,
    required this.creadoEn,
    required this.actualizadoEn,
    this.eliminadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre'] = Variable<String>(nombre);
    map['notas'] = Variable<String>(notas);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    if (!nullToAbsent || eliminadoEn != null) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn);
    }
    return map;
  }

  CarpetasVentaCompanion toCompanion(bool nullToAbsent) {
    return CarpetasVentaCompanion(
      id: Value(id),
      nombre: Value(nombre),
      notas: Value(notas),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
      eliminadoEn: eliminadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(eliminadoEn),
    );
  }

  factory CarpetaVentaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CarpetaVentaRow(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      notas: serializer.fromJson<String>(json['notas']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
      eliminadoEn: serializer.fromJson<DateTime?>(json['eliminadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String>(nombre),
      'notas': serializer.toJson<String>(notas),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
      'eliminadoEn': serializer.toJson<DateTime?>(eliminadoEn),
    };
  }

  CarpetaVentaRow copyWith({
    String? id,
    String? nombre,
    String? notas,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
    Value<DateTime?> eliminadoEn = const Value.absent(),
  }) => CarpetaVentaRow(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    notas: notas ?? this.notas,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    eliminadoEn: eliminadoEn.present ? eliminadoEn.value : this.eliminadoEn,
  );
  CarpetaVentaRow copyWithCompanion(CarpetasVentaCompanion data) {
    return CarpetaVentaRow(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      notas: data.notas.present ? data.notas.value : this.notas,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
      eliminadoEn: data.eliminadoEn.present
          ? data.eliminadoEn.value
          : this.eliminadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CarpetaVentaRow(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('notas: $notas, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nombre, notas, creadoEn, actualizadoEn, eliminadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CarpetaVentaRow &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.notas == this.notas &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn &&
          other.eliminadoEn == this.eliminadoEn);
}

class CarpetasVentaCompanion extends UpdateCompanion<CarpetaVentaRow> {
  final Value<String> id;
  final Value<String> nombre;
  final Value<String> notas;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  final Value<DateTime?> eliminadoEn;
  final Value<int> rowid;
  const CarpetasVentaCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.notas = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CarpetasVentaCompanion.insert({
    required String id,
    this.nombre = const Value.absent(),
    this.notas = const Value.absent(),
    required DateTime creadoEn,
    required DateTime actualizadoEn,
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<CarpetaVentaRow> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<String>? notas,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
    Expression<DateTime>? eliminadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (notas != null) 'notas': notas,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (eliminadoEn != null) 'eliminado_en': eliminadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CarpetasVentaCompanion copyWith({
    Value<String>? id,
    Value<String>? nombre,
    Value<String>? notas,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
    Value<DateTime?>? eliminadoEn,
    Value<int>? rowid,
  }) {
    return CarpetasVentaCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      notas: notas ?? this.notas,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      eliminadoEn: eliminadoEn ?? this.eliminadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (eliminadoEn.present) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CarpetasVentaCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('notas: $notas, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VentasTable extends Ventas with TableInfo<$VentasTable, VentaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<String> clienteId = GeneratedColumn<String>(
    'cliente_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clientes (id)',
    ),
  );
  static const VerificationMeta _clienteMeta = const VerificationMeta(
    'cliente',
  );
  @override
  late final GeneratedColumn<String> cliente = GeneratedColumn<String>(
    'cliente',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _carpetaIdMeta = const VerificationMeta(
    'carpetaId',
  );
  @override
  late final GeneratedColumn<String> carpetaId = GeneratedColumn<String>(
    'carpeta_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES carpetas_venta (id)',
    ),
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('apartada'),
  );
  static const VerificationMeta _entregadaEnMeta = const VerificationMeta(
    'entregadaEn',
  );
  @override
  late final GeneratedColumn<DateTime> entregadaEn = GeneratedColumn<DateTime>(
    'entregada_en',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _eliminadoEnMeta = const VerificationMeta(
    'eliminadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> eliminadoEn = GeneratedColumn<DateTime>(
    'eliminado_en',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fecha,
    clienteId,
    cliente,
    carpetaId,
    notas,
    estado,
    entregadaEn,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventas';
  @override
  VerificationContext validateIntegrity(
    Insertable<VentaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    }
    if (data.containsKey('cliente')) {
      context.handle(
        _clienteMeta,
        cliente.isAcceptableOrUnknown(data['cliente']!, _clienteMeta),
      );
    }
    if (data.containsKey('carpeta_id')) {
      context.handle(
        _carpetaIdMeta,
        carpetaId.isAcceptableOrUnknown(data['carpeta_id']!, _carpetaIdMeta),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('entregada_en')) {
      context.handle(
        _entregadaEnMeta,
        entregadaEn.isAcceptableOrUnknown(
          data['entregada_en']!,
          _entregadaEnMeta,
        ),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    if (data.containsKey('eliminado_en')) {
      context.handle(
        _eliminadoEnMeta,
        eliminadoEn.isAcceptableOrUnknown(
          data['eliminado_en']!,
          _eliminadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VentaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VentaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cliente_id'],
      ),
      cliente: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cliente'],
      )!,
      carpetaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}carpeta_id'],
      ),
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      entregadaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entregada_en'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
      eliminadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}eliminado_en'],
      ),
    );
  }

  @override
  $VentasTable createAlias(String alias) {
    return $VentasTable(attachedDatabase, alias);
  }
}

class VentaRow extends DataClass implements Insertable<VentaRow> {
  final String id;
  final DateTime fecha;

  /// Quien compra, del padron. Nullable porque las ventas capturadas antes de
  /// que el padron existiera no tienen a quien apuntar, y porque se permite
  /// abrir una venta sin ponerle nombre todavia.
  ///
  /// Es lo que permite que un abono sepa a que adeudo pegarle.
  final String? clienteId;

  /// El nombre tal como se lee en esta venta.
  ///
  /// Convive con [clienteId] y no lo sustituye: mientras la venta este
  /// enlazada, esta columna es una copia del nombre del padron que el
  /// repositorio refresca al renombrar, y sirve para que las ventas viejas
  /// -y las que se abrieron sin elegir cliente- sigan diciendo a quien se le
  /// vendio. Es la unica columna del sistema que se copia *y* se mantiene al
  /// dia, porque un cliente mal escrito se corrige y debe corregirse en todas
  /// partes; una descripcion de producto, en cambio, se congela.
  final String cliente;

  /// Carpeta donde la propietaria guardo esta venta. `null` es "Sin carpeta",
  /// que no es una carpeta de verdad sino el monton de las que nunca se
  /// separaron.
  final String? carpetaId;
  final String notas;

  /// Estado del apartado: `apartada`, `entregada` o `cancelada`.
  ///
  /// Se guarda como texto y no como entero para que la base siga siendo
  /// legible si algun dia hay que revisarla a mano. El mapeo vive en
  /// `EstadoVenta`, del dominio.
  ///
  /// Mientras esta `apartada` las piezas quedan comprometidas pero siguen
  /// contadas en `cantidadActual` del producto; al pasar a `entregada` se
  /// descuentan de verdad.
  final String estado;

  /// Momento en que las piezas salieron del inventario. Es el seguro contra
  /// descontar dos veces: si ya tiene fecha, la entrega no se vuelve a aplicar.
  final DateTime? entregadaEn;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  final DateTime? eliminadoEn;
  const VentaRow({
    required this.id,
    required this.fecha,
    this.clienteId,
    required this.cliente,
    this.carpetaId,
    required this.notas,
    required this.estado,
    this.entregadaEn,
    required this.creadoEn,
    required this.actualizadoEn,
    this.eliminadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fecha'] = Variable<DateTime>(fecha);
    if (!nullToAbsent || clienteId != null) {
      map['cliente_id'] = Variable<String>(clienteId);
    }
    map['cliente'] = Variable<String>(cliente);
    if (!nullToAbsent || carpetaId != null) {
      map['carpeta_id'] = Variable<String>(carpetaId);
    }
    map['notas'] = Variable<String>(notas);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || entregadaEn != null) {
      map['entregada_en'] = Variable<DateTime>(entregadaEn);
    }
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    if (!nullToAbsent || eliminadoEn != null) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn);
    }
    return map;
  }

  VentasCompanion toCompanion(bool nullToAbsent) {
    return VentasCompanion(
      id: Value(id),
      fecha: Value(fecha),
      clienteId: clienteId == null && nullToAbsent
          ? const Value.absent()
          : Value(clienteId),
      cliente: Value(cliente),
      carpetaId: carpetaId == null && nullToAbsent
          ? const Value.absent()
          : Value(carpetaId),
      notas: Value(notas),
      estado: Value(estado),
      entregadaEn: entregadaEn == null && nullToAbsent
          ? const Value.absent()
          : Value(entregadaEn),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
      eliminadoEn: eliminadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(eliminadoEn),
    );
  }

  factory VentaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VentaRow(
      id: serializer.fromJson<String>(json['id']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      clienteId: serializer.fromJson<String?>(json['clienteId']),
      cliente: serializer.fromJson<String>(json['cliente']),
      carpetaId: serializer.fromJson<String?>(json['carpetaId']),
      notas: serializer.fromJson<String>(json['notas']),
      estado: serializer.fromJson<String>(json['estado']),
      entregadaEn: serializer.fromJson<DateTime?>(json['entregadaEn']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
      eliminadoEn: serializer.fromJson<DateTime?>(json['eliminadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fecha': serializer.toJson<DateTime>(fecha),
      'clienteId': serializer.toJson<String?>(clienteId),
      'cliente': serializer.toJson<String>(cliente),
      'carpetaId': serializer.toJson<String?>(carpetaId),
      'notas': serializer.toJson<String>(notas),
      'estado': serializer.toJson<String>(estado),
      'entregadaEn': serializer.toJson<DateTime?>(entregadaEn),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
      'eliminadoEn': serializer.toJson<DateTime?>(eliminadoEn),
    };
  }

  VentaRow copyWith({
    String? id,
    DateTime? fecha,
    Value<String?> clienteId = const Value.absent(),
    String? cliente,
    Value<String?> carpetaId = const Value.absent(),
    String? notas,
    String? estado,
    Value<DateTime?> entregadaEn = const Value.absent(),
    DateTime? creadoEn,
    DateTime? actualizadoEn,
    Value<DateTime?> eliminadoEn = const Value.absent(),
  }) => VentaRow(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    clienteId: clienteId.present ? clienteId.value : this.clienteId,
    cliente: cliente ?? this.cliente,
    carpetaId: carpetaId.present ? carpetaId.value : this.carpetaId,
    notas: notas ?? this.notas,
    estado: estado ?? this.estado,
    entregadaEn: entregadaEn.present ? entregadaEn.value : this.entregadaEn,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    eliminadoEn: eliminadoEn.present ? eliminadoEn.value : this.eliminadoEn,
  );
  VentaRow copyWithCompanion(VentasCompanion data) {
    return VentaRow(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      cliente: data.cliente.present ? data.cliente.value : this.cliente,
      carpetaId: data.carpetaId.present ? data.carpetaId.value : this.carpetaId,
      notas: data.notas.present ? data.notas.value : this.notas,
      estado: data.estado.present ? data.estado.value : this.estado,
      entregadaEn: data.entregadaEn.present
          ? data.entregadaEn.value
          : this.entregadaEn,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
      eliminadoEn: data.eliminadoEn.present
          ? data.eliminadoEn.value
          : this.eliminadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VentaRow(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('clienteId: $clienteId, ')
          ..write('cliente: $cliente, ')
          ..write('carpetaId: $carpetaId, ')
          ..write('notas: $notas, ')
          ..write('estado: $estado, ')
          ..write('entregadaEn: $entregadaEn, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fecha,
    clienteId,
    cliente,
    carpetaId,
    notas,
    estado,
    entregadaEn,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VentaRow &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.clienteId == this.clienteId &&
          other.cliente == this.cliente &&
          other.carpetaId == this.carpetaId &&
          other.notas == this.notas &&
          other.estado == this.estado &&
          other.entregadaEn == this.entregadaEn &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn &&
          other.eliminadoEn == this.eliminadoEn);
}

class VentasCompanion extends UpdateCompanion<VentaRow> {
  final Value<String> id;
  final Value<DateTime> fecha;
  final Value<String?> clienteId;
  final Value<String> cliente;
  final Value<String?> carpetaId;
  final Value<String> notas;
  final Value<String> estado;
  final Value<DateTime?> entregadaEn;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  final Value<DateTime?> eliminadoEn;
  final Value<int> rowid;
  const VentasCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.cliente = const Value.absent(),
    this.carpetaId = const Value.absent(),
    this.notas = const Value.absent(),
    this.estado = const Value.absent(),
    this.entregadaEn = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VentasCompanion.insert({
    required String id,
    required DateTime fecha,
    this.clienteId = const Value.absent(),
    this.cliente = const Value.absent(),
    this.carpetaId = const Value.absent(),
    this.notas = const Value.absent(),
    this.estado = const Value.absent(),
    this.entregadaEn = const Value.absent(),
    required DateTime creadoEn,
    required DateTime actualizadoEn,
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fecha = Value(fecha),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<VentaRow> custom({
    Expression<String>? id,
    Expression<DateTime>? fecha,
    Expression<String>? clienteId,
    Expression<String>? cliente,
    Expression<String>? carpetaId,
    Expression<String>? notas,
    Expression<String>? estado,
    Expression<DateTime>? entregadaEn,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
    Expression<DateTime>? eliminadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (clienteId != null) 'cliente_id': clienteId,
      if (cliente != null) 'cliente': cliente,
      if (carpetaId != null) 'carpeta_id': carpetaId,
      if (notas != null) 'notas': notas,
      if (estado != null) 'estado': estado,
      if (entregadaEn != null) 'entregada_en': entregadaEn,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (eliminadoEn != null) 'eliminado_en': eliminadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VentasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? fecha,
    Value<String?>? clienteId,
    Value<String>? cliente,
    Value<String?>? carpetaId,
    Value<String>? notas,
    Value<String>? estado,
    Value<DateTime?>? entregadaEn,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
    Value<DateTime?>? eliminadoEn,
    Value<int>? rowid,
  }) {
    return VentasCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      clienteId: clienteId ?? this.clienteId,
      cliente: cliente ?? this.cliente,
      carpetaId: carpetaId ?? this.carpetaId,
      notas: notas ?? this.notas,
      estado: estado ?? this.estado,
      entregadaEn: entregadaEn ?? this.entregadaEn,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      eliminadoEn: eliminadoEn ?? this.eliminadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<String>(clienteId.value);
    }
    if (cliente.present) {
      map['cliente'] = Variable<String>(cliente.value);
    }
    if (carpetaId.present) {
      map['carpeta_id'] = Variable<String>(carpetaId.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (entregadaEn.present) {
      map['entregada_en'] = Variable<DateTime>(entregadaEn.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (eliminadoEn.present) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentasCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('clienteId: $clienteId, ')
          ..write('cliente: $cliente, ')
          ..write('carpetaId: $carpetaId, ')
          ..write('notas: $notas, ')
          ..write('estado: $estado, ')
          ..write('entregadaEn: $entregadaEn, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LineasVentaTable extends LineasVenta
    with TableInfo<$LineasVentaTable, LineaVentaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineasVentaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ventaIdMeta = const VerificationMeta(
    'ventaId',
  );
  @override
  late final GeneratedColumn<String> ventaId = GeneratedColumn<String>(
    'venta_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ventas (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
    'producto_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES productos (id)',
    ),
  );
  static const VerificationMeta _marcaMeta = const VerificationMeta('marca');
  @override
  late final GeneratedColumn<String> marca = GeneratedColumn<String>(
    'marca',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _precioUnitarioMeta = const VerificationMeta(
    'precioUnitario',
  );
  @override
  late final GeneratedColumn<int> precioUnitario = GeneratedColumn<int>(
    'precio_unitario',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _descuentoMeta = const VerificationMeta(
    'descuento',
  );
  @override
  late final GeneratedColumn<int> descuento = GeneratedColumn<int>(
    'descuento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _eliminadoEnMeta = const VerificationMeta(
    'eliminadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> eliminadoEn = GeneratedColumn<DateTime>(
    'eliminado_en',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ventaId,
    productoId,
    marca,
    codigo,
    descripcion,
    cantidad,
    precioUnitario,
    descuento,
    orden,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lineas_venta';
  @override
  VerificationContext validateIntegrity(
    Insertable<LineaVentaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('venta_id')) {
      context.handle(
        _ventaIdMeta,
        ventaId.isAcceptableOrUnknown(data['venta_id']!, _ventaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ventaIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    }
    if (data.containsKey('marca')) {
      context.handle(
        _marcaMeta,
        marca.isAcceptableOrUnknown(data['marca']!, _marcaMeta),
      );
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
        _precioUnitarioMeta,
        precioUnitario.isAcceptableOrUnknown(
          data['precio_unitario']!,
          _precioUnitarioMeta,
        ),
      );
    }
    if (data.containsKey('descuento')) {
      context.handle(
        _descuentoMeta,
        descuento.isAcceptableOrUnknown(data['descuento']!, _descuentoMeta),
      );
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    if (data.containsKey('eliminado_en')) {
      context.handle(
        _eliminadoEnMeta,
        eliminadoEn.isAcceptableOrUnknown(
          data['eliminado_en']!,
          _eliminadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LineaVentaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineaVentaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ventaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}venta_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_id'],
      ),
      marca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marca'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      precioUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_unitario'],
      )!,
      descuento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}descuento'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
      eliminadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}eliminado_en'],
      ),
    );
  }

  @override
  $LineasVentaTable createAlias(String alias) {
    return $LineasVentaTable(attachedDatabase, alias);
  }
}

class LineaVentaRow extends DataClass implements Insertable<LineaVentaRow> {
  final String id;
  final String ventaId;

  /// Producto del inventario del que salen las piezas.
  ///
  /// Nullable porque se permite vender algo que no estaba dado de alta (una
  /// muestra, un regalo de la distribuidora); esa linea simplemente no mueve
  /// existencias.
  final String? productoId;
  final String marca;
  final String codigo;
  final String descripcion;

  /// Piezas vendidas en este renglon.
  final int cantidad;

  /// Precio unitario cobrado al cliente, en centavos.
  final int precioUnitario;

  /// Rebaja aplicada al renglon completo, en centavos.
  final int descuento;
  final int orden;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  final DateTime? eliminadoEn;
  const LineaVentaRow({
    required this.id,
    required this.ventaId,
    this.productoId,
    required this.marca,
    required this.codigo,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.descuento,
    required this.orden,
    required this.creadoEn,
    required this.actualizadoEn,
    this.eliminadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['venta_id'] = Variable<String>(ventaId);
    if (!nullToAbsent || productoId != null) {
      map['producto_id'] = Variable<String>(productoId);
    }
    map['marca'] = Variable<String>(marca);
    map['codigo'] = Variable<String>(codigo);
    map['descripcion'] = Variable<String>(descripcion);
    map['cantidad'] = Variable<int>(cantidad);
    map['precio_unitario'] = Variable<int>(precioUnitario);
    map['descuento'] = Variable<int>(descuento);
    map['orden'] = Variable<int>(orden);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    if (!nullToAbsent || eliminadoEn != null) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn);
    }
    return map;
  }

  LineasVentaCompanion toCompanion(bool nullToAbsent) {
    return LineasVentaCompanion(
      id: Value(id),
      ventaId: Value(ventaId),
      productoId: productoId == null && nullToAbsent
          ? const Value.absent()
          : Value(productoId),
      marca: Value(marca),
      codigo: Value(codigo),
      descripcion: Value(descripcion),
      cantidad: Value(cantidad),
      precioUnitario: Value(precioUnitario),
      descuento: Value(descuento),
      orden: Value(orden),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
      eliminadoEn: eliminadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(eliminadoEn),
    );
  }

  factory LineaVentaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineaVentaRow(
      id: serializer.fromJson<String>(json['id']),
      ventaId: serializer.fromJson<String>(json['ventaId']),
      productoId: serializer.fromJson<String?>(json['productoId']),
      marca: serializer.fromJson<String>(json['marca']),
      codigo: serializer.fromJson<String>(json['codigo']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      precioUnitario: serializer.fromJson<int>(json['precioUnitario']),
      descuento: serializer.fromJson<int>(json['descuento']),
      orden: serializer.fromJson<int>(json['orden']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
      eliminadoEn: serializer.fromJson<DateTime?>(json['eliminadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ventaId': serializer.toJson<String>(ventaId),
      'productoId': serializer.toJson<String?>(productoId),
      'marca': serializer.toJson<String>(marca),
      'codigo': serializer.toJson<String>(codigo),
      'descripcion': serializer.toJson<String>(descripcion),
      'cantidad': serializer.toJson<int>(cantidad),
      'precioUnitario': serializer.toJson<int>(precioUnitario),
      'descuento': serializer.toJson<int>(descuento),
      'orden': serializer.toJson<int>(orden),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
      'eliminadoEn': serializer.toJson<DateTime?>(eliminadoEn),
    };
  }

  LineaVentaRow copyWith({
    String? id,
    String? ventaId,
    Value<String?> productoId = const Value.absent(),
    String? marca,
    String? codigo,
    String? descripcion,
    int? cantidad,
    int? precioUnitario,
    int? descuento,
    int? orden,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
    Value<DateTime?> eliminadoEn = const Value.absent(),
  }) => LineaVentaRow(
    id: id ?? this.id,
    ventaId: ventaId ?? this.ventaId,
    productoId: productoId.present ? productoId.value : this.productoId,
    marca: marca ?? this.marca,
    codigo: codigo ?? this.codigo,
    descripcion: descripcion ?? this.descripcion,
    cantidad: cantidad ?? this.cantidad,
    precioUnitario: precioUnitario ?? this.precioUnitario,
    descuento: descuento ?? this.descuento,
    orden: orden ?? this.orden,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    eliminadoEn: eliminadoEn.present ? eliminadoEn.value : this.eliminadoEn,
  );
  LineaVentaRow copyWithCompanion(LineasVentaCompanion data) {
    return LineaVentaRow(
      id: data.id.present ? data.id.value : this.id,
      ventaId: data.ventaId.present ? data.ventaId.value : this.ventaId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      marca: data.marca.present ? data.marca.value : this.marca,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      descuento: data.descuento.present ? data.descuento.value : this.descuento,
      orden: data.orden.present ? data.orden.value : this.orden,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
      eliminadoEn: data.eliminadoEn.present
          ? data.eliminadoEn.value
          : this.eliminadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineaVentaRow(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('productoId: $productoId, ')
          ..write('marca: $marca, ')
          ..write('codigo: $codigo, ')
          ..write('descripcion: $descripcion, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('descuento: $descuento, ')
          ..write('orden: $orden, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ventaId,
    productoId,
    marca,
    codigo,
    descripcion,
    cantidad,
    precioUnitario,
    descuento,
    orden,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineaVentaRow &&
          other.id == this.id &&
          other.ventaId == this.ventaId &&
          other.productoId == this.productoId &&
          other.marca == this.marca &&
          other.codigo == this.codigo &&
          other.descripcion == this.descripcion &&
          other.cantidad == this.cantidad &&
          other.precioUnitario == this.precioUnitario &&
          other.descuento == this.descuento &&
          other.orden == this.orden &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn &&
          other.eliminadoEn == this.eliminadoEn);
}

class LineasVentaCompanion extends UpdateCompanion<LineaVentaRow> {
  final Value<String> id;
  final Value<String> ventaId;
  final Value<String?> productoId;
  final Value<String> marca;
  final Value<String> codigo;
  final Value<String> descripcion;
  final Value<int> cantidad;
  final Value<int> precioUnitario;
  final Value<int> descuento;
  final Value<int> orden;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  final Value<DateTime?> eliminadoEn;
  final Value<int> rowid;
  const LineasVentaCompanion({
    this.id = const Value.absent(),
    this.ventaId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.marca = const Value.absent(),
    this.codigo = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.descuento = const Value.absent(),
    this.orden = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LineasVentaCompanion.insert({
    required String id,
    required String ventaId,
    this.productoId = const Value.absent(),
    this.marca = const Value.absent(),
    this.codigo = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.descuento = const Value.absent(),
    this.orden = const Value.absent(),
    required DateTime creadoEn,
    required DateTime actualizadoEn,
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ventaId = Value(ventaId),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<LineaVentaRow> custom({
    Expression<String>? id,
    Expression<String>? ventaId,
    Expression<String>? productoId,
    Expression<String>? marca,
    Expression<String>? codigo,
    Expression<String>? descripcion,
    Expression<int>? cantidad,
    Expression<int>? precioUnitario,
    Expression<int>? descuento,
    Expression<int>? orden,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
    Expression<DateTime>? eliminadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ventaId != null) 'venta_id': ventaId,
      if (productoId != null) 'producto_id': productoId,
      if (marca != null) 'marca': marca,
      if (codigo != null) 'codigo': codigo,
      if (descripcion != null) 'descripcion': descripcion,
      if (cantidad != null) 'cantidad': cantidad,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (descuento != null) 'descuento': descuento,
      if (orden != null) 'orden': orden,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (eliminadoEn != null) 'eliminado_en': eliminadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LineasVentaCompanion copyWith({
    Value<String>? id,
    Value<String>? ventaId,
    Value<String?>? productoId,
    Value<String>? marca,
    Value<String>? codigo,
    Value<String>? descripcion,
    Value<int>? cantidad,
    Value<int>? precioUnitario,
    Value<int>? descuento,
    Value<int>? orden,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
    Value<DateTime?>? eliminadoEn,
    Value<int>? rowid,
  }) {
    return LineasVentaCompanion(
      id: id ?? this.id,
      ventaId: ventaId ?? this.ventaId,
      productoId: productoId ?? this.productoId,
      marca: marca ?? this.marca,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      descuento: descuento ?? this.descuento,
      orden: orden ?? this.orden,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      eliminadoEn: eliminadoEn ?? this.eliminadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ventaId.present) {
      map['venta_id'] = Variable<String>(ventaId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (marca.present) {
      map['marca'] = Variable<String>(marca.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<int>(precioUnitario.value);
    }
    if (descuento.present) {
      map['descuento'] = Variable<int>(descuento.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (eliminadoEn.present) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineasVentaCompanion(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('productoId: $productoId, ')
          ..write('marca: $marca, ')
          ..write('codigo: $codigo, ')
          ..write('descripcion: $descripcion, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('descuento: $descuento, ')
          ..write('orden: $orden, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AbonosTable extends Abonos with TableInfo<$AbonosTable, AbonoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AbonosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ventaIdMeta = const VerificationMeta(
    'ventaId',
  );
  @override
  late final GeneratedColumn<String> ventaId = GeneratedColumn<String>(
    'venta_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ventas (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<String> clienteId = GeneratedColumn<String>(
    'cliente_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clientes (id)',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _montoAdeudoMeta = const VerificationMeta(
    'montoAdeudo',
  );
  @override
  late final GeneratedColumn<int> montoAdeudo = GeneratedColumn<int>(
    'monto_adeudo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _eliminadoEnMeta = const VerificationMeta(
    'eliminadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> eliminadoEn = GeneratedColumn<DateTime>(
    'eliminado_en',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ventaId,
    clienteId,
    fecha,
    monto,
    montoAdeudo,
    nota,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'abonos';
  @override
  VerificationContext validateIntegrity(
    Insertable<AbonoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('venta_id')) {
      context.handle(
        _ventaIdMeta,
        ventaId.isAcceptableOrUnknown(data['venta_id']!, _ventaIdMeta),
      );
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    }
    if (data.containsKey('monto_adeudo')) {
      context.handle(
        _montoAdeudoMeta,
        montoAdeudo.isAcceptableOrUnknown(
          data['monto_adeudo']!,
          _montoAdeudoMeta,
        ),
      );
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    if (data.containsKey('eliminado_en')) {
      context.handle(
        _eliminadoEnMeta,
        eliminadoEn.isAcceptableOrUnknown(
          data['eliminado_en']!,
          _eliminadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AbonoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AbonoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ventaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}venta_id'],
      ),
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cliente_id'],
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto'],
      )!,
      montoAdeudo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto_adeudo'],
      )!,
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
      eliminadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}eliminado_en'],
      ),
    );
  }

  @override
  $AbonosTable createAlias(String alias) {
    return $AbonosTable(attachedDatabase, alias);
  }
}

class AbonoRow extends DataClass implements Insertable<AbonoRow> {
  final String id;

  /// Venta cuyo saldo baja con este pago.
  ///
  /// Nullable desde que existen los adeudos: un cliente puede venir a pagar
  /// pura deuda vieja, sin ninguna venta abierta contra la cual aplicar el
  /// pago.
  final String? ventaId;

  /// Quien pago. Obligatorio en la practica cuando [montoAdeudo] es mayor que
  /// cero: sin cliente no habria de que adeudo descontarlo.
  final String? clienteId;
  final DateTime fecha;

  /// Importe total entregado por el cliente, en centavos.
  final int monto;

  /// Cuanto de [monto] se aplico al adeudo del cliente, en centavos.
  ///
  /// La diferencia (`monto - montoAdeudo`) es lo que bajo el saldo de la
  /// venta. Se guarda el reparto y no solo el total porque la propietaria lo
  /// puede mover: la propuesta es tapar primero lo viejo, pero a veces
  /// prefiere abonar a la venta del dia.
  final int montoAdeudo;
  final String nota;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  final DateTime? eliminadoEn;
  const AbonoRow({
    required this.id,
    this.ventaId,
    this.clienteId,
    required this.fecha,
    required this.monto,
    required this.montoAdeudo,
    required this.nota,
    required this.creadoEn,
    required this.actualizadoEn,
    this.eliminadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || ventaId != null) {
      map['venta_id'] = Variable<String>(ventaId);
    }
    if (!nullToAbsent || clienteId != null) {
      map['cliente_id'] = Variable<String>(clienteId);
    }
    map['fecha'] = Variable<DateTime>(fecha);
    map['monto'] = Variable<int>(monto);
    map['monto_adeudo'] = Variable<int>(montoAdeudo);
    map['nota'] = Variable<String>(nota);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    if (!nullToAbsent || eliminadoEn != null) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn);
    }
    return map;
  }

  AbonosCompanion toCompanion(bool nullToAbsent) {
    return AbonosCompanion(
      id: Value(id),
      ventaId: ventaId == null && nullToAbsent
          ? const Value.absent()
          : Value(ventaId),
      clienteId: clienteId == null && nullToAbsent
          ? const Value.absent()
          : Value(clienteId),
      fecha: Value(fecha),
      monto: Value(monto),
      montoAdeudo: Value(montoAdeudo),
      nota: Value(nota),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
      eliminadoEn: eliminadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(eliminadoEn),
    );
  }

  factory AbonoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AbonoRow(
      id: serializer.fromJson<String>(json['id']),
      ventaId: serializer.fromJson<String?>(json['ventaId']),
      clienteId: serializer.fromJson<String?>(json['clienteId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      monto: serializer.fromJson<int>(json['monto']),
      montoAdeudo: serializer.fromJson<int>(json['montoAdeudo']),
      nota: serializer.fromJson<String>(json['nota']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
      eliminadoEn: serializer.fromJson<DateTime?>(json['eliminadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ventaId': serializer.toJson<String?>(ventaId),
      'clienteId': serializer.toJson<String?>(clienteId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'monto': serializer.toJson<int>(monto),
      'montoAdeudo': serializer.toJson<int>(montoAdeudo),
      'nota': serializer.toJson<String>(nota),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
      'eliminadoEn': serializer.toJson<DateTime?>(eliminadoEn),
    };
  }

  AbonoRow copyWith({
    String? id,
    Value<String?> ventaId = const Value.absent(),
    Value<String?> clienteId = const Value.absent(),
    DateTime? fecha,
    int? monto,
    int? montoAdeudo,
    String? nota,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
    Value<DateTime?> eliminadoEn = const Value.absent(),
  }) => AbonoRow(
    id: id ?? this.id,
    ventaId: ventaId.present ? ventaId.value : this.ventaId,
    clienteId: clienteId.present ? clienteId.value : this.clienteId,
    fecha: fecha ?? this.fecha,
    monto: monto ?? this.monto,
    montoAdeudo: montoAdeudo ?? this.montoAdeudo,
    nota: nota ?? this.nota,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    eliminadoEn: eliminadoEn.present ? eliminadoEn.value : this.eliminadoEn,
  );
  AbonoRow copyWithCompanion(AbonosCompanion data) {
    return AbonoRow(
      id: data.id.present ? data.id.value : this.id,
      ventaId: data.ventaId.present ? data.ventaId.value : this.ventaId,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      monto: data.monto.present ? data.monto.value : this.monto,
      montoAdeudo: data.montoAdeudo.present
          ? data.montoAdeudo.value
          : this.montoAdeudo,
      nota: data.nota.present ? data.nota.value : this.nota,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
      eliminadoEn: data.eliminadoEn.present
          ? data.eliminadoEn.value
          : this.eliminadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AbonoRow(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('clienteId: $clienteId, ')
          ..write('fecha: $fecha, ')
          ..write('monto: $monto, ')
          ..write('montoAdeudo: $montoAdeudo, ')
          ..write('nota: $nota, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ventaId,
    clienteId,
    fecha,
    monto,
    montoAdeudo,
    nota,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AbonoRow &&
          other.id == this.id &&
          other.ventaId == this.ventaId &&
          other.clienteId == this.clienteId &&
          other.fecha == this.fecha &&
          other.monto == this.monto &&
          other.montoAdeudo == this.montoAdeudo &&
          other.nota == this.nota &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn &&
          other.eliminadoEn == this.eliminadoEn);
}

class AbonosCompanion extends UpdateCompanion<AbonoRow> {
  final Value<String> id;
  final Value<String?> ventaId;
  final Value<String?> clienteId;
  final Value<DateTime> fecha;
  final Value<int> monto;
  final Value<int> montoAdeudo;
  final Value<String> nota;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  final Value<DateTime?> eliminadoEn;
  final Value<int> rowid;
  const AbonosCompanion({
    this.id = const Value.absent(),
    this.ventaId = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.monto = const Value.absent(),
    this.montoAdeudo = const Value.absent(),
    this.nota = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AbonosCompanion.insert({
    required String id,
    this.ventaId = const Value.absent(),
    this.clienteId = const Value.absent(),
    required DateTime fecha,
    this.monto = const Value.absent(),
    this.montoAdeudo = const Value.absent(),
    this.nota = const Value.absent(),
    required DateTime creadoEn,
    required DateTime actualizadoEn,
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fecha = Value(fecha),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<AbonoRow> custom({
    Expression<String>? id,
    Expression<String>? ventaId,
    Expression<String>? clienteId,
    Expression<DateTime>? fecha,
    Expression<int>? monto,
    Expression<int>? montoAdeudo,
    Expression<String>? nota,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
    Expression<DateTime>? eliminadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ventaId != null) 'venta_id': ventaId,
      if (clienteId != null) 'cliente_id': clienteId,
      if (fecha != null) 'fecha': fecha,
      if (monto != null) 'monto': monto,
      if (montoAdeudo != null) 'monto_adeudo': montoAdeudo,
      if (nota != null) 'nota': nota,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (eliminadoEn != null) 'eliminado_en': eliminadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AbonosCompanion copyWith({
    Value<String>? id,
    Value<String?>? ventaId,
    Value<String?>? clienteId,
    Value<DateTime>? fecha,
    Value<int>? monto,
    Value<int>? montoAdeudo,
    Value<String>? nota,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
    Value<DateTime?>? eliminadoEn,
    Value<int>? rowid,
  }) {
    return AbonosCompanion(
      id: id ?? this.id,
      ventaId: ventaId ?? this.ventaId,
      clienteId: clienteId ?? this.clienteId,
      fecha: fecha ?? this.fecha,
      monto: monto ?? this.monto,
      montoAdeudo: montoAdeudo ?? this.montoAdeudo,
      nota: nota ?? this.nota,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      eliminadoEn: eliminadoEn ?? this.eliminadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ventaId.present) {
      map['venta_id'] = Variable<String>(ventaId.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<String>(clienteId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    if (montoAdeudo.present) {
      map['monto_adeudo'] = Variable<int>(montoAdeudo.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (eliminadoEn.present) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AbonosCompanion(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('clienteId: $clienteId, ')
          ..write('fecha: $fecha, ')
          ..write('monto: $monto, ')
          ..write('montoAdeudo: $montoAdeudo, ')
          ..write('nota: $nota, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdeudosTable extends Adeudos with TableInfo<$AdeudosTable, AdeudoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdeudosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<String> clienteId = GeneratedColumn<String>(
    'cliente_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clientes (id)',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conceptoMeta = const VerificationMeta(
    'concepto',
  );
  @override
  late final GeneratedColumn<String> concepto = GeneratedColumn<String>(
    'concepto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ventaOrigenIdMeta = const VerificationMeta(
    'ventaOrigenId',
  );
  @override
  late final GeneratedColumn<String> ventaOrigenId = GeneratedColumn<String>(
    'venta_origen_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ventas (id)',
    ),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _eliminadoEnMeta = const VerificationMeta(
    'eliminadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> eliminadoEn = GeneratedColumn<DateTime>(
    'eliminado_en',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clienteId,
    fecha,
    concepto,
    monto,
    ventaOrigenId,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adeudos';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdeudoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('concepto')) {
      context.handle(
        _conceptoMeta,
        concepto.isAcceptableOrUnknown(data['concepto']!, _conceptoMeta),
      );
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    }
    if (data.containsKey('venta_origen_id')) {
      context.handle(
        _ventaOrigenIdMeta,
        ventaOrigenId.isAcceptableOrUnknown(
          data['venta_origen_id']!,
          _ventaOrigenIdMeta,
        ),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    if (data.containsKey('eliminado_en')) {
      context.handle(
        _eliminadoEnMeta,
        eliminadoEn.isAcceptableOrUnknown(
          data['eliminado_en']!,
          _eliminadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdeudoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdeudoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cliente_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      concepto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concepto'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto'],
      )!,
      ventaOrigenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}venta_origen_id'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
      eliminadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}eliminado_en'],
      ),
    );
  }

  @override
  $AdeudosTable createAlias(String alias) {
    return $AdeudosTable(attachedDatabase, alias);
  }
}

class AdeudoRow extends DataClass implements Insertable<AdeudoRow> {
  final String id;

  /// De quien es la deuda. Aqui no es nullable: un adeudo sin duenio no se le
  /// puede cobrar a nadie.
  final String clienteId;
  final DateTime fecha;

  /// Que fue lo que se llevo: "productos de la campana 9", "lo de diciembre".
  final String concepto;

  /// Importe del cargo, en centavos. Los pagos no se restan aqui: viven en
  /// [Abonos.montoAdeudo] y el saldo se calcula, nunca se guarda.
  final int monto;

  /// Venta cuyo saldo se traspaso a este cargo, o `null` si se capturo a mano.
  final String? ventaOrigenId;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  final DateTime? eliminadoEn;
  const AdeudoRow({
    required this.id,
    required this.clienteId,
    required this.fecha,
    required this.concepto,
    required this.monto,
    this.ventaOrigenId,
    required this.creadoEn,
    required this.actualizadoEn,
    this.eliminadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cliente_id'] = Variable<String>(clienteId);
    map['fecha'] = Variable<DateTime>(fecha);
    map['concepto'] = Variable<String>(concepto);
    map['monto'] = Variable<int>(monto);
    if (!nullToAbsent || ventaOrigenId != null) {
      map['venta_origen_id'] = Variable<String>(ventaOrigenId);
    }
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    if (!nullToAbsent || eliminadoEn != null) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn);
    }
    return map;
  }

  AdeudosCompanion toCompanion(bool nullToAbsent) {
    return AdeudosCompanion(
      id: Value(id),
      clienteId: Value(clienteId),
      fecha: Value(fecha),
      concepto: Value(concepto),
      monto: Value(monto),
      ventaOrigenId: ventaOrigenId == null && nullToAbsent
          ? const Value.absent()
          : Value(ventaOrigenId),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
      eliminadoEn: eliminadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(eliminadoEn),
    );
  }

  factory AdeudoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdeudoRow(
      id: serializer.fromJson<String>(json['id']),
      clienteId: serializer.fromJson<String>(json['clienteId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      concepto: serializer.fromJson<String>(json['concepto']),
      monto: serializer.fromJson<int>(json['monto']),
      ventaOrigenId: serializer.fromJson<String?>(json['ventaOrigenId']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
      eliminadoEn: serializer.fromJson<DateTime?>(json['eliminadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clienteId': serializer.toJson<String>(clienteId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'concepto': serializer.toJson<String>(concepto),
      'monto': serializer.toJson<int>(monto),
      'ventaOrigenId': serializer.toJson<String?>(ventaOrigenId),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
      'eliminadoEn': serializer.toJson<DateTime?>(eliminadoEn),
    };
  }

  AdeudoRow copyWith({
    String? id,
    String? clienteId,
    DateTime? fecha,
    String? concepto,
    int? monto,
    Value<String?> ventaOrigenId = const Value.absent(),
    DateTime? creadoEn,
    DateTime? actualizadoEn,
    Value<DateTime?> eliminadoEn = const Value.absent(),
  }) => AdeudoRow(
    id: id ?? this.id,
    clienteId: clienteId ?? this.clienteId,
    fecha: fecha ?? this.fecha,
    concepto: concepto ?? this.concepto,
    monto: monto ?? this.monto,
    ventaOrigenId: ventaOrigenId.present
        ? ventaOrigenId.value
        : this.ventaOrigenId,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    eliminadoEn: eliminadoEn.present ? eliminadoEn.value : this.eliminadoEn,
  );
  AdeudoRow copyWithCompanion(AdeudosCompanion data) {
    return AdeudoRow(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      concepto: data.concepto.present ? data.concepto.value : this.concepto,
      monto: data.monto.present ? data.monto.value : this.monto,
      ventaOrigenId: data.ventaOrigenId.present
          ? data.ventaOrigenId.value
          : this.ventaOrigenId,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
      eliminadoEn: data.eliminadoEn.present
          ? data.eliminadoEn.value
          : this.eliminadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdeudoRow(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('fecha: $fecha, ')
          ..write('concepto: $concepto, ')
          ..write('monto: $monto, ')
          ..write('ventaOrigenId: $ventaOrigenId, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clienteId,
    fecha,
    concepto,
    monto,
    ventaOrigenId,
    creadoEn,
    actualizadoEn,
    eliminadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdeudoRow &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.fecha == this.fecha &&
          other.concepto == this.concepto &&
          other.monto == this.monto &&
          other.ventaOrigenId == this.ventaOrigenId &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn &&
          other.eliminadoEn == this.eliminadoEn);
}

class AdeudosCompanion extends UpdateCompanion<AdeudoRow> {
  final Value<String> id;
  final Value<String> clienteId;
  final Value<DateTime> fecha;
  final Value<String> concepto;
  final Value<int> monto;
  final Value<String?> ventaOrigenId;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  final Value<DateTime?> eliminadoEn;
  final Value<int> rowid;
  const AdeudosCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.concepto = const Value.absent(),
    this.monto = const Value.absent(),
    this.ventaOrigenId = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdeudosCompanion.insert({
    required String id,
    required String clienteId,
    required DateTime fecha,
    this.concepto = const Value.absent(),
    this.monto = const Value.absent(),
    this.ventaOrigenId = const Value.absent(),
    required DateTime creadoEn,
    required DateTime actualizadoEn,
    this.eliminadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clienteId = Value(clienteId),
       fecha = Value(fecha),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<AdeudoRow> custom({
    Expression<String>? id,
    Expression<String>? clienteId,
    Expression<DateTime>? fecha,
    Expression<String>? concepto,
    Expression<int>? monto,
    Expression<String>? ventaOrigenId,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
    Expression<DateTime>? eliminadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (fecha != null) 'fecha': fecha,
      if (concepto != null) 'concepto': concepto,
      if (monto != null) 'monto': monto,
      if (ventaOrigenId != null) 'venta_origen_id': ventaOrigenId,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (eliminadoEn != null) 'eliminado_en': eliminadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdeudosCompanion copyWith({
    Value<String>? id,
    Value<String>? clienteId,
    Value<DateTime>? fecha,
    Value<String>? concepto,
    Value<int>? monto,
    Value<String?>? ventaOrigenId,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
    Value<DateTime?>? eliminadoEn,
    Value<int>? rowid,
  }) {
    return AdeudosCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      fecha: fecha ?? this.fecha,
      concepto: concepto ?? this.concepto,
      monto: monto ?? this.monto,
      ventaOrigenId: ventaOrigenId ?? this.ventaOrigenId,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      eliminadoEn: eliminadoEn ?? this.eliminadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<String>(clienteId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (concepto.present) {
      map['concepto'] = Variable<String>(concepto.value);
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    if (ventaOrigenId.present) {
      map['venta_origen_id'] = Variable<String>(ventaOrigenId.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (eliminadoEn.present) {
      map['eliminado_en'] = Variable<DateTime>(eliminadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdeudosCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('fecha: $fecha, ')
          ..write('concepto: $concepto, ')
          ..write('monto: $monto, ')
          ..write('ventaOrigenId: $ventaOrigenId, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('eliminadoEn: $eliminadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PedidosTable pedidos = $PedidosTable(this);
  late final $ProductosTable productos = $ProductosTable(this);
  late final $LineasPedidoTable lineasPedido = $LineasPedidoTable(this);
  late final $ClientesTable clientes = $ClientesTable(this);
  late final $CarpetasVentaTable carpetasVenta = $CarpetasVentaTable(this);
  late final $VentasTable ventas = $VentasTable(this);
  late final $LineasVentaTable lineasVenta = $LineasVentaTable(this);
  late final $AbonosTable abonos = $AbonosTable(this);
  late final $AdeudosTable adeudos = $AdeudosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pedidos,
    productos,
    lineasPedido,
    clientes,
    carpetasVenta,
    ventas,
    lineasVenta,
    abonos,
    adeudos,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pedidos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lineas_pedido', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ventas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lineas_venta', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ventas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('abonos', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PedidosTableCreateCompanionBuilder =
    PedidosCompanion Function({
      required String id,
      required DateTime fecha,
      Value<String> campana,
      Value<String> marcaPredeterminada,
      Value<String> notas,
      Value<bool> cerrado,
      Value<DateTime?> recibidoEn,
      required DateTime creadoEn,
      required DateTime actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });
typedef $$PedidosTableUpdateCompanionBuilder =
    PedidosCompanion Function({
      Value<String> id,
      Value<DateTime> fecha,
      Value<String> campana,
      Value<String> marcaPredeterminada,
      Value<String> notas,
      Value<bool> cerrado,
      Value<DateTime?> recibidoEn,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });

final class $$PedidosTableReferences
    extends BaseReferences<_$AppDatabase, $PedidosTable, PedidoRow> {
  $$PedidosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LineasPedidoTable, List<LineaRow>>
  _lineasPedidoRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lineasPedido,
    aliasName: 'pedidos__id__lineas_pedido__pedido_id',
  );

  $$LineasPedidoTableProcessedTableManager get lineasPedidoRefs {
    final manager = $$LineasPedidoTableTableManager(
      $_db,
      $_db.lineasPedido,
    ).filter((f) => f.pedidoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lineasPedidoRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PedidosTableFilterComposer
    extends Composer<_$AppDatabase, $PedidosTable> {
  $$PedidosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campana => $composableBuilder(
    column: $table.campana,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marcaPredeterminada => $composableBuilder(
    column: $table.marcaPredeterminada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cerrado => $composableBuilder(
    column: $table.cerrado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recibidoEn => $composableBuilder(
    column: $table.recibidoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> lineasPedidoRefs(
    Expression<bool> Function($$LineasPedidoTableFilterComposer f) f,
  ) {
    final $$LineasPedidoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineasPedido,
      getReferencedColumn: (t) => t.pedidoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineasPedidoTableFilterComposer(
            $db: $db,
            $table: $db.lineasPedido,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PedidosTableOrderingComposer
    extends Composer<_$AppDatabase, $PedidosTable> {
  $$PedidosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campana => $composableBuilder(
    column: $table.campana,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marcaPredeterminada => $composableBuilder(
    column: $table.marcaPredeterminada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cerrado => $composableBuilder(
    column: $table.cerrado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recibidoEn => $composableBuilder(
    column: $table.recibidoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PedidosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PedidosTable> {
  $$PedidosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get campana =>
      $composableBuilder(column: $table.campana, builder: (column) => column);

  GeneratedColumn<String> get marcaPredeterminada => $composableBuilder(
    column: $table.marcaPredeterminada,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<bool> get cerrado =>
      $composableBuilder(column: $table.cerrado, builder: (column) => column);

  GeneratedColumn<DateTime> get recibidoEn => $composableBuilder(
    column: $table.recibidoEn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => column,
  );

  Expression<T> lineasPedidoRefs<T extends Object>(
    Expression<T> Function($$LineasPedidoTableAnnotationComposer a) f,
  ) {
    final $$LineasPedidoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineasPedido,
      getReferencedColumn: (t) => t.pedidoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineasPedidoTableAnnotationComposer(
            $db: $db,
            $table: $db.lineasPedido,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PedidosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PedidosTable,
          PedidoRow,
          $$PedidosTableFilterComposer,
          $$PedidosTableOrderingComposer,
          $$PedidosTableAnnotationComposer,
          $$PedidosTableCreateCompanionBuilder,
          $$PedidosTableUpdateCompanionBuilder,
          (PedidoRow, $$PedidosTableReferences),
          PedidoRow,
          PrefetchHooks Function({bool lineasPedidoRefs})
        > {
  $$PedidosTableTableManager(_$AppDatabase db, $PedidosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PedidosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PedidosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PedidosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String> campana = const Value.absent(),
                Value<String> marcaPredeterminada = const Value.absent(),
                Value<String> notas = const Value.absent(),
                Value<bool> cerrado = const Value.absent(),
                Value<DateTime?> recibidoEn = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PedidosCompanion(
                id: id,
                fecha: fecha,
                campana: campana,
                marcaPredeterminada: marcaPredeterminada,
                notas: notas,
                cerrado: cerrado,
                recibidoEn: recibidoEn,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime fecha,
                Value<String> campana = const Value.absent(),
                Value<String> marcaPredeterminada = const Value.absent(),
                Value<String> notas = const Value.absent(),
                Value<bool> cerrado = const Value.absent(),
                Value<DateTime?> recibidoEn = const Value.absent(),
                required DateTime creadoEn,
                required DateTime actualizadoEn,
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PedidosCompanion.insert(
                id: id,
                fecha: fecha,
                campana: campana,
                marcaPredeterminada: marcaPredeterminada,
                notas: notas,
                cerrado: cerrado,
                recibidoEn: recibidoEn,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PedidosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lineasPedidoRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (lineasPedidoRefs) db.lineasPedido],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (lineasPedidoRefs)
                    await $_getPrefetchedData<
                      PedidoRow,
                      $PedidosTable,
                      LineaRow
                    >(
                      currentTable: table,
                      referencedTable: $$PedidosTableReferences
                          ._lineasPedidoRefsTable(db),
                      managerFromTypedResult: (p0) => $$PedidosTableReferences(
                        db,
                        table,
                        p0,
                      ).lineasPedidoRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.pedidoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PedidosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PedidosTable,
      PedidoRow,
      $$PedidosTableFilterComposer,
      $$PedidosTableOrderingComposer,
      $$PedidosTableAnnotationComposer,
      $$PedidosTableCreateCompanionBuilder,
      $$PedidosTableUpdateCompanionBuilder,
      (PedidoRow, $$PedidosTableReferences),
      PedidoRow,
      PrefetchHooks Function({bool lineasPedidoRefs})
    >;
typedef $$ProductosTableCreateCompanionBuilder =
    ProductosCompanion Function({
      required String id,
      Value<String> marca,
      Value<String> codigo,
      Value<String> descripcion,
      Value<int> cantidadActual,
      Value<int> cantidadOriginal,
      required DateTime creadoEn,
      required DateTime actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });
typedef $$ProductosTableUpdateCompanionBuilder =
    ProductosCompanion Function({
      Value<String> id,
      Value<String> marca,
      Value<String> codigo,
      Value<String> descripcion,
      Value<int> cantidadActual,
      Value<int> cantidadOriginal,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });

final class $$ProductosTableReferences
    extends BaseReferences<_$AppDatabase, $ProductosTable, ProductoRow> {
  $$ProductosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LineasPedidoTable, List<LineaRow>>
  _lineasPedidoRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lineasPedido,
    aliasName: 'productos__id__lineas_pedido__producto_id',
  );

  $$LineasPedidoTableProcessedTableManager get lineasPedidoRefs {
    final manager = $$LineasPedidoTableTableManager(
      $_db,
      $_db.lineasPedido,
    ).filter((f) => f.productoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lineasPedidoRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LineasVentaTable, List<LineaVentaRow>>
  _lineasVentaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lineasVenta,
    aliasName: 'productos__id__lineas_venta__producto_id',
  );

  $$LineasVentaTableProcessedTableManager get lineasVentaRefs {
    final manager = $$LineasVentaTableTableManager(
      $_db,
      $_db.lineasVenta,
    ).filter((f) => f.productoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lineasVentaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductosTableFilterComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidadActual => $composableBuilder(
    column: $table.cantidadActual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidadOriginal => $composableBuilder(
    column: $table.cantidadOriginal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> lineasPedidoRefs(
    Expression<bool> Function($$LineasPedidoTableFilterComposer f) f,
  ) {
    final $$LineasPedidoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineasPedido,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineasPedidoTableFilterComposer(
            $db: $db,
            $table: $db.lineasPedido,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lineasVentaRefs(
    Expression<bool> Function($$LineasVentaTableFilterComposer f) f,
  ) {
    final $$LineasVentaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineasVenta,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineasVentaTableFilterComposer(
            $db: $db,
            $table: $db.lineasVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductosTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidadActual => $composableBuilder(
    column: $table.cantidadActual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidadOriginal => $composableBuilder(
    column: $table.cantidadOriginal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get marca =>
      $composableBuilder(column: $table.marca, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidadActual => $composableBuilder(
    column: $table.cantidadActual,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidadOriginal => $composableBuilder(
    column: $table.cantidadOriginal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => column,
  );

  Expression<T> lineasPedidoRefs<T extends Object>(
    Expression<T> Function($$LineasPedidoTableAnnotationComposer a) f,
  ) {
    final $$LineasPedidoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineasPedido,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineasPedidoTableAnnotationComposer(
            $db: $db,
            $table: $db.lineasPedido,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lineasVentaRefs<T extends Object>(
    Expression<T> Function($$LineasVentaTableAnnotationComposer a) f,
  ) {
    final $$LineasVentaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineasVenta,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineasVentaTableAnnotationComposer(
            $db: $db,
            $table: $db.lineasVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductosTable,
          ProductoRow,
          $$ProductosTableFilterComposer,
          $$ProductosTableOrderingComposer,
          $$ProductosTableAnnotationComposer,
          $$ProductosTableCreateCompanionBuilder,
          $$ProductosTableUpdateCompanionBuilder,
          (ProductoRow, $$ProductosTableReferences),
          ProductoRow,
          PrefetchHooks Function({bool lineasPedidoRefs, bool lineasVentaRefs})
        > {
  $$ProductosTableTableManager(_$AppDatabase db, $ProductosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> marca = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<int> cantidadActual = const Value.absent(),
                Value<int> cantidadOriginal = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductosCompanion(
                id: id,
                marca: marca,
                codigo: codigo,
                descripcion: descripcion,
                cantidadActual: cantidadActual,
                cantidadOriginal: cantidadOriginal,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> marca = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<int> cantidadActual = const Value.absent(),
                Value<int> cantidadOriginal = const Value.absent(),
                required DateTime creadoEn,
                required DateTime actualizadoEn,
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductosCompanion.insert(
                id: id,
                marca: marca,
                codigo: codigo,
                descripcion: descripcion,
                cantidadActual: cantidadActual,
                cantidadOriginal: cantidadOriginal,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({lineasPedidoRefs = false, lineasVentaRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lineasPedidoRefs) db.lineasPedido,
                    if (lineasVentaRefs) db.lineasVenta,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lineasPedidoRefs)
                        await $_getPrefetchedData<
                          ProductoRow,
                          $ProductosTable,
                          LineaRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductosTableReferences
                              ._lineasPedidoRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductosTableReferences(
                                db,
                                table,
                                p0,
                              ).lineasPedidoRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lineasVentaRefs)
                        await $_getPrefetchedData<
                          ProductoRow,
                          $ProductosTable,
                          LineaVentaRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductosTableReferences
                              ._lineasVentaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductosTableReferences(
                                db,
                                table,
                                p0,
                              ).lineasVentaRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductosTable,
      ProductoRow,
      $$ProductosTableFilterComposer,
      $$ProductosTableOrderingComposer,
      $$ProductosTableAnnotationComposer,
      $$ProductosTableCreateCompanionBuilder,
      $$ProductosTableUpdateCompanionBuilder,
      (ProductoRow, $$ProductosTableReferences),
      ProductoRow,
      PrefetchHooks Function({bool lineasPedidoRefs, bool lineasVentaRefs})
    >;
typedef $$LineasPedidoTableCreateCompanionBuilder =
    LineasPedidoCompanion Function({
      required String id,
      required String pedidoId,
      Value<String?> productoId,
      Value<String> marca,
      Value<String> codigo,
      Value<String> descripcion,
      Value<int> cantPedida,
      Value<int> cantEnviada,
      Value<int> valorTotalPuntos,
      Value<int> precioUnitario,
      Value<int> precioRevista,
      Value<int> valorTotalPromocionado,
      Value<int> totalDescuentoCn,
      Value<int> valorRegalos,
      Value<int?> valorPromSinIvaManual,
      Value<int?> tuPagasManual,
      Value<int?> precioTotalManual,
      Value<int> orden,
      required DateTime creadoEn,
      required DateTime actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });
typedef $$LineasPedidoTableUpdateCompanionBuilder =
    LineasPedidoCompanion Function({
      Value<String> id,
      Value<String> pedidoId,
      Value<String?> productoId,
      Value<String> marca,
      Value<String> codigo,
      Value<String> descripcion,
      Value<int> cantPedida,
      Value<int> cantEnviada,
      Value<int> valorTotalPuntos,
      Value<int> precioUnitario,
      Value<int> precioRevista,
      Value<int> valorTotalPromocionado,
      Value<int> totalDescuentoCn,
      Value<int> valorRegalos,
      Value<int?> valorPromSinIvaManual,
      Value<int?> tuPagasManual,
      Value<int?> precioTotalManual,
      Value<int> orden,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });

final class $$LineasPedidoTableReferences
    extends BaseReferences<_$AppDatabase, $LineasPedidoTable, LineaRow> {
  $$LineasPedidoTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PedidosTable _pedidoIdTable(_$AppDatabase db) =>
      db.pedidos.createAlias('lineas_pedido__pedido_id__pedidos__id');

  $$PedidosTableProcessedTableManager get pedidoId {
    final $_column = $_itemColumn<String>('pedido_id')!;

    final manager = $$PedidosTableTableManager(
      $_db,
      $_db.pedidos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pedidoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductosTable _productoIdTable(_$AppDatabase db) =>
      db.productos.createAlias('lineas_pedido__producto_id__productos__id');

  $$ProductosTableProcessedTableManager? get productoId {
    final $_column = $_itemColumn<String>('producto_id');
    if ($_column == null) return null;
    final manager = $$ProductosTableTableManager(
      $_db,
      $_db.productos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LineasPedidoTableFilterComposer
    extends Composer<_$AppDatabase, $LineasPedidoTable> {
  $$LineasPedidoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantPedida => $composableBuilder(
    column: $table.cantPedida,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantEnviada => $composableBuilder(
    column: $table.cantEnviada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorTotalPuntos => $composableBuilder(
    column: $table.valorTotalPuntos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precioRevista => $composableBuilder(
    column: $table.precioRevista,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorTotalPromocionado => $composableBuilder(
    column: $table.valorTotalPromocionado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDescuentoCn => $composableBuilder(
    column: $table.totalDescuentoCn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorRegalos => $composableBuilder(
    column: $table.valorRegalos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorPromSinIvaManual => $composableBuilder(
    column: $table.valorPromSinIvaManual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tuPagasManual => $composableBuilder(
    column: $table.tuPagasManual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precioTotalManual => $composableBuilder(
    column: $table.precioTotalManual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$PedidosTableFilterComposer get pedidoId {
    final $$PedidosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedidoId,
      referencedTable: $db.pedidos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedidosTableFilterComposer(
            $db: $db,
            $table: $db.pedidos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableFilterComposer get productoId {
    final $$ProductosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableFilterComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineasPedidoTableOrderingComposer
    extends Composer<_$AppDatabase, $LineasPedidoTable> {
  $$LineasPedidoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantPedida => $composableBuilder(
    column: $table.cantPedida,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantEnviada => $composableBuilder(
    column: $table.cantEnviada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorTotalPuntos => $composableBuilder(
    column: $table.valorTotalPuntos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioRevista => $composableBuilder(
    column: $table.precioRevista,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorTotalPromocionado => $composableBuilder(
    column: $table.valorTotalPromocionado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDescuentoCn => $composableBuilder(
    column: $table.totalDescuentoCn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorRegalos => $composableBuilder(
    column: $table.valorRegalos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorPromSinIvaManual => $composableBuilder(
    column: $table.valorPromSinIvaManual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tuPagasManual => $composableBuilder(
    column: $table.tuPagasManual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioTotalManual => $composableBuilder(
    column: $table.precioTotalManual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$PedidosTableOrderingComposer get pedidoId {
    final $$PedidosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedidoId,
      referencedTable: $db.pedidos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedidosTableOrderingComposer(
            $db: $db,
            $table: $db.pedidos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableOrderingComposer get productoId {
    final $$ProductosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableOrderingComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineasPedidoTableAnnotationComposer
    extends Composer<_$AppDatabase, $LineasPedidoTable> {
  $$LineasPedidoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get marca =>
      $composableBuilder(column: $table.marca, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantPedida => $composableBuilder(
    column: $table.cantPedida,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantEnviada => $composableBuilder(
    column: $table.cantEnviada,
    builder: (column) => column,
  );

  GeneratedColumn<int> get valorTotalPuntos => $composableBuilder(
    column: $table.valorTotalPuntos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => column,
  );

  GeneratedColumn<int> get precioRevista => $composableBuilder(
    column: $table.precioRevista,
    builder: (column) => column,
  );

  GeneratedColumn<int> get valorTotalPromocionado => $composableBuilder(
    column: $table.valorTotalPromocionado,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDescuentoCn => $composableBuilder(
    column: $table.totalDescuentoCn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get valorRegalos => $composableBuilder(
    column: $table.valorRegalos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get valorPromSinIvaManual => $composableBuilder(
    column: $table.valorPromSinIvaManual,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tuPagasManual => $composableBuilder(
    column: $table.tuPagasManual,
    builder: (column) => column,
  );

  GeneratedColumn<int> get precioTotalManual => $composableBuilder(
    column: $table.precioTotalManual,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => column,
  );

  $$PedidosTableAnnotationComposer get pedidoId {
    final $$PedidosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedidoId,
      referencedTable: $db.pedidos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedidosTableAnnotationComposer(
            $db: $db,
            $table: $db.pedidos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableAnnotationComposer get productoId {
    final $$ProductosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableAnnotationComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineasPedidoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LineasPedidoTable,
          LineaRow,
          $$LineasPedidoTableFilterComposer,
          $$LineasPedidoTableOrderingComposer,
          $$LineasPedidoTableAnnotationComposer,
          $$LineasPedidoTableCreateCompanionBuilder,
          $$LineasPedidoTableUpdateCompanionBuilder,
          (LineaRow, $$LineasPedidoTableReferences),
          LineaRow,
          PrefetchHooks Function({bool pedidoId, bool productoId})
        > {
  $$LineasPedidoTableTableManager(_$AppDatabase db, $LineasPedidoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineasPedidoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineasPedidoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineasPedidoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pedidoId = const Value.absent(),
                Value<String?> productoId = const Value.absent(),
                Value<String> marca = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<int> cantPedida = const Value.absent(),
                Value<int> cantEnviada = const Value.absent(),
                Value<int> valorTotalPuntos = const Value.absent(),
                Value<int> precioUnitario = const Value.absent(),
                Value<int> precioRevista = const Value.absent(),
                Value<int> valorTotalPromocionado = const Value.absent(),
                Value<int> totalDescuentoCn = const Value.absent(),
                Value<int> valorRegalos = const Value.absent(),
                Value<int?> valorPromSinIvaManual = const Value.absent(),
                Value<int?> tuPagasManual = const Value.absent(),
                Value<int?> precioTotalManual = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LineasPedidoCompanion(
                id: id,
                pedidoId: pedidoId,
                productoId: productoId,
                marca: marca,
                codigo: codigo,
                descripcion: descripcion,
                cantPedida: cantPedida,
                cantEnviada: cantEnviada,
                valorTotalPuntos: valorTotalPuntos,
                precioUnitario: precioUnitario,
                precioRevista: precioRevista,
                valorTotalPromocionado: valorTotalPromocionado,
                totalDescuentoCn: totalDescuentoCn,
                valorRegalos: valorRegalos,
                valorPromSinIvaManual: valorPromSinIvaManual,
                tuPagasManual: tuPagasManual,
                precioTotalManual: precioTotalManual,
                orden: orden,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pedidoId,
                Value<String?> productoId = const Value.absent(),
                Value<String> marca = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<int> cantPedida = const Value.absent(),
                Value<int> cantEnviada = const Value.absent(),
                Value<int> valorTotalPuntos = const Value.absent(),
                Value<int> precioUnitario = const Value.absent(),
                Value<int> precioRevista = const Value.absent(),
                Value<int> valorTotalPromocionado = const Value.absent(),
                Value<int> totalDescuentoCn = const Value.absent(),
                Value<int> valorRegalos = const Value.absent(),
                Value<int?> valorPromSinIvaManual = const Value.absent(),
                Value<int?> tuPagasManual = const Value.absent(),
                Value<int?> precioTotalManual = const Value.absent(),
                Value<int> orden = const Value.absent(),
                required DateTime creadoEn,
                required DateTime actualizadoEn,
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LineasPedidoCompanion.insert(
                id: id,
                pedidoId: pedidoId,
                productoId: productoId,
                marca: marca,
                codigo: codigo,
                descripcion: descripcion,
                cantPedida: cantPedida,
                cantEnviada: cantEnviada,
                valorTotalPuntos: valorTotalPuntos,
                precioUnitario: precioUnitario,
                precioRevista: precioRevista,
                valorTotalPromocionado: valorTotalPromocionado,
                totalDescuentoCn: totalDescuentoCn,
                valorRegalos: valorRegalos,
                valorPromSinIvaManual: valorPromSinIvaManual,
                tuPagasManual: tuPagasManual,
                precioTotalManual: precioTotalManual,
                orden: orden,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LineasPedidoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pedidoId = false, productoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pedidoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pedidoId,
                                referencedTable: $$LineasPedidoTableReferences
                                    ._pedidoIdTable(db),
                                referencedColumn: $$LineasPedidoTableReferences
                                    ._pedidoIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (productoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productoId,
                                referencedTable: $$LineasPedidoTableReferences
                                    ._productoIdTable(db),
                                referencedColumn: $$LineasPedidoTableReferences
                                    ._productoIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LineasPedidoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LineasPedidoTable,
      LineaRow,
      $$LineasPedidoTableFilterComposer,
      $$LineasPedidoTableOrderingComposer,
      $$LineasPedidoTableAnnotationComposer,
      $$LineasPedidoTableCreateCompanionBuilder,
      $$LineasPedidoTableUpdateCompanionBuilder,
      (LineaRow, $$LineasPedidoTableReferences),
      LineaRow,
      PrefetchHooks Function({bool pedidoId, bool productoId})
    >;
typedef $$ClientesTableCreateCompanionBuilder =
    ClientesCompanion Function({
      required String id,
      Value<String> nombre,
      Value<String> telefono,
      Value<String> direccion,
      Value<String> notas,
      required DateTime creadoEn,
      required DateTime actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });
typedef $$ClientesTableUpdateCompanionBuilder =
    ClientesCompanion Function({
      Value<String> id,
      Value<String> nombre,
      Value<String> telefono,
      Value<String> direccion,
      Value<String> notas,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });

final class $$ClientesTableReferences
    extends BaseReferences<_$AppDatabase, $ClientesTable, ClienteRow> {
  $$ClientesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VentasTable, List<VentaRow>> _ventasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.ventas,
    aliasName: 'clientes__id__ventas__cliente_id',
  );

  $$VentasTableProcessedTableManager get ventasRefs {
    final manager = $$VentasTableTableManager(
      $_db,
      $_db.ventas,
    ).filter((f) => f.clienteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ventasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AbonosTable, List<AbonoRow>> _abonosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.abonos,
    aliasName: 'clientes__id__abonos__cliente_id',
  );

  $$AbonosTableProcessedTableManager get abonosRefs {
    final manager = $$AbonosTableTableManager(
      $_db,
      $_db.abonos,
    ).filter((f) => f.clienteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_abonosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AdeudosTable, List<AdeudoRow>> _adeudosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.adeudos,
    aliasName: 'clientes__id__adeudos__cliente_id',
  );

  $$AdeudosTableProcessedTableManager get adeudosRefs {
    final manager = $$AdeudosTableTableManager(
      $_db,
      $_db.adeudos,
    ).filter((f) => f.clienteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_adeudosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClientesTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ventasRefs(
    Expression<bool> Function($$VentasTableFilterComposer f) f,
  ) {
    final $$VentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableFilterComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> abonosRefs(
    Expression<bool> Function($$AbonosTableFilterComposer f) f,
  ) {
    final $$AbonosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.abonos,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AbonosTableFilterComposer(
            $db: $db,
            $table: $db.abonos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> adeudosRefs(
    Expression<bool> Function($$AdeudosTableFilterComposer f) f,
  ) {
    final $$AdeudosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adeudos,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdeudosTableFilterComposer(
            $db: $db,
            $table: $db.adeudos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => column,
  );

  Expression<T> ventasRefs<T extends Object>(
    Expression<T> Function($$VentasTableAnnotationComposer a) f,
  ) {
    final $$VentasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableAnnotationComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> abonosRefs<T extends Object>(
    Expression<T> Function($$AbonosTableAnnotationComposer a) f,
  ) {
    final $$AbonosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.abonos,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AbonosTableAnnotationComposer(
            $db: $db,
            $table: $db.abonos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> adeudosRefs<T extends Object>(
    Expression<T> Function($$AdeudosTableAnnotationComposer a) f,
  ) {
    final $$AdeudosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adeudos,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdeudosTableAnnotationComposer(
            $db: $db,
            $table: $db.adeudos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientesTable,
          ClienteRow,
          $$ClientesTableFilterComposer,
          $$ClientesTableOrderingComposer,
          $$ClientesTableAnnotationComposer,
          $$ClientesTableCreateCompanionBuilder,
          $$ClientesTableUpdateCompanionBuilder,
          (ClienteRow, $$ClientesTableReferences),
          ClienteRow,
          PrefetchHooks Function({
            bool ventasRefs,
            bool abonosRefs,
            bool adeudosRefs,
          })
        > {
  $$ClientesTableTableManager(_$AppDatabase db, $ClientesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> telefono = const Value.absent(),
                Value<String> direccion = const Value.absent(),
                Value<String> notas = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientesCompanion(
                id: id,
                nombre: nombre,
                telefono: telefono,
                direccion: direccion,
                notas: notas,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> nombre = const Value.absent(),
                Value<String> telefono = const Value.absent(),
                Value<String> direccion = const Value.absent(),
                Value<String> notas = const Value.absent(),
                required DateTime creadoEn,
                required DateTime actualizadoEn,
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientesCompanion.insert(
                id: id,
                nombre: nombre,
                telefono: telefono,
                direccion: direccion,
                notas: notas,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClientesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({ventasRefs = false, abonosRefs = false, adeudosRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ventasRefs) db.ventas,
                    if (abonosRefs) db.abonos,
                    if (adeudosRefs) db.adeudos,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ventasRefs)
                        await $_getPrefetchedData<
                          ClienteRow,
                          $ClientesTable,
                          VentaRow
                        >(
                          currentTable: table,
                          referencedTable: $$ClientesTableReferences
                              ._ventasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientesTableReferences(
                                db,
                                table,
                                p0,
                              ).ventasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clienteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (abonosRefs)
                        await $_getPrefetchedData<
                          ClienteRow,
                          $ClientesTable,
                          AbonoRow
                        >(
                          currentTable: table,
                          referencedTable: $$ClientesTableReferences
                              ._abonosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientesTableReferences(
                                db,
                                table,
                                p0,
                              ).abonosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clienteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (adeudosRefs)
                        await $_getPrefetchedData<
                          ClienteRow,
                          $ClientesTable,
                          AdeudoRow
                        >(
                          currentTable: table,
                          referencedTable: $$ClientesTableReferences
                              ._adeudosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClientesTableReferences(
                                db,
                                table,
                                p0,
                              ).adeudosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clienteId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ClientesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientesTable,
      ClienteRow,
      $$ClientesTableFilterComposer,
      $$ClientesTableOrderingComposer,
      $$ClientesTableAnnotationComposer,
      $$ClientesTableCreateCompanionBuilder,
      $$ClientesTableUpdateCompanionBuilder,
      (ClienteRow, $$ClientesTableReferences),
      ClienteRow,
      PrefetchHooks Function({
        bool ventasRefs,
        bool abonosRefs,
        bool adeudosRefs,
      })
    >;
typedef $$CarpetasVentaTableCreateCompanionBuilder =
    CarpetasVentaCompanion Function({
      required String id,
      Value<String> nombre,
      Value<String> notas,
      required DateTime creadoEn,
      required DateTime actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });
typedef $$CarpetasVentaTableUpdateCompanionBuilder =
    CarpetasVentaCompanion Function({
      Value<String> id,
      Value<String> nombre,
      Value<String> notas,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });

final class $$CarpetasVentaTableReferences
    extends
        BaseReferences<_$AppDatabase, $CarpetasVentaTable, CarpetaVentaRow> {
  $$CarpetasVentaTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$VentasTable, List<VentaRow>> _ventasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.ventas,
    aliasName: 'carpetas_venta__id__ventas__carpeta_id',
  );

  $$VentasTableProcessedTableManager get ventasRefs {
    final manager = $$VentasTableTableManager(
      $_db,
      $_db.ventas,
    ).filter((f) => f.carpetaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ventasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CarpetasVentaTableFilterComposer
    extends Composer<_$AppDatabase, $CarpetasVentaTable> {
  $$CarpetasVentaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ventasRefs(
    Expression<bool> Function($$VentasTableFilterComposer f) f,
  ) {
    final $$VentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.carpetaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableFilterComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CarpetasVentaTableOrderingComposer
    extends Composer<_$AppDatabase, $CarpetasVentaTable> {
  $$CarpetasVentaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CarpetasVentaTableAnnotationComposer
    extends Composer<_$AppDatabase, $CarpetasVentaTable> {
  $$CarpetasVentaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => column,
  );

  Expression<T> ventasRefs<T extends Object>(
    Expression<T> Function($$VentasTableAnnotationComposer a) f,
  ) {
    final $$VentasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.carpetaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableAnnotationComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CarpetasVentaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CarpetasVentaTable,
          CarpetaVentaRow,
          $$CarpetasVentaTableFilterComposer,
          $$CarpetasVentaTableOrderingComposer,
          $$CarpetasVentaTableAnnotationComposer,
          $$CarpetasVentaTableCreateCompanionBuilder,
          $$CarpetasVentaTableUpdateCompanionBuilder,
          (CarpetaVentaRow, $$CarpetasVentaTableReferences),
          CarpetaVentaRow,
          PrefetchHooks Function({bool ventasRefs})
        > {
  $$CarpetasVentaTableTableManager(_$AppDatabase db, $CarpetasVentaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CarpetasVentaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CarpetasVentaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CarpetasVentaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> notas = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CarpetasVentaCompanion(
                id: id,
                nombre: nombre,
                notas: notas,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> nombre = const Value.absent(),
                Value<String> notas = const Value.absent(),
                required DateTime creadoEn,
                required DateTime actualizadoEn,
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CarpetasVentaCompanion.insert(
                id: id,
                nombre: nombre,
                notas: notas,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CarpetasVentaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ventasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ventasRefs) db.ventas],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ventasRefs)
                    await $_getPrefetchedData<
                      CarpetaVentaRow,
                      $CarpetasVentaTable,
                      VentaRow
                    >(
                      currentTable: table,
                      referencedTable: $$CarpetasVentaTableReferences
                          ._ventasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CarpetasVentaTableReferences(
                            db,
                            table,
                            p0,
                          ).ventasRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.carpetaId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CarpetasVentaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CarpetasVentaTable,
      CarpetaVentaRow,
      $$CarpetasVentaTableFilterComposer,
      $$CarpetasVentaTableOrderingComposer,
      $$CarpetasVentaTableAnnotationComposer,
      $$CarpetasVentaTableCreateCompanionBuilder,
      $$CarpetasVentaTableUpdateCompanionBuilder,
      (CarpetaVentaRow, $$CarpetasVentaTableReferences),
      CarpetaVentaRow,
      PrefetchHooks Function({bool ventasRefs})
    >;
typedef $$VentasTableCreateCompanionBuilder =
    VentasCompanion Function({
      required String id,
      required DateTime fecha,
      Value<String?> clienteId,
      Value<String> cliente,
      Value<String?> carpetaId,
      Value<String> notas,
      Value<String> estado,
      Value<DateTime?> entregadaEn,
      required DateTime creadoEn,
      required DateTime actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });
typedef $$VentasTableUpdateCompanionBuilder =
    VentasCompanion Function({
      Value<String> id,
      Value<DateTime> fecha,
      Value<String?> clienteId,
      Value<String> cliente,
      Value<String?> carpetaId,
      Value<String> notas,
      Value<String> estado,
      Value<DateTime?> entregadaEn,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });

final class $$VentasTableReferences
    extends BaseReferences<_$AppDatabase, $VentasTable, VentaRow> {
  $$VentasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientesTable _clienteIdTable(_$AppDatabase db) =>
      db.clientes.createAlias('ventas__cliente_id__clientes__id');

  $$ClientesTableProcessedTableManager? get clienteId {
    final $_column = $_itemColumn<String>('cliente_id');
    if ($_column == null) return null;
    final manager = $$ClientesTableTableManager(
      $_db,
      $_db.clientes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clienteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CarpetasVentaTable _carpetaIdTable(_$AppDatabase db) =>
      db.carpetasVenta.createAlias('ventas__carpeta_id__carpetas_venta__id');

  $$CarpetasVentaTableProcessedTableManager? get carpetaId {
    final $_column = $_itemColumn<String>('carpeta_id');
    if ($_column == null) return null;
    final manager = $$CarpetasVentaTableTableManager(
      $_db,
      $_db.carpetasVenta,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_carpetaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LineasVentaTable, List<LineaVentaRow>>
  _lineasVentaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lineasVenta,
    aliasName: 'ventas__id__lineas_venta__venta_id',
  );

  $$LineasVentaTableProcessedTableManager get lineasVentaRefs {
    final manager = $$LineasVentaTableTableManager(
      $_db,
      $_db.lineasVenta,
    ).filter((f) => f.ventaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lineasVentaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AbonosTable, List<AbonoRow>> _abonosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.abonos,
    aliasName: 'ventas__id__abonos__venta_id',
  );

  $$AbonosTableProcessedTableManager get abonosRefs {
    final manager = $$AbonosTableTableManager(
      $_db,
      $_db.abonos,
    ).filter((f) => f.ventaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_abonosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AdeudosTable, List<AdeudoRow>> _adeudosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.adeudos,
    aliasName: 'ventas__id__adeudos__venta_origen_id',
  );

  $$AdeudosTableProcessedTableManager get adeudosRefs {
    final manager = $$AdeudosTableTableManager(
      $_db,
      $_db.adeudos,
    ).filter((f) => f.ventaOrigenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_adeudosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VentasTableFilterComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cliente => $composableBuilder(
    column: $table.cliente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entregadaEn => $composableBuilder(
    column: $table.entregadaEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientesTableFilterComposer get clienteId {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableFilterComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CarpetasVentaTableFilterComposer get carpetaId {
    final $$CarpetasVentaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carpetaId,
      referencedTable: $db.carpetasVenta,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarpetasVentaTableFilterComposer(
            $db: $db,
            $table: $db.carpetasVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> lineasVentaRefs(
    Expression<bool> Function($$LineasVentaTableFilterComposer f) f,
  ) {
    final $$LineasVentaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineasVenta,
      getReferencedColumn: (t) => t.ventaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineasVentaTableFilterComposer(
            $db: $db,
            $table: $db.lineasVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> abonosRefs(
    Expression<bool> Function($$AbonosTableFilterComposer f) f,
  ) {
    final $$AbonosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.abonos,
      getReferencedColumn: (t) => t.ventaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AbonosTableFilterComposer(
            $db: $db,
            $table: $db.abonos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> adeudosRefs(
    Expression<bool> Function($$AdeudosTableFilterComposer f) f,
  ) {
    final $$AdeudosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adeudos,
      getReferencedColumn: (t) => t.ventaOrigenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdeudosTableFilterComposer(
            $db: $db,
            $table: $db.adeudos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VentasTableOrderingComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cliente => $composableBuilder(
    column: $table.cliente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entregadaEn => $composableBuilder(
    column: $table.entregadaEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientesTableOrderingComposer get clienteId {
    final $$ClientesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableOrderingComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CarpetasVentaTableOrderingComposer get carpetaId {
    final $$CarpetasVentaTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carpetaId,
      referencedTable: $db.carpetasVenta,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarpetasVentaTableOrderingComposer(
            $db: $db,
            $table: $db.carpetasVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VentasTableAnnotationComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get cliente =>
      $composableBuilder(column: $table.cliente, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get entregadaEn => $composableBuilder(
    column: $table.entregadaEn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => column,
  );

  $$ClientesTableAnnotationComposer get clienteId {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableAnnotationComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CarpetasVentaTableAnnotationComposer get carpetaId {
    final $$CarpetasVentaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carpetaId,
      referencedTable: $db.carpetasVenta,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarpetasVentaTableAnnotationComposer(
            $db: $db,
            $table: $db.carpetasVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> lineasVentaRefs<T extends Object>(
    Expression<T> Function($$LineasVentaTableAnnotationComposer a) f,
  ) {
    final $$LineasVentaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineasVenta,
      getReferencedColumn: (t) => t.ventaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineasVentaTableAnnotationComposer(
            $db: $db,
            $table: $db.lineasVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> abonosRefs<T extends Object>(
    Expression<T> Function($$AbonosTableAnnotationComposer a) f,
  ) {
    final $$AbonosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.abonos,
      getReferencedColumn: (t) => t.ventaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AbonosTableAnnotationComposer(
            $db: $db,
            $table: $db.abonos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> adeudosRefs<T extends Object>(
    Expression<T> Function($$AdeudosTableAnnotationComposer a) f,
  ) {
    final $$AdeudosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adeudos,
      getReferencedColumn: (t) => t.ventaOrigenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdeudosTableAnnotationComposer(
            $db: $db,
            $table: $db.adeudos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VentasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VentasTable,
          VentaRow,
          $$VentasTableFilterComposer,
          $$VentasTableOrderingComposer,
          $$VentasTableAnnotationComposer,
          $$VentasTableCreateCompanionBuilder,
          $$VentasTableUpdateCompanionBuilder,
          (VentaRow, $$VentasTableReferences),
          VentaRow,
          PrefetchHooks Function({
            bool clienteId,
            bool carpetaId,
            bool lineasVentaRefs,
            bool abonosRefs,
            bool adeudosRefs,
          })
        > {
  $$VentasTableTableManager(_$AppDatabase db, $VentasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String?> clienteId = const Value.absent(),
                Value<String> cliente = const Value.absent(),
                Value<String?> carpetaId = const Value.absent(),
                Value<String> notas = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<DateTime?> entregadaEn = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VentasCompanion(
                id: id,
                fecha: fecha,
                clienteId: clienteId,
                cliente: cliente,
                carpetaId: carpetaId,
                notas: notas,
                estado: estado,
                entregadaEn: entregadaEn,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime fecha,
                Value<String?> clienteId = const Value.absent(),
                Value<String> cliente = const Value.absent(),
                Value<String?> carpetaId = const Value.absent(),
                Value<String> notas = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<DateTime?> entregadaEn = const Value.absent(),
                required DateTime creadoEn,
                required DateTime actualizadoEn,
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VentasCompanion.insert(
                id: id,
                fecha: fecha,
                clienteId: clienteId,
                cliente: cliente,
                carpetaId: carpetaId,
                notas: notas,
                estado: estado,
                entregadaEn: entregadaEn,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$VentasTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                clienteId = false,
                carpetaId = false,
                lineasVentaRefs = false,
                abonosRefs = false,
                adeudosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lineasVentaRefs) db.lineasVenta,
                    if (abonosRefs) db.abonos,
                    if (adeudosRefs) db.adeudos,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (clienteId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.clienteId,
                                    referencedTable: $$VentasTableReferences
                                        ._clienteIdTable(db),
                                    referencedColumn: $$VentasTableReferences
                                        ._clienteIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (carpetaId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.carpetaId,
                                    referencedTable: $$VentasTableReferences
                                        ._carpetaIdTable(db),
                                    referencedColumn: $$VentasTableReferences
                                        ._carpetaIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lineasVentaRefs)
                        await $_getPrefetchedData<
                          VentaRow,
                          $VentasTable,
                          LineaVentaRow
                        >(
                          currentTable: table,
                          referencedTable: $$VentasTableReferences
                              ._lineasVentaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VentasTableReferences(
                                db,
                                table,
                                p0,
                              ).lineasVentaRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ventaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (abonosRefs)
                        await $_getPrefetchedData<
                          VentaRow,
                          $VentasTable,
                          AbonoRow
                        >(
                          currentTable: table,
                          referencedTable: $$VentasTableReferences
                              ._abonosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VentasTableReferences(db, table, p0).abonosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ventaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (adeudosRefs)
                        await $_getPrefetchedData<
                          VentaRow,
                          $VentasTable,
                          AdeudoRow
                        >(
                          currentTable: table,
                          referencedTable: $$VentasTableReferences
                              ._adeudosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VentasTableReferences(
                                db,
                                table,
                                p0,
                              ).adeudosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ventaOrigenId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VentasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VentasTable,
      VentaRow,
      $$VentasTableFilterComposer,
      $$VentasTableOrderingComposer,
      $$VentasTableAnnotationComposer,
      $$VentasTableCreateCompanionBuilder,
      $$VentasTableUpdateCompanionBuilder,
      (VentaRow, $$VentasTableReferences),
      VentaRow,
      PrefetchHooks Function({
        bool clienteId,
        bool carpetaId,
        bool lineasVentaRefs,
        bool abonosRefs,
        bool adeudosRefs,
      })
    >;
typedef $$LineasVentaTableCreateCompanionBuilder =
    LineasVentaCompanion Function({
      required String id,
      required String ventaId,
      Value<String?> productoId,
      Value<String> marca,
      Value<String> codigo,
      Value<String> descripcion,
      Value<int> cantidad,
      Value<int> precioUnitario,
      Value<int> descuento,
      Value<int> orden,
      required DateTime creadoEn,
      required DateTime actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });
typedef $$LineasVentaTableUpdateCompanionBuilder =
    LineasVentaCompanion Function({
      Value<String> id,
      Value<String> ventaId,
      Value<String?> productoId,
      Value<String> marca,
      Value<String> codigo,
      Value<String> descripcion,
      Value<int> cantidad,
      Value<int> precioUnitario,
      Value<int> descuento,
      Value<int> orden,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });

final class $$LineasVentaTableReferences
    extends BaseReferences<_$AppDatabase, $LineasVentaTable, LineaVentaRow> {
  $$LineasVentaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VentasTable _ventaIdTable(_$AppDatabase db) =>
      db.ventas.createAlias('lineas_venta__venta_id__ventas__id');

  $$VentasTableProcessedTableManager get ventaId {
    final $_column = $_itemColumn<String>('venta_id')!;

    final manager = $$VentasTableTableManager(
      $_db,
      $_db.ventas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ventaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductosTable _productoIdTable(_$AppDatabase db) =>
      db.productos.createAlias('lineas_venta__producto_id__productos__id');

  $$ProductosTableProcessedTableManager? get productoId {
    final $_column = $_itemColumn<String>('producto_id');
    if ($_column == null) return null;
    final manager = $$ProductosTableTableManager(
      $_db,
      $_db.productos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LineasVentaTableFilterComposer
    extends Composer<_$AppDatabase, $LineasVentaTable> {
  $$LineasVentaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get descuento => $composableBuilder(
    column: $table.descuento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$VentasTableFilterComposer get ventaId {
    final $$VentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableFilterComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableFilterComposer get productoId {
    final $$ProductosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableFilterComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineasVentaTableOrderingComposer
    extends Composer<_$AppDatabase, $LineasVentaTable> {
  $$LineasVentaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get descuento => $composableBuilder(
    column: $table.descuento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$VentasTableOrderingComposer get ventaId {
    final $$VentasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableOrderingComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableOrderingComposer get productoId {
    final $$ProductosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableOrderingComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineasVentaTableAnnotationComposer
    extends Composer<_$AppDatabase, $LineasVentaTable> {
  $$LineasVentaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get marca =>
      $composableBuilder(column: $table.marca, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<int> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => column,
  );

  GeneratedColumn<int> get descuento =>
      $composableBuilder(column: $table.descuento, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => column,
  );

  $$VentasTableAnnotationComposer get ventaId {
    final $$VentasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableAnnotationComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableAnnotationComposer get productoId {
    final $$ProductosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableAnnotationComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineasVentaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LineasVentaTable,
          LineaVentaRow,
          $$LineasVentaTableFilterComposer,
          $$LineasVentaTableOrderingComposer,
          $$LineasVentaTableAnnotationComposer,
          $$LineasVentaTableCreateCompanionBuilder,
          $$LineasVentaTableUpdateCompanionBuilder,
          (LineaVentaRow, $$LineasVentaTableReferences),
          LineaVentaRow,
          PrefetchHooks Function({bool ventaId, bool productoId})
        > {
  $$LineasVentaTableTableManager(_$AppDatabase db, $LineasVentaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineasVentaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineasVentaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineasVentaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ventaId = const Value.absent(),
                Value<String?> productoId = const Value.absent(),
                Value<String> marca = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<int> precioUnitario = const Value.absent(),
                Value<int> descuento = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LineasVentaCompanion(
                id: id,
                ventaId: ventaId,
                productoId: productoId,
                marca: marca,
                codigo: codigo,
                descripcion: descripcion,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
                descuento: descuento,
                orden: orden,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ventaId,
                Value<String?> productoId = const Value.absent(),
                Value<String> marca = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<int> precioUnitario = const Value.absent(),
                Value<int> descuento = const Value.absent(),
                Value<int> orden = const Value.absent(),
                required DateTime creadoEn,
                required DateTime actualizadoEn,
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LineasVentaCompanion.insert(
                id: id,
                ventaId: ventaId,
                productoId: productoId,
                marca: marca,
                codigo: codigo,
                descripcion: descripcion,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
                descuento: descuento,
                orden: orden,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LineasVentaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ventaId = false, productoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ventaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ventaId,
                                referencedTable: $$LineasVentaTableReferences
                                    ._ventaIdTable(db),
                                referencedColumn: $$LineasVentaTableReferences
                                    ._ventaIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (productoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productoId,
                                referencedTable: $$LineasVentaTableReferences
                                    ._productoIdTable(db),
                                referencedColumn: $$LineasVentaTableReferences
                                    ._productoIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LineasVentaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LineasVentaTable,
      LineaVentaRow,
      $$LineasVentaTableFilterComposer,
      $$LineasVentaTableOrderingComposer,
      $$LineasVentaTableAnnotationComposer,
      $$LineasVentaTableCreateCompanionBuilder,
      $$LineasVentaTableUpdateCompanionBuilder,
      (LineaVentaRow, $$LineasVentaTableReferences),
      LineaVentaRow,
      PrefetchHooks Function({bool ventaId, bool productoId})
    >;
typedef $$AbonosTableCreateCompanionBuilder =
    AbonosCompanion Function({
      required String id,
      Value<String?> ventaId,
      Value<String?> clienteId,
      required DateTime fecha,
      Value<int> monto,
      Value<int> montoAdeudo,
      Value<String> nota,
      required DateTime creadoEn,
      required DateTime actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });
typedef $$AbonosTableUpdateCompanionBuilder =
    AbonosCompanion Function({
      Value<String> id,
      Value<String?> ventaId,
      Value<String?> clienteId,
      Value<DateTime> fecha,
      Value<int> monto,
      Value<int> montoAdeudo,
      Value<String> nota,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });

final class $$AbonosTableReferences
    extends BaseReferences<_$AppDatabase, $AbonosTable, AbonoRow> {
  $$AbonosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VentasTable _ventaIdTable(_$AppDatabase db) =>
      db.ventas.createAlias('abonos__venta_id__ventas__id');

  $$VentasTableProcessedTableManager? get ventaId {
    final $_column = $_itemColumn<String>('venta_id');
    if ($_column == null) return null;
    final manager = $$VentasTableTableManager(
      $_db,
      $_db.ventas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ventaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ClientesTable _clienteIdTable(_$AppDatabase db) =>
      db.clientes.createAlias('abonos__cliente_id__clientes__id');

  $$ClientesTableProcessedTableManager? get clienteId {
    final $_column = $_itemColumn<String>('cliente_id');
    if ($_column == null) return null;
    final manager = $$ClientesTableTableManager(
      $_db,
      $_db.clientes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clienteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AbonosTableFilterComposer
    extends Composer<_$AppDatabase, $AbonosTable> {
  $$AbonosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get montoAdeudo => $composableBuilder(
    column: $table.montoAdeudo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$VentasTableFilterComposer get ventaId {
    final $$VentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableFilterComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClientesTableFilterComposer get clienteId {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableFilterComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AbonosTableOrderingComposer
    extends Composer<_$AppDatabase, $AbonosTable> {
  $$AbonosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get montoAdeudo => $composableBuilder(
    column: $table.montoAdeudo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$VentasTableOrderingComposer get ventaId {
    final $$VentasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableOrderingComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClientesTableOrderingComposer get clienteId {
    final $$ClientesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableOrderingComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AbonosTableAnnotationComposer
    extends Composer<_$AppDatabase, $AbonosTable> {
  $$AbonosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<int> get montoAdeudo => $composableBuilder(
    column: $table.montoAdeudo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => column,
  );

  $$VentasTableAnnotationComposer get ventaId {
    final $$VentasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableAnnotationComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClientesTableAnnotationComposer get clienteId {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableAnnotationComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AbonosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AbonosTable,
          AbonoRow,
          $$AbonosTableFilterComposer,
          $$AbonosTableOrderingComposer,
          $$AbonosTableAnnotationComposer,
          $$AbonosTableCreateCompanionBuilder,
          $$AbonosTableUpdateCompanionBuilder,
          (AbonoRow, $$AbonosTableReferences),
          AbonoRow,
          PrefetchHooks Function({bool ventaId, bool clienteId})
        > {
  $$AbonosTableTableManager(_$AppDatabase db, $AbonosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AbonosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AbonosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AbonosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> ventaId = const Value.absent(),
                Value<String?> clienteId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> monto = const Value.absent(),
                Value<int> montoAdeudo = const Value.absent(),
                Value<String> nota = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AbonosCompanion(
                id: id,
                ventaId: ventaId,
                clienteId: clienteId,
                fecha: fecha,
                monto: monto,
                montoAdeudo: montoAdeudo,
                nota: nota,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> ventaId = const Value.absent(),
                Value<String?> clienteId = const Value.absent(),
                required DateTime fecha,
                Value<int> monto = const Value.absent(),
                Value<int> montoAdeudo = const Value.absent(),
                Value<String> nota = const Value.absent(),
                required DateTime creadoEn,
                required DateTime actualizadoEn,
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AbonosCompanion.insert(
                id: id,
                ventaId: ventaId,
                clienteId: clienteId,
                fecha: fecha,
                monto: monto,
                montoAdeudo: montoAdeudo,
                nota: nota,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AbonosTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({ventaId = false, clienteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ventaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ventaId,
                                referencedTable: $$AbonosTableReferences
                                    ._ventaIdTable(db),
                                referencedColumn: $$AbonosTableReferences
                                    ._ventaIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (clienteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.clienteId,
                                referencedTable: $$AbonosTableReferences
                                    ._clienteIdTable(db),
                                referencedColumn: $$AbonosTableReferences
                                    ._clienteIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AbonosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AbonosTable,
      AbonoRow,
      $$AbonosTableFilterComposer,
      $$AbonosTableOrderingComposer,
      $$AbonosTableAnnotationComposer,
      $$AbonosTableCreateCompanionBuilder,
      $$AbonosTableUpdateCompanionBuilder,
      (AbonoRow, $$AbonosTableReferences),
      AbonoRow,
      PrefetchHooks Function({bool ventaId, bool clienteId})
    >;
typedef $$AdeudosTableCreateCompanionBuilder =
    AdeudosCompanion Function({
      required String id,
      required String clienteId,
      required DateTime fecha,
      Value<String> concepto,
      Value<int> monto,
      Value<String?> ventaOrigenId,
      required DateTime creadoEn,
      required DateTime actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });
typedef $$AdeudosTableUpdateCompanionBuilder =
    AdeudosCompanion Function({
      Value<String> id,
      Value<String> clienteId,
      Value<DateTime> fecha,
      Value<String> concepto,
      Value<int> monto,
      Value<String?> ventaOrigenId,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
      Value<DateTime?> eliminadoEn,
      Value<int> rowid,
    });

final class $$AdeudosTableReferences
    extends BaseReferences<_$AppDatabase, $AdeudosTable, AdeudoRow> {
  $$AdeudosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientesTable _clienteIdTable(_$AppDatabase db) =>
      db.clientes.createAlias('adeudos__cliente_id__clientes__id');

  $$ClientesTableProcessedTableManager get clienteId {
    final $_column = $_itemColumn<String>('cliente_id')!;

    final manager = $$ClientesTableTableManager(
      $_db,
      $_db.clientes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clienteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VentasTable _ventaOrigenIdTable(_$AppDatabase db) =>
      db.ventas.createAlias('adeudos__venta_origen_id__ventas__id');

  $$VentasTableProcessedTableManager? get ventaOrigenId {
    final $_column = $_itemColumn<String>('venta_origen_id');
    if ($_column == null) return null;
    final manager = $$VentasTableTableManager(
      $_db,
      $_db.ventas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ventaOrigenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AdeudosTableFilterComposer
    extends Composer<_$AppDatabase, $AdeudosTable> {
  $$AdeudosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientesTableFilterComposer get clienteId {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableFilterComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VentasTableFilterComposer get ventaOrigenId {
    final $$VentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaOrigenId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableFilterComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdeudosTableOrderingComposer
    extends Composer<_$AppDatabase, $AdeudosTable> {
  $$AdeudosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientesTableOrderingComposer get clienteId {
    final $$ClientesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableOrderingComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VentasTableOrderingComposer get ventaOrigenId {
    final $$VentasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaOrigenId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableOrderingComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdeudosTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdeudosTable> {
  $$AdeudosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get concepto =>
      $composableBuilder(column: $table.concepto, builder: (column) => column);

  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eliminadoEn => $composableBuilder(
    column: $table.eliminadoEn,
    builder: (column) => column,
  );

  $$ClientesTableAnnotationComposer get clienteId {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableAnnotationComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VentasTableAnnotationComposer get ventaOrigenId {
    final $$VentasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaOrigenId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableAnnotationComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdeudosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdeudosTable,
          AdeudoRow,
          $$AdeudosTableFilterComposer,
          $$AdeudosTableOrderingComposer,
          $$AdeudosTableAnnotationComposer,
          $$AdeudosTableCreateCompanionBuilder,
          $$AdeudosTableUpdateCompanionBuilder,
          (AdeudoRow, $$AdeudosTableReferences),
          AdeudoRow,
          PrefetchHooks Function({bool clienteId, bool ventaOrigenId})
        > {
  $$AdeudosTableTableManager(_$AppDatabase db, $AdeudosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdeudosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdeudosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdeudosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clienteId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String> concepto = const Value.absent(),
                Value<int> monto = const Value.absent(),
                Value<String?> ventaOrigenId = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdeudosCompanion(
                id: id,
                clienteId: clienteId,
                fecha: fecha,
                concepto: concepto,
                monto: monto,
                ventaOrigenId: ventaOrigenId,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clienteId,
                required DateTime fecha,
                Value<String> concepto = const Value.absent(),
                Value<int> monto = const Value.absent(),
                Value<String?> ventaOrigenId = const Value.absent(),
                required DateTime creadoEn,
                required DateTime actualizadoEn,
                Value<DateTime?> eliminadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdeudosCompanion.insert(
                id: id,
                clienteId: clienteId,
                fecha: fecha,
                concepto: concepto,
                monto: monto,
                ventaOrigenId: ventaOrigenId,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                eliminadoEn: eliminadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AdeudosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clienteId = false, ventaOrigenId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (clienteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.clienteId,
                                referencedTable: $$AdeudosTableReferences
                                    ._clienteIdTable(db),
                                referencedColumn: $$AdeudosTableReferences
                                    ._clienteIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (ventaOrigenId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ventaOrigenId,
                                referencedTable: $$AdeudosTableReferences
                                    ._ventaOrigenIdTable(db),
                                referencedColumn: $$AdeudosTableReferences
                                    ._ventaOrigenIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AdeudosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdeudosTable,
      AdeudoRow,
      $$AdeudosTableFilterComposer,
      $$AdeudosTableOrderingComposer,
      $$AdeudosTableAnnotationComposer,
      $$AdeudosTableCreateCompanionBuilder,
      $$AdeudosTableUpdateCompanionBuilder,
      (AdeudoRow, $$AdeudosTableReferences),
      AdeudoRow,
      PrefetchHooks Function({bool clienteId, bool ventaOrigenId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PedidosTableTableManager get pedidos =>
      $$PedidosTableTableManager(_db, _db.pedidos);
  $$ProductosTableTableManager get productos =>
      $$ProductosTableTableManager(_db, _db.productos);
  $$LineasPedidoTableTableManager get lineasPedido =>
      $$LineasPedidoTableTableManager(_db, _db.lineasPedido);
  $$ClientesTableTableManager get clientes =>
      $$ClientesTableTableManager(_db, _db.clientes);
  $$CarpetasVentaTableTableManager get carpetasVenta =>
      $$CarpetasVentaTableTableManager(_db, _db.carpetasVenta);
  $$VentasTableTableManager get ventas =>
      $$VentasTableTableManager(_db, _db.ventas);
  $$LineasVentaTableTableManager get lineasVenta =>
      $$LineasVentaTableTableManager(_db, _db.lineasVenta);
  $$AbonosTableTableManager get abonos =>
      $$AbonosTableTableManager(_db, _db.abonos);
  $$AdeudosTableTableManager get adeudos =>
      $$AdeudosTableTableManager(_db, _db.adeudos);
}
