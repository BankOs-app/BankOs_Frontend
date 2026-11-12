class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'Server exception occurred.',
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (statusCode: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Cache exception occurred.'});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'Network connection exception.'});

  @override
  String toString() => 'NetworkException: $message';
}
