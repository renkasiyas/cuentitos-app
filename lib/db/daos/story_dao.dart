import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/stories.dart';

part 'story_dao.g.dart';

@DriftAccessor(tables: [Stories])
class StoryDao extends DatabaseAccessor<AppDatabase> with _$StoryDaoMixin {
  StoryDao(super.db);

  Future<List<Story>> getAllStories({String? searchQuery, String? themeFilter}) {
    final query = select(stories)..orderBy([(t) => OrderingTerm.desc(t.storyDate)]);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((t) =>
        t.title.like('%$searchQuery%') | t.bodyText.like('%$searchQuery%') | t.themeTags.like('%$searchQuery%'));
    }
    if (themeFilter != null) {
      query.where((t) => t.themeTags.like('%$themeFilter%'));
    }
    return query.get();
  }

  Future<Story?> getStoryById(String id) =>
    (select(stories)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Story?> getTodayStory(String childId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(stories)
      ..where((t) => t.childId.equals(childId) &
        t.storyDate.isBiggerOrEqualValue(startOfDay) &
        t.storyDate.isSmallerThanValue(endOfDay))
    ).getSingleOrNull();
  }

  Future<List<Story>> getFavorites() =>
    (select(stories)..where((t) => t.isFavorite.equals(true))
      ..orderBy([(t) => OrderingTerm.desc(t.storyDate)])).get();

  Future<List<Story>> getDownloaded() =>
    (select(stories)..where((t) => t.audioDownloaded.equals(true))
      ..orderBy([(t) => OrderingTerm.desc(t.storyDate)])).get();

  Future<void> upsertStory(StoriesCompanion story) =>
    into(stories).insertOnConflictUpdate(story);

  Future<void> upsertStories(List<StoriesCompanion> storyList) async {
    await batch((b) {
      for (final story in storyList) {
        b.insert(stories, story, onConflict: DoUpdate((old) => story));
      }
    });
  }

  Future<void> toggleFavorite(String id, bool favorite) =>
    (update(stories)..where((t) => t.id.equals(id)))
      .write(StoriesCompanion(isFavorite: Value(favorite)));

  Future<void> markAudioDownloaded(String id, bool downloaded) =>
    (update(stories)..where((t) => t.id.equals(id)))
      .write(StoriesCompanion(audioDownloaded: Value(downloaded)));

  Stream<Story?> watchTodayStory(String childId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(stories)
      ..where((t) => t.childId.equals(childId) &
        t.storyDate.isBiggerOrEqualValue(startOfDay) &
        t.storyDate.isSmallerThanValue(endOfDay))
    ).watchSingleOrNull();
  }
}
