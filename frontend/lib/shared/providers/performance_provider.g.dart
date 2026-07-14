// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(performance)
final performanceProvider = PerformanceProvider._();

final class PerformanceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PerformanceData>,
          PerformanceData,
          FutureOr<PerformanceData>
        >
    with $FutureModifier<PerformanceData>, $FutureProvider<PerformanceData> {
  PerformanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performanceHash();

  @$internal
  @override
  $FutureProviderElement<PerformanceData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PerformanceData> create(Ref ref) {
    return performance(ref);
  }
}

String _$performanceHash() => r'75c862dc14865a7bda2079d1f950219694de5158';
