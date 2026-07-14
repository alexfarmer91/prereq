import 'package:freezed_annotation/freezed_annotation.dart';

import 'market.dart';

part 'watchlist_item.freezed.dart';
part 'watchlist_item.g.dart';

/// One entry of `GET /watchlist`.
@freezed
abstract class WatchlistItem with _$WatchlistItem {
  const factory WatchlistItem({
    required String id,
    required String marketTicker,
    double? alertEdgeThreshold,
    double? edgeAtAdd,
    required DateTime createdAt,
    Market? market,
  }) = _WatchlistItem;

  factory WatchlistItem.fromJson(Map<String, dynamic> json) =>
      _$WatchlistItemFromJson(json);
}
