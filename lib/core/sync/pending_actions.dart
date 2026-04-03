import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../../core/api/endpoints.dart';
import '../../db/database.dart';

class PendingActionsService {
  final Dio _dio;
  final AppDatabase _db;

  PendingActionsService(this._dio, this._db);

  Future<void> enqueue(String actionType, Map<String, dynamic> payload) async {
    await _db.into(_db.pendingActions).insert(PendingActionsCompanion.insert(
      actionType: actionType,
      payload: jsonEncode(payload),
      createdAt: DateTime.now(),
    ));
  }

  Future<void> flushAll() async {
    final actions = await (_db.select(_db.pendingActions)
      ..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

    for (final action in actions) {
      try {
        await _executeAction(action.actionType, jsonDecode(action.payload) as Map<String, dynamic>);
        await (_db.delete(_db.pendingActions)..where((t) => t.id.equals(action.id))).go();
      } catch (e) {
        break; // Stop on first failure
      }
    }
  }

  Future<void> _executeAction(String type, Map<String, dynamic> payload) async {
    switch (type) {
      case 'profile_edit':
        await _dio.patch(Endpoints.childrenUpdate, data: payload);
      case 'delivery_time':
        await _dio.post(Endpoints.deliveryTime, data: payload);
      case 'phone_update':
        await _dio.patch(Endpoints.parentUpdate, data: payload);
      case 'tier_change':
        await _dio.post(Endpoints.tier, data: payload);
      case 'playlist_create':
        await _dio.post(Endpoints.playlists, data: payload);
      case 'playlist_update':
        final id = payload.remove('id') as String;
        await _dio.patch(Endpoints.playlist(id), data: payload);
      case 'playlist_delete':
        await _dio.delete(Endpoints.playlist(payload['id'] as String));
    }
  }
}
