import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:5000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    } catch (_) {}
    return 'http://127.0.0.1:5000';
  }

  static Future<String> testBackend() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Backend connected';
      } else {
        return 'Backend error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Connection failed: $e';
    }
  }

  static Future<Map<String, dynamic>?> syncSessionTelemetry(Map<String, dynamic> telemetry) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/ai/sync-session'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(telemetry),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return null;
  }
}