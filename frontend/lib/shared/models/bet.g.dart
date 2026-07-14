// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bet _$BetFromJson(Map<String, dynamic> json) => _Bet(
  id: json['id'] as String,
  marketTicker: json['market_ticker'] as String,
  marketTitle: json['market_title'] as String,
  side: $enumDecode(_$BetSideEnumMap, json['side']),
  entryPriceDollars: (json['entry_price_dollars'] as num).toDouble(),
  contracts: (json['contracts'] as num).toInt(),
  yourProbability: (json['your_probability'] as num).toDouble(),
  kellyFraction: (json['kelly_fraction'] as num?)?.toDouble(),
  outcome: $enumDecode(_$BetOutcomeEnumMap, json['outcome']),
  exitPriceDollars: (json['exit_price_dollars'] as num?)?.toDouble(),
  placedAt: DateTime.parse(json['placed_at'] as String),
  resolvedAt: json['resolved_at'] == null
      ? null
      : DateTime.parse(json['resolved_at'] as String),
);

Map<String, dynamic> _$BetToJson(_Bet instance) => <String, dynamic>{
  'id': instance.id,
  'market_ticker': instance.marketTicker,
  'market_title': instance.marketTitle,
  'side': _$BetSideEnumMap[instance.side]!,
  'entry_price_dollars': instance.entryPriceDollars,
  'contracts': instance.contracts,
  'your_probability': instance.yourProbability,
  'kelly_fraction': instance.kellyFraction,
  'outcome': _$BetOutcomeEnumMap[instance.outcome]!,
  'exit_price_dollars': instance.exitPriceDollars,
  'placed_at': instance.placedAt.toIso8601String(),
  'resolved_at': instance.resolvedAt?.toIso8601String(),
};

const _$BetSideEnumMap = {BetSide.yes: 'yes', BetSide.no: 'no'};

const _$BetOutcomeEnumMap = {
  BetOutcome.win: 'win',
  BetOutcome.loss: 'loss',
  BetOutcome.pending: 'pending',
};

_BetsPage _$BetsPageFromJson(Map<String, dynamic> json) => _BetsPage(
  bets: (json['bets'] as List<dynamic>)
      .map((e) => Bet.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  perPage: (json['per_page'] as num).toInt(),
);

Map<String, dynamic> _$BetsPageToJson(_BetsPage instance) => <String, dynamic>{
  'bets': instance.bets.map((e) => e.toJson()).toList(),
  'total': instance.total,
  'page': instance.page,
  'per_page': instance.perPage,
};
