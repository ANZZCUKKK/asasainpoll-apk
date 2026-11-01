import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String _base = 'http://YOUR_VPS_IP:3000';

  static Future<void> loadConfig() async {
    final p = await SharedPreferences.getInstance();
    _base = p.getString('api_url') ?? _base;
  }

  static Future<void> saveConfig(String url) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('api_url', url);
    _base = url;
  }

  static Future<bool> checkStatus() async {
    try {
      final r = await http.get(Uri.parse('$_base/status'))
          .timeout(const Duration(seconds: 5));
      return r.statusCode == 200;
    } catch (_) { return false; }
  }

  static Future<Map<String, dynamic>> validateKey(String key) async {
    try {
      final r = await http.post(
        Uri.parse('$_base/validate-key'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'key': key}),
      ).timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) return jsonDecode(r.body);
      return {'valid': false, 'message': 'Server error'};
    } catch (_) { return {'valid': false, 'message': 'Koneksi gagal'}; }
  }

  static Future<void> log(String action) async {
    try {
      await http.post(Uri.parse('$_base/log'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': action, 'ts': DateTime.now().toIso8601String()}));
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> checkUpdate(String currentVersion) async {
    try {
      final r = await http.get(Uri.parse('$_base/version'))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return jsonDecode(r.body);
      return null;
    } catch (_) { return null; }
  }
}
