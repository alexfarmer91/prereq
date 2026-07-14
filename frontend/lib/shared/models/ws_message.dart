import 'package:freezed_annotation/freezed_annotation.dart';

part 'ws_message.freezed.dart';
part 'ws_message.g.dart';

/// Messages pushed by the backend over `/ws/markets`, discriminated by the
/// `type` field (`price_update` | `arb_count`).
sealed class WsMessage {
  /// Parses a raw server message; returns null for unknown message types so
  /// the socket can ignore them gracefully.
  static WsMessage? tryParse(Map<String, dynamic> json) {
    return switch (json['type']) {
      'price_update' => WsPriceUpdate.fromJson(json),
      'arb_count' => WsArbCount.fromJson(json),
      _ => null,
    };
  }
}

@freezed
abstract class WsPriceUpdate with _$WsPriceUpdate implements WsMessage {
  const factory WsPriceUpdate({
    required String ticker,
    required double yesBid,
    required double yesAsk,
    required DateTime ts,
  }) = _WsPriceUpdate;

  factory WsPriceUpdate.fromJson(Map<String, dynamic> json) =>
      _$WsPriceUpdateFromJson(json);
}

@freezed
abstract class WsArbCount with _$WsArbCount implements WsMessage {
  const factory WsArbCount({required int count}) = _WsArbCount;

  factory WsArbCount.fromJson(Map<String, dynamic> json) =>
      _$WsArbCountFromJson(json);
}
