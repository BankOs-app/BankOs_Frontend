import 'package:dio/dio.dart';

import '../localization/app_locale_provider.dart';

/// Converts transport and validation failures into messages customers can act on.
class UserFacingError {
  static String from(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return Tr.bankConnectionError(LocaleNotifier.currentLanguage);
      }

      final payload = error.response?.data;
      if (payload is Map) {
        final code = payload['internalCode']?.toString();
        if (status != null) {
          return Tr.apiError(LocaleNotifier.currentLanguage, status, code);
        }
      }
      if (status != null) {
        return Tr.apiError(LocaleNotifier.currentLanguage, status, null);
      }
    }

    final message = error
        .toString()
        .replaceFirst(
          RegExp(r'^(Exception|ArgumentError|ServerException):\s*'),
          '',
        )
        .trim();
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('saldo insuficiente') ||
        lowerMessage.contains('insufficient balance')) {
      return Tr.insufficientFundsError(LocaleNotifier.currentLanguage);
    }
    if (lowerMessage.contains('no encontrada') ||
        lowerMessage.contains('no fue encontrada')) {
      return Tr.notFoundError(LocaleNotifier.currentLanguage);
    }
    if (lowerMessage.contains('no se permite') ||
        lowerMessage.contains('no está activa')) {
      return Tr.accountInactiveError(LocaleNotifier.currentLanguage);
    }
    if (lowerMessage.contains('límite') || lowerMessage.contains('limite')) {
      return Tr.transactionLimitError(LocaleNotifier.currentLanguage);
    }
    if (message.isEmpty ||
        message.contains('DioException') ||
        message.contains('PlatformException') ||
        message.contains('Unsupported operation') ||
        message.contains('SocketException') ||
        message.contains('HandshakeException') ||
        message.contains('statusCode:')) {
      return Tr.genericError(LocaleNotifier.currentLanguage);
    }
    // Unknown server and platform messages can contain codes or implementation
    // details. Keep them out of the customer interface.
    return Tr.genericError(LocaleNotifier.currentLanguage);
  }
}
