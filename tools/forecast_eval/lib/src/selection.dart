/// Benchmark/selection policy and the eligibility filter. The policy is
/// versioned: change any setting → new [EvalPolicy.id] and a fresh
/// evaluation period (docs/forecast-validation.md).
library;

import 'observation.dart';

class EvalPolicy {
  const EvalPolicy({
    required this.promptVersion,
    required this.cutoff,
    this.maxSpread = 0.10,
    this.logLossEps = 1e-6,
  });

  /// Policy identifier printed on every report.
  static const id = 'policy-v1';

  /// Only forecasts from exactly this prompt version are evaluated —
  /// versions are never pooled.
  final String promptVersion;

  /// Data cutoff: forecasts made after it, and outcomes that settled after
  /// it, are treated as not yet known.
  final DateTime cutoff;

  /// Widest YES spread (dollars) at which the mid is an acceptable benchmark.
  final double maxSpread;

  /// Log loss bounds probabilities to [eps, 1 - eps] inside the metric only.
  final double logLossEps;
}

/// Exclusion reasons, in the order they are checked. Each row gets the first
/// reason that applies.
enum Exclusion {
  legacy('Legacy row (no prompt_version)'),
  otherPromptVersion('Different prompt version'),
  scoredAfterCutoff('Scored after the data cutoff'),
  invalidProbability('AI probability not in [0, 1]'),
  unchecked('Outcome never checked'),
  pending('Outcome pending'),
  disputed('Outcome disputed/amended'),
  nonbinary('Scalar / non-binary settlement'),
  exception('Finalized but not a clean yes/no'),
  settledAfterCutoff('Outcome settled after the data cutoff'),
  missingCloseTime('Close time unknown'),
  scoredAfterClose('Scored at/after market close'),
  missingBenchmark('Market quotes missing'),
  wideSpread('Spread wider than policy maximum'),
  superseded('Later forecast for an already-selected market');

  const Exclusion(this.label);
  final String label;
}

class Selection {
  Selection(this.selected, this.excluded);

  /// One observation per market: the earliest eligible forecast.
  final List<Observation> selected;
  final Map<Observation, Exclusion> excluded;

  Map<Exclusion, int> get exclusionCounts {
    final counts = <Exclusion, int>{};
    for (final e in excluded.values) {
      counts[e] = (counts[e] ?? 0) + 1;
    }
    return counts;
  }
}

Exclusion? _reason(Observation o, EvalPolicy p) {
  if (o.promptVersion == null) return Exclusion.legacy;
  if (o.promptVersion != p.promptVersion) return Exclusion.otherPromptVersion;
  if (o.scoredAt.isAfter(p.cutoff)) return Exclusion.scoredAfterCutoff;
  if (!o.q.isFinite || o.q < 0 || o.q > 1) return Exclusion.invalidProbability;
  switch (o.resolution) {
    case null:
      return Exclusion.unchecked;
    case 'yes' || 'no':
      break;
    case 'disputed':
      return Exclusion.disputed;
    case 'nonbinary':
      return Exclusion.nonbinary;
    case 'exception':
      return Exclusion.exception;
    default:
      return Exclusion.pending;
  }
  // A label is only usable if it was known by the cutoff.
  if (o.settlementTs == null || o.settlementTs!.isAfter(p.cutoff)) {
    return Exclusion.settledAfterCutoff;
  }
  if (o.closeTime == null) return Exclusion.missingCloseTime;
  if (!o.scoredAt.isBefore(o.closeTime!)) return Exclusion.scoredAfterClose;
  final m = o.m;
  if (m == null || !m.isFinite || m < 0 || m > 1 || o.spread == null) {
    return Exclusion.missingBenchmark;
  }
  if (o.spread! > p.maxSpread + 1e-12) return Exclusion.wideSpread;
  return null;
}

/// Apply [policy]: per-row exclusion reasons, then the earliest eligible
/// forecast per market. Ties on scoredAt break on scoreId for determinism.
Selection select(List<Observation> rows, EvalPolicy policy) {
  final excluded = <Observation, Exclusion>{};
  final eligible = <Observation>[];
  for (final o in rows) {
    final r = _reason(o, policy);
    if (r == null) {
      eligible.add(o);
    } else {
      excluded[o] = r;
    }
  }
  eligible.sort((a, b) {
    final t = a.scoredAt.compareTo(b.scoredAt);
    return t != 0 ? t : a.scoreId.compareTo(b.scoreId);
  });
  final seen = <String>{};
  final selected = <Observation>[];
  for (final o in eligible) {
    if (seen.add(o.marketTicker)) {
      selected.add(o);
    } else {
      excluded[o] = Exclusion.superseded;
    }
  }
  selected.sort((a, b) => a.marketTicker.compareTo(b.marketTicker));
  return Selection(selected, excluded);
}
