import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/api_client.dart';
import '../../core/config/app_config.dart';
import 'auth_provider.dart';

part 'api_client_provider.g.dart';

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  return ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    getToken: () => ref.read(authControllerProvider.notifier).getToken(),
  );
}
