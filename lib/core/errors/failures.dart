abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => '$runtimeType: $message (code: $statusCode)';
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'A server error occurred.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'A local cache error occurred.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection detected.']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}
