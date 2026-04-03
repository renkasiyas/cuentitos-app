import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../api/endpoints.dart';

class AudioCache {
  static Future<String> get _cacheDir async {
    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(dir.path, 'audio'));
    if (!audioDir.existsSync()) audioDir.createSync(recursive: true);
    return audioDir.path;
  }

  static Future<String> filePath(String storyId) async {
    final dir = await _cacheDir;
    return p.join(dir, '$storyId.mp3');
  }

  static Future<bool> exists(String storyId) async {
    final path = await filePath(storyId);
    return File(path).existsSync();
  }

  static Future<String> download(Dio dio, String storyId) async {
    final path = await filePath(storyId);
    final url = '${Endpoints.baseUrl}${Endpoints.storyAudio(storyId)}';
    await dio.download(url, path);
    return path;
  }

  static Future<void> delete(String storyId) async {
    final path = await filePath(storyId);
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }

  static Future<int> totalSizeBytes() async {
    final dir = await _cacheDir;
    final audioDir = Directory(dir);
    if (!audioDir.existsSync()) return 0;
    int total = 0;
    await for (final entity in audioDir.list()) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }

  static Future<int> fileCount() async {
    final dir = await _cacheDir;
    final audioDir = Directory(dir);
    if (!audioDir.existsSync()) return 0;
    return audioDir.listSync().whereType<File>().length;
  }

  static Future<void> clearAll() async {
    final dir = await _cacheDir;
    final audioDir = Directory(dir);
    if (audioDir.existsSync()) await audioDir.delete(recursive: true);
  }

  static Future<void> pruneOlderThan(Duration age) async {
    final dir = await _cacheDir;
    final audioDir = Directory(dir);
    if (!audioDir.existsSync()) return;
    final cutoff = DateTime.now().subtract(age);
    await for (final entity in audioDir.list()) {
      if (entity is File) {
        final stat = await entity.stat();
        if (stat.modified.isBefore(cutoff)) await entity.delete();
      }
    }
  }
}
