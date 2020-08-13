// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onexbetDataBase.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class User extends DataClass implements Insertable<User> {
  final int id;
  final String numero;
  final String email;
  User({@required this.id, @required this.numero, this.email});
  factory User.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return User(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      numero:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}numero']),
      email:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}email']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || numero != null) {
      map['numero'] = Variable<String>(numero);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      numero:
          numero == null && nullToAbsent ? const Value.absent() : Value(numero),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      numero: serializer.fromJson<String>(json['numero']),
      email: serializer.fromJson<String>(json['email']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'numero': serializer.toJson<String>(numero),
      'email': serializer.toJson<String>(email),
    };
  }

  User copyWith({int id, String numero, String email}) => User(
        id: id ?? this.id,
        numero: numero ?? this.numero,
        email: email ?? this.email,
      );
  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('email: $email')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      $mrjf($mrjc(id.hashCode, $mrjc(numero.hashCode, email.hashCode)));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.numero == this.numero &&
          other.email == this.email);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> numero;
  final Value<String> email;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.numero = const Value.absent(),
    this.email = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    @required String numero,
    this.email = const Value.absent(),
  }) : numero = Value(numero);
  static Insertable<User> custom({
    Expression<int> id,
    Expression<String> numero,
    Expression<String> email,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (numero != null) 'numero': numero,
      if (email != null) 'email': email,
    });
  }

  UsersCompanion copyWith(
      {Value<int> id, Value<String> numero, Value<String> email}) {
    return UsersCompanion(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      email: email ?? this.email,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (numero.present) {
      map['numero'] = Variable<String>(numero.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('email: $email')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  final GeneratedDatabase _db;
  final String _alias;
  $UsersTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _numeroMeta = const VerificationMeta('numero');
  GeneratedTextColumn _numero;
  @override
  GeneratedTextColumn get numero => _numero ??= _constructNumero();
  GeneratedTextColumn _constructNumero() {
    return GeneratedTextColumn('numero', $tableName, false,
        minTextLength: 1, maxTextLength: 191);
  }

  final VerificationMeta _emailMeta = const VerificationMeta('email');
  GeneratedTextColumn _email;
  @override
  GeneratedTextColumn get email => _email ??= _constructEmail();
  GeneratedTextColumn _constructEmail() {
    return GeneratedTextColumn(
      'email',
      $tableName,
      true,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [id, numero, email];
  @override
  $UsersTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'users';
  @override
  final String actualTableName = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    if (data.containsKey('numero')) {
      context.handle(_numeroMeta,
          numero.isAcceptableOrUnknown(data['numero'], _numeroMeta));
    } else if (isInserting) {
      context.missing(_numeroMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email'], _emailMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return User.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(_db, alias);
  }
}

class Transfert extends DataClass implements Insertable<Transfert> {
  final int id;
  final String documentID;
  final String type;
  final String numero;
  Transfert(
      {@required this.id, @required this.documentID, this.type, this.numero});
  factory Transfert.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return Transfert(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      documentID: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}document_i_d']),
      type: stringType.mapFromDatabaseResponse(data['${effectivePrefix}type']),
      numero:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}numero']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || documentID != null) {
      map['document_i_d'] = Variable<String>(documentID);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || numero != null) {
      map['numero'] = Variable<String>(numero);
    }
    return map;
  }

  TransfertsCompanion toCompanion(bool nullToAbsent) {
    return TransfertsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      documentID: documentID == null && nullToAbsent
          ? const Value.absent()
          : Value(documentID),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      numero:
          numero == null && nullToAbsent ? const Value.absent() : Value(numero),
    );
  }

  factory Transfert.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Transfert(
      id: serializer.fromJson<int>(json['id']),
      documentID: serializer.fromJson<String>(json['documentID']),
      type: serializer.fromJson<String>(json['type']),
      numero: serializer.fromJson<String>(json['numero']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'documentID': serializer.toJson<String>(documentID),
      'type': serializer.toJson<String>(type),
      'numero': serializer.toJson<String>(numero),
    };
  }

  Transfert copyWith({int id, String documentID, String type, String numero}) =>
      Transfert(
        id: id ?? this.id,
        documentID: documentID ?? this.documentID,
        type: type ?? this.type,
        numero: numero ?? this.numero,
      );
  @override
  String toString() {
    return (StringBuffer('Transfert(')
          ..write('id: $id, ')
          ..write('documentID: $documentID, ')
          ..write('type: $type, ')
          ..write('numero: $numero')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(id.hashCode,
      $mrjc(documentID.hashCode, $mrjc(type.hashCode, numero.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Transfert &&
          other.id == this.id &&
          other.documentID == this.documentID &&
          other.type == this.type &&
          other.numero == this.numero);
}

class TransfertsCompanion extends UpdateCompanion<Transfert> {
  final Value<int> id;
  final Value<String> documentID;
  final Value<String> type;
  final Value<String> numero;
  const TransfertsCompanion({
    this.id = const Value.absent(),
    this.documentID = const Value.absent(),
    this.type = const Value.absent(),
    this.numero = const Value.absent(),
  });
  TransfertsCompanion.insert({
    this.id = const Value.absent(),
    @required String documentID,
    this.type = const Value.absent(),
    this.numero = const Value.absent(),
  }) : documentID = Value(documentID);
  static Insertable<Transfert> custom({
    Expression<int> id,
    Expression<String> documentID,
    Expression<String> type,
    Expression<String> numero,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentID != null) 'document_i_d': documentID,
      if (type != null) 'type': type,
      if (numero != null) 'numero': numero,
    });
  }

  TransfertsCompanion copyWith(
      {Value<int> id,
      Value<String> documentID,
      Value<String> type,
      Value<String> numero}) {
    return TransfertsCompanion(
      id: id ?? this.id,
      documentID: documentID ?? this.documentID,
      type: type ?? this.type,
      numero: numero ?? this.numero,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (documentID.present) {
      map['document_i_d'] = Variable<String>(documentID.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (numero.present) {
      map['numero'] = Variable<String>(numero.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransfertsCompanion(')
          ..write('id: $id, ')
          ..write('documentID: $documentID, ')
          ..write('type: $type, ')
          ..write('numero: $numero')
          ..write(')'))
        .toString();
  }
}

class $TransfertsTable extends Transferts
    with TableInfo<$TransfertsTable, Transfert> {
  final GeneratedDatabase _db;
  final String _alias;
  $TransfertsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _documentIDMeta = const VerificationMeta('documentID');
  GeneratedTextColumn _documentID;
  @override
  GeneratedTextColumn get documentID => _documentID ??= _constructDocumentID();
  GeneratedTextColumn _constructDocumentID() {
    return GeneratedTextColumn('document_i_d', $tableName, false,
        minTextLength: 1, maxTextLength: 191);
  }

  final VerificationMeta _typeMeta = const VerificationMeta('type');
  GeneratedTextColumn _type;
  @override
  GeneratedTextColumn get type => _type ??= _constructType();
  GeneratedTextColumn _constructType() {
    return GeneratedTextColumn('type', $tableName, true,
        minTextLength: 1, maxTextLength: 50);
  }

  final VerificationMeta _numeroMeta = const VerificationMeta('numero');
  GeneratedTextColumn _numero;
  @override
  GeneratedTextColumn get numero => _numero ??= _constructNumero();
  GeneratedTextColumn _constructNumero() {
    return GeneratedTextColumn('numero', $tableName, true,
        minTextLength: 1, maxTextLength: 50);
  }

  @override
  List<GeneratedColumn> get $columns => [id, documentID, type, numero];
  @override
  $TransfertsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'transferts';
  @override
  final String actualTableName = 'transferts';
  @override
  VerificationContext validateIntegrity(Insertable<Transfert> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    if (data.containsKey('document_i_d')) {
      context.handle(
          _documentIDMeta,
          documentID.isAcceptableOrUnknown(
              data['document_i_d'], _documentIDMeta));
    } else if (isInserting) {
      context.missing(_documentIDMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type'], _typeMeta));
    }
    if (data.containsKey('numero')) {
      context.handle(_numeroMeta,
          numero.isAcceptableOrUnknown(data['numero'], _numeroMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transfert map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Transfert.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $TransfertsTable createAlias(String alias) {
    return $TransfertsTable(_db, alias);
  }
}

abstract class _$OnexbetDataBase extends GeneratedDatabase {
  _$OnexbetDataBase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $UsersTable _users;
  $UsersTable get users => _users ??= $UsersTable(this);
  $TransfertsTable _transferts;
  $TransfertsTable get transferts => _transferts ??= $TransfertsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [users, transferts];
}
