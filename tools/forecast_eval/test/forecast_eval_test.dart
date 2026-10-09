import 'dart:math' as math;

import 'package:forecast_eval/forecast_eval.dart';
import 'package:test/test.dart';

final t0 = DateTime.utc(2026, 11, 1);
final cutoff = DateTime.utc(2027, 6, 1);
final policy = EvalPolicy(promptVersion: '3', cutoff: cutoff);

var _id = 0;

/// A clean, eligible synthetic row unless overridden.
Observation obs({
  String? ticker,
  String? event,
  double q = 0.6,
  double? m = 0.5,
  String? resolution = 'yes',
  String? promptVersion = '3',
  Duration scoredAfter = Duration.zero,
  Duration closeAfter = const Duration(days: 5),
  Duration settledAfter = const Duration(days: 6),
  double spread = 0.02,
  bool settled = true,
}) {
  final id = ++_id;
  final scored = t0.add(scoredAfter);
  final mid = m;
  return Observation(
    scoreId: '$id'.padLeft(6, '0'),
    marketTicker: ticker ?? '${syntheticPrefix}M$id',
    eventTicker: event,
    promptVersion: promptVersion,
    confidence: 'medium',
    category: 'Politics',
    q: q,
    m: mid,
    yesBid: mid == null ? null : mid - spread / 2,
    yesAsk: mid == null ? null : mid + spread / 2,
    noBid: mid == null ? null : 1 - mid - spread / 2,
    noAsk: mid == null ? null : 1 - mid + spread / 2,
    scoredAt: scored,
    closeTime: scored.add(closeAfter),
    resolution: resolution,
    settlementTs: settled ? scored.add(settledAfter) : null,
  );
}

void main() {
  group('CSV', () {
    test('handles quotes, commas, newlines and CRLF', () {
      final rows = parseCsv('a,b\r\n"x, y","he said ""hi""\nthere"\r\n');
      expect(rows, [
        ['a', 'b'],
        ['x, y', 'he said "hi"\nthere'],
      ]);
      expect(parseCsv(toCsv(rows)), rows);
    });

    test('parses an export row including Postgres timestamps', () {
      final csv =
          '${exportColumns.join(',')}\n'
          '1,KX-A,KX,Politics,3,high,0.62,0.55,0.54,0.56,0.44,0.46,'
          '2026-10-07 12:00:00+00,2026-10-07 12:00:20.5+00,2026-10-09 00:00:00+00,t,yes,'
          '2026-10-09 02:00:00+00\n';
      final o = Observation.fromRecord(parseCsvRecords(csv).single);
      expect(o.q, 0.62);
      expect(o.scoredAt, DateTime.utc(2026, 10, 7, 12, 0, 20, 500));
      expect(o.webSearchEnabled, isTrue);
      expect(o.y, 1.0);
      expect(o.spread, closeTo(0.02, 1e-12));
    });
  });

  group('selection', () {
    test('excludes each failure mode with its own reason', () {
      final rows = [
        obs(promptVersion: null),
        obs(promptVersion: '2'),
        obs(scoredAfter: const Duration(days: 400)),
        obs(q: 1.3),
        obs(resolution: null),
        obs(resolution: 'pending'),
        obs(resolution: 'disputed'),
        obs(resolution: 'nonbinary'),
        obs(resolution: 'exception'),
        obs(settledAfter: const Duration(days: 300)),
        obs(closeAfter: Duration.zero),
        obs(m: null),
        obs(spread: 0.2),
        obs(),
      ];
      final s = select(rows, policy);
      expect(s.selected, hasLength(1));
      expect(s.exclusionCounts, {
        Exclusion.legacy: 1,
        Exclusion.otherPromptVersion: 1,
        Exclusion.scoredAfterCutoff: 1,
        Exclusion.invalidProbability: 1,
        Exclusion.unchecked: 1,
        Exclusion.pending: 1,
        Exclusion.disputed: 1,
        Exclusion.nonbinary: 1,
        Exclusion.exception: 1,
        Exclusion.settledAfterCutoff: 1,
        Exclusion.scoredAfterClose: 1,
        Exclusion.missingBenchmark: 1,
        Exclusion.wideSpread: 1,
      });
    });

    test('repeated forecasts on one market count once (earliest wins)', () {
      final rows = [
        obs(ticker: 'SYN-X', q: 0.9, scoredAfter: const Duration(hours: 5)),
        obs(ticker: 'SYN-X', q: 0.2),
        obs(ticker: 'SYN-X', q: 0.7, scoredAfter: const Duration(hours: 9)),
      ];
      final s = select(rows, policy);
      expect(s.selected.single.q, 0.2);
      expect(s.exclusionCounts[Exclusion.superseded], 2);
    });

    test('an outcome unknown at the cutoff is not used', () {
      final early = EvalPolicy(
        promptVersion: '3',
        cutoff: t0.add(const Duration(days: 2)),
      );
      final s = select([obs(settledAfter: const Duration(days: 3))], early);
      expect(s.selected, isEmpty);
      expect(s.exclusionCounts[Exclusion.settledAfterCutoff], 1);
    });
  });

  group('evaluation', () {
    test('AI closer to outcomes than the market → positive improvement', () {
      final rows = [
        for (var i = 0; i < 20; i++) ...[
          obs(event: 'SYN-E$i', q: 0.8, m: 0.6, resolution: 'yes'),
          obs(event: 'SYN-E$i', q: 0.2, m: 0.4, resolution: 'no'),
        ],
      ];
      final r = evaluate(rows, policy);
      expect(r.scores.n, 40);
      expect(r.scores.groups, 20);
      expect(r.scores.aiBrier, closeTo(0.04, 1e-12));
      expect(r.scores.marketBrier, closeTo(0.16, 1e-12));
      expect(r.scores.brierImprovement, closeTo(0.12, 1e-12));
      expect(r.interval!.excludesZero, isTrue);
    });

    test('AI worse than the market → negative improvement', () {
      final rows = [
        for (var i = 0; i < 12; i++)
          obs(event: 'SYN-E$i', q: 0.3, m: 0.7, resolution: 'yes'),
      ];
      final r = evaluate(rows, policy);
      expect(r.scores.brierImprovement, closeTo(0.09 - 0.49, 1e-12));
      expect(r.interval!.high, lessThan(0));
    });

    test('identical forecasts → zero improvement', () {
      final rows = [
        for (var i = 0; i < 12; i++)
          obs(
            event: 'SYN-E$i',
            q: 0.55,
            m: 0.55,
            resolution: i.isEven ? 'yes' : 'no',
          ),
      ];
      final r = evaluate(rows, policy);
      expect(r.scores.brierImprovement, 0);
      expect(r.interval!.excludesZero, isFalse);
    });

    test('related strikes in one event count as one unit of evidence', () {
      // One event with 10 strikes where the AI wins big, 9 single-market
      // events where it loses slightly: per-market says AI wins, per-event
      // says it loses.
      final rows = [
        for (var i = 0; i < 10; i++)
          obs(event: 'SYN-BIG', q: 0.9, m: 0.5, resolution: 'yes'),
        for (var i = 0; i < 9; i++)
          obs(event: 'SYN-E$i', q: 0.5, m: 0.6, resolution: 'yes'),
      ];
      final r = evaluate(rows, policy);
      expect(r.scores.brierImprovement, greaterThan(0));
      expect(r.scores.eventImprovement, lessThan(0));
    });

    test(
      'extreme probabilities are bounded only inside log loss and reported',
      () {
        final r = evaluate([obs(q: 1.0, m: 0.5, resolution: 'no')], policy);
        expect(r.scores.aiLogLoss, closeTo(13.8155, 1e-3)); // -ln(1e-6)
        expect(r.scores.boundedRows, 1);
        expect(r.selection.selected.single.q, 1.0); // raw value untouched
      },
    );

    test('no eligible data → insufficient-data report, no numbers', () {
      final r = evaluate([obs(resolution: 'pending')], policy);
      final text = r.toText();
      expect(text, contains('INSUFFICIENT DATA'));
      expect(text, isNot(contains('Brier')));
      expect(evaluate([], policy).toText(), contains('INSUFFICIENT DATA'));
    });

    test('fewer than 10 events → no interval', () {
      final r = evaluate([
        for (var i = 0; i < 5; i++) obs(event: 'SYN-E$i'),
      ], policy);
      expect(r.interval, isNull);
      expect(r.toText(), contains('not computed'));
      expect(r.toText(), contains('WARNING: only 5 markets'));
    });

    test('synthetic data is always stamped', () {
      final r = evaluate([obs()], policy);
      expect(r.toText(), startsWith('*** SYNTHETIC DATA'));
      expect(r.auditCsv(), startsWith('# SYNTHETIC DATA'));
    });

    test('failures are counted for this prompt version only', () {
      final r = evaluate(
        [obs()],
        policy,
        failures: [
          FailureRow('3', 'parse_failure', t0),
          FailureRow('3', 'abstained', t0),
          FailureRow('2', 'parse_failure', t0),
        ],
      );
      expect(r.failureCounts, {'parse_failure': 1, 'abstained': 1});
      expect(r.toText(), contains('Failure rate: 66.7% of 3 attempts'));
    });

    test('bootstrap is reproducible with a fixed seed', () {
      final rows = [
        for (var i = 0; i < 30; i++)
          obs(
            event: 'SYN-E$i',
            q: 0.5 + (i % 5) / 20,
            m: 0.6,
            resolution: i % 3 == 0 ? 'no' : 'yes',
          ),
      ];
      final a = evaluate(rows, policy).interval!;
      final b = evaluate(rows, policy).interval!;
      expect(a.low, b.low);
      expect(a.high, b.high);
    });

    test('audit CSV lists every row with its fate', () {
      final r = evaluate([obs(), obs(resolution: 'pending')], policy);
      final rows = parseCsv(r.auditCsv().split('\n').skip(1).join('\n'));
      expect(rows, hasLength(3));
      expect(rows.map((x) => x[8]).toSet(), {'status', 'selected', 'pending'});
    });
  });

  group('blend', () {
    test(
      'learns α near 0 when the AI is pure noise, α near 1 when it is sharp',
      () {
        final noisyAi = syntheticCsv(
          events: 150,
          aiNoise: 0.35,
          marketNoise: 0.02,
          seed: 1,
        );
        final sharpAi = syntheticCsv(
          events: 150,
          aiNoise: 0.01,
          marketNoise: 0.25,
          seed: 2,
        );
        double alphaFor(String csv) {
          final rows = parseCsvRecords(
            csv,
          ).map(Observation.fromRecord).toList();
          return blend(
            rows,
            policy,
            trainCutoff: DateTime.utc(2027, 1, 15),
          ).alpha!;
        }

        expect(alphaFor(noisyAi), lessThan(0.25));
        expect(alphaFor(sharpAi), greaterThan(0.75));
      },
    );

    test(
      'trains only on outcomes known by the train cutoff, tests only after it',
      () {
        final trainCutoff = t0.add(const Duration(days: 10));
        final rows = [
          obs(event: 'SYN-A', settledAfter: const Duration(days: 2)), // train
          obs(
            event: 'SYN-B',
            settledAfter: const Duration(days: 20),
          ), // straddles
          obs(event: 'SYN-C', scoredAfter: const Duration(days: 11)), // test
        ];
        final r = blend(
          rows,
          policy,
          trainCutoff: trainCutoff,
          minTrainEvents: 1,
        );
        expect(r.train, hasLength(1));
        expect(r.straddling, 1);
        expect(r.test, hasLength(1));
      },
    );

    test('refuses to fit on too little data', () {
      final r = blend([obs()], policy, trainCutoff: cutoff);
      expect(r.fitted, isFalse);
      expect(r.toText(), contains('INSUFFICIENT TRAINING DATA'));
    });

    test('market recalibration recovers a known distortion', () {
      // Outcomes follow sigmoid(0.5 + 1.0·logit m) exactly in expectation.
      final pairs = <Pair>[];
      for (var i = 1; i < 100; i++) {
        final m = i / 100;
        final logit = 0.5 + math.log(m / (1 - m));
        final p = 1 / (1 + math.exp(-logit));
        final yes = (p * 100).round();
        for (var k = 0; k < 100; k++) {
          pairs.add(
            Pair(group: 'g$i-$k', ai: m, market: m, y: k < yes ? 1 : 0),
          );
        }
      }
      final (a, b) = fitRecalibration(pairs)!;
      expect(a, closeTo(0.5, 0.05));
      expect(b, closeTo(1.0, 0.05));
    });
  });

  group('shadow simulation', () {
    final fees = FeeModel(verified: false, source: 'test', coefficient: 0.07);

    test('fees round up to the cent per order', () {
      // 0.07 × 10 × 0.5 × 0.5 = 0.175 → $0.18
      expect(fees.fee('S', 10, 0.5), 0.18);
      // 0.07 × 100 × 0.5 × 0.5 = 1.75 exactly → $1.75
      expect(fees.fee('S', 100, 0.5), 1.75);
      expect(fees.fee('S', 0, 0.5), 0);
      final multiplied = FeeModel(
        verified: false,
        source: '',
        coefficient: 0.07,
        seriesMultipliers: {'HALF': 0.5},
      );
      expect(multiplied.fee('HALF', 100, 0.5), 0.88);
      final unsupported = FeeModel(
        verified: false,
        source: '',
        coefficient: 0.07,
        unsupportedSeries: {'FLAT'},
      );
      expect(unsupported.fee('FLAT', 10, 0.5), isNull);
    });

    test(
      'takes the side with positive EV after fees and books P&L at settlement',
      () {
        // AI 0.80 vs YES ask 0.51 (+0.01 slippage = 0.52): 19 contracts.
        final r = simulate([obs(event: 'SYN-E', q: 0.8, m: 0.5)], policy, fees);
        final t = r.trades.single;
        expect(t.side, 'yes');
        expect(t.contracts, 19);
        expect(t.price, closeTo(0.52, 1e-12));
        // fee = ceil(0.07 × 19 × 0.52 × 0.48 × 100)/100 = ceil(33.2)/100 = 0.34
        expect(t.fee, 0.34);
        expect(t.pnl, closeTo(19 - 19 * 0.52 - 0.34, 1e-9));

        final no = simulate(
          [obs(event: 'SYN-E', q: 0.2, m: 0.5, resolution: 'yes')],
          policy,
          fees,
        );
        expect(no.trades.single.side, 'no');
        expect(no.trades.single.won, isFalse);
        expect(no.totalPnl, lessThan(0));
      },
    );

    test('small disagreements are eaten by fees and skipped', () {
      final r = simulate([obs(q: 0.53, m: 0.5)], policy, fees);
      expect(r.trades, isEmpty);
      expect(r.skips['EV after fees below threshold'], 1);
      expect(r.toText(), contains('NO TRADES'));
    });

    test('unverified fees are flagged and unsupported series skipped', () {
      final r = simulate(
        [obs(event: 'FLATSERIES-1', q: 0.9)],
        policy,
        FeeModel(
          verified: false,
          source: '',
          coefficient: 0.07,
          unsupportedSeries: {'FLATSERIES'},
        ),
      );
      expect(r.skips['fees unavailable for series'], 1);
      expect(r.toText(), contains('UNVERIFIED'));
      expect(r.toText(), contains('HYPOTHETICAL'));
    });

    test('a blend α of 0 never trades (it is just the market)', () {
      final r = simulate(
        [obs(q: 0.95, m: 0.5)],
        policy,
        fees,
        policy: const ShadowPolicy(alpha: 0),
      );
      expect(r.trades, isEmpty);
    });
  });
}
