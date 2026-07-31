import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists the Google ID token across page reloads so the user isn't forced
/// through interactive sign-in on every refresh.
///
/// Google issues ID tokens with a fixed, non-configurable 1h lifetime and no
/// refresh token in this flow — so this only survives up to that expiry
/// (decoded from the token's own `exp` claim), not indefinitely.
abstract final class TokenCache {
  static const _tokenKey = 'google_id_token';
  static const _expiryKey = 'google_id_token_exp_millis';

  static String? _token;
  static DateTime? _expiry;

  /// Loads any cached token from disk. Must be awaited before the auth
  /// provider's synchronous `build()` runs, so call this before `runApp`.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiryMillis = prefs.getInt(_expiryKey);
    if (token == null || expiryMillis == null) return;
    final expiry = DateTime.fromMillisecondsSinceEpoch(expiryMillis);
    if (expiry.isAfter(DateTime.now())) {
      _token = token;
      _expiry = expiry;
    }
  }

  /// The cached token, or null if there isn't one or it has expired.
  static String? get validToken {
    final expiry = _expiry;
    if (_token == null || expiry == null || !expiry.isAfter(DateTime.now())) {
      return null;
    }
    return _token;
  }

  /// Stores [idToken], decoding its own `exp` claim rather than assuming
  /// Google's current 1h lifetime.
  static Future<void> save(String idToken) async {
    final expiry = _decodeExpiry(idToken);
    if (expiry == null) return;
    _token = idToken;
    _expiry = expiry;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, idToken);
    await prefs.setInt(_expiryKey, expiry.millisecondsSinceEpoch);
  }

  static Future<void> clear() async {
    _token = null;
    _expiry = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiryKey);
  }

  static DateTime? _decodeExpiry(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;
      final payload = base64Url.normalize(parts[1]);
      final claims = jsonDecode(utf8.decode(base64Url.decode(payload)));
      final exp = claims['exp'];
      if (exp is! int) return null;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (_) {
      return null;
    }
  }
}
