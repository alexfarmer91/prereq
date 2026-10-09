/// Milestone 2: does combining the AI with the market beat the market?
///
/// Fits on forecasts whose outcomes were known by [trainCutoff] and scores on
/// forecasts made strictly after it, so nothing is tested on data it was
/// fitted to. Compares:
///   1. market:             p = m
///   2. recalibrated market: logit p = a + b·logit m   (market-only baseline)
///   3. raw AI:             p = q
///   4. blend:              p = m + α(q − m),  α ∈ [0, 1]
/// α = 0 ("ignore the AI") is a legitimate result.
library;

import 'dart:convert';
import 'dart:math' as math;

import 'metrics.dart';
import 'observation.dart';
import 'selection.dart';

const blendArtifactVersion = 'blend-v1';

double _logit(double p, [double eps = 1e-4]) {
  final b = p.clamp(eps, 1 - eps);
  return math.log(b / (1 - b));
}

double _sigmoid(double x) => 1 / (1 + math.exp(-x));

/// Logistic regression of y on logit(m) by Newton–Raphson. Null if it fails
/// to converge (e.g. perfectly separable data).
(double, double)? fitRecalibration(List<Pair> train) {
  var a = 0.0, b = 1.0;
  for (var iter = 0; iter < 50; iter++) {
    var g0 = 0.0, g1 = 0.0, h00 = 0.0, h01 = 0.0, h11 = 0.0;
    for (final p in train) {
      final x = _logit(p.market);
      final mu = _sigmoid(a + b * x);
      final w = mu * (1 - mu);
      g0 += p.y - mu;
      g1 += (p.y - mu) * x;
      h00 += w;
      h01 += w * x;
      h11 += w * x * x;
    }
    final det = h00 * h11 - h01 * h01;
    if (det.abs() < 1e-12) return null;
    final da = (h11 * g0 - h01 * g1) / det;
    final db = (h00 * g1 - h01 * g0) / det;
    a += da;
    b += db;
    if (!a.isFinite || !b.isFinite || a.abs() > 50 || b.abs() > 50) return null;
    if (da.abs() < 1e-10 && db.abs() < 1e-10) return (a, b);
  }
  return null;
}

/// α on a 0.01 grid minimizing mean log loss; ties go to the smaller α.
double fitAlpha(List<Pair> train, double eps) {
  var best = 0.0, bestLoss = double.infinity;
  for (var i = 0; i <= 100; i++) {
    final alpha = i / 100;
    final loss = mean(
      train.map((p) => logLoss(p.market + alpha * (p.ai - p.market), p.y, eps)),
    );
    if (loss < bestLoss - 1e-15) {
      bestLoss = loss;
      best = alpha;
    }
  }
  return best;
}

class ModelResult {
  ModelResult(
    this.name,
    this.brier,
    this.logLoss,
    this.improvementVsMarket,
    this.interval,
  );
  final String name;
  final double brier;
  final double logLoss;

  /// Mean per-event Brier improvement over the raw market on the test set.
  final double improvementVsMarket;
  final Interval? interval;
}

class BlendReport {
  BlendReport({
    required this.policy,
    required this.trainCutoff,
    required this.train,
    required this.test,
    required this.straddling,
    required this.minTrainEvents,
    required this.seed,
    required this.synthetic,
  }) {
    final trainEvents = train.map((p) => p.group).toSet().length;
    if (trainEvents >= minTrainEvents) {
      alpha = fitAlpha(train, policy.logLossEps);
      recal = fitRecalibration(train);
    }
  }

  final EvalPolicy policy;
  final DateTime trainCutoff;
  final List<Pair> train;
  final List<Pair> test;

  /// Forecasts made before the train cutoff whose outcome came after it —
  /// usable for neither fitting nor testing.
  final int straddling;
  final int minTrainEvents;
  final int seed;
  final bool synthetic;

  double? alpha;
  (double, double)? recal;

  bool get fitted => alpha != null;

  List<ModelResult> results() {
    if (!fitted || test.isEmpty) return [];
    final eps = policy.logLossEps;
    ModelResult score(String name, double Function(Pair) predict) {
      final relabeled = [
        for (final p in test)
          Pair(group: p.group, ai: predict(p), market: p.market, y: p.y),
      ];
      final s = PairedScores(relabeled, eps: eps);
      return ModelResult(
        name,
        s.aiBrier,
        s.aiLogLoss,
        s.eventImprovement,
        improvementInterval(relabeled, seed: seed),
      );
    }

    final a = alpha!;
    return [
      score('market', (p) => p.market),
      if (recal != null)
        score(
          'recalibrated market',
          (p) => _sigmoid(recal!.$1 + recal!.$2 * _logit(p.market)),
        ),
      score('raw AI', (p) => p.ai),
      score(
        'blend α=${a.toStringAsFixed(2)}',
        (p) => p.market + a * (p.ai - p.market),
      ),
    ];
  }

  /// Versioned artifact — kept separate from raw forecasts, never deployed
  /// by this tool.
  String artifactJson() => const JsonEncoder.withIndent('  ').convert({
    'artifact': blendArtifactVersion,
    'synthetic': synthetic,
    'policy': EvalPolicy.id,
    'prompt_version': policy.promptVersion,
    'train_cutoff': trainCutoff.toIso8601String(),
    'data_cutoff': policy.cutoff.toIso8601String(),
    'train_markets': train.length,
    'train_events': train.map((p) => p.group).toSet().length,
    'test_markets': test.length,
    'alpha': alpha,
    'recalibration': recal == null ? null : {'a': recal!.$1, 'b': recal!.$2},
    'objective': 'mean log loss, eps ${policy.logLossEps}',
    'alpha_grid': '0.00..1.00 step 0.01, ties to smaller',
  });

  String toText() {
    final b = StringBuffer();
    String f(double x) => x.isNaN ? 'n/a' : x.toStringAsFixed(4);
    String signed(double x) =>
        x.isNaN ? 'n/a' : '${x >= 0 ? '+' : ''}${x.toStringAsFixed(4)}';
    if (synthetic) b.writeln('*** SYNTHETIC DATA — NOT REAL PERFORMANCE ***\n');
    b.writeln(
      'Blend evaluation ($blendArtifactVersion, ${EvalPolicy.id}, prompt version '
      '${policy.promptVersion})',
    );
    b.writeln(
      'Train: outcomes known by ${trainCutoff.toIso8601String()} — '
      '${train.length} markets, ${train.map((p) => p.group).toSet().length} events',
    );
    b.writeln(
      'Test:  forecasts made after it, settled by ${policy.cutoff.toIso8601String()} — '
      '${test.length} markets, ${test.map((p) => p.group).toSet().length} events',
    );
    b.writeln('Unusable (forecast before cutoff, outcome after): $straddling');
    b.writeln();
    if (!fitted) {
      b.writeln(
        'INSUFFICIENT TRAINING DATA: fewer than $minTrainEvents resolved events '
        'before the train cutoff. Nothing was fitted.',
      );
      return b.toString();
    }
    b.writeln(
      'Fitted α = ${alpha!.toStringAsFixed(2)} '
      '(0 = ignore the AI, 1 = use the AI alone)',
    );
    b.writeln(
      recal == null
          ? 'Market recalibration did not converge; omitted.'
          : 'Market recalibration: logit p = ${f(recal!.$1)} + ${f(recal!.$2)}·logit m',
    );
    b.writeln();
    if (test.isEmpty) {
      b.writeln(
        'INSUFFICIENT TEST DATA: no resolved forecasts after the train cutoff yet.',
      );
      return b.toString();
    }
    b.writeln(
      'Test-period results (lower loss is better; improvement is vs. raw market, per event):',
    );
    for (final r in results()) {
      final ci = r.interval;
      b.writeln(
        '  ${r.name.padRight(22)} Brier ${f(r.brier)}  log loss ${f(r.logLoss)}  '
        'improvement ${signed(r.improvementVsMarket)}  '
        '${ci == null ? '(interval: <10 events)' : '95% [${signed(ci.low)}, ${signed(ci.high)}]'}',
      );
    }
    b.writeln();
    b.writeln(
      'A positive α or a test-period win is not proof of usefulness on its own: '
      'check the interval, and re-confirm on the next untouched period.',
    );
    return b.toString();
  }
}

BlendReport blend(
  List<Observation> rows,
  EvalPolicy policy, {
  required DateTime trainCutoff,
  int minTrainEvents = 30,
  int seed = 42,
}) {
  final selected = select(rows, policy).selected;
  final train = <Pair>[], test = <Pair>[];
  var straddling = 0;
  for (final o in selected) {
    final pair = Pair(group: o.group, ai: o.q, market: o.m!, y: o.y!);
    if (o.scoredAt.isAfter(trainCutoff)) {
      test.add(pair);
    } else if (!o.settlementTs!.isAfter(trainCutoff)) {
      train.add(pair);
    } else {
      straddling++;
    }
  }
  return BlendReport(
    policy: policy,
    trainCutoff: trainCutoff,
    train: train,
    test: test,
    straddling: straddling,
    minTrainEvents: minTrainEvents,
    seed: seed,
    synthetic: rows.any((o) => o.isSynthetic),
  );
}
