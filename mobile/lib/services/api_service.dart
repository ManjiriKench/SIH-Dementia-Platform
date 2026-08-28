import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000';

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
}