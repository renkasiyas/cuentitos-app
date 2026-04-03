import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/playlists.dart';
import '../tables/playlist_stories.dart';
import '../tables/stories.dart';

part 'playlist_dao.g.dart';

@DriftAccessor(tables: [Playlists, PlaylistStoryEntries, Stories])
class PlaylistDao extends DatabaseAccessor<AppDatabase> with _$PlaylistDaoMixin {
  PlaylistDao(super.db);

  Future<List<Playlist>> getAllPlaylists() =>
    (select(playlists)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();

  Future<void> upsertPlaylist(PlaylistsCompanion playlist) =>
    into(playlists).insertOnConflictUpdate(playlist);

  Future<void> deletePlaylist(String id) =>
    (delete(playlists)..where((t) => t.id.equals(id))).go();

  Future<List<Story>> getPlaylistStories(String playlistId) {
    final query = select(stories).join([
      innerJoin(playlistStoryEntries, playlistStoryEntries.storyId.equalsExp(stories.id)),
    ])
      ..where(playlistStoryEntries.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(playlistStoryEntries.position)]);
    return query.map((row) => row.readTable(stories)).get();
  }

  Future<void> setPlaylistStories(String playlistId, List<String> storyIds) async {
    await (delete(playlistStoryEntries)..where((t) => t.playlistId.equals(playlistId))).go();
    await batch((b) {
      for (var i = 0; i < storyIds.length; i++) {
        b.insert(playlistStoryEntries, PlaylistStoryEntriesCompanion.insert(
          playlistId: playlistId, storyId: storyIds[i], position: i,
        ));
      }
    });
  }

  Future<int> getStoryCount(String playlistId) async {
    final count = countAll();
    final query = selectOnly(playlistStoryEntries)
      ..addColumns([count])
      ..where(playlistStoryEntries.playlistId.equals(playlistId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
