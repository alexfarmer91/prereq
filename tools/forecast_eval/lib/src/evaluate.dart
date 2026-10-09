/// Forecast evaluation: AI vs. market on the same selected markets.
library;

import 'csv.dart';
import 'metrics.dart';
import 'observation.dart';
import 'selection.dart';

/// Below this many markets in a group, results are flagged as sparse.
const sparseThreshold = 30;

/// A failed scoring attempt from the ai_score_failures export.
class FailureRow {
  FailureRow(this.promptVersion, this.errorKind, this.requestedAt);
  final String? promptVersion;
  final String errorKind;
  final DateTime? requestedAt;

  static FailureRow fromRecord(Map<String, String> r) => FailureRow(
    (r['prompt_version'] ?? '').trim().isEmpty
        ? null
        : r['prompt_version']!.trim(),
    (r['error_kind'] ?? 'other').trim(),
    DateTime.tryParse((r['requested_at'] ?? '').trim())?.toUtc(),
  );
}

String horizonBucket(Observation o) {
  final d = o.horizonDays;
  if (d == null) return 'unknown';
  if (d < 1) return '<1d';
  if (d < 7) return '1-7d';
  if (d < 30) return '7-30d';
  return '30d+';
}

class Breakdown {
  Breakdown(this.dimension, this.groups);
  final String dimension;
  final Map<String, PairedScores> groups;
}

class EvalReport {
  EvalReport({
    required this.policy,
    required this.rowCount,
    required this.selection,
    required this.failures,
    required this.seed,
  }) : scores = PairedScores([
         for (final o in selection.selected) toPair(o),
       ], eps: policy.logLossEps);

  final EvalPolicy policy;
  final int rowCount;
  final Selection selection;
  final List<FailureRow> failures;
  final int seed;
  final PairedScores scores;

  bool get synthetic =>
      selection.selected.any((o) => o.isSynthetic) ||
      selection.excluded.keys.any((o) => o.isSynthetic);

  static Pair toPair(Observation o) =>
      Pair(group: o.group, ai: o.q, market: o.m!, y: o.y!);

  Interval? get interval => improvementInterval(scores.pairs, seed: seed);

  Map<String, int> get failureCounts {
    final counts = <String, int>{};
    for (final f in failures) {
      if (f.promptVersion != policy.promptVersion) continue;
      if (f.requestedAt != null && f.requestedAt!.isAfter(policy.cutoff)) {
        continue;
      }
      counts[f.errorKind] = (counts[f.errorKind] ?? 0) + 1;
    }
    return counts;
  }

  Breakdown breakdown(String dimension, String Function(Observation) key) {
    final grouped = <String, List<Pair>>{};
    for (final o in selection.selected) {
      (grouped[key(o)] ??= []).add(toPair(o));
    }
    return Breakdown(dimension, {
      for (final e in grouped.entries)
        e.key: PairedScores(e.value, eps: policy.logLossEps),
    });
  }

  List<Breakdown> get breakdowns => [
    breakdown('category', (o) => o.category ?? 'unknown'),
    breakdown('horizon', horizonBucket),
    breakdown('self-rated confidence', (o) => o.confidence ?? 'unknown'),
    breakdown(
      'web search',
      (o) => switch (o.webSearchEnabled) {
        true => 'on',
        false => 'off',
        null => 'unknown',
      },
    ),
  ];

  String toText() {
    final b = StringBuffer();
    String f(double x) => x.isNaN ? 'n/a' : x.toStringAsFixed(4);
    String signed(double x) =>
        x.isNaN ? 'n/a' : '${x >= 0 ? '+' : ''}${x.toStringAsFixed(4)}';

    if (synthetic) {
      b.writeln('*** SYNTHETIC DATA — NOT REAL PERFORMANCE ***\n');
    }
    b.writeln('Prereq forecast evaluation');
    b.writeln(
      'Policy ${EvalPolicy.id} | prompt version ${policy.promptVersion} | '
      'cutoff ${policy.cutoff.toIso8601String()} | max spread ${policy.maxSpread} | '
      'log-loss eps ${policy.logLossEps} | bootstrap seed $seed',
    );
    b.writeln();

    b.writeln('Rows read: $rowCount');
    b.writeln('Selected markets: ${scores.n} across ${scores.groups} events');
    b.writeln('Excluded rows:');
    final counts = selection.exclusionCounts;
    if (counts.isEmpty) b.writeln('  (none)');
    for (final e in Exclusion.values) {
      if (counts[e] != null) {
        b.writeln('  ${counts[e].toString().padLeft(6)}  ${e.label}');
      }
    }
    final fails = failureCounts;
    // Successful scores of this version made before the cutoff.
    final attempts = [...selection.selected, ...selection.excluded.keys]
        .where(
          (o) =>
              o.promptVersion == policy.promptVersion &&
              !o.scoredAt.isAfter(policy.cutoff),
        )
        .length;
    final failTotal = fails.values.fold(0, (a, b) => a + b);
    b.writeln(
      'Failed scoring attempts (this prompt version, before cutoff): $failTotal'
      '${failures.isEmpty ? ' (no failures file given)' : ''}',
    );
    for (final e in fails.entries) {
      b.writeln('  ${e.value.toString().padLeft(6)}  ${e.key}');
    }
    if (attempts + failTotal > 0) {
      b.writeln(
        'Failure rate: ${(100 * failTotal / (attempts + failTotal)).toStringAsFixed(1)}% '
        'of ${attempts + failTotal} attempts',
      );
    }
    b.writeln();

    if (scores.n == 0) {
      b.writeln(
        'INSUFFICIENT DATA: no eligible resolved forecasts. No scores are reported.',
      );
      return b.toString();
    }

    b.writeln(
      'Same ${scores.n} markets, AI vs. market (lower loss is better):',
    );
    b.writeln(
      '  Brier     AI ${f(scores.aiBrier)}   market ${f(scores.marketBrier)}',
    );
    b.writeln(
      '  Log loss  AI ${f(scores.aiLogLoss)}   market ${f(scores.marketLogLoss)}'
      '   (${scores.boundedRows} rows needed the eps bound)',
    );
    b.writeln(
      '  Brier improvement (market − AI), per market: ${signed(scores.brierImprovement)}',
    );
    b.writeln(
      '  Brier improvement, per event:                ${signed(scores.eventImprovement)}',
    );
    final ci = interval;
    if (ci == null) {
      b.writeln(
        '  95% interval: not computed — fewer than 10 events. '
        'Too little evidence to say anything.',
      );
    } else {
      b.writeln(
        '  95% event-bootstrap interval: [${signed(ci.low)}, ${signed(ci.high)}] '
        '(${ci.resamples} resamples)',
      );
      b.writeln(
        ci.excludesZero
            ? '  The interval excludes zero on this data. Confirm on a later, untouched period '
                  'before calling it an edge; same-series events are still correlated.'
            : '  The interval includes zero: no demonstrated difference from the market.',
      );
    }
    if (scores.n < sparseThreshold) {
      b.writeln(
        '  WARNING: only ${scores.n} markets — results are noise-dominated.',
      );
    }
    b.writeln();

    b.writeln('Calibration of AI probabilities (descriptive):');
    b.writeln('  bucket       n   mean AI   observed YES');
    for (final c in calibration(scores.pairs.map((p) => (p.ai, p.y)))) {
      if (c.n == 0) continue;
      b.writeln(
        '  ${c.low.toStringAsFixed(1)}-${c.high.toStringAsFixed(1)} '
        '${c.n.toString().padLeft(6)}   ${f(c.meanP)}    ${f(c.observed)}'
        '${c.n < sparseThreshold ? '   (sparse)' : ''}',
      );
    }
    b.writeln();

    b.writeln(
      'Breakdowns (descriptive only — a subgroup "win" is a hypothesis, not an edge):',
    );
    for (final bd in breakdowns) {
      b.writeln('  By ${bd.dimension}:');
      final keys = bd.groups.keys.toList()..sort();
      for (final k in keys) {
        final s = bd.groups[k]!;
        b.writeln(
          '    ${k.padRight(14)} n=${s.n.toString().padLeft(4)} events=${s.groups.toString().padLeft(4)} '
          'AI ${f(s.aiBrier)} mkt ${f(s.marketBrier)} improvement ${signed(s.brierImprovement)}'
          '${s.n < sparseThreshold ? '  (sparse)' : ''}',
        );
      }
    }
    return b.toString();
  }

  /// Every input row with its fate, so the summary can be reproduced.
  String auditCsv() {
    final rows = <List<Object?>>[
      [
        'score_id',
        'market_ticker',
        'event_group',
        'prompt_version',
        'scored_at',
        'q_ai', 'm_market', 'y', 'status', 'ai_brier', 'market_brier', //
      ],
    ];
    final all = [...selection.selected, ...selection.excluded.keys]
      ..sort((a, b) => a.scoreId.compareTo(b.scoreId));
    final selected = selection.selected.toSet();
    for (final o in all) {
      final sel = selected.contains(o);
      rows.add([
        o.scoreId,
        o.marketTicker,
        o.group,
        o.promptVersion ?? 'legacy',
        o.scoredAt.toIso8601String(),
        o.q,
        o.m,
        o.y,
        sel ? 'selected' : selection.excluded[o]!.name,
        sel ? brier(o.q, o.y!) : null,
        sel ? brier(o.m!, o.y!) : null,
      ]);
    }
    final csv = toCsv(rows);
    return synthetic ? '# SYNTHETIC DATA — NOT REAL PERFORMANCE\n$csv' : csv;
  }
}

EvalReport evaluate(
  List<Observation> rows,
  EvalPolicy policy, {
  List<FailureRow> failures = const [],
  int seed = 42,
}) => EvalReport(
  policy: policy,
  rowCount: rows.length,
  selection: select(rows, policy),
  failures: failures,
  seed: seed,
);
