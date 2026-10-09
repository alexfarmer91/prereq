# Founder checklist: forecast validation and launch readiness

Specific to the repo as of 2026-10-09. **Blocks** uses four levels:
**local dev**, **live collection** (gathering real forecasts and outcomes),
**commercial launch**, and **validated-edge claims** (saying the AI beats the
market). Every "proposed default" is a suggestion, not an approved decision.

## A. Done in code (for reference)

| Item | Where |
|---|---|
| AI probability no longer prefills the Kelly sizer; probability starts unset and resets on side switch | `frontend/lib/features/position_sizer/kelly_sizer.dart` |
| EV computed by the backend from live asks (before fees), null when no usable ask; edge/EV never taken from the model | `backend/src/services/scorer.rs` (`reprice`) |
| UI relabelled: "AI estimate — unvalidated", "AI–market gap", self-rated confidence in a neutral colour, evidence marked unverified | `frontend/lib/features/market_detail/widgets/score_card.dart` and others |
| Forecast ledger (context, versions, timing, quotes) and a failure/abstention log | migrations `0010`, `0011`; `db/scores.rs` |
| Kalshi outcome sync, frozen once finalized | `backend/src/services/outcomes.rs` |
| Prompt v3: current date, structured evidence, explicit abstention | `scorer.rs` (`build_prompt`, `parse_output`) |
| Offline evaluator, blend fit and simulated trading, all with synthetic tests | `tools/forecast_eval/` |

## B. Decisions and setup needed from you

| Task | Why it matters | Owner | What blocks it | Exact action | Completion evidence | Priority |
|---|---|---|---|---|---|---|
| Get the pending commits deployed | No Milestone 0+ code has been compiled anywhere. The Railway deployment is still `aadcbda` (Sept 2), even though `origin/dev` is ahead. Nothing is being collected | You | **live collection** | Push `dev`, then check Railway → service `prereq` → Deployments. If no build starts, check that auto-deploy from `dev` is still on, or click Redeploy | A Railway deployment whose commit hash matches `dev` HEAD shows SUCCESS. Logs show "migrations applied" and, about 5 min later, "Outcome sync complete" | **P0** |
| Rollback plan for migrations 0009–0011 | They are additive (new nullable columns and tables), but there's no down-migration | You | live collection | Proposed default: on failure, redeploy the previous Railway deployment. The extra columns and tables are harmless to old code, so leave them in place. Take a Supabase backup before the first deploy | Backup timestamp noted; the rollback deploy id is known | P0 |
| Scoring budget and hard limit | v3 adds about 300 output tokens per call. 30 markets × daily rescore, plus rescoring on 5¢ price moves | You | live collection | Set a monthly spend limit in the Anthropic console. After a week, run `SELECT date_trunc('day', scored_at), SUM(input_tokens), SUM(output_tokens), SUM(web_search_count) FROM ai_scores GROUP BY 1 ORDER BY 1;` and price it with current model rates | Console limit set; first-week cost known | P0 |
| Freeze the evaluation cohort and schedule | Changing which markets get scored mid-study invalidates comparisons | You | validated-edge claims | Proposed default: keep the top 30 by volume, a 24h max age and v3, with no web search (`SCORER_WEB_SEARCH` unset) until the first evaluation. Turning search on creates a separate cohort, so record the date | Note the date v3 went live and the env vars in effect | P1 |
| Pro "deep research" cohort | `Plan::can_research` exists, but on-demand scoring doesn't yet. When it ships, user-picked markets are a different population from the top 30 | You + dev | validated-edge claims | Before shipping on-demand research, add a `cohort` column (`top_volume` / `user_requested`) to `ai_scores` and evaluate the two separately | Column exists; the evaluator filters by it | P2 |
| Minimum quote-quality policy | Wide spreads make the mid a bad benchmark | You | validated-edge claims | Proposed default: `policy-v1` as written, with spread ≤ $0.10. Approve it now, before looking at any results | Approval recorded in `docs/forecast-validation.md` | P1 |
| Who watches settlement sync and failures | Silent failures stop outcomes from accruing | You | live collection | Proposed default: a weekly look at the coverage SQL in the validation doc, plus a Railway log alert on "Outcome sync failed" | First weekly check done | P1 |
| Verify the Kalshi fee formula | The simulated trading results depend on it. The PDF returned HTTP 429 when I tried to fetch it | You or dev | validated-edge claims (trading) | Read https://kalshi.com/docs/kalshi-fee-schedule.pdf, correct `tools/forecast_eval/fees.kalshi.json` if needed, add per-series `fee_multiplier` values, then set `"verified": true` | Simulator report no longer shows the UNVERIFIED warning | P2 |

## C. External permission or qualified review

| Task | Why it matters | Owner | What blocks it | Exact action | Completion evidence | Priority |
|---|---|---|---|---|---|---|
| Kalshi API data-use terms | We store Kalshi market data and outcomes (`ai_scores`, `market_outcomes`) and show them in a paid product. The four endpoints we call are public and unauthenticated, but public access ≠ a commercial redistribution licence | You → lawyer | **commercial launch** | Read Kalshi's developer and API terms on storage, redistribution and commercial use. If they're unclear, email Kalshi asking whether a paid analytics app may display and store its market data | Written answer or clause on file | **P0** |
| Polymarket Gamma API terms and access | Used for arbitrage only. Polymarket's availability to US persons has changed over time | You → lawyer | commercial launch | Check the current API terms and which jurisdictions can trade there. Don't present arbs that users in your markets can't legally execute | Supported jurisdictions written down; arb UI gated to match | P0 |
| Which users and jurisdictions you serve | Kalshi is a US CFTC-regulated exchange with its own state-level restrictions. Your app's audience has to fit both venues' rules | You → lawyer | commercial launch | Decide your launch jurisdictions; geo-restrict or disclaim accordingly | A decision memo; matching terms of service | P0 |
| Advice and sizing review | A paid product that shows AI probabilities, "EV if AI right", a Kelly calculator and a tier literally named **"Edge"** may be read as investment or trading advice. README copy says "find edge" | You → qualified counsel | commercial launch | Have counsel review the score card, sizer copy, tier names and marketing language. Consider renaming the "Edge" tier before launch | Review notes; copy changes merged | P0 |
| Anthropic usage policy for this use case | Financial-adjacent AI outputs shown to end users | You | commercial launch | Review Anthropic's usage policies and commercial terms for automated forecasting shown to customers | Confirmed in writing or noted as reviewed | P1 |
| Retention of research content | `raw_content` stores web search results, which is third-party text | You → lawyer | commercial launch | Proposed default: keep `raw_content` internal only (it is never sent to clients today) and set a retention period, for example 180 days, after which it is deleted. Evidence claims shown to users are the model's paraphrases plus URLs | Retention policy written; a deletion job scheduled if one is adopted | P2 |

## D. Depends on accumulated data (don't start early)

| Task | Why it matters | Owner | What blocks it | Exact action | Completion evidence | Priority |
|---|---|---|---|---|---|---|
| First real evaluation | The only honest answer to "does the AI add anything?" | Dev | ~100+ resolved v3 events for a first look; several hundred for a conclusion | Export → `forecast_eval evaluate` (see the validation doc) | `out/evaluation.txt` reviewed. Its interval decides the next step | P1 once data exists |
| Blend fit (Milestone 2) | Measures whether combining the AI with the market helps | Dev | ≥ 30 training events plus a later test period | `forecast_eval blend` | `blend-v1.json` plus a test-period interval | P2 |
| Simulated trading evaluation (Milestone 3) | Forecast accuracy ≠ profit after fees and spread | Dev | Verified fees; the same data as above | `forecast_eval simulate` | Shadow report without the UNVERIFIED flag | P2 |
| Any public accuracy claim | Must survive scrutiny | You | **validated-edge claims**: requires an interval excluding zero on two consecutive untouched periods | Don't claim forecasting skill before then. Synthetic results are never evidence | — | — |

## E. Measuring workflow value separately from forecast accuracy

The product may be worth paying for even if the AI has no forecasting edge:
the scanner, arbitrage alerts, research summaries and bet tracking are useful
on their own. Test that directly rather than waiting months for accuracy data.

| Task | Why it matters | Owner | What blocks it | Exact action | Completion evidence | Priority |
|---|---|---|---|---|---|---|
| Recruit 5–10 pilot users | Real willingness to pay is the commercial question | You | Commercial-launch items above, if charging | Proposed default: a free pilot with active Kalshi traders. Make no accuracy claims | Signed-up list | P1 |
| Define workflow metrics | Distinguishes "useful tool" from "accurate oracle" | You | — | Proposed: weekly active use, research cards opened, watchlist adds, arb alerts acted on, and the stated reason for keeping or cancelling. Mixpanel telemetry already exists | A dashboard with these metrics | P1 |
