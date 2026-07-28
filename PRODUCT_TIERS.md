# Product tiers

Companion to `PRODUCT_ROADMAP.md`. This documents what the code currently
defines as tier scaffolding, and the alpha-launch decision that governs when
it actually turns on. Source of truth for the code is
`backend/src/models/plan.rs` and the comment in
`backend/migrations/0003_user_plans.sql`.

## Alpha status: all tiers unlocked, on purpose

Alpha ships with every signed-in user getting full access to every feature
below, regardless of `users.plan`. This isn't a gap — it's the plan (see
`PRODUCT_ROADMAP.md`'s Phase 0). Concretely:

- No route calls `Plan::can_view_arbs()` or `Plan::can_research()` — leave
  them uncalled through alpha.
- No billing integration writes to `users.plan` — leave it defaulting to
  `'free'` for everyone through alpha.
- No frontend paywall/upgrade UI exists — none is needed for alpha.
- If alpha monetizes, it's via ads (undecided — see `PRODUCT_ROADMAP.md`),
  not by enforcing any of the tiers below.

The tier model exists in code now because it was built ahead of the
alpha-first decision, not because it's about to be enforced. Treat everything
below as **documented for later, not in effect** until `PRODUCT_ROADMAP.md`
Phase 1 explicitly starts.

## Tiers as scaffolded in code (post-alpha; not enforced yet)

| Tier | Unlocks (per migration comment + `plan.rs`) |
|---|---|
| **Free** | Scanner + base AI market scores + watchlist + bet log / calibration |
| **Edge** | Everything in Free, + arbitrage scanner + arb/watchlist alerts (`can_view_arbs()`), + scanner horizon filter (`can_filter_by_horizon()`) |
| **Pro** | Everything in Edge, + user-triggered deep research: on-demand Claude scoring with live web search, metered at 100 runs/month (`can_research()`, `research_credits_per_month()`) |

Notable detail already in the code: `scorer.rs` (lines 22-25) documents the
intended split between the two AI paths —

- **Automated background scoring** (the shared batch job in `market_store.rs`,
  used during alpha for everyone) stays cheap and web-search-free by default
  (`SCORER_WEB_SEARCH` env flag, currently opt-in/off).
- **User-triggered research** (Pro tier, post-alpha) is meant to be a
  separate, on-demand, web-search-enabled Claude call, metered per user.

This is the same shape as the "on-demand personalized analysis" option in
`PRODUCT_ROADMAP.md` Phase 3 — the schema/model already anticipated it. There's
no `/research` route or credit-consumption tracking built yet ("consumption
tracking comes with the research endpoint" per the doc comment in `plan.rs`),
and per the roadmap, none should be built until Phase 1 is underway with real
subscriber signal — no further refinement or testing of the Pro tier during
alpha.

## Not wired yet (expected, not a bug, during alpha)

- `GET /arbs` currently serves any authenticated user regardless of plan —
  correct for alpha; will need `can_view_arbs()` wired in when Phase 1 starts.
- No research endpoint exists — the Pro entitlement has nothing to gate yet.
- `users.plan` only ever changes manually — correct for alpha; needs a real
  billing integration (Stripe web / Apple IAP / Google Play Billing) before
  Phase 1 can enforce anything.
- No frontend paywall/upgrade UI — not needed until Phase 1.

## Open decision: gate confidence visibility behind signup (resolve before Phase 1)

Confidence (`Score.confidence`, shown on `MarketCard` as of this pass) is
currently visible to anyone signed in — no `Plan` gate exists for it, unlike
the horizon filter above. The idea floated: use confidence as a signup hook
("see medium/high-confidence markets — sign up free to unlock"), which implies
an access tier *below* Free (anonymous browsing of basic market data, with
confidence/edge requiring an account) rather than a paid-tier boundary. That's
a different shape than the existing Free/Edge/Pro model — it needs an actual
anonymous-access mode designed (what's visible unauthenticated?) before it can
be wired up. Not done here; flagging so it doesn't get lost.

## Open decision: Free vs. Edge boundary for arbs (resolve before Phase 1)

This doesn't block alpha (everything's free either way right now), but needs
an answer before `can_view_arbs()` gets wired into `routes/arbs.rs`:

- **Keep arbs behind Edge** (what the code currently implies): monetize the
  mechanical, cheap-to-run arb feature directly. Free tier (post-alpha) would
  be AI-scored scanner only.
- **Move arbs to Free** (the original MVP framing this roadmap started from):
  arbs cost nothing in Claude spend and make a good no-cost hook; paid tiers
  become entirely about AI analysis depth (Edge = better/more scores, Pro =
  on-demand deep research). Requires re-scoping what "Edge" unlocks, since
  arbs were its named entitlement.

Your call once Phase 1 planning starts — pick whichever offers more user
value; see `PRODUCT_ROADMAP.md` open questions for the related Phase 1
trigger question.
