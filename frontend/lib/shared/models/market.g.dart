// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Score _$ScoreFromJson(Map<String, dynamic> json) => _Score(
  fairProbability: (json['fair_probability'] as num).toDouble(),
  confidence: $enumDecode(_$ScoreConfidenceEnumMap, json['confidence']),
  edge: (json['edge'] as num).toDouble(),
  evPerDollar: (json['ev_per_dollar'] as num).toDouble(),
  rationale: json['rationale'] as String,
  signals: (json['signals'] as List<dynamic>).map((e) => e as String).toList(),
  risks: (json['risks'] as List<dynamic>).map((e) => e as String).toList(),
  scoredAt: DateTime.parse(json['scored_at'] as String),
);

Map<String, dynamic> _$ScoreToJson(_Score instance) => <String, dynamic>{
  'fair_probability': instance.fairProbability,
  'confidence': _$ScoreConfidenceEnumMap[instance.confidence]!,
  'edge': instance.edge,
  'ev_per_dollar': instance.evPerDollar,
  'rationale': instance.rationale,
  'signals': instance.signals,
  'risks': instance.risks,
  'scored_at': instance.scoredAt.toIso8601String(),
};

const _$ScoreConfidenceEnumMap = {
  ScoreConfidence.low: 'low',
  ScoreConfidence.medium: 'medium',
  ScoreConfidence.high: 'high',
};

_Market _$MarketFromJson(Map<String, dynamic> json) => _Market(
  ticker: json['ticker'] as String,
  eventTicker: json['event_ticker'] as String,
  title: json['title'] as String,
  yesBid: (json['yes_bid'] as num).toDouble(),
  yesAsk: (json['yes_ask'] as num).toDouble(),
  noBid: (json['no_bid'] as num).toDouble(),
  noAsk: (json['no_ask'] as num).toDouble(),
  midPrice: (json['mid_price'] as num).toDouble(),
  spread: (json['spread'] as num).toDouble(),
  volume24h: (json['volume_24h'] as num).toDouble(),
  closeTime: DateTime.parse(json['close_time'] as String),
  rulesPrimary: json['rules_primary'] as String?,
  category: json['category'] as String,
  score: json['score'] == null
      ? null
      : Score.fromJson(json['score'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MarketToJson(_Market instance) => <String, dynamic>{
  'ticker': instance.ticker,
  'event_ticker': instance.eventTicker,
  'title': instance.title,
  'yes_bid': instance.yesBid,
  'yes_ask': instance.yesAsk,
  'no_bid': instance.noBid,
  'no_ask': instance.noAsk,
  'mid_price': instance.midPrice,
  'spread': instance.spread,
  'volume_24h': instance.volume24h,
  'close_time': instance.closeTime.toIso8601String(),
  'rules_primary': instance.rulesPrimary,
  'category': instance.category,
  'score': instance.score?.toJson(),
};
