import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prereq/shared/models/market.dart';
import 'package:prereq/shared/theme/app_theme.dart';
import 'package:prereq/shared/widgets/market_card.dart';

Market sampleMarket({Score? score}) => Market(
      ticker: 'KXHIGHNY-26MAY18-T84',
      eventTicker: 'KXHIGHNY-26MAY18',
      title: 'Will the high temp in NYC be >84 on May 18, 2026?',
      yesBid: 0.85,
      yesAsk: 0.89,
      noBid: 0.11,
      noAsk: 0.15,
      midPrice: 0.87,
      spread: 0.04,
      volume24h: 14074.65,
      // 30-minute buffer so the formatted label stays "3d 4h" even after the
      // few milliseconds between construction and render.
      closeTime: DateTime.now()
          .toUtc()
          .add(const Duration(days: 3, hours: 4, minutes: 30)),
      category: 'Weather',
      score: score,
    );

Score sampleScore() => Score(
      fairProbability: 0.62,
      confidence: ScoreConfidence.medium,
      edge: 0.05,
      evPerDollar: 0.08,
      rationale: 'Rationale',
      signals: const ['s1'],
      risks: const ['r1'],
      scoredAt: DateTime.utc(2026, 7, 14, 12),
    );

Widget host(Widget child) => MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('MarketCard renders title, category, price, edge, volume',
      (tester) async {
    await tester.pumpWidget(host(MarketCard(market: sampleMarket(score: sampleScore()))));

    expect(find.textContaining('Will the high temp in NYC'), findsOneWidget);
    expect(find.text('Weather'), findsOneWidget);
    expect(find.text(r'$0.87'), findsOneWidget); // yes mid price
    expect(find.text('+5.0%'), findsOneWidget); // edge
    expect(find.text(r'$14.1K'), findsOneWidget); // 24h volume
    expect(find.text('3d 4h'), findsOneWidget); // time to close
  });

  testWidgets('MarketCard shows placeholder edge when unscored',
      (tester) async {
    await tester.pumpWidget(host(MarketCard(market: sampleMarket())));
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('MarketCard tap fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(host(MarketCard(
      market: sampleMarket(),
      onTap: () => tapped = true,
    )));
    await tester.tap(find.byType(MarketCard));
    expect(tapped, isTrue);
  });
}
