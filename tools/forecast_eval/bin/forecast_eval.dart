import 'dart:io';

import 'package:args/args.dart';
import 'package:forecast_eval/forecast_eval.dart';

const usage = '''
Offline evaluation of Prereq AI forecasts. Reads CSV exports; no network, no DB.

  dart run bin/forecast_eval.dart evaluate --scores scores.csv --prompt-version 3 --cutoff 2027-03-01T00:00:00Z [--failures failures.csv] [--out out/]
  dart run bin/forecast_eval.dart blend    --scores scores.csv --prompt-version 3 --cutoff ... --train-cutoff ... [--out out/]
  dart run bin/forecast_eval.dart simulate --scores scores.csv --prompt-version 3 --cutoff ... --fees fees.kalshi.json [--stake 10] [--min-ev 0.05] [--slippage 0.01] [--alpha 0.3]
  dart run bin/forecast_eval.dart synthetic --out out/synthetic_scores.csv [--ai-noise 0.12] [--market-noise 0.08]

The export queries are in docs/forecast-validation.md.
''';

ArgParser _common(ArgParser p) => p
  ..addOption(
    'scores',
    help: 'CSV export of scores joined with outcomes',
    mandatory: true,
  )
  ..addOption(
    'prompt-version',
    help: 'Evaluate exactly this prompt version',
    mandatory: true,
  )
  ..addOption('cutoff', help: 'Data cutoff (ISO 8601, UTC)', mandatory: true)
  ..addOption('max-spread', defaultsTo: '0.10')
  ..addOption('seed', defaultsTo: '42')
  ..addOption('out', help: 'Directory for report/audit files');

Future<void> main(List<String> argv) async {
  try {
    await _run(argv);
  } on Object catch (e) {
    // Bad options, unreadable files, malformed CSV rows: explain, don't trace.
    if (e is! ArgumentError &&
        e is! FormatException &&
        e is! FileSystemException) {
      rethrow;
    }
    stderr.writeln('Error: $e\n\n$usage');
    exitCode = 64;
  }
}

Future<void> _run(List<String> argv) async {
  final parser = ArgParser()
    ..addCommand('evaluate', _common(ArgParser())..addOption('failures'))
    ..addCommand(
      'blend',
      _common(ArgParser())
        ..addOption('train-cutoff', mandatory: true)
        ..addOption('min-train-events', defaultsTo: '30'),
    )
    ..addCommand(
      'simulate',
      _common(ArgParser())
        ..addOption('fees', mandatory: true)
        ..addOption('stake', defaultsTo: '10')
        ..addOption('min-ev', defaultsTo: '0.05')
        ..addOption('slippage', defaultsTo: '0.01')
        ..addOption('alpha'),
    )
    ..addCommand(
      'synthetic',
      ArgParser()
        ..addOption('out', mandatory: true)
        ..addOption('ai-noise', defaultsTo: '0.12')
        ..addOption('market-noise', defaultsTo: '0.08')
        ..addOption('prompt-version', defaultsTo: '3')
        ..addOption('seed', defaultsTo: '7'),
    );

  // ArgParserException is a FormatException; main() reports both with usage.
  final cmd = parser.parse(argv).command;
  if (cmd == null) throw const FormatException('missing command');
  if (cmd.name == 'synthetic') {
    final out = File(cmd['out'] as String)..createSync(recursive: true);
    out.writeAsStringSync(
      syntheticCsv(
        aiNoise: double.parse(cmd['ai-noise'] as String),
        marketNoise: double.parse(cmd['market-noise'] as String),
        promptVersion: cmd['prompt-version'] as String,
        seed: int.parse(cmd['seed'] as String),
      ),
    );
    stdout.writeln('Wrote SYNTHETIC data to ${out.path}');
    return;
  }

  final rows = parseCsvRecords(
    File(cmd['scores'] as String).readAsStringSync(),
  ).map(Observation.fromRecord).toList();
  final policy = EvalPolicy(
    promptVersion: cmd['prompt-version'] as String,
    cutoff: DateTime.parse(cmd['cutoff'] as String).toUtc(),
    maxSpread: double.parse(cmd['max-spread'] as String),
  );
  final seed = int.parse(cmd['seed'] as String);
  final outDir = cmd['out'] as String?;
  void save(String name, String content) {
    if (outDir == null) return;
    final f = File('$outDir/$name')..createSync(recursive: true);
    f.writeAsStringSync(content);
    stdout.writeln('Wrote ${f.path}');
  }

  switch (cmd.name) {
    case 'evaluate':
      final failuresPath = cmd['failures'] as String?;
      final failures = failuresPath == null
          ? <FailureRow>[]
          : parseCsvRecords(
              File(failuresPath).readAsStringSync(),
            ).map(FailureRow.fromRecord).toList();
      final report = evaluate(rows, policy, failures: failures, seed: seed);
      final text = report.toText();
      stdout.write(text);
      save('evaluation.txt', text);
      save('evaluation_audit.csv', report.auditCsv());
    case 'blend':
      final report = blend(
        rows,
        policy,
        trainCutoff: DateTime.parse(cmd['train-cutoff'] as String).toUtc(),
        minTrainEvents: int.parse(cmd['min-train-events'] as String),
        seed: seed,
      );
      final text = report.toText();
      stdout.write(text);
      save('blend.txt', text);
      if (report.fitted) {
        save('$blendArtifactVersion.json', report.artifactJson());
      }
    case 'simulate':
      final alpha = cmd['alpha'] as String?;
      final report = simulate(
        rows,
        policy,
        FeeModel.parse(File(cmd['fees'] as String).readAsStringSync()),
        policy: ShadowPolicy(
          stakeDollars: double.parse(cmd['stake'] as String),
          minEvAfterFees: double.parse(cmd['min-ev'] as String),
          slippage: double.parse(cmd['slippage'] as String),
          alpha: alpha == null ? null : double.parse(alpha),
        ),
        seed: seed,
      );
      final text = report.toText();
      stdout.write(text);
      save('shadow.txt', text);
  }
}
