import 'package:drift/drift.dart';

class PlaylistStoryEntries extends Table {
  TextColumn get playlistId => text()();
  TextColumn get storyId => text()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, storyId};
}
