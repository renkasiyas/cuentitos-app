import 'package:drift/drift.dart';

class Playlists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isAuto => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
