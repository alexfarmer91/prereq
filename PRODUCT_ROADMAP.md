# Product roadmap

See `GET_STARTED.md` for the original full spec and `PRODUCT_TIERS.md` for the
detailed tier definitions this roadmap references. Revisit this doc as real
usage data comes in — it's a sequencing decision, not a permanent architecture.

## Alpha: ship everything free

Alpha launches with **no paid tiers enforced** — every signed-in user gets full
access to the scanner, AI-scored markets, the arb scanner, watchlist, Kelly
sizer, bet log, and performance dashboard. Monetization during alpha, if any,
is **ads, not subscriptions** (see "Ads — open decision" below).

This requires no code changes to ship. Today, nothing in the backend calls
`Plan::can_view_arbs()` or `Plan::can_research()` (see `PRODUCT_TIERS.md`), so
every route already behaves as fully unlocked regardless of `users.plan`. That
unwired state — previously flagged as a gap to close — is now the intended
alpha behavior, not a bug to rush-fix. Leave it unwired until the "Post-alpha"
phase below actually starts.

Do **not** build during alpha: billing/Stripe/Apple IAP/Google Play Billing
integration, paywall UI, plan-gated routes, or further refinement/testing of
the Pro tier's on-demand research flow. That work is scaffolded in the code
and documented for later (`PRODUCT_TIERS.md`), but stays untouched until
there's a signal to move past alpha.

### Ads — open decision (not yet built)

No ad SDK or network is integrated anywhere in the app today. If alpha runs
ads, this needs a product decision before any implementation: which network
(AdMob is the natural default for Flutter), which placements (banner in the
scanner list? interstitial between screens? none on the Kelly sizer/bet log
so money-management flows stay uncluttered?), and whether ads fit the
"Bloomberg terminal" positioning this product is going for. Flagged for you to
decide — see questions at the end of this doc.

## Why batch scoring, not per-user agents

`services/market_store.rs` already runs a **shared batch job**: every 5 minutes it
fetches markets, scores the top 30 most liquid with Claude once, caches the
result, and every user reads the same cached snapshot. This is the right model
to build on regardless of monetization approach, and it's what makes an
all-free alpha affordable:

- **Cost scales with markets analyzed (fixed ~30/5min), not with signup
  count.** 10 or 10,000 alpha users cost the same to serve. A standing
  per-user analysis agent (each user gets their own background Claude loop
  watching their own criteria) scales cost with *users × query frequency* —
  a bad shape for a free, ad-supported alpha with unknown signup volume.
- It's already built, tested, and cached (`scorer.rs`, Redis-backed).

**Recommendation: keep batch scoring as the only AI model through alpha.**
Don't build per-user standing agents now.

## Phased plan

**Phase 0 — current state / Alpha (ship this)**
- Free for everyone: auth, arb scanner (`/arbs`), AI-scored markets
  (`/markets`), watchlist, Kelly sizer, bet log, performance dashboard.
- `Plan`/tier scaffolding exists in code (`models/plan.rs`,
  `migrations/0003_user_plans.sql`) but is intentionally left uncalled — see
  `PRODUCT_TIERS.md` for what it already models for later.
- Optional: ads, pending the decision above.

**Phase 1 — post-alpha: enforce the paid tiers already scaffolded in code**
Start this only once there's a signal alpha is working (see questions below
for what that trigger should be) — not on a fixed calendar date.
- Decide the still-open Free vs. Edge boundary for arbs (see
  `PRODUCT_TIERS.md`'s open conflict) before wiring anything.
- Call `can_view_arbs()` / `can_research()` from the relevant routes.
- Wire an actual upgrade path that flips `users.plan`: Stripe for web,
  Apple IAP for iOS, Google Play Billing for Android — three separate
  purchase rails converging on the same `users.plan` column (see hosting/infra
  discussion in this repo's chat history; not yet written to a doc — ask if
  you want a `PAYMENTS.md` for this when Phase 1 starts).
- Frontend: build the paywall/upgrade UI — none exists yet.

**Phase 2 — notifications on the existing batch scores**
- `watchlist.alert_edge_threshold` is already stored per README but nothing
  pushes an alert when a scored market crosses it. This is "run once and send
  out," using data that already exists.
- Can ship during alpha (it's not plan-gated) or as a Phase 1 upgrade hook —
  your call once Phase 1 planning starts.
- Delivery mechanism (push vs. email vs. in-app only) still needs to be picked.

**Phase 3 — on-demand personalized research (Pro tier, only after Phase 1 has
real subscriber signal)**
- `models/plan.rs` and `services/scorer.rs` already scaffold this direction:
  a scoped, user-triggered, web-search-enabled Claude call, metered at 100
  runs/month for Pro. No route or credit-consumption tracking exists yet.
- Per this roadmap's goal, this scaffolding gets **no further refinement or
  testing during alpha** — it stays exactly as documented in
  `PRODUCT_TIERS.md` until Phase 1 is underway and there's subscriber demand
  for it specifically.

**Not planned (unless subscriber demand clearly asks for it later)**
- A persistent, always-on analysis agent per premium user. Revisit only if
  Phase 3's on-demand version proves popular enough that its per-request cost
  starts exceeding what a bounded background loop per user would cost — no
  evidence for that yet.

## Open questions

1. **Ads**: commit to them for alpha, or leave alpha unmonetized and skip ad
   infra entirely for now? If yes — which network/placements?
2. **Free vs. Edge boundary for arbs**: once Phase 1 starts, should the arb
   scanner stay free (this doc's original framing) or move to Edge (what
   `can_view_arbs()` currently implies)? See `PRODUCT_TIERS.md` for the
   full tradeoff — needs your call before Phase 1 enforcement work begins.
3. **Phase 1 trigger**: what signal moves this from "alpha" to "start building
   paid tiers" — a user count, a time-in-market, specific qualitative
   feedback, something else?
4. **Notification delivery channel** for Phase 2 (push/email/in-app).
