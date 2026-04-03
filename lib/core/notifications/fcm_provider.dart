import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';

final fcmProvider = Provider<FcmService>((ref) {
  return FcmService(ref.read(apiClientProvider));
});

class FcmService {
  final Dio _dio;
  final _messaging = FirebaseMessaging.instance;

  FcmService(this._dio);

  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await _messaging.getToken();
    if (token != null) await _registerToken(token);

    _messaging.onTokenRefresh.listen(_registerToken);

    FirebaseMessaging.onMessage.listen((message) {
      // Story ready — UI updates via stream providers automatically
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Navigate to reader — handled by app's deep link routing
    });
  }

  Future<void> _registerToken(String token) async {
    final platform = Platform.isIOS ? 'ios' : 'android';
    try {
      await _dio.post(Endpoints.fcmToken, data: {'token': token, 'platform': platform});
    } catch (_) {}
  }
}
