import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/theme/app_theme.dart';

/// Login/signup screen.
///
/// - Clerk mode: renders Clerk's prebuilt authentication component.
/// - Unconfigured: shows a clear setup notice (never crashes).
/// - Dev bypass: users never land here (router redirects), but shows a note
///   just in case.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Brand(),
                const SizedBox(height: 32),
                switch (auth.mode) {
                  AuthMode.clerk => const _ClerkPanel(),
                  AuthMode.unconfigured => const _SetupNotice(),
                  AuthMode.devBypass => const Text(
                      'Dev auth bypass is active — you are signed in.'),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent),
          ),
          child: const Icon(Icons.query_stats, color: AppColors.accent, size: 30),
        ),
        const SizedBox(height: 16),
        Text('Prereq', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Prediction market analytics',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ClerkPanel extends StatelessWidget {
  const _ClerkPanel();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: ClerkErrorListener(child: ClerkAuthentication()),
      ),
    );
  }
}

class _SetupNotice extends StatelessWidget {
  const _SetupNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.key_off, color: AppColors.amber),
                const SizedBox(width: 8),
                Text('Clerk not configured',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Authentication is not set up for this build. To enable '
              'sign-in, provide your Clerk publishable key at build time:',
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'flutter run \\\n'
                '  --dart-define=CLERK_PUBLISHABLE_KEY=pk_...',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'For local development against a backend running with '
              'SKIP_AUTH=true, you can instead pass '
              '--dart-define=DEV_AUTH_BYPASS=true.',
            ),
          ],
        ),
      ),
    );
  }
}
