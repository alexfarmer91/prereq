import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/api_client.dart';
import '../models/market.dart';
import '../models/market_detail.dart';
import '../models/price_point.dart';
import 'api_client_provider.dart';

part 'markets_provider.g.dart';

/// Category filter chips shown on the scanner. `null` = All.
const scannerCategories = <String?>[
  null,
  'Sports',
  'Economics',
  'Politics',
  'Weather',
];

@riverpod
Future<List<Market>> markets(
  Ref ref, {
  String? category,
  MarketSort sort = MarketSort.edge,
}) {
  return ref
      .watch(apiClientProvider)
      .getMarkets(category: category, sort: sort);
}

@riverpod
Future<MarketDetail> marketDetail(Ref ref, String ticker) {
  return ref.watch(apiClientProvider).getMarketDetail(ticker);
}

@riverpod
Future<List<PricePoint>> marketHistory(Ref ref, String ticker) {
  return ref.watch(apiClientProvider).getMarketHistory(ticker);
}
