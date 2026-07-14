import 'package:freezed_annotation/freezed_annotation.dart';

part 'bet.freezed.dart';
part 'bet.g.dart';

/// Which side of the binary market a bet was placed on.
enum BetSide { yes, no }

/// Resolution status of a logged bet.
enum BetOutcome { win, loss, pending }

/// One logged bet from the bet log.
@freezed
abstract class Bet with _$Bet {
  const factory Bet({
    required String id,
    required String marketTicker,
    required String marketTitle,
    required BetSide side,
    required double entryPriceDollars,
    required int contracts,
    required double yourProbability,
    double? kellyFraction,
    required BetOutcome outcome,
    double? exitPriceDollars,
    required DateTime placedAt,
    DateTime? resolvedAt,
  }) = _Bet;

  factory Bet.fromJson(Map<String, dynamic> json) => _$BetFromJson(json);
}

/// Paginated payload of `GET /bets`.
@freezed
abstract class BetsPage with _$BetsPage {
  const factory BetsPage({
    required List<Bet> bets,
    required int total,
    required int page,
    required int perPage,
  }) = _BetsPage;

  factory BetsPage.fromJson(Map<String, dynamic> json) =>
      _$BetsPageFromJson(json);
}
