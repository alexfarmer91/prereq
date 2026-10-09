import 'package:freezed_annotation/freezed_annotation.dart';

part 'market.freezed.dart';
part 'market.g.dart';

/// Confidence level attached to an AI score.
enum ScoreConfidence { low, medium, high }

/// AI-generated score for a market. `null` on a [Market] means "not yet
/// scored".
///
/// [fairProbability] is an unvalidated AI estimate that the market resolves
/// YES, and [confidence] is the model's self-rating, not measured
/// reliability. [edge] (AI–market gap) and the EV fields are computed by the
/// backend from live quotes; EV is null when there is no usable ask.
@freezed
abstract class Score with _$Score {
  const factory Score({
    required double fairProbability,
    required ScoreConfidence confidence,
    required double edge,
    double? evYesPerDollar,
    double? evNoPerDollar,
    required String rationale,
    required List<String> signals,
    required List<String> risks,
    @Default(<Evidence>[]) List<Evidence> evidence,
    required DateTime scoredAt,
  }) = _Score;

  factory Score.fromJson(Map<String, dynamic> json) => _$ScoreFromJson(json);
}

/// One piece of evidence the AI cited (prompt v3+). These are the model's
/// claims; sources are not independently verified.
@freezed
abstract class Evidence with _$Evidence {
  const factory Evidence({
    required String claim,
    String? source,
    String? date,

    /// yes | no | neutral — which outcome the claim points toward.
    String? supports,
  }) = _Evidence;

  factory Evidence.fromJson(Map<String, dynamic> json) =>
      _$EvidenceFromJson(json);
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
