import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'core/analytics/analytics.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/terms_screen.dart';
import 'features/market_detail/market_detail_screen.dart';
import 'features/performance/performance_screen.dart';
import 'features/position_sizer/sizer_screen.dart';
import 'features/scanner/scanner_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/watchlist/watchlist_screen.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/profile_provider.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  // Bump a Listenable whenever auth or profile state changes so redirects
  // re-evaluate.
  final refresh = ValueNotifier(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);
  ref.listen(profileProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: '/scanner',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final onLogin = state.matchedLocation == '/login';
      final onTerms = state.matchedLocation == '/terms';

      switch (auth.status) {
        case AuthStatus.initializing:
          // Google Sign-In is restoring the session; stay put (login screen
          // renders the sign-in button, which handles its own loading state).
          return onLogin ? null : '/login';
        case AuthStatus.signedOut:
        case AuthStatus.unconfigured:
          return onLogin ? null : '/login';
        case AuthStatus.signedIn:
          // Unknown (still loading/errored) is treated as accepted so the
          // app isn't blocked before the profile has loaded even once; the
          // redirect re-evaluates as soon as it resolves to false.
          final termsAccepted =
              ref.read(profileProvider).value?.termsAccepted ?? true;
          if (!termsAccepted) return onTerms ? null : '/terms';
          return (onLogin || onTerms) ? '/scanner' : null;
      }
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/scanner',
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/scanner',
              builder: (context, state) => const ScannerScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/watchlist',
              builder: (context, state) => const WatchlistScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/performance',
              builder: (context, state) => const PerformanceScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/market/:ticker',
        builder: (context, state) =>
            MarketDetailScreen(ticker: state.pathParameters['ticker']!),
      ),
      GoRoute(
        path: '/sizer',
        builder: (context, state) => const SizerScreen(),
      ),
    ],
  );

  // Central screen tracking: one `screen_viewed` per location change, with
  // dynamic segments (the market ticker) kept out of the screen name.
  String? lastTrackedPath;
  void trackScreen() {
    final uri = router.routerDelegate.currentConfiguration.uri;
    if (uri.path == lastTrackedPath) return;
    lastTrackedPath = uri.path;
    final segments = uri.pathSegments;
    final isMarket = segments.isNotEmpty && segments.first == 'market';
    Analytics.track('screen_viewed', {
      'screen': isMarket
          ? 'market_detail'
          : (segments.isEmpty ? 'root' : segments.first),
      if (isMarket && segments.length > 1) 'market_ticker': segments[1],
    });
  }

  router.routerDelegate.addListener(trackScreen);
  ref.onDispose(() => router.routerDelegate.removeListener(trackScreen));

  return router;
}
