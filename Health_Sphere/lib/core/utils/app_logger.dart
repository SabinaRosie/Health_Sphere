import 'dart:developer' as developer;

class AppLogger {
  AppLogger._();

  static void d(String message) {
    developer.log('DEBUG: $message', name: 'HealthSphere');
  }

  static void i(String message) {
    developer.log('INFO: $message', name: 'HealthSphere');
  }

  static void w(String message, {Object? error}) {
    developer.log('WARN: $message', name: 'HealthSphere', error: error);
  }

  static void e(String message, {Object? error}) {
    developer.log('ERROR: $message', name: 'HealthSphere', error: error, stackTrace: StackTrace.current);
  }
}
