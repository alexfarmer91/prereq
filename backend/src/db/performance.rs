use serde::Serialize;

use super::bets::Bet;

#[derive(Debug, Serialize)]
pub struct CalibrationBucket {
    pub bucket_min: f64,
    pub bucket_max: f64,
    pub predicted_count: i64,
    pub actual_win_rate: f64,
}

#[derive(Debug, Serialize)]
pub struct PnlSummary {
    pub total_wagered: f64,
    pub total_returned: f64,
    pub roi: f64,
    pub win_rate: f64,
    pub bet_count: i64,
}

#[derive(Debug, Serialize)]
pub struct Streaks {
    pub current_win_streak: i64,
    pub longest_win_streak: i64,
}

#[derive(Debug, Serialize)]
pub struct PerformanceReport {
    pub calibration: Vec<CalibrationBucket>,
    pub pnl: PnlSummary,
    pub streaks: Streaks,
}

/// Build the full report from resolved bets (ordered by resolved_at ascending).
pub fn build_report(resolved: &[Bet]) -> PerformanceReport {
    PerformanceReport {
        calibration: calibration(resolved),
        pnl: pnl(resolved),
        streaks: streaks(resolved),
    }
}

/// Bucket resolved bets by the user's predicted probability in 10% bands.
/// Only buckets with at least one bet are returned.
fn calibration(resolved: &[Bet]) -> Vec<CalibrationBucket> {
    let mut counts = [0i64; 10];
    let mut wins = [0i64; 10];

    for bet in resolved {
        let idx = ((bet.your_probability * 10.0).floor() as usize).min(9);
        counts[idx] += 1;
        if bet.outcome == "win" {
            wins[idx] += 1;
        }
    }

    (0..10)
        .filter(|&i| counts[i] > 0)
        .map(|i| CalibrationBucket {
            bucket_min: i as f64 / 10.0,
            bucket_max: (i + 1) as f64 / 10.0,
            predicted_count: counts[i],
            actual_win_rate: wins[i] as f64 / counts[i] as f64,
        })
        .collect()
}

/// A binary contract costs the entry price and pays $1 on a win. When an exit
/// price is recorded (early close), it is used as the payout instead.
fn pnl(resolved: &[Bet]) -> PnlSummary {
    let mut wagered = 0.0;
    let mut returned = 0.0;
    let mut wins = 0i64;

    for bet in resolved {
        let cost = bet.entry_price_dollars * bet.contracts as f64;
        wagered += cost;
        let payout_per_contract = match bet.exit_price_dollars {
            Some(exit) => exit,
            None if bet.outcome == "win" => 1.0,
            None => 0.0,
        };
        returned += payout_per_contract * bet.contracts as f64;
        if bet.outcome == "win" {
            wins += 1;
        }
    }

    let count = resolved.len() as i64;
    PnlSummary {
        total_wagered: wagered,
        total_returned: returned,
        roi: if wagered > 0.0 {
            (returned - wagered) / wagered
        } else {
            0.0
        },
        win_rate: if count > 0 {
            wins as f64 / count as f64
        } else {
            0.0
        },
        bet_count: count,
    }
}

fn streaks(resolved: &[Bet]) -> Streaks {
    let mut current = 0i64;
    let mut longest = 0i64;

    for bet in resolved {
        if bet.outcome == "win" {
            current += 1;
            longest = longest.max(current);
        } else {
            current = 0;
        }
    }

    Streaks {
        current_win_streak: current,
        longest_win_streak: longest,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::Utc;
    use uuid::Uuid;

    fn bet(outcome: &str, probability: f64, entry: f64, contracts: i32) -> Bet {
        Bet {
            id: Uuid::new_v4(),
            market_ticker: "T".into(),
            market_title: "T".into(),
            side: "yes".into(),
            entry_price_dollars: entry,
            contracts,
            your_probability: probability,
            kelly_fraction: None,
            outcome: outcome.into(),
            exit_price_dollars: None,
            placed_at: Utc::now(),
            resolved_at: Some(Utc::now()),
        }
    }

    #[test]
    fn calibration_buckets_by_probability() {
        let bets = vec![
            bet("win", 0.65, 0.5, 1),
            bet("loss", 0.62, 0.5, 1),
            bet("win", 0.95, 0.9, 1),
            bet("win", 1.0, 0.9, 1), // clamps into the 0.9–1.0 bucket
        ];
        let cal = calibration(&bets);
        assert_eq!(cal.len(), 2);
        assert_eq!(cal[0].bucket_min, 0.6);
        assert_eq!(cal[0].predicted_count, 2);
        assert!((cal[0].actual_win_rate - 0.5).abs() < 1e-9);
        assert_eq!(cal[1].bucket_min, 0.9);
        assert_eq!(cal[1].predicted_count, 2);
        assert!((cal[1].actual_win_rate - 1.0).abs() < 1e-9);
    }

    #[test]
    fn pnl_pays_dollar_per_winning_contract() {
        let bets = vec![bet("win", 0.6, 0.50, 10), bet("loss", 0.6, 0.25, 4)];
        let p = pnl(&bets);
        assert!((p.total_wagered - 6.0).abs() < 1e-9); // 5.00 + 1.00
        assert!((p.total_returned - 10.0).abs() < 1e-9);
        assert!((p.roi - (4.0 / 6.0)).abs() < 1e-9);
        assert!((p.win_rate - 0.5).abs() < 1e-9);
        assert_eq!(p.bet_count, 2);
    }

    #[test]
    fn pnl_uses_exit_price_when_present() {
        let mut b = bet("win", 0.6, 0.50, 10);
        b.exit_price_dollars = Some(0.80);
        let p = pnl(&[b]);
        assert!((p.total_returned - 8.0).abs() < 1e-9);
    }

    #[test]
    fn streaks_track_current_and_longest() {
        let bets = vec![
            bet("win", 0.5, 0.5, 1),
            bet("win", 0.5, 0.5, 1),
            bet("win", 0.5, 0.5, 1),
            bet("loss", 0.5, 0.5, 1),
            bet("win", 0.5, 0.5, 1),
            bet("win", 0.5, 0.5, 1),
        ];
        let s = streaks(&bets);
        assert_eq!(s.longest_win_streak, 3);
        assert_eq!(s.current_win_streak, 2);
    }

    #[test]
    fn empty_history_is_all_zeroes() {
        let r = build_report(&[]);
        assert!(r.calibration.is_empty());
        assert_eq!(r.pnl.bet_count, 0);
        assert_eq!(r.pnl.roi, 0.0);
        assert_eq!(r.streaks.longest_win_streak, 0);
    }
}
