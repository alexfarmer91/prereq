// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arb.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Arb _$ArbFromJson(Map<String, dynamic> json) => _Arb(
  kalshiTicker: json['kalshi_ticker'] as String,
  kalshiTitle: json['kalshi_title'] as String,
  polymarketId: json['polymarket_id'] as String,
  polymarketQuestion: json['polymarket_question'] as String,
  kalshiYesAsk: (json['kalshi_yes_ask'] as num).toDouble(),
  polymarketNoAsk: (json['polymarket_no_ask'] as num).toDouble(),
  combinedCost: (json['combined_cost'] as num).toDouble(),
  edge: (json['edge'] as num).toDouble(),
  detectedAt: DateTime.parse(json['detected_at'] as String),
);

Map<String, dynamic> _$ArbToJson(_Arb instance) => <String, dynamic>{
  'kalshi_ticker': instance.kalshiTicker,
  'kalshi_title': instance.kalshiTitle,
  'polymarket_id': instance.polymarketId,
  'polymarket_question': instance.polymarketQuestion,
  'kalshi_yes_ask': instance.kalshiYesAsk,
  'polymarket_no_ask': instance.polymarketNoAsk,
  'combined_cost': instance.combinedCost,
  'edge': instance.edge,
  'detected_at': instance.detectedAt.toIso8601String(),
};
