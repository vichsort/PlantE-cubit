class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? errorCode;
  ApiException(this.message, this.statusCode, {this.errorCode});

  @override
  String toString() {
    return 'ApiException: $statusCode ${errorCode != null ? '[$errorCode]' : ''}: $message';
  }
}