import 'dart:convert';
import 'package:health_sphere/core/utils/string_utils.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/const.dart';
import '../utils/strings.dart';
import '../utils/app_logger.dart';

class ApiService {
  ApiService._();

  // 🔹 Cached SharedPreferences instance
  static SharedPreferences? _prefsCache;
  static Future<SharedPreferences> get _prefs async {
    _prefsCache ??= await SharedPreferences.getInstance();
    return _prefsCache!;
  }

  /// 🔹 Keep-alive ping for Hugging Face Spaces (prevents cold starts)
  static Future<void> keepAlive() async {
    try {
      await http.get(
        Uri.parse('${AppConstants.baseUrl}/health-check'),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {
      // Silent warm-up ping
    }
  }

  /// 🔹 Handle standard API responses
  static Map<String, dynamic> _handleResponse(
    http.Response response,
    String defaultError,
  ) {
    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        String errorMsg = defaultError;
        if (data is Map) {
          errorMsg = data['error'] ?? data['detail'] ?? defaultError;
        }
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      if (response.statusCode == 503 || response.statusCode == 502) {
        return {
          'success': false,
          'error': 'Server is waking up. Please wait a moment and try again.',
        };
      }
      return {'success': false, 'error': 'Unexpected response from server.'};
    }
  }

  /// 🔹 Format common network errors
  static String _formatError(dynamic e) {
    String err = e.toString();
    if (err.contains('SocketException') || err.contains('Connection timed out')) {
      return 'Connection timed out. The server might be waking up or your internet is unstable.';
    }
    if (err.contains('ClientException')) {
      return 'Network error. Please check your connection.';
    }
    return err;
  }

  // ── Authentication ──

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${AppConstants.baseUrl}/api/login/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));
      
      final result = _handleResponse(response, 'Login failed');
      
      if (result['success']) {
        final prefs = await _prefs;
        await prefs.setString(keyAuthToken, result['data']['access']);
        // Save refresh token if applicable
        if (result['data']['refresh'] != null) {
          await prefs.setString('refreshToken', result['data']['refresh']);
        }
      }
      return result;
    } catch (e) {
      return {'success': false, 'error': _formatError(e)};
    }
  }

  static Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
    final url = Uri.parse('${AppConstants.baseUrl}/api/signup/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      ).timeout(const Duration(seconds: 30));
      return _handleResponse(response, 'Signup failed');
    } catch (e) {
      return {'success': false, 'error': _formatError(e)};
    }
  }

  // ── Profile & Data ──

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getValidToken();
    if (token == null) return {'success': false, 'error': errorSessionExpired};

    final url = Uri.parse('${AppConstants.baseUrl}/api/profile/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response, 'Failed to fetch profile');
    } catch (e) {
      return {'success': false, 'error': _formatError(e)};
    }
  }

  /// 🔹 Helper to get a valid access token, refreshing it if needed
  static Future<String?> getValidToken() async {
    final prefs = await _prefs;
    String? accessToken = prefs.getString(keyAuthToken);

    if (accessToken == null) return null;

    // Optional: JWT Expiry Check (Simplified)
    try {
      final parts = accessToken.split('.');
      if (parts.length == 3) {
        final payload = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
        );
        final exp = payload['exp'] as int?;
        if (exp != null) {
          final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          if (expiryDate.isBefore(DateTime.now().add(const Duration(seconds: 30)))) {
            return await forceRefreshToken();
          }
        }
      }
    } catch (e) {
      AppLogger.w('Token parse error', error: e);
    }

    return accessToken;
  }

  static Future<String?> forceRefreshToken() async {
    final prefs = await _prefs;
    final refresh = prefs.getString('refreshToken');
    if (refresh == null) return null;

    final url = Uri.parse('${AppConstants.baseUrl}/api/token/refresh/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final newAccess = data['access'];
        await prefs.setString(keyAuthToken, newAccess);
        return newAccess;
      }
    } catch (_) {}
    return null;
  }
}
