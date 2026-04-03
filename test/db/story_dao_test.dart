import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cuentitos/db/database.dart';
import 'package:drift/drift.dart' hide isNotNull;

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('upsert and retrieve a story', () async {
    final dao = db.storyDao;
    await dao.upsertStory(StoriesCompanion.insert(
      id: 'story-1',
      childId: 'child-1',
      storyDate: DateTime(2026, 4, 2),
      title: const Value('El dragon amigable'),
      bodyText: const Value('Habia una vez...'),
      generationStatus: const Value('generated'),
      deliveryStatus: const Value('sent'),
      createdAt: DateTime.now(),
    ));
    final story = await dao.getStoryById('story-1');
    expect(story, isNotNull);
    expect(story!.title, 'El dragon amigable');
  });

  test('search stories by title', () async {
    final dao = db.storyDao;
    await dao.upsertStory(StoriesCompanion.insert(
      id: 'story-1', childId: 'child-1', storyDate: DateTime(2026, 4, 1),
      title: const Value('El dragon amigable'), bodyText: const Value('text'), createdAt: DateTime.now(),
    ));
    await dao.upsertStory(StoriesCompanion.insert(
      id: 'story-2', childId: 'child-1', storyDate: DateTime(2026, 4, 2),
      title: const Value('La princesa valiente'), bodyText: const Value('text'), createdAt: DateTime.now(),
    ));
    final results = await dao.getAllStories(searchQuery: 'dragon');
    expect(results.length, 1);
    expect(results.first.id, 'story-1');
  });

  test('toggle favorite', () async {
    final dao = db.storyDao;
    await dao.upsertStory(StoriesCompanion.insert(
      id: 'story-1', childId: 'child-1', storyDate: DateTime(2026, 4, 1),
      title: const Value('Test'), bodyText: const Value('text'), createdAt: DateTime.now(),
    ));
    await dao.toggleFavorite('story-1', true);
    final favs = await dao.getFavorites();
    expect(favs.length, 1);
  });
}
