import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/config/app_config.dart';

part 'auth_provider.g.dart';

/// Where the session stands, regardless of which auth mode is active.
enum AuthStatus {
  /// Clerk is still restoring the persisted session.
  initializing,
  signedIn,
  signedOut,

  /// No Clerk key and no dev bypass — the login screen shows a setup notice.
  unconfigured,
}

/// Auth session state exposed to the rest of the app. The app never needs to
/// know whether Clerk or the dev bypass is active.
class AuthState {
  const AuthState({required this.status, required this.mode});

  final AuthStatus status;
  final AuthMode mode;

  bool get isSignedIn => status == AuthStatus.signedIn;
}

/// Single source of truth for session state and token retrieval.
///
/// - Clerk mode: state is driven by [attachClerk] (called by the
///   `ClerkAuthBridge` widget that sits below the `ClerkAuth` root widget);
///   `getToken()` returns the current Clerk session JWT.
/// - Dev bypass mode: always signed in; `getToken()` returns null so no
///   Authorization header is attached (backend runs with SKIP_AUTH=true).
/// - Unconfigured: signed out forever; login screen explains setup.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  ClerkAuthState? _clerk;

  @override
  AuthState build() {
    switch (AppConfig.authMode) {
      case AuthMode.devBypass:
        return const AuthState(
            status: AuthStatus.signedIn, mode: AuthMode.devBypass);
      case AuthMode.unconfigured:
        return const AuthState(
            status: AuthStatus.unconfigured, mode: AuthMode.unconfigured);
      case AuthMode.clerk:
        return const AuthState(
            status: AuthStatus.initializing, mode: AuthMode.clerk);
    }
  }

  /// Called by the Clerk bridge widget whenever the Clerk auth state changes.
  void attachClerk(ClerkAuthState clerk) {
    _clerk = clerk;
    final signedIn = clerk.user != null;
    final next = AuthState(
      status: signedIn ? AuthStatus.signedIn : AuthStatus.signedOut,
      mode: AuthMode.clerk,
    );
    if (next.status != state.status) state = next;
  }

  /// The Bearer token for API calls / WebSocket, or null when no token is
  /// needed (dev bypass) or available.
  Future<String?> getToken() async {
    final clerk = _clerk;
    if (state.mode != AuthMode.clerk || clerk == null) return null;
    if (clerk.user == null) return null;
    try {
      final token = await clerk.sessionToken();
      return token.jwt;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    final clerk = _clerk;
    if (clerk != null) {
      await clerk.signOut();
      attachClerk(clerk);
    }
  }
}
