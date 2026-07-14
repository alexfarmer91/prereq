// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WsPriceUpdate _$WsPriceUpdateFromJson(Map<String, dynamic> json) =>
    _WsPriceUpdate(
      ticker: json['ticker'] as String,
      yesBid: (json['yes_bid'] as num).toDouble(),
      yesAsk: (json['yes_ask'] as num).toDouble(),
      ts: DateTime.parse(json['ts'] as String),
    );

Map<String, dynamic> _$WsPriceUpdateToJson(_WsPriceUpdate instance) =>
    <String, dynamic>{
      'ticker': instance.ticker,
      'yes_bid': instance.yesBid,
      'yes_ask': instance.yesAsk,
      'ts': instance.ts.toIso8601String(),
    };

_WsArbCount _$WsArbCountFromJson(Map<String, dynamic> json) =>
    _WsArbCount(count: (json['count'] as num).toInt());

Map<String, dynamic> _$WsArbCountToJson(_WsArbCount instance) =>
    <String, dynamic>{'count': instance.count};
