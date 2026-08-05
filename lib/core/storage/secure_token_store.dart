// PayMaye — Secure Token Storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../auth/auth_service.dart';

class SecureTokenStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keys = (
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
    idToken: 'id_token',
    expiresAt: 'expires_at',
  );

  Future<void> saveTokens(OAuthTokens tokens) async {
    await Future.wait([
      _storage.write(key: _keys.accessToken, value: tokens.accessToken),
      if (tokens.refreshToken != null)
        _storage.write(key: _keys.refreshToken, value: tokens.refreshToken!),
      if (tokens.idToken != null)
        _storage.write(key: _keys.idToken, value: tokens.idToken!),
      _storage.write(
          key: _keys.expiresAt, value: tokens.expiresAt.toIso8601String()),
    ]);
  }

  Future<OAuthTokens?> loadTokens() async {
    final accessToken = await _storage.read(key: _keys.accessToken);
    if (accessToken == null) return null;
    return OAuthTokens(
      accessToken: accessToken,
      refreshToken: await _storage.read(key: _keys.refreshToken),
      idToken: await _storage.read(key: _keys.idToken),
      expiresAt: DateTime.parse(
        await _storage.read(key: _keys.expiresAt) ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<void> clearTokens() => _storage.deleteAll();
}
