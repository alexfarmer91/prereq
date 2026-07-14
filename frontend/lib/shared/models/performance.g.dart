// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalibrationBucket _$CalibrationBucketFromJson(Map<String, dynamic> json) =>
    _CalibrationBucket(
      bucketMin: (json['bucket_min'] as num).toDouble(),
      bucketMax: (json['bucket_max'] as num).toDouble(),
      predictedCount: (json['predicted_count'] as num).toInt(),
      actualWinRate: (json['actual_win_rate'] as num).toDouble(),
    );

Map<String, dynamic> _$CalibrationBucketToJson(_CalibrationBucket instance) =>
    <String, dynamic>{
      'bucket_min': instance.bucketMin,
      'bucket_max': instance.bucketMax,
      'predicted_count': instance.predictedCount,
      'actual_win_rate': instance.actualWinRate,
    };

_PnlSummary _$PnlSummaryFromJson(Map<String, dynamic> json) => _PnlSummary(
  totalWagered: (json['total_wagered'] as num).toDouble(),
  totalReturned: (json['total_returned'] as num).toDouble(),
  roi: (json['roi'] as num).toDouble(),
  winRate: (json['win_rate'] as num).toDouble(),
  betCount: (json['bet_count'] as num).toInt(),
);

Map<String, dynamic> _$PnlSummaryToJson(_PnlSummary instance) =>
    <String, dynamic>{
      'total_wagered': instance.totalWagered,
      'total_returned': instance.totalReturned,
      'roi': instance.roi,
      'win_rate': instance.winRate,
      'bet_count': instance.betCount,
    };

_Streaks _$StreaksFromJson(Map<String, dynamic> json) => _Streaks(
  currentWinStreak: (json['current_win_streak'] as num).toInt(),
  longestWinStreak: (json['longest_win_streak'] as num).toInt(),
);

Map<String, dynamic> _$StreaksToJson(_Streaks instance) => <String, dynamic>{
  'current_win_streak': instance.currentWinStreak,
  'longest_win_streak': instance.longestWinStreak,
};

_PerformanceData _$PerformanceDataFromJson(Map<String, dynamic> json) =>
    _PerformanceData(
      calibration: (json['calibration'] as List<dynamic>)
          .map((e) => CalibrationBucket.fromJson(e as Map<String, dynamic>))
          .toList(),
      pnl: PnlSummary.fromJson(json['pnl'] as Map<String, dynamic>),
      streaks: Streaks.fromJson(json['streaks'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PerformanceDataToJson(_PerformanceData instance) =>
    <String, dynamic>{
      'calibration': instance.calibration.map((e) => e.toJson()).toList(),
      'pnl': instance.pnl.toJson(),
      'streaks': instance.streaks.toJson(),
    };
