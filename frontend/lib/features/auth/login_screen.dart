import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart'
    if (dart.library.io) 'gsi_web_stub.dart' as gsi_web;

import '../../core/config/app_config.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_backdrop.dart';
import '../../shared/widgets/prereq_mark.dart';
import '../../shared/widgets/prereq_spinner.dart';

/// Login/signup screen.
///
/// - Google mode: renders a Google sign-in button.
/// - Unconfigured: shows a clear setup notice (never crashes).
/// - Dev bypass: users never land here (router redirects), but shows a note
///   just in case.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final restoring =
        auth.mode == AuthMode.google && auth.status == AuthStatus.initializing;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Brand(),
                  const SizedBox(height: 32),
                  if (restoring)
                    const _LoadingPanel()
                  else
                    switch (auth.mode) {
                      AuthMode.google => const _GoogleSignInPanel(),
                      AuthMode.unconfigured => const _SetupNotice(),
                      AuthMode.devBypass => const Text(
                          'Dev auth bypass is active — you are signed in.'),
                    },
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const PrereqSpinner(),
        const SizedBox(height: 16),
        Text(
          'Checking for a saved session…',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
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
        const PrereqLockup(markSize: 56, stacked: true),
        const SizedBox(height: 16),
        Text(
          'Don\'t go in alone',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _GoogleSignInPanel extends StatelessWidget {
  const _GoogleSignInPanel();

  Future<void> _signIn(BuildContext context) async {
    try {
      await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (context.mounted && e.code != GoogleSignInExceptionCode.canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: ${e.description ?? e.code}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button(context),
        const SizedBox(height: 20),
        const _TermsNote(),
      ],
    );
  }

  Widget _button(BuildContext context) {
    // Native platforms: the theme's outlined-primary style already carries
    // the accent border plus hover/pressed states.
    if (!kIsWeb) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () => _signIn(context),
          icon: const Icon(Icons.login),
          label: const Text('Continue with Google'),
        ),
      );
    }

    // Web: supportsAuthenticate() is false — sign-in can only be triggered
    // by the GIS-rendered iframe button, which offers no transparent theme.
    // So the panel below carries the whole look (G logo + label directly on
    // the glowing box), and the real GIS button is stretched over it at ~1%
    // opacity to receive the clicks. Deliberately outside Google's branding
    // guidelines; revisit if GIS changes its button layout.
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.accent),
            boxShadow: [
              // Hairline ring just outside the border.
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.10),
                spreadRadius: 1,
              ),
              // Soft glow under the panel.
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.55),
                offset: const Offset(0, 8),
                blurRadius: 40,
                spreadRadius: -12,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/g_logo.png', width: 22, height: 22),
              const SizedBox(width: 12),
              const Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        // The click target. GIS caps its width at 400px, so on a wider panel
        // the outermost edges aren't clickable — acceptable at maxWidth 440.
        Opacity(
          opacity: 0.01,
          child: gsi_web.renderButton(
            configuration: gsi_web.GSIButtonConfiguration(
              theme: gsi_web.GSIButtonTheme.filledBlack,
              size: gsi_web.GSIButtonSize.large,
              text: gsi_web.GSIButtonText.continueWith,
              minimumWidth: 400,
            ),
          ),
        ),
      ],
    );
  }
}

/// The terms/privacy note under the sign-in button. The highlighted words
/// aren't links yet — the terms text lives in the onboarding flow and there
/// are no hosted terms/privacy pages to point at.
class _TermsNote extends StatelessWidget {
  const _TermsNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      const TextSpan(
        text: 'By continuing you accept the ',
        children: [
          TextSpan(
              text: 'terms', style: TextStyle(color: AppColors.accentText)),
          TextSpan(text: ' and '),
          TextSpan(
              text: 'privacy policy',
              style: TextStyle(color: AppColors.accentText)),
          TextSpan(text: '.'),
        ],
      ),
      style: theme.textTheme.bodyMedium
          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      textAlign: TextAlign.center,
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
                Text('Sign-in not configured',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Authentication is not set up for this build. To enable '
              'sign-in, provide your Google OAuth Web Client ID at build '
              'time:',
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
                '  --dart-define=GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com',
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
