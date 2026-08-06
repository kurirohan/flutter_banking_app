// PayMaye — Auth Service (OAuth 2.0 PKCE with Keycloak)
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../storage/secure_token_store.dart';

class AuthConfig {
  static const issuer = 'https://auth.nexabank.com/realms/nexa';
  static const clientId = 'nexabank-mobile';
  static const redirectUri = 'nexabank://callback';
  static const scopes = ['openid', 'profile', 'email', 'accounts:read', 'payments:write'];

  static String get authorizationEndpoint => '$issuer/protocol/openid-connect/auth';
  static String get tokenEndpoint => '$issuer/protocol/openid-connect/token';
}

class OAuthTokens {
  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final DateTime expiresAt;

  const OAuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    required this.expiresAt,
  });

  bool get needsRefresh =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 60)));

  factory OAuthTokens.fromJson(Map<String, dynamic> json) => OAuthTokens(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String?,
        idToken: json['id_token'] as String?,
        expiresAt: DateTime.now().add(Duration(seconds: json['expires_in'] as int)),
      );
}

class AuthService {
  final SecureTokenStore _store;
  OAuthTokens? _cached;

  AuthService(this._store);

  String generateCodeVerifier() {
    final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  String generateCodeChallenge(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  String buildAuthorizationUrl(String verifier, String state) {
    final challenge = generateCodeChallenge(verifier);
    final params = {
      'response_type': 'code',
      'client_id': AuthConfig.clientId,
      'redirect_uri': AuthConfig.redirectUri,
      'scope': AuthConfig.scopes.join(' '),
      'code_challenge': challenge,
      'code_challenge_method': 'S256',
      'state': state,
    };
    return Uri.parse(AuthConfig.authorizationEndpoint)
        .replace(queryParameters: params)
        .toString();
  }

  Future<OAuthTokens> exchangeCode({required String code, required String verifier}) async {
    // In real app: POST to AuthConfig.tokenEndpoint
    await Future.delayed(const Duration(milliseconds: 500));
    final tokens = OAuthTokens(
      accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token',
      idToken: 'mock_id_token',
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
    await _store.saveTokens(tokens);
    _cached = tokens;
    return tokens;
  }

  /// Mock username/password sign-in.
  ///
  /// NOTE: real backends should NOT use the OAuth "Resource Owner
  /// Password Credentials" grant (Keycloak and OAuth 2.1 both deprecate
  /// it) — swap this for a call to your own login endpoint that returns
  /// tokens after verifying the credentials server-side.
  Future<OAuthTokens> loginWithPassword({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (username.isEmpty || password.isEmpty) {
      throw Exception('Invalid username or password');
    }
    final tokens = OAuthTokens(
      accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token',
      idToken: 'mock_id_token',
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
    await _store.saveTokens(tokens);
    _cached = tokens;
    return tokens;
  }

  Future<String> getValidAccessToken() async {
    final tokens = _cached ?? await _store.loadTokens();
    if (tokens == null) throw Exception('Not authenticated');
    if (tokens.needsRefresh) return (await _refreshTokens(tokens)).accessToken;
    return tokens.accessToken;
  }

  Future<OAuthTokens> _refreshTokens(OAuthTokens current) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final refreshed = OAuthTokens(
      accessToken: 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: current.refreshToken,
      idToken: current.idToken,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
    await _store.saveTokens(refreshed);
    _cached = refreshed;
    return refreshed;
  }

  Future<bool> isAuthenticated() async {
    final tokens = await _store.loadTokens();
    return tokens != null;
  }

  Future<void> logout() async {
    _cached = null;
    await _store.clearTokens();
  }
}
