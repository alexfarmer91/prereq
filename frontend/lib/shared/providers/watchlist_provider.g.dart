// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watchlist_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's watchlist. Whenever it (re)loads, the WebSocket subscription is
/// updated to exactly the watched tickers so live prices flow only for them.

@ProviderFor(WatchlistController)
final watchlistControllerProvider = WatchlistControllerProvider._();

/// The user's watchlist. Whenever it (re)loads, the WebSocket subscription is
/// updated to exactly the watched tickers so live prices flow only for them.
final class WatchlistControllerProvider
    extends $AsyncNotifierProvider<WatchlistController, List<WatchlistItem>> {
  /// The user's watchlist. Whenever it (re)loads, the WebSocket subscription is
  /// updated to exactly the watched tickers so live prices flow only for them.
  WatchlistControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchlistControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchlistControllerHash();

  @$internal
  @override
  WatchlistController create() => WatchlistController();
}

String _$watchlistControllerHash() =>
    r'24017673c28cd44a404342021395f7267e44858b';

/// The user's watchlist. Whenever it (re)loads, the WebSocket subscription is
/// updated to exactly the watched tickers so live prices flow only for them.

abstract class _$WatchlistController
    extends $AsyncNotifier<List<WatchlistItem>> {
  FutureOr<List<WatchlistItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<WatchlistItem>>, List<WatchlistItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<WatchlistItem>>, List<WatchlistItem>>,
              AsyncValue<List<WatchlistItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether [ticker] is currently on the watchlist (null while loading).

@ProviderFor(isWatched)
final isWatchedProvider = IsWatchedFamily._();

/// Whether [ticker] is currently on the watchlist (null while loading).

final class IsWatchedProvider extends $FunctionalProvider<bool?, bool?, bool?>
    with $Provider<bool?> {
  /// Whether [ticker] is currently on the watchlist (null while loading).
  IsWatchedProvider._({
    required IsWatchedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isWatchedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isWatchedHash();

  @override
  String toString() {
    return r'isWatchedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool? create(Ref ref) {
    final argument = this.argument as String;
    return isWatched(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsWatchedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isWatchedHash() => r'c399143f41adfad0b8c34678c86faae84f1b2bf3';

/// Whether [ticker] is currently on the watchlist (null while loading).

final class IsWatchedFamily extends $Family
    with $FunctionalFamilyOverride<bool?, String> {
  IsWatchedFamily._()
    : super(
        retry: null,
        name: r'isWatchedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether [ticker] is currently on the watchlist (null while loading).

  IsWatchedProvider call(String ticker) =>
      IsWatchedProvider._(argument: ticker, from: this);

  @override
  String toString() => r'isWatchedProvider';
}
