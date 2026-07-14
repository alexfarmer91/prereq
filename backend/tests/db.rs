//! Database integration tests — run only when TEST_DATABASE_URL is set
//! (CI provides a Postgres service container; locally they no-op).

use prereq_backend::db;

fn test_db_url() -> Option<String> {
    std::env::var("TEST_DATABASE_URL")
        .ok()
        .filter(|u| !u.is_empty())
}

#[tokio::test]
async fn user_watchlist_bets_performance_roundtrip() {
    let Some(url) = test_db_url() else {
        eprintln!("TEST_DATABASE_URL not set — skipping DB integration test");
        return;
    };

    let pool = db::init(Some(&url)).await.expect("db connect + migrate");

    // User provisioning is idempotent.
    let user = db::users::get_or_create(&pool, "it_user_1").await.unwrap();
    let again = db::users::get_or_create(&pool, "it_user_1").await.unwrap();
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
    let other = db::users::get_or_create(&pool, "it_user_2").await.unwrap();
    assert!(
        db::bets::update_outcome(&pool, other.id, bet.id, "loss", None)
            .await
            .is_err()
    );
}
