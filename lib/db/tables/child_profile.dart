import 'package:drift/drift.dart';

class ChildProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get birthdate => text()(); // YYYY-MM-DD
  TextColumn get gender => text()(); // "nino" | "nina"
  TextColumn get favoriteAnimal => text()();
  TextColumn get favoriteColor => text()();
  TextColumn get otherInterests => text().nullable()(); // JSON-encoded string[]

  @override
  Set<Column> get primaryKey => {id};
}
