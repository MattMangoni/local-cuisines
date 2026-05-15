class BestiebiteApiException implements Exception {
  const BestiebiteApiException({
    required this.statusCode,
    required this.message,
  });

  final int? statusCode;
  final String message;

  @override
  String toString() => 'BestiebiteApiException($statusCode): $message';
}
