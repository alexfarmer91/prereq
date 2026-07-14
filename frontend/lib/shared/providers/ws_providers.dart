import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/config/app_config.dart';
import '../../core/ws/market_socket.dart';
import '../models/ws_message.dart';
import 'api_client_provider.dart';
import 'auth_provider.dart';

part 'ws_providers.g.dart';

@Riverpod(keepAlive: true)
MarketSocket marketSocket(Ref ref) {
  final socket = MarketSocket(
    uriBuilder: () async {
      final token =
          await ref.read(authControllerProvider.notifier).getToken();
      return AppConfig.wsUri(token: token);
    },
  );
  ref.onDispose(socket.dispose);
  return socket;
}

/// Latest live prices per ticker, fed by `price_update` WebSocket messages.
@Riverpod(keepAlive: true)
class LivePrices extends _$LivePrices {
  @override
  Map<String, WsPriceUpdate> build() {
    final socket = ref.watch(marketSocketProvider);
    final sub = socket.messages.listen((message) {
      if (message is WsPriceUpdate) {
        state = {...state, message.ticker: message};
      }
    });
    ref.onDispose(sub.cancel);
    return const {};
  }
}

/// Number of live cross-platform arb opportunities. Seeded from `GET /arbs`
/// and kept fresh by `arb_count` WebSocket pushes. Drives the badge on the
/// Watchlist tab.
@Riverpod(keepAlive: true)
class ArbCount extends _$ArbCount {
  @override
  int build() {
    final auth = ref.watch(authControllerProvider);
    if (!auth.isSignedIn) return 0;

    final socket = ref.watch(marketSocketProvider);
    final sub = socket.messages.listen((message) {
      if (message is WsArbCount) state = message.count;
    });
    ref.onDispose(sub.cancel);
    Future.microtask(_seed);
    return 0;
  }

  Future<void> _seed() async {
    try {
      final arbs = await ref.read(apiClientProvider).getArbs();
      state = arbs.length;
      // Make sure the socket is up so we keep receiving arb_count pushes.
      await ref.read(marketSocketProvider).ensureConnected();
    } catch (_) {
      // Badge is best-effort; ignore failures.
    }
  }
}
