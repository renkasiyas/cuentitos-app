import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../storage/secure_storage.dart';

enum UserState { unknown, anonymous, lead, onboarding, unpaid, active, pastDue, canceled }

final userStateProvider = StateNotifierProvider<UserStateNotifier, UserState>((ref) {
  return UserStateNotifier(ref.read(apiClientProvider));
});

class UserStateNotifier extends StateNotifier<UserState> {
  final Dio _dio;

  UserStateNotifier(this._dio) : super(UserState.unknown) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      state = UserState.anonymous;
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
          state = UserState.anonymous;
          return;
        }
        await SecureStorage.saveToken(newToken, expiresAt);
      } catch (_) {
        await SecureStorage.clear();
        state = UserState.anonymous;
        return;
      }
    }
    state = await _fetchUserState();
  }

  Future<UserState> _fetchUserState() async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await _dio.get(Endpoints.me);
        final stateStr = response.data['userState'] as String?;
        return _mapState(stateStr);
      } catch (_) {
        if (attempt < 2) await Future.delayed(Duration(seconds: attempt + 1));
      }
    }
    return UserState.unknown;
  }

  UserState _mapState(String? s) => switch (s) {
    'lead' => UserState.lead,
    'onboarding' => UserState.onboarding,
    'unpaid' => UserState.unpaid,
    'active' => UserState.active,
    'past_due' => UserState.pastDue,
    'canceled' => UserState.canceled,
    _ => UserState.unknown,
  };

  /// Re-fetches /me and updates state.
  Future<void> refreshState() async {
    state = await _fetchUserState();
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
      state = await _fetchUserState();
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
      state = await _fetchUserState();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await SecureStorage.clear();
    state = UserState.anonymous;
  }
}
