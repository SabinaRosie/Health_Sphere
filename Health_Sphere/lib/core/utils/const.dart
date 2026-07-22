import 'package:flutter/foundation.dart';

class AppConstants {
  // 🔹 Use 192.168.101.2 so that physical local devices can access the backend server
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else {
      return 'http://192.168.101.2:8000';
    }
  }
}
