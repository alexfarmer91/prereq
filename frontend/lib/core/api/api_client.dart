import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../shared/models/arb.dart';
import '../../shared/models/bet.dart';
import '../../shared/models/market.dart';
import '../../shared/models/market_detail.dart';
import '../../shared/models/performance.dart';
import '../../shared/models/price_point.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/models/watchlist_item.dart';
import 'api_exception.dart';

/// Sort options accepted by `GET /markets`.
enum MarketSort {
  edge('edge'),
  volume('volume'),
  close('close');

  const MarketSort(this.queryValue);
  final String queryValue;
}

/// Envelope-aware REST client for the Prereq backend.
///
/// Every response is `{"data": ..., "error": null}` on success and
/// `{"data": null, "error": "message"}` on failure; failures are surfaced as
/// [ApiException].
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.getToken,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String baseUrl;

  /// Returns the Bearer token to attach, or `null` when running without auth
  /// (dev bypass mode).
  final Future<String?> Function() getToken;

  final http.Client _http;

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final base = Uri.parse(baseUrl);
    final uri = base.replace(
      path: path,
      queryParameters: (query == null || query.isEmpty) ? null : query,
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      response = await http.Response.fromStream(await _http.send(request));
    } on http.ClientException catch (e) {
      throw ApiException('Could not reach the server: ${e.message}');
    } catch (e) {
      throw ApiException('Network error: $e');
    }

    Map<String, dynamic>? envelope;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) envelope = decoded;
    } on FormatException {
      envelope = null;
    }

    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok) {
      final message = envelope?['error'] as String? ??
          'Request failed (HTTP ${response.statusCode})';
      throw ApiException(message, statusCode: response.statusCode);
    }
    if (envelope == null) {
      throw ApiException('Malformed response from server',
          statusCode: response.statusCode);
    }
    if (envelope['error'] != null) {
      throw ApiException(envelope['error'] as String,
          statusCode: response.statusCode);
    }
    return envelope['data'];
  }

  // ---------------------------------------------------------------- Markets

  Future<List<Market>> getMarkets({String? category, MarketSort? sort}) async {
    final data = await _send('GET', '/markets', query: {
      'category': ?category,
      'sort': ?sort?.queryValue,
    });
    return (data as List<dynamic>)
        .map((e) => Market.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MarketDetail> getMarketDetail(String ticker) async {
    final data = await _send('GET', '/markets/$ticker');
    return MarketDetail.fromJson(data as Map<String, dynamic>);
  }

  Future<List<PricePoint>> getMarketHistory(String ticker) async {
    final data = await _send('GET', '/markets/$ticker/history');
    return (data as List<dynamic>)
        .map((e) => PricePoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------- Profile

  Future<UserProfile> getMe() async {
    final data = await _send('GET', '/me');
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  Future<UserProfile> updateBankroll(double bankrollDollars) async {
    final data = await _send('PATCH', '/me',
        body: {'bankroll_dollars': bankrollDollars});
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  Future<UserProfile> acceptTerms() async {
    final data = await _send('POST', '/me/accept-terms');
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  // -------------------------------------------------------------- Watchlist

  Future<List<WatchlistItem>> getWatchlist() async {
    final data = await _send('GET', '/watchlist');
    return (data as List<dynamic>)
        .map((e) => WatchlistItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WatchlistItem> addToWatchlist(
    String ticker, {
    double? alertEdgeThreshold,
  }) async {
    final data = await _send('POST', '/watchlist', body: {
      'ticker': ticker,
      'alert_edge_threshold': alertEdgeThreshold,
    });
    return WatchlistItem.fromJson(data as Map<String, dynamic>);
  }

  Future<void> removeFromWatchlist(String ticker) async {
    await _send('DELETE', '/watchlist/$ticker');
  }

  // ------------------------------------------------------------------- Bets

  Future<BetsPage> getBets({
    BetOutcome? outcome,
    int page = 1,
    int perPage = 25,
  }) async {
    final data = await _send('GET', '/bets', query: {
      if (outcome != null) 'outcome': outcome.name,
      'page': '$page',
      'per_page': '$perPage',
    });
    return BetsPage.fromJson(data as Map<String, dynamic>);
  }

  Future<Bet> logBet({
    required String marketTicker,
    required String marketTitle,
    required BetSide side,
    required double entryPriceDollars,
    required int contracts,
    required double yourProbability,
    double? kellyFraction,
  }) async {
    final data = await _send('POST', '/bets', body: {
      'market_ticker': marketTicker,
      'market_title': marketTitle,
      'side': side.name,
      'entry_price_dollars': entryPriceDollars,
      'contracts': contracts,
      'your_probability': yourProbability,
      'kelly_fraction': kellyFraction,
    });
    return Bet.fromJson(data as Map<String, dynamic>);
  }

  Future<Bet> resolveBet(
    String id, {
    required BetOutcome outcome,
    required double exitPriceDollars,
  }) async {
    final data = await _send('PATCH', '/bets/$id', body: {
      'outcome': outcome.name,
      'exit_price_dollars': exitPriceDollars,
    });
    return Bet.fromJson(data as Map<String, dynamic>);
  }

  // ------------------------------------------------------------ Performance

  Future<PerformanceData> getPerformance() async {
    final data = await _send('GET', '/performance');
    return PerformanceData.fromJson(data as Map<String, dynamic>);
  }

  // ------------------------------------------------------------------- Arbs

  Future<List<Arb>> getArbs() async {
    final data = await _send('GET', '/arbs');
    return (data as List<dynamic>)
        .map((e) => Arb.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
