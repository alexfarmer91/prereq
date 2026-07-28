// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Single source of truth for session state and token retrieval.
///
/// - Google mode: state is driven by [GoogleSignIn]'s `authenticationEvents`
///   stream, subscribed once from [build]; `getToken()` returns the current
///   Google ID token.
/// - Dev bypass mode: always signed in; `getToken()` returns null so no
///   Authorization header is attached (backend runs with SKIP_AUTH=true).
/// - Unconfigured: signed out forever; login screen explains setup.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Single source of truth for session state and token retrieval.
///
/// - Google mode: state is driven by [GoogleSignIn]'s `authenticationEvents`
///   stream, subscribed once from [build]; `getToken()` returns the current
///   Google ID token.
/// - Dev bypass mode: always signed in; `getToken()` returns null so no
///   Authorization header is attached (backend runs with SKIP_AUTH=true).
/// - Unconfigured: signed out forever; login screen explains setup.
final class AuthControllerProvider
    extends $NotifierProvider<AuthController, AuthState> {
  /// Single source of truth for session state and token retrieval.
  ///
  /// - Google mode: state is driven by [GoogleSignIn]'s `authenticationEvents`
  ///   stream, subscribed once from [build]; `getToken()` returns the current
  ///   Google ID token.
  /// - Dev bypass mode: always signed in; `getToken()` returns null so no
  ///   Authorization header is attached (backend runs with SKIP_AUTH=true).
  /// - Unconfigured: signed out forever; login screen explains setup.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authControllerHash() => r'c6c9d4c84a3a8f54a522e4a2492008f2a2949dcd';

/// Single source of truth for session state and token retrieval.
///
/// - Google mode: state is driven by [GoogleSignIn]'s `authenticationEvents`
///   stream, subscribed once from [build]; `getToken()` returns the current
///   Google ID token.
/// - Dev bypass mode: always signed in; `getToken()` returns null so no
///   Authorization header is attached (backend runs with SKIP_AUTH=true).
/// - Unconfigured: signed out forever; login screen explains setup.

abstract class _$AuthController extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
