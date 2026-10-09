# Forecast validation

**Question:** do Claude's probabilities add information beyond the market price?
Until the evaluation below shows that on enough resolved, independent events,
the product treats every AI probability as an **unvalidated estimate**. It is
never a recommendation and never feeds position sizing.

Forecasting accuracy, simulated trading results, users' real bets and
arbitrage execution are four separate questions, and they are kept separate
here.

## What gets recorded

| Table | Written by | Contents |
|---|---|---|
| `ai_scores` | `services::scorer` on each successful Claude call | Probability, self-rated confidence, rationale, cited `evidence` (v3+), raw research content, model, `prompt_version`, `requested_at`/`scored_at`, quotes shown to Claude (`yes_bid`/`yes_ask`/`no_bid`/`no_ask`), the YES mid at scoring (`market_price_at_score`), `event_ticker`, `category`, `market_close_time`, and token/search usage. Append-only. |
| `ai_score_failures` | `services::scorer` on each call that produced no estimate | `error_kind` (`abstained`, `parse_failure`, `invalid_probability`, `provider_error`, `request_failed`, `other`), a truncated message (for abstentions, the model's reason), and the price at request time. |
| `market_outcomes` | `services::outcomes` every 6h | Kalshi's official `status`, `result`, and `settlement_value` for every scored market, plus our `resolution` classification. A `finalized` row is never rewritten. |

Rows written before migration 0010 have `prompt_version IS NULL`. They are
**legacy**: kept for the record, reported separately, and never evaluated.
Nothing is backfilled.

Derived numbers (`edge`, `ev_yes_per_dollar`, `ev_no_per_dollar`) are never
stored. The API recomputes them from live quotes (`scorer::reprice`). EV assumes
a binary $1 payout and a fill at the top-of-book ask, before fees, with no
depth or slippage. It is shown only as "EV if the AI is right."

## Prompt versions

| Version | Live from | What changed |
|---|---|---|
| (legacy) | before migration 0010 | No ledger context; never evaluated |
| `2` | Milestone 0 | Asks only for the probability. Edge and EV are computed by the backend |
| `3` | Milestone 1+ | Adds the current date, structured `evidence`, and an explicit **abstain** option: the model declines when the rules are ambiguous, the outcome already appears decided, or it has nothing beyond the price |

**Versions are never pooled.** Each one is evaluated on its own.

Abstention helps keep "already-known outcome" forecasts out of the data, but
it also means the AI picks which markets it answers. The evaluation always
compares AI and market **on the same markets**, so that comparison stays fair.
**Coverage**, meaning the share of attempts that produced an estimate, is
reported next to it.

## Outcome policy

`services::outcomes::resolution` classifies each market from Kalshi's
settlement fields only:

| `resolution` | Meaning | Used in evaluation |
|---|---|---|
| `yes` / `no` | `status = finalized`, binary, and the payout agrees with the result | **Yes** |
| `pending` | Anything not finalized, **including `closed` and `determined`** | No (counted) |
| `disputed` | `disputed` or `amended` | No (counted) |
| `nonbinary` | Scalar market or scalar result | No (counted) |
| `exception` | Finalized, but not a clean yes/no (for example voided, or a payout that contradicts the result) | No (counted) |

We never treat a market's closing, or its price drifting toward 0 or 1, as an
outcome.

**Known limitations:**
- Markets that settled before Kalshi's historical cutoff are served only by
  `/historical/markets`, which we don't call yet. The 6-hourly sync normally
  records outcomes well before that, and any market it misses is counted as
  "not returned" in the sync log.
- An amendment made *after* a market is finalized is not picked up, because
  finalized rows are frozen on purpose.
- Forecasts made after the result was already public are only partly guarded
  against: v3 abstention and excluding forecasts made after close. For
  fast-resolving markets (in-game sports, 15-minute crypto), treat results with
  suspicion.

## Evaluation policy `policy-v1` (frozen)

Implemented in `tools/forecast_eval/lib/src/selection.dart`. Changing any
setting means a new policy id and a fresh evaluation period, not re-running on
the same data.

- **q**: `fair_probability`, used raw and never clamped. Out-of-range outputs
  are rejected at scoring time and recorded as failures.
- **m**: `market_price_at_score`, the YES mid from the same quotes Claude saw.
  These come from the 5-minute snapshot, so they can be up to about 5 minutes
  older than `requested_at`.
- **y**: 1 if `resolution = 'yes'`, 0 if `'no'`.
- **Chronology:** a forecast is used only if it was made, and its outcome
  settled, by the data cutoff.
- **One forecast per market:** the earliest eligible score. Refreshes would
  otherwise let frequently rescored markets dominate.
- **Eligible:** exactly one prompt version, a `yes`/`no` outcome, a known close
  time, `scored_at < market_close_time`, and a YES spread ≤ $0.10 (a wide
  spread makes the mid a poor benchmark).
- **Dependence:** strikes in the same Kalshi event are averaged together
  first, and uncertainty comes from resampling whole events (2,000 resamples,
  seed 42). No interval is given with fewer than 10 events. Events in the same
  series are still correlated, so true uncertainty is wider than reported.
- **Log loss:** probabilities are bounded to [1e-6, 1 − 1e-6] *inside the
  metric only*. The number of rows where that bound applied is reported.
- **Positive improvement** means the AI beat the market on the same markets.

## Running the evaluation

### 1. Export (read-only, Supabase SQL editor → download CSV)

`scores.csv`:

```sql
SELECT s.id AS score_id, s.market_ticker, s.event_ticker, s.category,
       s.prompt_version, s.confidence, s.fair_probability,
       s.market_price_at_score, s.yes_bid, s.yes_ask, s.no_bid, s.no_ask,
       s.requested_at, s.scored_at, s.market_close_time, s.web_search_enabled,
       o.resolution, o.settlement_ts
FROM ai_scores s
LEFT JOIN market_outcomes o USING (market_ticker)
ORDER BY s.id;
```

`failures.csv`:

```sql
SELECT market_ticker, requested_at, prompt_version, error_kind
FROM ai_score_failures ORDER BY id;
```

### 2. Evaluate (offline: no network, no DB, no model calls)

```sh
cd tools/forecast_eval
dart pub get
dart run bin/forecast_eval.dart evaluate --scores scores.csv --failures failures.csv \
  --prompt-version 3 --cutoff 2027-03-01T00:00:00Z --out out/
```

This prints a report and writes `out/evaluation.txt` plus
`out/evaluation_audit.csv`, which lists every input row and why it was selected
or excluded. With no eligible data it says **INSUFFICIENT DATA** and reports no
scores.

To check that the tool works without real data, run
`dart run bin/forecast_eval.dart synthetic --out out/syn.csv`. Anything built
from it is stamped **SYNTHETIC**.

### Quick SQL coverage check

```sql
SELECT 'scores' AS what, COALESCE(prompt_version, 'legacy') AS bucket, COUNT(*) FROM ai_scores GROUP BY 2
UNION ALL
SELECT 'non-estimates', prompt_version || ':' || error_kind, COUNT(*) FROM ai_score_failures GROUP BY 2
UNION ALL
SELECT 'outcomes', resolution, COUNT(*) FROM market_outcomes GROUP BY 2
ORDER BY 1, 2;
```

## Reading the result

The question is whether the event-bootstrap interval for the improvement
excludes zero. If it includes zero, the result is "no demonstrated difference,"
whichever sign the point estimate has. Breakdowns by category, horizon, model
confidence or search are **descriptive**. A subgroup where the AI "wins" is a
hypothesis to test on *future* data, not a validated edge.

**How much data is enough.** There's no fixed row count or number of weeks.
Brier differences between a good forecaster and a liquid market are typically
below 0.01, and the per-event spread is several times that. Detecting a real
but small advantage therefore takes **several hundred resolved independent
events**, collected after the policy was frozen. With the top-30-by-volume
cohort and 24-hour rescoring, that likely means months.

## Milestone 2: market baseline and AI blend

```sh
dart run bin/forecast_eval.dart blend --scores scores.csv --prompt-version 3 \
  --cutoff 2027-06-01T00:00:00Z --train-cutoff 2027-03-01T00:00:00Z --out out/
```

This compares four things on forecasts made **after** `--train-cutoff`:
1. the raw market price;
2. a market-only recalibration (`logit p = a + b·logit m`);
3. raw Claude;
4. a blend, `p = m + α(q − m)`.

The recalibration and α are fitted only on outcomes known by the train cutoff.
α is constrained to [0, 1] and chosen to minimize log loss. **α = 0 ("ignore the
AI") is a legitimate answer**, and a fitted positive α is not proof of
usefulness. Forecasts made before the cutoff whose outcomes arrived after it
are used for neither fitting nor testing. Fewer than 30 training events
produces **INSUFFICIENT TRAINING DATA** and nothing is fitted.

The fitted values are written to a versioned artifact (`out/blend-v1.json`).
It is kept separate from the raw forecasts and is **not deployed**. Showing a
blended probability in the product is a separate decision. It needs a
test-period interval that excludes zero, confirmed again on the next untouched
period.

**Acceptance:** at least 30 training events; a test-period blend improvement
whose interval excludes zero; the same result on a second, later period.

## Milestone 3: simulated trading evaluation

```sh
dart run bin/forecast_eval.dart simulate --scores scores.csv --prompt-version 3 \
  --cutoff 2027-06-01T00:00:00Z --fees fees.kalshi.json [--alpha 0.3]
```

This is a hypothetical mechanical policy, `shadow-v1`, frozen before any
results. It places no orders.
- One position per market, using the earliest eligible forecast, held to
  settlement.
- A fixed stake ($10 by default), **not Kelly**.
- It enters only when the expected return after fees, at the top-of-book ask
  plus $0.01 of slippage, is at least 5%.

It reports P&L, ROI with an event-bootstrap interval, the largest exposure to
any single event, and the average time capital is tied up.

**Not modeled:** order-book depth (not recorded), the real reaction delay
(only approximated by slippage), exits, and how correlated events across a
series are.

**Fees:** `tools/forecast_eval/fees.kalshi.json` uses Kalshi's commonly
published taker formula, `0.07 × C × P × (1 − P)` rounded up to the cent, and
is marked **unverified**. Every report prints a warning until someone checks
it against https://kalshi.com/docs/kalshi-fee-schedule.pdf and sets
`"verified": true`. Kalshi reports a `fee_type` and `fee_multiplier` per series
(`GET /series/{ticker}`). Add the multipliers to the config, and list
`flat`-fee series under `unsupported_series` so they are skipped rather than
guessed.

The synthetic demo shows why this is a separate milestone. With an AI that is
*worse* than the market at forecasting, a run can still show positive ROI by
chance (+5.3%, interval −39% to +71%). Forecast accuracy and trading profit
have to be checked separately.

## Not yet done

- **Prompt diagnostics** (search on vs. off; price shown vs. hidden). Each
  needs its own prompt version and paired calls on the same markets, which
  roughly doubles cost for that cohort. Run it only after v3 has a baseline.
- **Consistency across related strikes.** The ladder of strikes in one event
  should form a sensible distribution, but each strike is scored on its own
  today. Measure how often they're inconsistent before building anything.
- **Polymarket.** Only Kalshi markets are scored and evaluated. Nothing is
  matched or copied across venues by title.
