import 'package:flutter_test/flutter_test.dart';
import 'package:prereq/shared/utils/kelly.dart';

void main() {
  group('kellyFraction', () {
    test('classic positive-edge case: q=0.62, p=0.55', () {
      // f* = (0.62 - 0.55) / (1 - 0.55) = 0.07 / 0.45
      expect(
        kellyFraction(probability: 0.62, price: 0.55),
        closeTo(0.07 / 0.45, 1e-12),
      );
    });

    test('no edge means zero fraction', () {
      expect(kellyFraction(probability: 0.5, price: 0.5), 0);
    });

    test('negative edge is clamped to zero', () {
      expect(kellyFraction(probability: 0.4, price: 0.55), 0);
    });

    test('cheap contract with high conviction', () {
      // f* = (0.5 - 0.1) / 0.9
      expect(
        kellyFraction(probability: 0.5, price: 0.10),
        closeTo(0.4 / 0.9, 1e-12),
      );
    });

    test('degenerate prices return zero', () {
      expect(kellyFraction(probability: 0.9, price: 1.0), 0);
      expect(kellyFraction(probability: 0.9, price: 1.5), 0);
      expect(kellyFraction(probability: 0.9, price: -0.1), 0);
    });

    test('certain win takes the full bankroll', () {
      expect(kellyFraction(probability: 1.0, price: 0.6), closeTo(1.0, 1e-12));
    });
  });

  group('KellySizing', () {
    final sizing = KellySizing(probability: 0.62, price: 0.55, bankroll: 1000);

    test('half and quarter fractions derive from full', () {
      expect(sizing.halfFraction, sizing.fullFraction / 2);
      expect(sizing.quarterFraction, sizing.fullFraction / 4);
    });

    test('dollar sizing scales with bankroll', () {
      expect(sizing.dollarsFor(sizing.fullFraction),
          closeTo(1000 * 0.07 / 0.45, 1e-9));
    });

    test('contracts are floored whole contracts', () {
      // full Kelly = 155.55... dollars at $0.55 → 282.82... → 282 contracts
      expect(sizing.contractsFor(sizing.fullFraction), 282);
    });

    test('contracts are zero for zero price', () {
      final s = KellySizing(probability: 0.6, price: 0, bankroll: 1000);
      expect(s.contractsFor(0.5), 0);
    });

    test('aggressive warning above 15% of bankroll', () {
      expect(sizing.isAggressive, isTrue); // 15.55% > 15%
      final mild = KellySizing(probability: 0.56, price: 0.55, bankroll: 1000);
      expect(mild.isAggressive, isFalse); // (0.01/0.45) = 2.2%
    });
  });
}
