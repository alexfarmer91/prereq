import 'package:flutter/material.dart';

import 'analytics.dart';

/// Overlays a one-time analytics consent banner on top of the app. Shows only
/// while [Analytics.consent] is [ConsentStatus.unknown]; until the user
/// accepts, the Mixpanel SDK stays opted out and sends nothing.
class ConsentGate extends StatelessWidget {
  const ConsentGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ConsentStatus>(
      valueListenable: Analytics.consent,
      builder: (context, status, _) {
        if (status != ConsentStatus.unknown) return child;
        return Stack(
          children: [
            child,
            const Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _ConsentBanner(),
            ),
          ],
        );
      },
    );
  }
}

class _ConsentBanner extends StatelessWidget {
  const _ConsentBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: SafeArea(
          top: false,
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(
                  'Prereq uses anonymous usage analytics to improve the app. '
                  'No bet amounts or personal data are shared beyond your '
                  'account id. Allow analytics?',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              TextButton(
                onPressed: () => Analytics.setConsent(granted: false),
                child: const Text('Decline'),
              ),
              FilledButton(
                onPressed: () => Analytics.setConsent(granted: true),
                child: const Text('Allow'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
