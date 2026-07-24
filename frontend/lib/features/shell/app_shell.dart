import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/ws_providers.dart';

/// Responsive navigation shell: sidebar rail above 900px, bottom nav below.
/// The Watchlist destination shows a badge whenever live arbs exist.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arbCount = ref.watch(arbCountProvider);
    final wide = MediaQuery.sizeOf(context).width > 900;

    Widget watchlistIcon(bool selected) {
      final icon =
          Icon(selected ? Icons.bookmarks : Icons.bookmarks_outlined);
      if (arbCount <= 0) return icon;
      return Badge.count(count: arbCount, child: icon);
    }

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: MediaQuery.sizeOf(context).width > 1200,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              labelType: MediaQuery.sizeOf(context).width > 1200
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Icon(Icons.query_stats, size: 28),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _SignOutButton(),
                  ),
                ),
              ),
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.radar_outlined),
                  selectedIcon: Icon(Icons.radar),
                  label: Text('Scanner'),
                ),
                NavigationRailDestination(
                  icon: watchlistIcon(false),
                  selectedIcon: watchlistIcon(true),
                  label: const Text('Watchlist'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights),
                  label: Text('Performance'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.radar_outlined),
            selectedIcon: Icon(Icons.radar),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: watchlistIcon(false),
            selectedIcon: watchlistIcon(true),
            label: 'Watchlist',
          ),
          const NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Performance',
          ),
        ],
      ),
    );
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    if (auth.mode != AuthMode.google) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'Sign out',
      icon: const Icon(Icons.logout),
      onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
    );
  }
}
