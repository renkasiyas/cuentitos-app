import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/sync/sync_provider.dart';
import '../db/database.dart';

final storiesProvider = FutureProvider.family<List<Story>, StoryFilter>((ref, filter) async {
  final db = ref.read(databaseProvider);
  return db.storyDao.getAllStories(searchQuery: filter.searchQuery, themeFilter: filter.themeFilter);
});

final todayStoryProvider = StreamProvider<Story?>((ref) {
  final db = ref.read(databaseProvider);
  final child = ref.watch(childProfileProvider).value;
  if (child == null) return Stream.value(null);
  return db.storyDao.watchTodayStory(child.id);
});

final childProfileProvider = FutureProvider<ChildProfile?>((ref) async {
  final db = ref.read(databaseProvider);
  final rows = await db.select(db.childProfiles).get();
  return rows.isEmpty ? null : rows.first;
});

class StoryFilter {
  final String? searchQuery;
  final String? themeFilter;
  const StoryFilter({this.searchQuery, this.themeFilter});

  @override
  bool operator ==(Object other) =>
      other is StoryFilter && other.searchQuery == searchQuery && other.themeFilter == themeFilter;

  @override
  int get hashCode => Object.hash(searchQuery, themeFilter);
}
