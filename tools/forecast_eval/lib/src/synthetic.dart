/// Synthetic dataset generator for demos and tests. Every ticker starts with
/// [syntheticPrefix], so every report built from it is stamped SYNTHETIC.
library;

import 'dart:math' as math;

import 'csv.dart';
import 'observation.dart';

/// [events] events of [strikesPerEvent] related markets, each scored once
/// plus one later refresh. True probabilities are random; the market sees
/// them with noise [marketNoise], the AI with noise [aiNoise]. With aiNoise <
/// marketNoise the AI should win on average — and vice versa.
String syntheticCsv({
  int events = 60,
  int strikesPerEvent = 3,
  double marketNoise = 0.08,
  double aiNoise = 0.12,
  String promptVersion = '3',
  int seed = 7,
  DateTime? start,
}) {
  final rng = math.Random(seed);
  final t0 = start ?? DateTime.utc(2026, 11, 1);
  double noisy(double p, double sd) {
    // Box–Muller; clamp keeps synthetic quotes inside (0.01, 0.99).
    final z =
        math.sqrt(-2 * math.log(1 - rng.nextDouble())) *
        math.cos(2 * math.pi * rng.nextDouble());
    return (p + sd * z).clamp(0.01, 0.99);
  }

  final rows = <List<Object?>>[exportColumns];
  var id = 0;
  for (var e = 0; e < events; e++) {
    final event = '${syntheticPrefix}EVT$e';
    final scored = t0.add(Duration(hours: 12 * e));
    final close = scored.add(Duration(days: 1 + rng.nextInt(20)));
    final settled = close.add(const Duration(hours: 2));
    for (var s = 0; s < strikesPerEvent; s++) {
      final truth = 0.05 + 0.9 * rng.nextDouble();
      final y = rng.nextDouble() < truth;
      final m = noisy(truth, marketNoise);
      final q = noisy(truth, aiNoise);
      for (var refresh = 0; refresh < 2; refresh++) {
        rows.add([
          ++id,
          '$event-S$s',
          event,
          ['Politics', 'Sports', 'Economics'][e % 3],
          promptVersion,
          ['low', 'medium', 'high'][rng.nextInt(3)],
          q,
          m,
          (m - 0.01).clamp(0.0, 1.0),
          (m + 0.01).clamp(0.0, 1.0),
          (1 - m - 0.01).clamp(0.0, 1.0),
          (1 - m + 0.01).clamp(0.0, 1.0),
          scored.add(Duration(hours: refresh)).toIso8601String(),
          scored.add(Duration(hours: refresh, seconds: 20)).toIso8601String(),
          close.toIso8601String(),
          'false',
          y ? 'yes' : 'no',
          settled.toIso8601String(),
        ]);
      }
    }
  }
  return toCsv(rows);
}
