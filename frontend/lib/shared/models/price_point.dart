import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_point.freezed.dart';
part 'price_point.g.dart';

/// One sample of `GET /markets/:ticker/history`.
@freezed
abstract class PricePoint with _$PricePoint {
  const factory PricePoint({
    required DateTime ts,
    required double yesPrice,
  }) = _PricePoint;

  factory PricePoint.fromJson(Map<String, dynamic> json) =>
      _$PricePointFromJson(json);
}
