import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple typed key-value store backed by SharedPreferences.
class AppPrefs {
  AppPrefs._();

  static SharedPreferences? _p;
  static SharedPreferences get _prefs {
    if (_p == null) throw StateError('AppPrefs.init() not called');
    return _p!;
  }

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  // ── Primitive helpers ──

  static String getString(String key, [String fallback = '']) =>
      _prefs.getString(key) ?? fallback;

  static Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  static bool getBool(String key, [bool fallback = false]) =>
      _prefs.getBool(key) ?? fallback;

  static Future<bool> setBool(String key, bool value) =>
      _prefs.setBool(key, value);

  // ── JSON object helpers ──

  static Map<String, dynamic> getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<bool> setJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));
}
