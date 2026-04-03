import 'dart:async';
import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import '../api/endpoints.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  Completer<String>? _refreshCompleter;

  // Separate Dio for refresh calls — no interceptor attached, avoids re-entry
  late final Dio _refreshDio = Dio(BaseOptions(
    baseUrl: Endpoints.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Don't try to refresh if the failing request IS the refresh endpoint
    if (err.requestOptions.path == Endpoints.refresh) {
      handler.next(err);
      return;
    }

    try {
      final newToken = await _refreshToken();
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';
      final retryResponse = await _dio.fetch(opts);
      handler.resolve(retryResponse);
    } catch (_) {
      await SecureStorage.clear();
      handler.next(err);
    }
  }

  Future<String> _refreshToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String>();
    try {
      final oldToken = await SecureStorage.getToken();
      if (oldToken == null) throw Exception('No token');

      // Use _refreshDio (no interceptor) to avoid re-entry
      final response = await _refreshDio.post(
        Endpoints.refresh,
        data: {'token': oldToken},
      );
      final newToken = response.data['token'] as String?;
      final expiresAt = response.data['expiresAt'] as String?;
      if (newToken == null || expiresAt == null) throw Exception('Invalid refresh response');
      await SecureStorage.saveToken(newToken, expiresAt);

      _refreshCompleter!.complete(newToken);
      return newToken;
    } catch (e) {
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }
}
