import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/performance.dart';
import 'api_client_provider.dart';

part 'performance_provider.g.dart';

@riverpod
Future<PerformanceData> performance(Ref ref) {
  return ref.watch(apiClientProvider).getPerformance();
}
