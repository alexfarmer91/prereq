/// How the app authenticates the user.
enum AuthMode {
  /// A Google OAuth client ID is configured; real Google sign-in and Bearer
  /// tokens (Google ID tokens).
  google,

  /// No Google client ID, but DEV_AUTH_BYPASS=true; act as signed in
  /// (backend runs with SKIP_AUTH=true).
  devBypass,

  /// No Google client ID and no bypass; show a setup notice on the login
  /// screen.
  unconfigured,
}

/// Compile-time runtime configuration, supplied via `--dart-define`.
abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// The Google Cloud "Web application" OAuth 2.0 Client ID. Used directly
  /// as `clientId` on web, and as `serverClientId` on native platforms so
  /// the resulting ID token's `aud` claim is the same value everywhere the
  /// backend can verify against.
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );

  /// Mixpanel project token (a public client-side identifier, not a secret).
  /// Pass `--dart-define=MIXPANEL_TOKEN=` (empty) to disable tracking.
  static const String mixpanelToken = String.fromEnvironment(
    'MIXPANEL_TOKEN',
    defaultValue: '73950bce8310f42d2fbcebeb8569b32c',
  );

  static const String _devAuthBypass = String.fromEnvironment(
    'DEV_AUTH_BYPASS',
    defaultValue: 'false',
  );

  static bool get devAuthBypass => _devAuthBypass.toLowerCase() == 'true';

  static AuthMode get authMode {
    if (googleClientId.isNotEmpty) return AuthMode.google;
    if (devAuthBypass) return AuthMode.devBypass;
    return AuthMode.unconfigured;
  }

  /// The WebSocket endpoint derived from [apiBaseUrl].
  static Uri wsUri({String? token}) {
    final base = Uri.parse(apiBaseUrl);
    return base.replace(
      scheme: base.scheme == 'https' ? 'wss' : 'ws',
      path: '/ws/markets',
      queryParameters: token == null || token.isEmpty ? null : {'token': token},
    );
  }
}
