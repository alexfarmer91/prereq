import 'package:freezed_annotation/freezed_annotation.dart';

part 'performance.freezed.dart';
part 'performance.g.dart';

/// One calibration bucket: how often predictions in [bucketMin, bucketMax)
/// actually won.
@freezed
abstract class CalibrationBucket with _$CalibrationBucket {
  const factory CalibrationBucket({
    required double bucketMin,
    required double bucketMax,
    required int predictedCount,
    required double actualWinRate,
  }) = _CalibrationBucket;

  factory CalibrationBucket.fromJson(Map<String, dynamic> json) =>
      _$CalibrationBucketFromJson(json);
}

/// Profit & loss summary.
@freezed
abstract class PnlSummary with _$PnlSummary {
  const factory PnlSummary({
    required double totalWagered,
    required double totalReturned,
    required double roi,
    required double winRate,
    required int betCount,
  }) = _PnlSummary;

  factory PnlSummary.fromJson(Map<String, dynamic> json) =>
      _$PnlSummaryFromJson(json);
}

/// Win streak stats.
@freezed
abstract class Streaks with _$Streaks {
  const factory Streaks({
    required int currentWinStreak,
    required int longestWinStreak,
  }) = _Streaks;

  factory Streaks.fromJson(Map<String, dynamic> json) =>
      _$StreaksFromJson(json);
}

/// Payload of `GET /performance`.
@freezed
abstract class PerformanceData with _$PerformanceData {
  const factory PerformanceData({
    required List<CalibrationBucket> calibration,
    required PnlSummary pnl,
    required Streaks streaks,
  }) = _PerformanceData;

  factory PerformanceData.fromJson(Map<String, dynamic> json) =>
      _$PerformanceDataFromJson(json);
}
