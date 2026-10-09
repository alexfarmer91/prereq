/// Milestone 3: hypothetical, execution-aware shadow evaluation.
///
/// Answers "had we mechanically traded on the AI estimate under a frozen,
/// pre-declared policy, what would have happened?" It never places orders.
/// It is deliberately conservative and still incomplete — see [caveats].
library;

import 'dart:convert';

import 'metrics.dart';
import 'observation.dart';
import 'selection.dart';

const shadowPolicyVersion = 'shadow-v1';

/// Kalshi trading-fee model, loaded from a JSON config so coefficients can be
/// checked against Kalshi's published fee schedule and changed without code.
///
/// Fee per order = ceil_to_cent(coefficient × multiplier × C × P × (1 − P)),
/// the "quadratic" fee type. Series listed in [unsupportedSeries] (e.g.
/// Kalshi's "flat" fee type) are skipped rather than guessed.
class FeeModel {
  FeeModel({
    required this.verified,
    required this.source,
    required this.coefficient,
    this.seriesMultipliers = const {},
    this.unsupportedSeries = const {},
  });

  factory FeeModel.fromJson(Map<String, dynamic> j) => FeeModel(
    verified: j['verified'] == true,
    source: (j['source'] ?? '').toString(),
    coefficient: (j['taker_coefficient'] as num).toDouble(),
    seriesMultipliers: {
      for (final e in ((j['series_multipliers'] ?? {}) as Map).entries)
        e.key.toString(): (e.value as num).toDouble(),
    },
    unsupportedSeries: {
      for (final s in (j['unsupported_series'] ?? []) as List) s.toString(),
    },
  );

  static FeeModel parse(String json) =>
      FeeModel.fromJson(jsonDecode(json) as Map<String, dynamic>);

  /// False until someone checks [coefficient] against Kalshi's fee schedule.
  final bool verified;
  final String source;
  final double coefficient;
  final Map<String, double> seriesMultipliers;
  final Set<String> unsupportedSeries;

  /// Fee in dollars for [contracts] at [price], or null if unsupported.
  double? fee(String series, int contracts, double price) {
    if (unsupportedSeries.contains(series)) return null;
    final raw =
        coefficient *
        (seriesMultipliers[series] ?? 1.0) *
        contracts *
        price *
        (1 - price);
    // Round up to the next cent; the epsilon absorbs float noise like 0.07000000001.
    return (raw * 100 - 1e-9).ceil().clamp(0, 1 << 31) / 100;
  }
}

/// Series ticker derived from the event ticker's prefix (KXFOO-26OCT07 →
/// KXFOO). Derived, not looked up — documented as such.
String seriesOf(Observation o) =>
    (o.eventTicker ?? o.marketTicker).split('-').first;

class ShadowPolicy {
  const ShadowPolicy({
    this.stakeDollars = 10,
    this.minEvAfterFees = 0.05,
    this.slippage = 0.01,
    this.alpha,
  });

  /// Fixed hypothetical stake per position — not Kelly.
  final double stakeDollars;

  /// Minimum expected return per dollar, after fees, to enter.
  final double minEvAfterFees;

  /// Dollars added to the ask: a crude penalty for the reaction delay
  /// between the quotes shown to the AI and the forecast becoming usable.
  final double slippage;

  /// If set, trade on m + α(q − m) instead of the raw AI probability.
  final double? alpha;
}

class Trade {
  Trade(
    this.obs,
    this.side,
    this.contracts,
    this.price,
    this.fee,
    this.expectedReturn,
  );
  final Observation obs;
  final String side;
  final int contracts;
  final double price;
  final double fee;
  final double expectedReturn;

  double get cost => contracts * price + fee;
  bool get won => (side == 'yes') == (obs.y == 1.0);
  double get pnl => (won ? contracts.toDouble() : 0) - cost;
}

class ShadowReport {
  ShadowReport(
    this.policy,
    this.evalPolicy,
    this.fees,
    this.trades,
    this.skips,
    this.synthetic,
    this.seed,
  );

  final ShadowPolicy policy;
  final EvalPolicy evalPolicy;
  final FeeModel fees;
  final List<Trade> trades;
  final Map<String, int> skips;
  final bool synthetic;
  final int seed;

  static const caveats = [
    'Fills assume the full stake executes at the (penalized) top-of-book ask; '
        'order-book depth was not recorded, so larger sizes would do worse.',
    'Quotes are those shown to the AI at request time, not at the moment the '
        'forecast became usable; the slippage penalty only approximates this.',
    'One position per market, held to settlement; no exits, no re-entry on refreshes.',
    'Capital is tied up until settlement; ROI below is not annualized.',
    'Positions in the same event are correlated; the interval resamples whole events '
        'but same-series events remain correlated.',
  ];

  double get totalCost => trades.fold(0.0, (s, t) => s + t.cost);
  double get totalFees => trades.fold(0.0, (s, t) => s + t.fee);
  double get totalPnl => trades.fold(0.0, (s, t) => s + t.pnl);
  double get roi => totalCost == 0 ? double.nan : totalPnl / totalCost;

  double get maxEventExposure {
    final byEvent = <String, double>{};
    for (final t in trades) {
      byEvent[t.obs.group] = (byEvent[t.obs.group] ?? 0) + t.cost;
    }
    return byEvent.values.fold(0.0, (a, b) => a > b ? a : b);
  }

  double get meanDaysLocked => mean(
    trades
        .where((t) => t.obs.settlementTs != null)
        .map(
          (t) =>
              t.obs.settlementTs!.difference(t.obs.scoredAt).inMinutes / 1440,
        ),
  );

  Interval? get roiInterval {
    final groups = <String, List<Trade>>{};
    for (final t in trades) {
      (groups[t.obs.group] ??= []).add(t);
    }
    return groupBootstrap<Trade>(groups, (sample) {
      var pnl = 0.0, cost = 0.0;
      for (final g in sample) {
        for (final t in g) {
          pnl += t.pnl;
          cost += t.cost;
        }
      }
      return cost == 0 ? double.nan : pnl / cost;
    }, seed: seed);
  }

  String toText() {
    final b = StringBuffer();
    String d(double x) => x.isNaN ? 'n/a' : '\$${x.toStringAsFixed(2)}';
    String pct(double x) =>
        x.isNaN ? 'n/a' : '${(x * 100).toStringAsFixed(1)}%';
    if (synthetic) b.writeln('*** SYNTHETIC DATA — NOT REAL PERFORMANCE ***\n');
    b.writeln(
      'HYPOTHETICAL shadow evaluation — no orders were or will be placed.',
    );
    b.writeln(
      '$shadowPolicyVersion | ${EvalPolicy.id} | prompt version ${evalPolicy.promptVersion} | '
      'stake ${d(policy.stakeDollars)} | min EV after fees ${pct(policy.minEvAfterFees)} | '
      'slippage ${d(policy.slippage)} | '
      'probability ${policy.alpha == null ? 'raw AI' : 'blend α=${policy.alpha}'}',
    );
    b.writeln('Fees: coefficient ${fees.coefficient} (${fees.source})');
    if (!fees.verified) {
      b.writeln(
        'WARNING: fee coefficients are UNVERIFIED against Kalshi\'s fee schedule. '
        'Results may be wrong.',
      );
    }
    b.writeln();
    b.writeln('Markets skipped:');
    if (skips.isEmpty) b.writeln('  (none)');
    for (final e in skips.entries) {
      b.writeln('  ${e.value.toString().padLeft(6)}  ${e.key}');
    }
    b.writeln();
    if (trades.isEmpty) {
      b.writeln(
        'NO TRADES: nothing met the policy. No performance is reported.',
      );
    } else {
      final wins = trades.where((t) => t.won).length;
      b.writeln(
        'Trades: ${trades.length} in ${trades.map((t) => t.obs.group).toSet().length} events '
        '($wins won)',
      );
      b.writeln(
        'Committed ${d(totalCost)} incl. fees ${d(totalFees)}; P&L ${d(totalPnl)}; '
        'ROI ${pct(roi)}',
      );
      b.writeln(
        'Largest single-event exposure ${d(maxEventExposure)}; '
        'mean days to settlement ${meanDaysLocked.isNaN ? 'n/a' : meanDaysLocked.toStringAsFixed(1)}',
      );
      final ci = roiInterval;
      b.writeln(
        ci == null
            ? 'ROI interval: not computed — fewer than 10 events.'
            : 'ROI 95% event-bootstrap interval: [${pct(ci.low)}, ${pct(ci.high)}]',
      );
    }
    b.writeln();
    b.writeln('Not modeled:');
    for (final c in caveats) {
      b.writeln('  - $c');
    }
    return b.toString();
  }
}

ShadowReport simulate(
  List<Observation> rows,
  EvalPolicy evalPolicy,
  FeeModel fees, {
  ShadowPolicy policy = const ShadowPolicy(),
  int seed = 42,
}) {
  final trades = <Trade>[];
  final skips = <String, int>{};
  void skip(String why) => skips[why] = (skips[why] ?? 0) + 1;

  for (final o in select(rows, evalPolicy).selected) {
    final p = policy.alpha == null ? o.q : o.m! + policy.alpha! * (o.q - o.m!);
    final series = seriesOf(o);
    Trade? best;
    var sawQuote = false, sawFee = false;
    for (final (side, ask, win) in [
      ('yes', o.yesAsk, p),
      ('no', o.noAsk, 1 - p),
    ]) {
      if (ask == null || ask <= 0 || ask >= 1) continue;
      sawQuote = true;
      final price = ask + policy.slippage;
      if (price >= 1) continue;
      final contracts = (policy.stakeDollars / price).floor();
      if (contracts == 0) continue;
      final fee = fees.fee(series, contracts, price);
      if (fee == null) continue;
      sawFee = true;
      final cost = contracts * price + fee;
      final ev = (contracts * win - cost) / cost;
      if (ev >= policy.minEvAfterFees &&
          (best == null || ev > best.expectedReturn)) {
        best = Trade(o, side, contracts, price, fee, ev);
      }
    }
    if (!sawQuote) {
      skip('no usable ask');
    } else if (!sawFee) {
      skip('fees unavailable for series');
    } else if (best == null) {
      skip('EV after fees below threshold');
    } else {
      trades.add(best);
    }
  }
  return ShadowReport(
    policy,
    evalPolicy,
    fees,
    trades,
    skips,
    rows.any((o) => o.isSynthetic),
    seed,
  );
}
