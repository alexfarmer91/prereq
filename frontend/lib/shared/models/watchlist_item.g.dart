// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watchlist_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WatchlistItem _$WatchlistItemFromJson(Map<String, dynamic> json) =>
    _WatchlistItem(
      id: json['id'] as String,
      marketTicker: json['market_ticker'] as String,
      alertEdgeThreshold: (json['alert_edge_threshold'] as num?)?.toDouble(),
      edgeAtAdd: (json['edge_at_add'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      market: json['market'] == null
          ? null
          : Market.fromJson(json['market'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WatchlistItemToJson(_WatchlistItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'market_ticker': instance.marketTicker,
      'alert_edge_threshold': instance.alertEdgeThreshold,
      'edge_at_add': instance.edgeAtAdd,
      'created_at': instance.createdAt.toIso8601String(),
      'market': instance.market?.toJson(),
    };
