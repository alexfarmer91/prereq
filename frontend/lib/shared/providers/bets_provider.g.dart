// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bets_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bets)
final betsProvider = BetsFamily._();

final class BetsProvider
    extends
        $FunctionalProvider<AsyncValue<BetsPage>, BetsPage, FutureOr<BetsPage>>
    with $FutureModifier<BetsPage>, $FutureProvider<BetsPage> {
  BetsProvider._({
    required BetsFamily super.from,
    required ({BetOutcome? outcome, int page, int perPage}) super.argument,
  }) : super(
         retry: null,
         name: r'betsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$betsHash();

  @override
  String toString() {
    return r'betsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<BetsPage> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<BetsPage> create(Ref ref) {
    final argument =
        this.argument as ({BetOutcome? outcome, int page, int perPage});
    return bets(
      ref,
      outcome: argument.outcome,
      page: argument.page,
      perPage: argument.perPage,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BetsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$betsHash() => r'948ae29ae660b8bfb58f16a7aec6347a50d82115';

final class BetsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<BetsPage>,
          ({BetOutcome? outcome, int page, int perPage})
        > {
  BetsFamily._()
    : super(
        retry: null,
        name: r'betsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BetsProvider call({BetOutcome? outcome, int page = 1, int perPage = 25}) =>
      BetsProvider._(
        argument: (outcome: outcome, page: page, perPage: perPage),
        from: this,
      );

  @override
  String toString() => r'betsProvider';
}

/// Mutations on the bet log; invalidates dependent views on success.

@ProviderFor(BetActions)
final betActionsProvider = BetActionsProvider._();

/// Mutations on the bet log; invalidates dependent views on success.
final class BetActionsProvider extends $NotifierProvider<BetActions, void> {
  /// Mutations on the bet log; invalidates dependent views on success.
  BetActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'betActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$betActionsHash();

  @$internal
  @override
  BetActions create() => BetActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$betActionsHash() => r'5cf2ae29ad7c192b229e4897da967b41492c9f7a';

/// Mutations on the bet log; invalidates dependent views on success.

abstract class _$BetActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
