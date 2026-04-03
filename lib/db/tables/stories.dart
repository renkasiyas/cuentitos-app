import 'package:drift/drift.dart';

class Stories extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text()();
  DateTimeColumn get storyDate => dateTime()();
  TextColumn get title => text().nullable()();
  TextColumn get bodyText => text().nullable()();
  TextColumn get audioUrl => text().nullable()();
  TextColumn get themeTags => text().nullable()(); // JSON-encoded string[]
  TextColumn get generationStatus => text().withDefault(const Constant('pending'))();
  TextColumn get deliveryStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get deliveredAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get audioDownloaded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
