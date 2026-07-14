// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'markets_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(markets)
final marketsProvider = MarketsFamily._();

final class MarketsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Market>>,
          List<Market>,
          FutureOr<List<Market>>
        >
    with $FutureModifier<List<Market>>, $FutureProvider<List<Market>> {
  MarketsProvider._({
    required MarketsFamily super.from,
    required ({String? category, MarketSort sort}) super.argument,
  }) : super(
         retry: null,
         name: r'marketsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$marketsHash();

  @override
  String toString() {
    return r'marketsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Market>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Market>> create(Ref ref) {
    final argument = this.argument as ({String? category, MarketSort sort});
    return markets(ref, category: argument.category, sort: argument.sort);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$marketsHash() => r'185990b6cecf991df3044314355a18805e641a1c';

final class MarketsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Market>>,
          ({String? category, MarketSort sort})
        > {
  MarketsFamily._()
    : super(
        retry: null,
        name: r'marketsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MarketsProvider call({String? category, MarketSort sort = MarketSort.edge}) =>
      MarketsProvider._(argument: (category: category, sort: sort), from: this);

  @override
  String toString() => r'marketsProvider';
}

@ProviderFor(marketDetail)
final marketDetailProvider = MarketDetailFamily._();

final class MarketDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<MarketDetail>,
          MarketDetail,
          FutureOr<MarketDetail>
        >
    with $FutureModifier<MarketDetail>, $FutureProvider<MarketDetail> {
  MarketDetailProvider._({
    required MarketDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'marketDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$marketDetailHash();

  @override
  String toString() {
    return r'marketDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MarketDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MarketDetail> create(Ref ref) {
    final argument = this.argument as String;
    return marketDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$marketDetailHash() => r'c5f1ece25b7b9860946025900192949fc1d73ef8';

final class MarketDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MarketDetail>, String> {
  MarketDetailFamily._()
    : super(
        retry: null,
        name: r'marketDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MarketDetailProvider call(String ticker) =>
      MarketDetailProvider._(argument: ticker, from: this);

  @override
  String toString() => r'marketDetailProvider';
}

@ProviderFor(marketHistory)
final marketHistoryProvider = MarketHistoryFamily._();

final class MarketHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PricePoint>>,
          List<PricePoint>,
          FutureOr<List<PricePoint>>
        >
    with $FutureModifier<List<PricePoint>>, $FutureProvider<List<PricePoint>> {
  MarketHistoryProvider._({
    required MarketHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'marketHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$marketHistoryHash();

  @override
  String toString() {
    return r'marketHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PricePoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PricePoint>> create(Ref ref) {
    final argument = this.argument as String;
    return marketHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$marketHistoryHash() => r'6011aaf027d9d1272314b6a60358fe22ec7f63db';

final class MarketHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PricePoint>>, String> {
  MarketHistoryFamily._()
    : super(
        retry: null,
        name: r'marketHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MarketHistoryProvider call(String ticker) =>
      MarketHistoryProvider._(argument: ticker, from: this);

  @override
  String toString() => r'marketHistoryProvider';
}
