// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(marketSocket)
final marketSocketProvider = MarketSocketProvider._();

final class MarketSocketProvider
    extends $FunctionalProvider<MarketSocket, MarketSocket, MarketSocket>
    with $Provider<MarketSocket> {
  MarketSocketProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketSocketProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketSocketHash();

  @$internal
  @override
  $ProviderElement<MarketSocket> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MarketSocket create(Ref ref) {
    return marketSocket(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarketSocket value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarketSocket>(value),
    );
  }
}

String _$marketSocketHash() => r'b63c47267f0ecf226d29406415bfdb5410c906d9';

/// Latest live prices per ticker, fed by `price_update` WebSocket messages.

@ProviderFor(LivePrices)
final livePricesProvider = LivePricesProvider._();

/// Latest live prices per ticker, fed by `price_update` WebSocket messages.
final class LivePricesProvider
    extends $NotifierProvider<LivePrices, Map<String, WsPriceUpdate>> {
  /// Latest live prices per ticker, fed by `price_update` WebSocket messages.
  LivePricesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'livePricesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$livePricesHash();

  @$internal
  @override
  LivePrices create() => LivePrices();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, WsPriceUpdate> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, WsPriceUpdate>>(value),
    );
  }
}

String _$livePricesHash() => r'a8478370bc19a9e8c37ce9435308d94f3b742dc7';

/// Latest live prices per ticker, fed by `price_update` WebSocket messages.

abstract class _$LivePrices extends $Notifier<Map<String, WsPriceUpdate>> {
  Map<String, WsPriceUpdate> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<Map<String, WsPriceUpdate>, Map<String, WsPriceUpdate>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, WsPriceUpdate>,
                Map<String, WsPriceUpdate>
              >,
              Map<String, WsPriceUpdate>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Number of live cross-platform arb opportunities. Seeded from `GET /arbs`
/// and kept fresh by `arb_count` WebSocket pushes. Drives the badge on the
/// Watchlist tab.

@ProviderFor(ArbCount)
final arbCountProvider = ArbCountProvider._();

/// Number of live cross-platform arb opportunities. Seeded from `GET /arbs`
/// and kept fresh by `arb_count` WebSocket pushes. Drives the badge on the
/// Watchlist tab.
final class ArbCountProvider extends $NotifierProvider<ArbCount, int> {
  /// Number of live cross-platform arb opportunities. Seeded from `GET /arbs`
  /// and kept fresh by `arb_count` WebSocket pushes. Drives the badge on the
  /// Watchlist tab.
  ArbCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'arbCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$arbCountHash();

  @$internal
  @override
  ArbCount create() => ArbCount();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$arbCountHash() => r'fe2b8f29574c970acbdfe0ba2cc002723ef658c1';

/// Number of live cross-platform arb opportunities. Seeded from `GET /arbs`
/// and kept fresh by `arb_count` WebSocket pushes. Drives the badge on the
/// Watchlist tab.

abstract class _$ArbCount extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
