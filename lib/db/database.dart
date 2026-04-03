import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/stories.dart';
import 'tables/child_profile.dart';
import 'tables/playlists.dart';
import 'tables/playlist_stories.dart';
import 'tables/pending_actions.dart';
import 'daos/story_dao.dart';
import 'daos/playlist_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Stories, ChildProfiles, Playlists, PlaylistStoryEntries, PendingActions],
  daos: [StoryDao, PlaylistDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cuentitos.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
