// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MarketDetail _$MarketDetailFromJson(Map<String, dynamic> json) =>
    _MarketDetail(
      market: Market.fromJson(json['market'] as Map<String, dynamic>),
      eventMarkets: (json['event_markets'] as List<dynamic>)
          .map((e) => Market.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MarketDetailToJson(_MarketDetail instance) =>
    <String, dynamic>{
      'market': instance.market.toJson(),
      'event_markets': instance.eventMarkets.map((e) => e.toJson()).toList(),
    };
