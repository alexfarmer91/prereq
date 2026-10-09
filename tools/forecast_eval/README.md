# forecast_eval

Offline evaluation of Prereq's AI forecasts. It reads CSV exports from the
production database and never touches the network, the database, or the
Claude API.

```sh
dart pub get
dart test                                    # synthetic fixtures only
dart run bin/forecast_eval.dart synthetic --out out/syn.csv
dart run bin/forecast_eval.dart evaluate --scores out/syn.csv --prompt-version 3 --cutoff 2027-06-01T00:00:00Z
```

| Command | Question it answers | Code |
|---|---|---|
| `evaluate` | Is the AI better calibrated than the market on the same markets? | `lib/src/evaluate.dart` |
| `blend` | Does a fitted AI/market blend beat the market on later, untouched data? | `lib/src/blend.dart` |
| `simulate` | What would a fixed, mechanical trading policy have earned after fees? (hypothetical) | `lib/src/simulate.dart` |
| `synthetic` | Generates a labelled synthetic dataset | `lib/src/synthetic.dart` |

The policy, the export queries and how to read the results are in
[`docs/forecast-validation.md`](../../docs/forecast-validation.md). Reports
built from synthetic tickers (`SYN-…`) are always stamped **SYNTHETIC**.
