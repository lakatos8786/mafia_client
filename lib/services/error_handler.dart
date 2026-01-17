import 'package:flutter/foundation.dart';

/// Centralized error handling service
/// Provides user-friendly error messages and logging capabilities
class ErrorHandler {
  /// Converts technical errors into user-friendly Korean messages
  static String getUserFriendlyMessage(dynamic error, {String? context}) {
    final errorStr = error.toString().toLowerCase();

    // Network/Connection errors
    if (errorStr.contains('socket') ||
        errorStr.contains('connection') ||
        errorStr.contains('network')) {
      return '서버 연결에 문제가 발생했습니다. 인터넷 연결을 확인해주세요.';
    }

    // Timeout errors
    if (errorStr.contains('timeout')) {
      return '서버 응답 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.';
    }

    // JSON parsing errors
    if (errorStr.contains('json') ||
        errorStr.contains('parse') ||
        errorStr.contains('format')) {
      return '데이터 처리 중 오류가 발생했습니다.';
    }

    // Room/Game errors
    if (context != null) {
      switch (context) {
        case 'create_room':
          return '방 생성에 실패했습니다. 다시 시도해주세요.';
        case 'join_room':
          return '방 참여에 실패했습니다. 방 번호를 확인해주세요.';
        case 'start_game':
          return '게임 시작에 실패했습니다.';
        case 'vote':
          return '투표 처리 중 오류가 발생했습니다.';
        case 'night_action':
          return '야간 행동 처리 중 오류가 발생했습니다.';
      }
    }

    // Generic error
    return '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
  }

  /// Logs error with context for debugging
  static void logError(
    String context,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 ERROR in $context');
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace:\n$stackTrace');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  /// Handles error and returns user-friendly message
  /// Also logs the error in debug mode
  static String handleError(
    String context,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    logError(context, error, stackTrace);
    return getUserFriendlyMessage(error, context: context);
  }
}
