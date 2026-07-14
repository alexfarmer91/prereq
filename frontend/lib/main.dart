import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'features/auth/clerk_bridge.dart';
import 'router.dart';
import 'shared/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PrereqApp()));
}

class PrereqApp extends ConsumerWidget {
  const PrereqApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    final app = MaterialApp.router(
      title: 'Prereq',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
    );

    // Only mount Clerk when a publishable key is configured; otherwise the
    // auth provider handles dev-bypass / unconfigured modes on its own.
    if (AppConfig.authMode == AuthMode.clerk) {
      return ClerkAuth(
        config: ClerkAuthConfig(
          publishableKey: AppConfig.clerkPublishableKey,
        ),
        child: ClerkBridge(child: app),
      );
    }
    return app;
  }
}
