/// One scoring row from the export query (docs/forecast-validation.md),
/// joined with its market's outcome. Raw values are kept as exported —
/// nothing is clamped or repaired here.
library;

class Observation {
  Observation({
    required this.scoreId,
    required this.marketTicker,
    this.eventTicker,
    this.category,
    this.promptVersion,
    this.confidence,
    required this.q,
    this.m,
    this.yesBid,
    this.yesAsk,
    this.noBid,
    this.noAsk,
    this.requestedAt,
    required this.scoredAt,
    this.closeTime,
    this.webSearchEnabled,
    this.resolution,
    this.settlementTs,
  });

  final String scoreId;
  final String marketTicker;
  final String? eventTicker;
  final String? category;

  /// null = legacy row written before the forecast ledger existed.
  final String? promptVersion;
  final String? confidence;

  /// AI probability of YES, raw.
  final double q;

  /// Market YES mid shown to the AI (the benchmark).
  final double? m;
  final double? yesBid;
  final double? yesAsk;
  final double? noBid;
  final double? noAsk;
  final DateTime? requestedAt;
  final DateTime scoredAt;
  final DateTime? closeTime;
  final bool? webSearchEnabled;

  /// market_outcomes.resolution; null when the market was never checked.
  final String? resolution;

  /// When Kalshi settled the market — the time the label became known.
  final DateTime? settlementTs;

  /// Unique grouping key for dependence: the Kalshi event, or the market
  /// itself when the event is unknown (documented, not guessed).
  String get group =>
      eventTicker?.isNotEmpty == true ? eventTicker! : marketTicker;

  bool get isSynthetic => marketTicker.startsWith(syntheticPrefix);

  double? get y => switch (resolution) {
    'yes' => 1.0,
    'no' => 0.0,
    _ => null,
  };

  double? get spread =>
      (yesBid != null && yesAsk != null) ? yesAsk! - yesBid! : null;

  /// Days from scoring to close.
  double? get horizonDays => closeTime == null
      ? null
      : closeTime!.difference(scoredAt).inMinutes / (60 * 24);

  static Observation fromRecord(Map<String, String> r) {
    String? str(String k) {
      final v = r[k]?.trim();
      return (v == null || v.isEmpty) ? null : v;
    }

    double? num_(String k) => str(k) == null ? null : double.tryParse(str(k)!);
    DateTime? time(String k) =>
        str(k) == null ? null : DateTime.tryParse(str(k)!)?.toUtc();

    final q = num_('fair_probability');
    final scoredAt = time('scored_at');
    if (q == null || scoredAt == null || str('market_ticker') == null) {
      throw FormatException(
        'Row ${r['score_id']} is missing market_ticker, fair_probability or scored_at',
      );
    }
    return Observation(
      scoreId: str('score_id') ?? '',
      marketTicker: str('market_ticker')!,
      eventTicker: str('event_ticker'),
      category: str('category'),
      promptVersion: str('prompt_version'),
      confidence: str('confidence'),
      q: q,
      m: num_('market_price_at_score'),
      yesBid: num_('yes_bid'),
      yesAsk: num_('yes_ask'),
      noBid: num_('no_bid'),
      noAsk: num_('no_ask'),
      requestedAt: time('requested_at'),
      scoredAt: scoredAt,
      closeTime: time('market_close_time'),
      webSearchEnabled: switch (str('web_search_enabled')?.toLowerCase()) {
        'true' || 't' => true,
        'false' || 'f' => false,
        _ => null,
      },
      resolution: str('resolution'),
      settlementTs: time('settlement_ts'),
    );
  }
}

/// Every synthetic fixture ticker starts with this, and any report built
/// from such rows is stamped SYNTHETIC.
const syntheticPrefix = 'SYN-';

/// The export's column order (see docs/forecast-validation.md).
const exportColumns = [
  'score_id',
  'market_ticker',
  'event_ticker',
  'category',
  'prompt_version',
  'confidence',
  'fair_probability',
  'market_price_at_score',
  'yes_bid',
  'yes_ask',
  'no_bid',
  'no_ask',
  'requested_at',
  'scored_at',
  'market_close_time',
  'web_search_enabled',
  'resolution',
  'settlement_ts',
];
