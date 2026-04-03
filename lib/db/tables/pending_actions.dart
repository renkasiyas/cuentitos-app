import 'package:drift/drift.dart';

class PendingActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionType => text()();
  TextColumn get payload => text()(); // JSON
  DateTimeColumn get createdAt => dateTime()();
}
