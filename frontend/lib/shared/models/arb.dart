import 'package:freezed_annotation/freezed_annotation.dart';

part 'arb.freezed.dart';
part 'arb.g.dart';

/// A cross-platform arbitrage opportunity from `GET /arbs`.
@freezed
abstract class Arb with _$Arb {
  const factory Arb({
    required String kalshiTicker,
    required String kalshiTitle,
    required String polymarketId,
    required String polymarketQuestion,
    required double kalshiYesAsk,
    required double polymarketNoAsk,
    required double combinedCost,
    required double edge,
    required DateTime detectedAt,
  }) = _Arb;

  factory Arb.fromJson(Map<String, dynamic> json) => _$ArbFromJson(json);
}
