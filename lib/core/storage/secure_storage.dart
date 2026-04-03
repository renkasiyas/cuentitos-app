import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _expiresKey = 'jwt_expires_at';

  static Future<void> saveToken(String token, String expiresAt) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _expiresKey, value: expiresAt);
  }

  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<String?> getExpiresAt() => _storage.read(key: _expiresKey);

  static Future<bool> isTokenExpired() async {
    final expiresAt = await getExpiresAt();
    if (expiresAt == null) return true;
    return DateTime.parse(expiresAt).isBefore(DateTime.now());
  }

  static Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiresKey);
  }
}
