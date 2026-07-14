import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/auth_provider.dart';

/// Sits directly below the [ClerkAuth] root widget and mirrors Clerk's auth
/// state into [authControllerProvider], keeping the rest of the app ignorant
/// of Clerk. `ClerkAuth.of(context)` registers this widget as a dependent, so
/// [didChangeDependencies] fires on every auth-state change.
class ClerkBridge extends ConsumerStatefulWidget {
  const ClerkBridge({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ClerkBridge> createState() => _ClerkBridgeState();
}

class _ClerkBridgeState extends ConsumerState<ClerkBridge> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final clerk = ClerkAuth.of(context);
    // Defer: provider mutation isn't allowed during build/dependency updates.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(authControllerProvider.notifier).attachClerk(clerk);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
