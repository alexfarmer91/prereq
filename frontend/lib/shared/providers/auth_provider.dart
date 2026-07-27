import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/analytics/analytics.dart';
import '../../core/config/app_config.dart';

part 'auth_provider.g.dart';

/// Where the session stands, regardless of which auth mode is active.
enum AuthStatus {
  /// Google Sign-In is still attempting to restore a persisted session.
  initializing,
  signedIn,
  signedOut,

  /// No Google client ID and no dev bypass — the login screen shows a setup
  /// notice.
  unconfigured,
}

/// Auth session state exposed to the rest of the app. The app never needs to
/// know whether Google Sign-In or the dev bypass is active.
class AuthState {
  const AuthState({required this.status, required this.mode});

  final AuthStatus status;
  final AuthMode mode;

  bool get isSignedIn => status == AuthStatus.signedIn;
}

/// Single source of truth for session state and token retrieval.
///
/// - Google mode: state is driven by [GoogleSignIn]'s `authenticationEvents`
///   stream, subscribed once from [build]; `getToken()` returns the current
///   Google ID token.
/// - Dev bypass mode: always signed in; `getToken()` returns null so no
///   Authorization header is attached (backend runs with SKIP_AUTH=true).
/// - Unconfigured: signed out forever; login screen explains setup.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  GoogleSignInAccount? _account;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _sub;

  @override
  AuthState build() {
    switch (AppConfig.authMode) {
      case AuthMode.devBypass:
        return const AuthState(
            status: AuthStatus.signedIn, mode: AuthMode.devBypass);
      case AuthMode.unconfigured:
        return const AuthState(
            status: AuthStatus.unconfigured, mode: AuthMode.unconfigured);
      case AuthMode.google:
        // build() must stay synchronous — state updates arrive later via
        // the auth event stream set up in _initGoogle.
        unawaited(_initGoogle());
        return const AuthState(
            status: AuthStatus.initializing, mode: AuthMode.google);
    }
  }

  Future<void> _initGoogle() async {
    // serverClientId is what ends up as the ID token's `aud` claim (checked
    // by the backend) and is the one value that must stay consistent across
    // platforms — but web specifically forbids passing it (asserts) and
    // wants the same value as `clientId` instead.
    await GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? AppConfig.googleClientId : null,
      serverClientId: kIsWeb ? null : AppConfig.googleClientId,
    );

    _sub = GoogleSignIn.instance.authenticationEvents.listen(
      _handleAuthEvent,
      onError: (Object _, StackTrace _) =>
          _handleAuthEvent(GoogleSignInAuthenticationEventSignOut()),
    );
    ref.onDispose(() => _sub?.cancel());

    // Best-effort silent restore of a prior session. On web this never
    // resolves — GIS One Tap either fires an auth event on the stream above
    // or stays silent forever if there's nothing to restore — so the result
    // (if any) is handled entirely by _handleAuthEvent, not here.
    final restore = GoogleSignIn.instance.attemptLightweightAuthentication();
    if (restore != null) {
      unawaited(restore.catchError((_) => null));
    }
  }

  void _handleAuthEvent(GoogleSignInAuthenticationEvent event) {
    final account = switch (event) {
      GoogleSignInAuthenticationEventSignIn(:final user) => user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };
    _account = account;
    final next = AuthState(
      status: account != null ? AuthStatus.signedIn : AuthStatus.signedOut,
      mode: AuthMode.google,
    );
    if (next.status != state.status) {
      // Identify on sign-in and session restore; reset on sign-out so the
      // next user on this device isn't merged into the same profile.
      if (account != null) {
        Analytics.identify(account.id);
      } else if (state.status == AuthStatus.signedIn) {
        Analytics.reset();
      }
      state = next;
    }
  }

  /// The Bearer token for API calls / WebSocket, or null when no token is
  /// needed (dev bypass) or available.
  ///
  /// Known limitation: Google ID tokens expire after ~1h and this plugin
  /// has no built-in refresh — a tab left open that long will need the
  /// user to sign in again. Acceptable for now; not solved here.
  Future<String?> getToken() async {
    if (state.mode != AuthMode.google) return null;
    return _account?.authentication.idToken;
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
  }
}
