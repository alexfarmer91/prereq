import 'dart:math' as math;

/// Kelly criterion math for binary prediction markets.
///
/// For a contract priced at [price] dollars that pays $1 when it resolves in
/// your favor, with your estimated win probability [probability]:
///
///   f* = (q - p) / (1 - p), clamped to >= 0
double kellyFraction({required double probability, required double price}) {
  if (price >= 1.0 || price < 0) return 0;
  final f = (probability - price) / (1.0 - price);
  return math.max(0.0, f);
}

/// Full sizing output for a bankroll.
class KellySizing {
  KellySizing({
    required this.probability,
    required this.price,
    required this.bankroll,
  }) : fullFraction = kellyFraction(probability: probability, price: price);

  final double probability;
  final double price;
  final double bankroll;
  final double fullFraction;

  double get halfFraction => fullFraction / 2;
  double get quarterFraction => fullFraction / 4;

  double dollarsFor(double fraction) => bankroll * fraction;

  /// Whole contracts purchasable with `bankroll * fraction` at [price].
  int contractsFor(double fraction) {
    if (price <= 0) return 0;
    return (dollarsFor(fraction) / price).floor();
  }

  /// Spec: warn when full Kelly exceeds 15% of bankroll.
  bool get isAggressive => fullFraction > 0.15;
}
