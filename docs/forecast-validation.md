# Forecast validation

**Question:** do Claude's probabilities add information beyond the market price?
Until the queries below show that on enough resolved, independent events, the
product treats every AI probability as an **unvalidated estimate**. It is
never a recommendation and never feeds position sizing.

## What gets recorded

| Table | Written by | Contents |
|---|---|---|
| `ai_scores` | `services::scorer` on each successful Claude call | Probability, self-rated confidence, rationale, raw research content, model, `prompt_version`, `requested_at`/`scored_at`, quotes shown to Claude (`yes_bid`/`yes_ask`/`no_bid`/`no_ask`), the YES mid at scoring (`market_price_at_score`), `event_ticker`, `category`, `market_close_time`, and token/search usage. Append-only. |
| `ai_score_failures` | `services::scorer` on each failed call | `error_kind` (`parse_failure`, `invalid_probability`, `provider_error`, `request_failed`, `other`), truncated message, and the price at request time. |
| `market_outcomes` | `services::outcomes` every 6h | Kalshi's official `status`, `result`, and `settlement_value` for every scored market, plus our `resolution` classification. A `finalized` row is never rewritten. |

Rows written before migration 0010 have `prompt_version IS NULL`. They are
**legacy**: kept for the record, reported separately, and excluded from the
evaluation, because their quotes, close time and timing are unknown. Nothing is
backfilled.

Derived numbers (`edge`, `ev_yes_per_dollar`, `ev_no_per_dollar`) are never
stored. The API recomputes them from live quotes (`scorer::reprice`). EV assumes
a binary $1 payout and a fill at the top-of-book ask, before fees, with no
depth or slippage. It is shown only as "EV if the AI is right."

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
- We cannot yet detect forecasts made after the real-world result was already
  public but before the market closed. Excluding forecasts made after close is
  only a partial guard. For fast-resolving markets such as sports, in-game
  weather or 15-minute crypto, treat results with suspicion.

## Benchmark and selection policy (version 1, frozen)

Freeze these settings before reading any results. Changing one means a new
policy version and a fresh evaluation period, not re-running on the same data.

- **q**: `fair_probability`, used raw and never clamped. Out-of-range outputs
  are rejected at scoring time and land in `ai_score_failures`.
- **m**: `market_price_at_score`, the YES mid from the same quotes Claude saw.
  These come from the 5-minute snapshot, so they can be up to about 5 minutes
  older than `requested_at`. That is acceptable at the current scoring latency.
  Revisit it if `scored_at - requested_at` grows to minutes, as it can with web
  search.
- **y**: 1 if `resolution = 'yes'`, 0 if `'no'`.
- **One forecast per market:** the earliest eligible score. Refreshes would
  otherwise let frequently rescored markets dominate.
- **Eligible:** `prompt_version = '2'`, outcome `yes`/`no`, `market_close_time`
  known, `scored_at < market_close_time`, and spread `yes_ask - yes_bid <= 0.10`
  (a wide spread makes the mid a poor benchmark).
- **Log loss:** probabilities are bounded to [1e-6, 1 - 1e-6] *inside the
  metric only*. The number of rows where that bound was applied is reported.
- **Positive improvement** means the AI beat the market on the same markets.

## Queries

These are read-only. Run them against the production database from the
Supabase SQL editor. They change nothing.

### 1. Coverage and exclusions (always run first)

```sql
SELECT 'scores' AS what, COALESCE(prompt_version, 'legacy') AS bucket, COUNT(*) FROM ai_scores GROUP BY 2
UNION ALL
SELECT 'failures', error_kind, COUNT(*) FROM ai_score_failures GROUP BY 2
UNION ALL
SELECT 'outcomes', resolution, COUNT(*) FROM market_outcomes GROUP BY 2
UNION ALL
SELECT 'scored markets never checked', '', COUNT(DISTINCT s.market_ticker)
FROM ai_scores s LEFT JOIN market_outcomes o USING (market_ticker)
WHERE o.market_ticker IS NULL
ORDER BY 1, 2;
```

### 2. Paired comparison on the same markets

```sql
WITH eligible AS (
  SELECT DISTINCT ON (s.market_ticker)
    s.market_ticker, s.event_ticker,
    s.fair_probability AS q,
    s.market_price_at_score AS m,
    CASE o.resolution WHEN 'yes' THEN 1.0 ELSE 0.0 END AS y
  FROM ai_scores s
  JOIN market_outcomes o USING (market_ticker)
  WHERE s.prompt_version = '2'
    AND o.resolution IN ('yes', 'no')
    AND s.market_close_time IS NOT NULL
    AND s.scored_at < s.market_close_time
    AND s.yes_ask - s.yes_bid <= 0.10
  ORDER BY s.market_ticker, s.scored_at
), scored AS (
  SELECT *,
    POWER(q - y, 2) AS ai_brier,
    POWER(m - y, 2) AS mkt_brier,
    -(y * LN(LEAST(GREATEST(q, 1e-6), 1 - 1e-6))
      + (1 - y) * LN(1 - LEAST(GREATEST(q, 1e-6), 1 - 1e-6))) AS ai_logloss,
    -(y * LN(LEAST(GREATEST(m, 1e-6), 1 - 1e-6))
      + (1 - y) * LN(1 - LEAST(GREATEST(m, 1e-6), 1 - 1e-6))) AS mkt_logloss,
    (q NOT BETWEEN 1e-6 AND 1 - 1e-6 OR m NOT BETWEEN 1e-6 AND 1 - 1e-6) AS bounded
  FROM eligible
), by_event AS (
  -- Related strikes in one event are not independent evidence: average
  -- within each event first, then treat events as the unit of evidence.
  SELECT event_ticker, AVG(mkt_brier - ai_brier) AS improvement
  FROM scored GROUP BY event_ticker
)
SELECT
  (SELECT COUNT(*) FROM scored)                          AS markets,
  (SELECT COUNT(*) FROM by_event)                        AS events,
  (SELECT AVG(ai_brier) FROM scored)                     AS ai_brier,
  (SELECT AVG(mkt_brier) FROM scored)                    AS market_brier,
  (SELECT AVG(ai_logloss) FROM scored)                   AS ai_logloss,
  (SELECT AVG(mkt_logloss) FROM scored)                  AS market_logloss,
  (SELECT COUNT(*) FILTER (WHERE bounded) FROM scored)   AS logloss_bounded_rows,
  AVG(improvement)                                       AS improvement_per_event,
  STDDEV_SAMP(improvement) / SQRT(COUNT(*))              AS improvement_se
FROM by_event;
```

Read `improvement_per_event ± 2 × improvement_se`. If that interval includes
zero, the result is "no demonstrated difference," whichever sign the point
estimate has. The standard error treats events as independent, but events in
the same series (the same team, the same daily weather station) are still
correlated, so the real uncertainty is wider than this.

### 3. Calibration (descriptive only)

```sql
-- Same `eligible` CTE as query 2, then:
SELECT WIDTH_BUCKET(q, 0, 1, 10) AS bucket,
       COUNT(*) AS n,
       AVG(q)  AS mean_ai_probability,
       AVG(y)  AS observed_yes_rate
FROM eligible GROUP BY 1 ORDER BY 1;
```

Treat buckets with fewer than about 30 markets as noise. A breakdown by
category or self-rated confidence works the same way. A subgroup where the AI
"wins" is a hypothesis to test on *future* data, not a validated edge.

## How much data is enough

There's no fixed row count or number of weeks. What we need:
- **Resolved, independent events**, not rows. Rescores of the same market and
  strikes in the same event collapse to one unit, as query 2 does.
- An improvement interval that excludes zero, measured on data collected
  **after** this policy was frozen.

As a rough guide, Brier differences between a good forecaster and a liquid
market are typically below 0.01, and the per-event spread is several times
that. Detecting a real but small advantage therefore takes several hundred
resolved independent events. With the current top-30-by-volume cohort and
24-hour rescoring, that likely means months.

## Next steps (once the data exists)

1. A market-only recalibration baseline, then a fitted blend
   `p = m + α(q − m)` with α in [0, 1]. Fit α on earlier outcomes and evaluate
   it on later, untouched ones. α = 0 is a legitimate answer.
2. Limited diagnostics: search on vs. off, and price shown vs. hidden in the
   prompt. Each gets its own `prompt_version`.
3. A separate, hypothetical execution-aware evaluation (fees, depth, fills).
   Forecast accuracy alone does not imply trading profit.
