import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/storage/audio_cache.dart';
import '../core/sync/sync_provider.dart';
import '../db/database.dart';

enum DownloadStatus { idle, downloading, done, error }

class DownloadState {
  final Map<String, DownloadStatus> statuses;
  const DownloadState({this.statuses = const {}});

  DownloadStatus statusFor(String storyId) => statuses[storyId] ?? DownloadStatus.idle;

  DownloadState copyWith(String storyId, DownloadStatus status) {
    return DownloadState(statuses: {...statuses, storyId: status});
  }
}

final downloadProvider = StateNotifierProvider<DownloadNotifier, DownloadState>((ref) {
  return DownloadNotifier(ref.read(apiClientProvider), ref.read(databaseProvider));
});

class DownloadNotifier extends StateNotifier<DownloadState> {
  final Dio _dio;
  final AppDatabase _db;

  DownloadNotifier(this._dio, this._db) : super(const DownloadState());

  Future<void> download(String storyId) async {
    state = state.copyWith(storyId, DownloadStatus.downloading);
    try {
      await AudioCache.download(_dio, storyId);
      await _db.storyDao.markAudioDownloaded(storyId, true);
      state = state.copyWith(storyId, DownloadStatus.done);
    } catch (_) {
      state = state.copyWith(storyId, DownloadStatus.error);
    }
  }

  Future<void> downloadMultiple(List<String> storyIds) async {
    for (final id in storyIds) {
      await download(id);
    }
  }

  Future<void> deleteDownload(String storyId) async {
    await AudioCache.delete(storyId);
    await _db.storyDao.markAudioDownloaded(storyId, false);
    state = state.copyWith(storyId, DownloadStatus.idle);
  }
}
