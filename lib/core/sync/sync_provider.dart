import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../db/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final syncProvider = Provider<SyncService>((ref) {
  return SyncService(ref.read(apiClientProvider), ref.read(databaseProvider));
});

class SyncService {
  final Dio _dio;
  final AppDatabase _db;

  SyncService(this._dio, this._db);

  Future<void> syncStories() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString('lastSyncTimestamp');

    final queryParams = <String, dynamic>{'limit': '100'};
    if (lastSync != null) queryParams['since'] = lastSync;

    final response = await _dio.get(Endpoints.stories, queryParameters: queryParams);
    final List<dynamic> storiesJson = response.data['stories'] as List<dynamic>;

    final companions = storiesJson.map((s) => StoriesCompanion(
      id: Value(s['id'] as String),
      childId: Value(s['childId'] as String),
      storyDate: Value(DateTime.parse(s['storyDate'] as String)),
      title: Value(s['title'] as String?),
      bodyText: Value(s['bodyText'] as String?),
      audioUrl: Value(s['audioUrl'] as String?),
      themeTags: Value(s['themeTags'] != null ? jsonEncode(s['themeTags']) : null),
      generationStatus: Value(s['generationStatus'] as String? ?? 'pending'),
      deliveryStatus: Value(s['deliveryStatus'] as String? ?? 'pending'),
      deliveredAt: Value(s['deliveredAt'] != null ? DateTime.parse(s['deliveredAt'] as String) : null),
      createdAt: Value(DateTime.parse(s['createdAt'] as String)),
    )).toList();

    await _db.storyDao.upsertStories(companions);
    await prefs.setString('lastSyncTimestamp', DateTime.now().toUtc().toIso8601String());
  }

  Future<void> syncProfile() async {
    final response = await _dio.get(Endpoints.me);
    final child = response.data['child'];
    if (child != null) {
      await _db.into(_db.childProfiles).insertOnConflictUpdate(ChildProfilesCompanion(
        id: Value(child['id'] as String),
        name: Value(child['name'] as String),
        birthdate: Value(child['birthdate'] as String),
        gender: Value(child['gender'] as String),
        favoriteAnimal: Value(child['favoriteAnimal'] as String),
        favoriteColor: Value(child['favoriteColor'] as String),
        otherInterests: Value(child['otherInterests'] != null ? jsonEncode(child['otherInterests']) : null),
      ));
    }
  }

  Future<void> syncPlaylists() async {
    final response = await _dio.get(Endpoints.playlists);
    final List<dynamic> playlistsJson = response.data['playlists'] as List<dynamic>;
    for (final p in playlistsJson) {
      await _db.playlistDao.upsertPlaylist(PlaylistsCompanion(
        id: Value(p['id'] as String),
        name: Value(p['name'] as String),
        createdAt: Value(DateTime.parse(p['createdAt'] as String)),
      ));
    }
  }

  Future<void> fullSync() async {
    await syncProfile();
    await syncStories();
    await syncPlaylists();
  }
}
