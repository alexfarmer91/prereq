import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/analytics/analytics.dart';
import '../models/bet.dart';
import 'api_client_provider.dart';
import 'performance_provider.dart';

part 'bets_provider.g.dart';

@riverpod
Future<BetsPage> bets(
  Ref ref, {
  BetOutcome? outcome,
  int page = 1,
  int perPage = 25,
}) {
  return ref
      .watch(apiClientProvider)
      .getBets(outcome: outcome, page: page, perPage: perPage);
}

/// Mutations on the bet log; invalidates dependent views on success.
@riverpod
class BetActions extends _$BetActions {
  @override
  void build() {}

  Future<Bet> logBet({
    required String marketTicker,
    required String marketTitle,
    required BetSide side,
    required double entryPriceDollars,
    required int contracts,
    required double yourProbability,
    double? kellyFraction,
  }) async {
    final bet = await ref.read(apiClientProvider).logBet(
          marketTicker: marketTicker,
          marketTitle: marketTitle,
          side: side,
          entryPriceDollars: entryPriceDollars,
          contracts: contracts,
          yourProbability: yourProbability,
          kellyFraction: kellyFraction,
        );
    Analytics.track('bet_logged', {
      'market_ticker': marketTicker,
      'side': side.name,
      'contracts': contracts,
      'entry_price_dollars': entryPriceDollars,
      'stake_dollars': entryPriceDollars * contracts,
      'your_probability': yourProbability,
      'kelly_fraction': ?kellyFraction,
    });
    _invalidate();
    return bet;
  }

  Future<Bet> resolveBet(
    String id, {
    required BetOutcome outcome,
    required double exitPriceDollars,
  }) async {
    final bet = await ref.read(apiClientProvider).resolveBet(
          id,
          outcome: outcome,
          exitPriceDollars: exitPriceDollars,
        );
    Analytics.track('bet_resolved', {
      'market_ticker': bet.marketTicker,
      'outcome': outcome.name,
      'exit_price_dollars': exitPriceDollars,
    });
    _invalidate();
    return bet;
  }

  void _invalidate() {
    ref.invalidate(betsProvider);
    ref.invalidate(performanceProvider);
  }
}
