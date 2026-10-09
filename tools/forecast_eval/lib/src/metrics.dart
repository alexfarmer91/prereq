/// Proper scoring rules, calibration, and event-group bootstrap.
library;

import 'dart:math' as math;

double brier(double p, double y) => (p - y) * (p - y);

/// Log loss with p bounded to [eps, 1 - eps] for the metric only.
double logLoss(double p, double y, double eps) {
  final b = p.clamp(eps, 1 - eps);
  return -(y * math.log(b) + (1 - y) * math.log(1 - b));
}

bool needsLogLossBound(double p, double eps) => p < eps || p > 1 - eps;

double mean(Iterable<double> xs) {
  var n = 0;
  var s = 0.0;
  for (final x in xs) {
    s += x;
    n++;
  }
  return n == 0 ? double.nan : s / n;
}

/// One forecast pair on one market.
class Pair {
  const Pair({
    required this.group,
    required this.ai,
    required this.market,
    required this.y,
  });

  /// Dependence group (event).
  final String group;
  final double ai;
  final double market;
  final double y;
}

class PairedScores {
  PairedScores(this.pairs, {this.eps = 1e-6});

  final List<Pair> pairs;
  final double eps;

  int get n => pairs.length;
  int get groups => pairs.map((p) => p.group).toSet().length;

  double get aiBrier => mean(pairs.map((p) => brier(p.ai, p.y)));
  double get marketBrier => mean(pairs.map((p) => brier(p.market, p.y)));
  double get aiLogLoss => mean(pairs.map((p) => logLoss(p.ai, p.y, eps)));
  double get marketLogLoss =>
      mean(pairs.map((p) => logLoss(p.market, p.y, eps)));

  /// Mean (market loss − AI loss) per market. Positive = AI better.
  double get brierImprovement => marketBrier - aiBrier;

  int get boundedRows => pairs
      .where(
        (p) => needsLogLossBound(p.ai, eps) || needsLogLossBound(p.market, eps),
      )
      .length;

  /// Mean improvement per event: average within each event first, so a
  /// ladder of related strikes counts once.
  double get eventImprovement => mean(_byGroup(pairs).values.map(_improvement));
}

double _improvement(List<Pair> ps) =>
    mean(ps.map((p) => brier(p.market, p.y) - brier(p.ai, p.y)));

Map<String, List<Pair>> _byGroup(List<Pair> pairs) {
  final m = <String, List<Pair>>{};
  for (final p in pairs) {
    (m[p.group] ??= []).add(p);
  }
  return m;
}

class Interval {
  const Interval(this.low, this.high, this.resamples);
  final double low;
  final double high;
  final int resamples;

  bool get excludesZero => low > 0 || high < 0;
}

/// Percentile bootstrap of [statistic] resampling whole event groups with a
/// fixed [seed]. Returns null with fewer than [minGroups] groups — too few
/// for an interval to mean anything.
Interval? groupBootstrap<T>(
  Map<String, List<T>> groups,
  double Function(List<List<T>> sample) statistic, {
  int resamples = 2000,
  int seed = 42,
  int minGroups = 10,
}) {
  if (groups.length < minGroups) return null;
  final keys = groups.keys.toList()..sort();
  final rng = math.Random(seed);
  final stats = <double>[];
  for (var i = 0; i < resamples; i++) {
    final sample = [
      for (var j = 0; j < keys.length; j++)
        groups[keys[rng.nextInt(keys.length)]]!,
    ];
    final s = statistic(sample);
    if (s.isFinite) stats.add(s);
  }
  if (stats.isEmpty) return null;
  stats.sort();
  double pct(double q) => stats[((stats.length - 1) * q).round()];
  return Interval(pct(0.025), pct(0.975), stats.length);
}

/// Bootstrap interval for the per-event Brier improvement.
Interval? improvementInterval(List<Pair> pairs, {int seed = 42}) =>
    groupBootstrap<Pair>(
      _byGroup(pairs),
      (sample) => mean(sample.map(_improvement)),
      seed: seed,
    );

class CalibrationBucket {
  CalibrationBucket(this.low, this.high);
  final double low;
  final double high;
  int n = 0;
  double sumP = 0;
  double sumY = 0;

  double get meanP => n == 0 ? double.nan : sumP / n;
  double get observed => n == 0 ? double.nan : sumY / n;
}

/// Ten equal-width buckets; p = 1.0 falls in the top bucket.
List<CalibrationBucket> calibration(
  Iterable<(double, double)> probsAndOutcomes,
) {
  final buckets = [
    for (var i = 0; i < 10; i++) CalibrationBucket(i / 10, (i + 1) / 10),
  ];
  for (final (p, y) in probsAndOutcomes) {
    final b = buckets[math.min(9, (p * 10).floor())];
    b.n++;
    b.sumP += p;
    b.sumY += y;
  }
  return buckets;
}
