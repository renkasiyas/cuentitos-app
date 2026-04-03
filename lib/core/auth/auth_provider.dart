import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../storage/secure_storage.dart';

enum AuthState { unknown, authenticated, unauthenticated }

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiClientProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;

  AuthNotifier(this._dio) : super(AuthState.unknown) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      state = AuthState.unauthenticated;
      return;
    }
    final expired = await SecureStorage.isTokenExpired();
    if (expired) {
      try {
        final response = await _dio.post(Endpoints.refresh, data: {'token': token});
        final newToken = response.data['token'] as String?;
        final expiresAt = response.data['expiresAt'] as String?;
        if (newToken == null || expiresAt == null) {
          await SecureStorage.clear();
          state = AuthState.unauthenticated;
          return;
        }
        await SecureStorage.saveToken(newToken, expiresAt);
        state = AuthState.authenticated;
      } catch (_) {
        await SecureStorage.clear();
        state = AuthState.unauthenticated;
      }
    } else {
      state = AuthState.authenticated;
    }
  }

  Future<bool> loginWithEmail(String email) async {
    try {
      await _dio.post(Endpoints.login, data: {'method': 'email', 'email': email});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> verifyMagicLink(String code, String email) async {
    try {
      final response = await _dio.post(Endpoints.verify, data: {'code': code, 'email': email});
      final token = response.data['token'] as String?;
      final expiresAt = response.data['expiresAt'] as String?;
      if (token == null || expiresAt == null) return false;
      await SecureStorage.saveToken(token, expiresAt);
      state = AuthState.authenticated;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post(Endpoints.login, data: {'method': 'google', 'idToken': idToken});
      final token = response.data['token'] as String?;
      final expiresAt = response.data['expiresAt'] as String?;
      if (token == null || expiresAt == null) return false;
      await SecureStorage.saveToken(token, expiresAt);
      state = AuthState.authenticated;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await SecureStorage.clear();
    state = AuthState.unauthenticated;
  }
}
