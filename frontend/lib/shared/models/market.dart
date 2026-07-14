import 'package:freezed_annotation/freezed_annotation.dart';

part 'market.freezed.dart';
part 'market.g.dart';

/// Confidence level attached to an AI score.
enum ScoreConfidence { low, medium, high }

/// AI-generated score for a market. `null` on a [Market] means "not yet
/// scored".
@freezed
abstract class Score with _$Score {
  const factory Score({
    required double fairProbability,
    required ScoreConfidence confidence,
    required double edge,
    required double evPerDollar,
    required String rationale,
    required List<String> signals,
    required List<String> risks,
    required DateTime scoredAt,
  }) = _Score;

  factory Score.fromJson(Map<String, dynamic> json) => _$ScoreFromJson(json);
}

/// A single Kalshi market as served by the backend. All prices are dollars.
@freezed
abstract class Market with _$Market {
  const Market._();

  const factory Market({
    required String ticker,
    required String eventTicker,
    required String title,
    required double yesBid,
    required double yesAsk,
    required double noBid,
    required double noAsk,
    required double midPrice,
    required double spread,
    @JsonKey(name: 'volume_24h') required double volume24h,
    required DateTime closeTime,
    String? rulesPrimary,
    required String category,
    Score? score,
  }) = _Market;

  factory Market.fromJson(Map<String, dynamic> json) => _$MarketFromJson(json);

  /// Time remaining until the market closes (negative when already closed).
  Duration get timeToClose => closeTime.difference(DateTime.now().toUtc());
}
