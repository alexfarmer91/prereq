//! Database integration tests — run only when TEST_DATABASE_URL is set
//! (CI provides a Postgres service container; locally they no-op).

use prereq_backend::db;
use prereq_backend::middleware::auth::AuthUser;

fn test_db_url() -> Option<String> {
    std::env::var("TEST_DATABASE_URL")
        .ok()
        .filter(|u| !u.is_empty())
}

fn test_auth_user(google_user_id: &str) -> AuthUser {
    AuthUser {
        google_user_id: google_user_id.to_string(),
        email: None,
        email_verified: false,
        display_name: None,
        avatar_url: None,
    }
}

#[tokio::test]
async fn user_watchlist_bets_performance_roundtrip() {
    let Some(url) = test_db_url() else {
        eprintln!("TEST_DATABASE_URL not set — skipping DB integration test");
        return;
    };

    let pool = db::init(Some(&url)).await.expect("db connect + migrate");

    // User provisioning is idempotent.
    let user = db::users::get_or_create(&pool, &test_auth_user("it_user_1"))
        .await
        .unwrap();
    let again = db::users::get_or_create(&pool, &test_auth_user("it_user_1"))
        .await
        .unwrap();
    assert_eq!(user.id, again.id);

    let user = db::users::update_bankroll(&pool, "it_user_1", 2500.0)
        .await
        .unwrap();
    assert!((user.bankroll_dollars - 2500.0).abs() < 1e-9);

    // Watchlist add / upsert / list / remove.
    let item = db::watchlist::add(&pool, user.id, "IT-TEST-T1", Some(0.05), Some(0.03))
        .await
        .unwrap();
    assert_eq!(item.market_ticker, "IT-TEST-T1");
    assert!((item.alert_edge_threshold.unwrap() - 0.05).abs() < 1e-9);

    // Re-adding the same ticker updates the threshold instead of failing.
    let item = db::watchlist::add(&pool, user.id, "IT-TEST-T1", Some(0.10), None)
        .await
        .unwrap();
    assert!((item.alert_edge_threshold.unwrap() - 0.10).abs() < 1e-9);

    let list = db::watchlist::list(&pool, user.id).await.unwrap();
    assert!(list.iter().any(|w| w.market_ticker == "IT-TEST-T1"));

    db::watchlist::remove(&pool, user.id, "IT-TEST-T1")
        .await
        .unwrap();
    assert!(db::watchlist::remove(&pool, user.id, "IT-TEST-T1")
        .await
        .is_err());

    // Bet lifecycle: insert → list → resolve → performance report.
    let bet = db::bets::insert(
        &pool,
        user.id,
        db::bets::NewBet {
            market_ticker: "IT-TEST-T1".into(),
            market_title: "Integration test market".into(),
            side: "yes".into(),
            entry_price_dollars: 0.40,
            contracts: 10,
            your_probability: 0.65,
            kelly_fraction: Some(0.08),
        },
    )
    .await
    .unwrap();
    assert_eq!(bet.outcome, "pending");

    let (bets, total) = db::bets::list(&pool, user.id, Some("pending"), 1, 25)
        .await
        .unwrap();
    assert!(total >= 1);
    assert!(bets.iter().any(|b| b.id == bet.id));

    let resolved = db::bets::update_outcome(&pool, user.id, bet.id, "win", None)
        .await
        .unwrap();
    assert_eq!(resolved.outcome, "win");
    assert!(resolved.resolved_at.is_some());

    let history = db::bets::resolved(&pool, user.id).await.unwrap();
    let report = db::performance::build_report(&history);
    assert!(report.pnl.bet_count >= 1);
    assert!(report.pnl.total_returned > 0.0);

    // A user can never touch another user's bets.
    let other = db::users::get_or_create(&pool, &test_auth_user("it_user_2"))
        .await
        .unwrap();
    assert!(
        db::bets::update_outcome(&pool, other.id, bet.id, "loss", None)
            .await
            .is_err()
    );
}

#[tokio::test]
async fn ai_scores_persist_and_return_latest() {
    let Some(url) = test_db_url() else {
        eprintln!("TEST_DATABASE_URL not set — skipping DB integration test");
        return;
    };
    use prereq_backend::models::market::Score;

    let pool = db::init(Some(&url)).await.expect("db connect + migrate");
    let ticker = format!("IT-SCORE-{}", uuid::Uuid::new_v4());

    let mut score = Score {
        fair_probability: 0.6,
        confidence: "medium".into(),
        edge: 0.1,
        ev_yes_per_dollar: None,
        ev_no_per_dollar: None,
        rationale: "first".into(),
        signals: vec!["s1".into()],
        risks: vec!["r1".into()],
        scored_at: chrono::Utc::now() - chrono::Duration::hours(1),
        market_price_at_score: Some(0.5),
    };
    let raw = serde_json::json!([{ "type": "text", "text": "{}" }]);
    let new = |score: &Score| db::scores::NewScore {
        market_ticker: &ticker,
        market_title: "Integration test market",
        score,
        market_price_at_score: 0.5,
        model: "test-model",
        web_search_enabled: true,
        web_search_count: 2,
        input_tokens: 100,
        output_tokens: 50,
        raw_content: Some(&raw),
        context: db::scores::ForecastContext {
            requested_at: score.scored_at - chrono::Duration::seconds(20),
            prompt_version: "test",
            event_ticker: "IT-EVENT",
            category: "Politics",
            market_close_time: None,
            yes_bid: 0.48,
            yes_ask: 0.52,
            no_bid: 0.48,
            no_ask: 0.52,
        },
    };
    db::scores::insert(&pool, &new(&score)).await.unwrap();

    score.rationale = "second".into();
    score.scored_at = chrono::Utc::now();
    db::scores::insert(&pool, &new(&score)).await.unwrap();

    let latest = db::scores::latest(&pool, &ticker).await.unwrap().unwrap();
    assert_eq!(latest.rationale, "second");
    assert_eq!(latest.signals, vec!["s1"]);
    assert_eq!(latest.market_price_at_score, Some(0.5));

    let batch = db::scores::latest_for(&pool, &[ticker.clone(), "IT-NONE".into()])
        .await
        .unwrap();
    assert_eq!(batch.len(), 1);
    assert_eq!(batch[&ticker].rationale, "second");
}

#[tokio::test]
async fn failures_and_outcomes_persist_without_rewriting_final_results() {
    let Some(url) = test_db_url() else {
        eprintln!("TEST_DATABASE_URL not set — skipping DB integration test");
        return;
    };
    use db::outcomes::upsert;

    let pool = db::init(Some(&url)).await.expect("db connect + migrate");
    let ticker = format!("IT-OUTCOME-{}", uuid::Uuid::new_v4());

    db::scores::insert_failure(
        &pool,
        &db::scores::NewFailure {
            market_ticker: &ticker,
            requested_at: chrono::Utc::now(),
            model: "test-model",
            prompt_version: "test",
            web_search_enabled: false,
            error_kind: "parse_failure",
            error_detail: "Unparseable score",
            market_price_at_request: 0.5,
        },
    )
    .await
    .unwrap();

    // (status, result, resolution) upserted → resolution stored afterwards.
    let steps = [
        ("closed", "", "pending", "pending"),
        ("finalized", "yes", "yes", "yes"),
        // Re-running is idempotent, and a finalized outcome is never rewritten.
        ("finalized", "yes", "yes", "yes"),
        ("amended", "no", "disputed", "yes"),
    ];
    for (status, result, resolution, expected) in steps {
        upsert(&pool, &outcome(&ticker, status, result, resolution))
            .await
            .unwrap();
        let stored: String =
            sqlx::query_scalar("SELECT resolution FROM market_outcomes WHERE market_ticker = $1")
                .bind(&ticker)
                .fetch_one(&pool)
                .await
                .unwrap();
        assert_eq!(stored, expected, "after upserting status {status}");
    }
}

fn outcome<'a>(
    ticker: &'a str,
    status: &'a str,
    result: &'a str,
    resolution: &'a str,
) -> db::outcomes::OutcomeUpdate<'a> {
    db::outcomes::OutcomeUpdate {
        market_ticker: ticker,
        status,
        market_type: Some("binary"),
        result: Some(result),
        settlement_value: None,
        settlement_ts: None,
        resolution,
    }
}
