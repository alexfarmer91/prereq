import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prereq/features/market_detail/widgets/score_card.dart';
import 'package:prereq/features/position_sizer/kelly_sizer.dart';
import 'package:prereq/shared/models/market.dart';
import 'package:prereq/shared/models/user_profile.dart';
import 'package:prereq/shared/providers/profile_provider.dart';
import 'package:prereq/shared/theme/app_theme.dart';

import 'market_card_test.dart' show sampleMarket;

/// Profile that never loads, so the sizer renders without a backend.
class _PendingProfile extends Profile {
  @override
  Future<UserProfile> build() => Completer<UserProfile>().future;
}

/// A very confident AI estimate far from the market: if it leaked into the
/// sizer, full Kelly at a $0.50 ask would be 90%.
Score confidentScore({double? evYes = 0.9, double? evNo}) => Score(
      fairProbability: 0.95,
      confidence: ScoreConfidence.high,
      edge: 0.45,
      evYesPerDollar: evYes,
      evNoPerDollar: evNo,
      rationale: 'Rationale',
      signals: const [],
      risks: const [],
      scoredAt: DateTime.utc(2026, 7, 14, 12),
    );

Widget host(Widget child) => ProviderScope(
      overrides: [profileProvider.overrideWith(_PendingProfile.new)],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  testWidgets('ScoreCard labels the estimate as unvalidated', (tester) async {
    await tester.pumpWidget(host(ScoreCard(score: confidentScore())));

    expect(find.text('AI estimate'), findsOneWidget);
    expect(find.textContaining('Unvalidated'), findsOneWidget);
    expect(find.text('SELF-RATED HIGH'), findsOneWidget);
    expect(find.text('AI–market gap'), findsOneWidget);
    expect(find.text('Edge'), findsNothing);
    expect(find.text('Fair probability'), findsNothing);
  });

  testWidgets('ScoreCard lists cited evidence as unverified', (tester) async {
    final score = confidentScore().copyWith(evidence: const [
      Evidence(
          claim: 'Poll lead of 5',
          source: 'https://example.com/poll',
          date: '2026-10-01',
          supports: 'yes'),
      Evidence(claim: 'Rules count certified results only'),
    ]);
    await tester.pumpWidget(host(ScoreCard(score: score)));

    expect(find.text('Evidence cited by the AI'), findsOneWidget);
    expect(find.text('Not independently verified.'), findsOneWidget);
    expect(find.text('For YES: Poll lead of 5'), findsOneWidget);
    expect(find.text('https://example.com/poll · 2026-10-01'), findsOneWidget);
    expect(find.text('Rules count certified results only'), findsOneWidget);
  });

  testWidgets('ScoreCard hides the evidence section when there is none',
      (tester) async {
    await tester.pumpWidget(host(ScoreCard(score: confidentScore())));
    expect(find.text('Evidence cited by the AI'), findsNothing);
  });

  testWidgets('ScoreCard shows unavailable EV as a dash, not zero',
      (tester) async {
    await tester.pumpWidget(host(ScoreCard(score: confidentScore(evNo: null))));

    expect(find.text('+90.0%'), findsOneWidget); // YES EV
    expect(find.text('—'), findsOneWidget); // NO EV unavailable
    expect(find.text('+0.0%'), findsNothing);
  });

  testWidgets('KellySizer never prefills the AI probability', (tester) async {
    final market = sampleMarket(score: confidentScore())
        .copyWith(yesAsk: 0.50, noAsk: 0.50);
    await tester.pumpWidget(host(KellySizer(market: market)));

    expect(find.text('Your probability YES wins: not set'), findsOneWidget);
    expect(find.textContaining('not the AI estimate'), findsOneWidget);
    // Nothing is sized until the user sets their own probability.
    expect(find.text('0.0%'), findsNWidgets(3));
    expect(find.text('90.0%'), findsNothing);
    final logButton = tester.widget<FilledButton>(
        find.ancestor(
            of: find.text('Log this bet'),
            // FilledButton.icon builds a private subclass.
            matching: find.byWidgetPredicate((w) => w is FilledButton)));
    expect(logButton.onPressed, isNull);
  });
}
