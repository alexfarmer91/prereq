/// Product tiers and their entitlements. The database's `users.plan` column
/// records which plan a user has (values constrained by the schema CHECK);
/// this enum is the single source of truth for what each plan unlocks.
/// Prices and subscription state will live in the billing provider.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum Plan {
    Free,
    Edge,
    Pro,
}

impl Plan {
    /// Parse the `users.plan` column. Unknown values (impossible while the
    /// CHECK constraint holds) degrade to Free rather than erroring.
    pub fn from_db(value: &str) -> Plan {
        match value {
            "edge" => Plan::Edge,
            "pro" => Plan::Pro,
            _ => Plan::Free,
        }
    }

    /// Arbitrage scanner + arb/watchlist alerts.
    pub fn can_view_arbs(self) -> bool {
        self >= Plan::Edge
    }

    /// User-triggered deep research (web-search scoring).
    pub fn can_research(self) -> bool {
        self >= Plan::Pro
    }

    /// Monthly allowance for deep research runs (metered; consumption
    /// tracking comes with the research endpoint).
    pub fn research_credits_per_month(self) -> u32 {
        match self {
            Plan::Pro => 100,
            Plan::Edge | Plan::Free => 0,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_db_values() {
        assert_eq!(Plan::from_db("free"), Plan::Free);
        assert_eq!(Plan::from_db("edge"), Plan::Edge);
        assert_eq!(Plan::from_db("pro"), Plan::Pro);
        assert_eq!(Plan::from_db("garbage"), Plan::Free);
    }

    #[test]
    fn tiers_are_ordered() {
        assert!(Plan::Free < Plan::Edge);
        assert!(Plan::Edge < Plan::Pro);
    }

    #[test]
    fn entitlements_follow_tiers() {
        assert!(!Plan::Free.can_view_arbs());
        assert!(Plan::Edge.can_view_arbs());
        assert!(Plan::Pro.can_view_arbs());

        assert!(!Plan::Edge.can_research());
        assert!(Plan::Pro.can_research());
        assert_eq!(Plan::Pro.research_credits_per_month(), 100);
        assert_eq!(Plan::Free.research_credits_per_month(), 0);
    }
}
