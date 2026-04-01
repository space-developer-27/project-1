// ── services/api_service.dart ────────────────────────────────
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiService {
  // ── Token helpers ─────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('name');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Generic helpers ───────────────────────────────────────
  static Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body,
      {bool auth = false}) async {
    final headers = auth
        ? await _authHeaders()
        : {'Content-Type': 'application/json'};
    try {
      final res = await http
          .post(Uri.parse('$BASE_URL$path'),
              headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    final headers = await _authHeaders();
    try {
      final res = await http
          .get(Uri.parse('$BASE_URL$path'), headers: headers)
          .timeout(const Duration(seconds: 15));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  ADMIN
  // ═══════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> adminLogin(
          String username, String password) =>
      _post('/api/admin/login', {'username': username, 'password': password});

  static Future<Map<String, dynamic>> adminStats() => _get('/api/admin/stats');

  static Future<Map<String, dynamic>> adminDonors() =>
      _get('/api/admin/donors');

  static Future<Map<String, dynamic>> adminRequests() =>
      _get('/api/admin/requests');

  // ═══════════════════════════════════════════════════════════
  //  DONOR
  // ═══════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> donorRegister(
          Map<String, dynamic> data) =>
      _post('/api/donor/register', data);

  static Future<Map<String, dynamic>> donorLogin(
          String regno, String password) =>
      _post('/api/donor/login', {'regno': regno, 'password': password});

  static Future<Map<String, dynamic>> donorDashboard() =>
      _get('/api/donor/dashboard');

  static Future<Map<String, dynamic>> donorUpdateRequest(
          int requestId, String action) =>
      _post('/api/donor/update_request',
          {'request_id': requestId, 'action': action},
          auth: true);

  // ═══════════════════════════════════════════════════════════
  //  CLIENT (PUBLIC)
  // ═══════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> submitBloodRequest(
          Map<String, dynamic> data) =>
      _post('/api/client/request', data);

  static Future<Map<String, dynamic>> checkStatus(
          {String? regno, String? reqid}) =>
      _post('/api/client/status', {'regno': regno ?? '', 'reqid': reqid ?? ''});
}
