import 'dart:async';
import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import '../api/endpoints.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  Completer<String>? _refreshCompleter;

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

    try {
      final newToken = await _refreshToken();
      // Retry original request with new token
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
    // If already refreshing, wait for the existing refresh
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String>();
    try {
      final oldToken = await SecureStorage.getToken();
      if (oldToken == null) throw Exception('No token');

      final response = await _dio.post(
        '${Endpoints.baseUrl}${Endpoints.refresh}',
        data: {'token': oldToken},
        options: Options(headers: {}),
      );
      final newToken = response.data['token'] as String;
      final expiresAt = response.data['expiresAt'] as String;
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
