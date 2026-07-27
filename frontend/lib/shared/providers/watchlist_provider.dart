import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/analytics/analytics.dart';
import '../models/watchlist_item.dart';
import 'api_client_provider.dart';
import 'ws_providers.dart';

part 'watchlist_provider.g.dart';

/// The user's watchlist. Whenever it (re)loads, the WebSocket subscription is
/// updated to exactly the watched tickers so live prices flow only for them.
@Riverpod(keepAlive: true)
class WatchlistController extends _$WatchlistController {
  @override
  Future<List<WatchlistItem>> build() async {
    final items = await ref.watch(apiClientProvider).getWatchlist();
    ref
        .read(marketSocketProvider)
        .subscribe(items.map((i) => i.marketTicker).toSet());
    return items;
  }

  Future<void> add(String ticker, {double? alertEdgeThreshold}) async {
    await ref
        .read(apiClientProvider)
        .addToWatchlist(ticker, alertEdgeThreshold: alertEdgeThreshold);
    Analytics.track('watchlist_market_added', {
      'market_ticker': ticker,
      'has_alert_threshold': alertEdgeThreshold != null,
    });
    ref.invalidateSelf();
    await future;
  }

  Future<void> remove(String ticker) async {
    // Optimistically drop the card, then confirm with the server.
    final current = state.value;
    if (current != null) {
      state = AsyncData(
          current.where((i) => i.marketTicker != ticker).toList());
    }
    try {
      await ref.read(apiClientProvider).removeFromWatchlist(ticker);
      Analytics.track('watchlist_market_removed', {'market_ticker': ticker});
    } finally {
      ref.invalidateSelf();
    }
    await future;
  }

  /// The API upserts on POST, so updating a threshold is a re-add.
  Future<void> setAlertThreshold(String ticker, double? threshold) async {
    await ref
        .read(apiClientProvider)
        .addToWatchlist(ticker, alertEdgeThreshold: threshold);
    ref.invalidateSelf();
    await future;
  }
}

/// Whether [ticker] is currently on the watchlist (null while loading).
@riverpod
bool? isWatched(Ref ref, String ticker) {
  final watchlist = ref.watch(watchlistControllerProvider);
  return switch (watchlist) {
    AsyncData(:final value) =>
      value.any((i) => i.marketTicker == ticker),
    _ => null,
  };
}
