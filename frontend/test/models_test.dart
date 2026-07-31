import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:prereq/shared/models/bet.dart';
import 'package:prereq/shared/models/market.dart';
import 'package:prereq/shared/models/market_detail.dart';
import 'package:prereq/shared/models/performance.dart';
import 'package:prereq/shared/models/price_point.dart';
import 'package:prereq/shared/models/user_profile.dart';
import 'package:prereq/shared/models/watchlist_item.dart';
import 'package:prereq/shared/models/ws_message.dart';

/// Exact Market payload from the API contract.
const marketJson = '''
{
  "ticker": "KXHIGHNY-26MAY18-T84",
  "event_ticker": "KXHIGHNY-26MAY18",
  "title": "Will the high temp in NYC be >84 on May 18, 2026?",
  "yes_bid": 0.85,
  "yes_ask": 0.89,
  "no_bid": 0.11,
  "no_ask": 0.15,
  "mid_price": 0.87,
  "spread": 0.04,
  "volume_24h": 14074.65,
  "close_time": "2026-05-19T04:59:00Z",
  "rules_primary": "If the highest temperature recorded in Central Park...",
  "category": "Weather",
  "score": {
    "fair_probability": 0.62,
    "confidence": "high",
    "edge": 0.05,
    "ev_per_dollar": 0.08,
    "rationale": "Forecast models agree.",
    "signals": ["NWS forecast 86F", "Warm front"],
    "risks": ["Cloud cover", "Station variance"],
    "scored_at": "2026-07-14T12:00:00Z"
  }
}
''';

Map<String, dynamic> decode(String s) =>
    jsonDecode(s) as Map<String, dynamic>;

void main() {
  group('Market', () {
    test('parses the contract payload', () {
      final market = Market.fromJson(decode(marketJson));
      expect(market.ticker, 'KXHIGHNY-26MAY18-T84');
      expect(market.eventTicker, 'KXHIGHNY-26MAY18');
      expect(market.yesBid, 0.85);
      expect(market.yesAsk, 0.89);
      expect(market.midPrice, 0.87);
      expect(market.spread, 0.04);
      expect(market.volume24h, 14074.65);
      expect(market.closeTime.isUtc, isTrue);
      expect(market.closeTime, DateTime.utc(2026, 5, 19, 4, 59));
      expect(market.category, 'Weather');
      expect(market.score, isNotNull);
      expect(market.score!.confidence, ScoreConfidence.high);
      expect(market.score!.fairProbability, 0.62);
      expect(market.score!.signals, hasLength(2));
    });

    test('handles null score and absent rules_primary', () {
      final json = decode(marketJson)
        ..['score'] = null
        ..remove('rules_primary');
      final market = Market.fromJson(json);
      expect(market.score, isNull);
      expect(market.rulesPrimary, isNull);
    });

    test('JSON round-trip preserves snake_case keys and values', () {
      final market = Market.fromJson(decode(marketJson));
      final json = market.toJson();
      expect(json['event_ticker'], 'KXHIGHNY-26MAY18');
      expect(json['volume_24h'], 14074.65);
      expect(json['mid_price'], 0.87);
      expect((json['score'] as Map<String, dynamic>)['ev_per_dollar'], 0.08);
      expect(Market.fromJson(json), market);
    });
  });

  test('MarketDetail round-trip', () {
    final market = Market.fromJson(decode(marketJson));
    final detail = MarketDetail(market: market, eventMarkets: [market]);
    expect(MarketDetail.fromJson(detail.toJson()), detail);
  });

  test('PricePoint parses and round-trips', () {
    final point =
        PricePoint.fromJson(decode('{"ts":"2026-07-01T00:00:00Z","yes_price":0.55}'));
    expect(point.yesPrice, 0.55);
    expect(PricePoint.fromJson(point.toJson()), point);
  });

  test('UserProfile parses and round-trips', () {
    final profile = UserProfile.fromJson(decode('''
      {"google_user_id":"user_123","bankroll_dollars":1000.0,"plan":"free",
       "terms_accepted":false,
       "email":"alex@example.com","email_verified":true,
       "display_name":"Alex","avatar_url":"https://example.com/a.png",
       "created_at":"2026-01-01T00:00:00Z","updated_at":"2026-01-01T00:00:00Z",
       "last_seen_at":null}
    '''));
    expect(profile.bankrollDollars, 1000.0);
    expect(profile.displayName, 'Alex');
    expect(profile.termsAccepted, isFalse);
    expect(UserProfile.fromJson(profile.toJson()), profile);
  });

  test('WatchlistItem parses with nullable fields and nested market', () {
    final item = WatchlistItem.fromJson(decode('''
      {"id":"uuid-1","market_ticker":"T1","alert_edge_threshold":0.05,
       "edge_at_add":0.03,"created_at":"2026-07-01T00:00:00Z",
       "market":${marketJson.trim()}}
    '''));
    expect(item.alertEdgeThreshold, 0.05);
    expect(item.edgeAtAdd, 0.03);
    expect(item.market!.ticker, 'KXHIGHNY-26MAY18-T84');
    expect(WatchlistItem.fromJson(item.toJson()), item);

    final bare = WatchlistItem.fromJson(decode(
        '{"id":"uuid-2","market_ticker":"T2","alert_edge_threshold":null,'
        '"edge_at_add":null,"created_at":"2026-07-01T00:00:00Z","market":null}'));
    expect(bare.market, isNull);
    expect(bare.alertEdgeThreshold, isNull);
  });

  group('Bet', () {
    const betJson = '''
      {"id":"uuid-9","market_ticker":"T1","market_title":"Title","side":"yes",
       "entry_price_dollars":0.55,"contracts":10,"your_probability":0.62,
       "kelly_fraction":0.08,"outcome":"pending","exit_price_dollars":null,
       "placed_at":"2026-07-01T00:00:00Z","resolved_at":null}
    ''';

    test('parses enums and nullables', () {
      final bet = Bet.fromJson(decode(betJson));
      expect(bet.side, BetSide.yes);
      expect(bet.outcome, BetOutcome.pending);
      expect(bet.exitPriceDollars, isNull);
      expect(bet.resolvedAt, isNull);
      expect(Bet.fromJson(bet.toJson()), bet);
    });

    test('BetsPage round-trip', () {
      final page = BetsPage.fromJson(decode(
          '{"bets":[${betJson.trim()}],"total":42,"page":1,"per_page":25}'));
      expect(page.total, 42);
      expect(page.perPage, 25);
      expect(page.bets.single.contracts, 10);
      expect(BetsPage.fromJson(page.toJson()), page);
    });
  });

  test('PerformanceData parses the contract payload', () {
    final data = PerformanceData.fromJson(decode('''
      {"calibration":[{"bucket_min":0.6,"bucket_max":0.7,
        "predicted_count":5,"actual_win_rate":0.8}],
       "pnl":{"total_wagered":500.0,"total_returned":620.0,"roi":0.24,
        "win_rate":0.61,"bet_count":18},
       "streaks":{"current_win_streak":3,"longest_win_streak":7}}
    '''));
    expect(data.calibration.single.bucketMin, 0.6);
    expect(data.calibration.single.actualWinRate, 0.8);
    expect(data.pnl.roi, 0.24);
    expect(data.pnl.betCount, 18);
    expect(data.streaks.longestWinStreak, 7);
    expect(PerformanceData.fromJson(data.toJson()), data);
  });

  group('WsMessage', () {
    test('price_update discriminates by type', () {
      final msg = WsMessage.tryParse(decode(
          '{"type":"price_update","ticker":"T1","yes_bid":0.55,'
          '"yes_ask":0.57,"ts":"2026-07-14T12:00:00Z"}'));
      expect(msg, isA<WsPriceUpdate>());
      final update = msg as WsPriceUpdate;
      expect(update.ticker, 'T1');
      expect(update.yesBid, 0.55);
    });

    test('arb_count discriminates by type', () {
      final msg = WsMessage.tryParse(decode('{"type":"arb_count","count":2}'));
      expect(msg, isA<WsArbCount>());
      expect((msg as WsArbCount).count, 2);
    });

    test('unknown message types are ignored', () {
      expect(WsMessage.tryParse(decode('{"type":"heartbeat"}')), isNull);
    });
  });
}
