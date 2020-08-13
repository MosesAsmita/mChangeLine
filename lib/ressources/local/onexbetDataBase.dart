import 'dart:io';
import 'package:moor/moor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path/path.dart' as p;
part 'onexbetDataBase.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get numero => text().withLength(min: 1, max: 191)();
  TextColumn get email => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Transferts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get documentID => text().withLength(min: 1, max: 191)();
  TextColumn get type => text().withLength(min: 1, max: 50).nullable()();
  TextColumn get numero => text().withLength(min: 1, max: 50).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}


LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return VmDatabase(file);
  });
}

@UseMoor(tables: [
  Users,
  Transferts
])
class OnexbetDataBase extends _$OnexbetDataBase {
  OnexbetDataBase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (Migrator m) {
    return m.createAll();
  }, onUpgrade: (Migrator m, int from, int to) async {
    if (from == 1) {}
  });

  //Users
  Future<List<User>> getAllUsers() => select(users).get();
  Stream<List<User>> get watchAllUsers => select(users).watch();
  Future insertUsers(User user) =>
      into(users).insert(user);
  Future updateUsers(User user) =>
      update(users).replace(user);
  Future deleteCategories(User user) =>
      delete(users).delete(user);

  //Transaction
  Future<List<Transfert>> getAllTransferts() => select(transferts).get();
  Stream<List<Transfert>> get watchAllTransferts => select(transferts).watch();
  Future insertTransferts(Transfert transfert) =>
      into(transferts).insert(transfert);
  Future updateTransferts(Transfert transfert) =>
      update(transferts).replace(transfert);
  Future deleteTransferts(Transfert transfert) =>
      delete(transferts).delete(transfert);


}
