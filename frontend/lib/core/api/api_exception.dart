/// Typed error thrown by [ApiClient] whenever a request fails, carrying the
/// backend's `error` message from the response envelope when available.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  @override
  String toString() => message;
}
