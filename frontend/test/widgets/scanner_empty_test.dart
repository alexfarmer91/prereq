import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prereq/core/api/api_client.dart';
import 'package:prereq/features/scanner/scanner_screen.dart';
import 'package:prereq/shared/models/market.dart';
import 'package:prereq/shared/providers/markets_provider.dart';
import 'package:prereq/shared/theme/app_theme.dart';
import 'package:prereq/shared/widgets/status_views.dart';

void main() {
  testWidgets('Scanner shows empty state when no markets match',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          marketsProvider(category: null, sort: MarketSort.edge)
              .overrideWith((ref) async => <Market>[]),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const ScannerScreen(),
        ),
      ),
    );

    // Let the future resolve.
    await tester.pumpAndSettle();

    expect(find.byType(EmptyStateView), findsOneWidget);
    expect(find.text('No markets found'), findsOneWidget);
    // Filter chips are still available.
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Weather'), findsOneWidget);
  });
}
