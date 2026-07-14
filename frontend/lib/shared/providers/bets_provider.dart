import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    _invalidate();
    return bet;
  }

  void _invalidate() {
    ref.invalidate(betsProvider);
    ref.invalidate(performanceProvider);
  }
}
