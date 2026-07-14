// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PricePoint _$PricePointFromJson(Map<String, dynamic> json) => _PricePoint(
  ts: DateTime.parse(json['ts'] as String),
  yesPrice: (json['yes_price'] as num).toDouble(),
);

Map<String, dynamic> _$PricePointToJson(_PricePoint instance) =>
    <String, dynamic>{
      'ts': instance.ts.toIso8601String(),
      'yes_price': instance.yesPrice,
    };
