import 'package:freezed_annotation/freezed_annotation.dart';

import 'market.dart';

part 'market_detail.freezed.dart';
part 'market_detail.g.dart';

/// Payload of `GET /markets/:ticker` — the market plus every strike variant
/// in the same event (including this market itself).
@freezed
abstract class MarketDetail with _$MarketDetail {
  const factory MarketDetail({
    required Market market,
    required List<Market> eventMarkets,
  }) = _MarketDetail;

  factory MarketDetail.fromJson(Map<String, dynamic> json) =>
      _$MarketDetailFromJson(json);
}
