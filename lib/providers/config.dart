import 'dart:convert';

import 'package:fl_croc/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appSettingProvider =
    NotifierProvider<AppSettingNotifier, AppSettingProps>(
      AppSettingNotifier.new,
    );

class AppSettingNotifier extends Notifier<AppSettingProps> {
  @override
  AppSettingProps build() => const AppSettingProps();

  Future<SharedPreferences?> _getPrefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  Future<void> load() async {
    final prefs = await _getPrefs();
    if (prefs == null) return;
    final json = prefs.getString('app_settings');
    if (json != null) {
      try {
        final map = jsonDecode(json) as Map<String, Object?>;
        state = AppSettingProps.fromJson(map);
      } catch (_) {
        state = const AppSettingProps();
      }
    }
  }

  Future<void> update(AppSettingProps Function(AppSettingProps) updater) async {
    state = updater(state);
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setString('app_settings', jsonEncode(state.toJson()));
      }
    } catch (_) {}
  }

  Future<void> resetAll() async {
    state = const AppSettingProps();
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.remove('app_settings');
        await prefs.remove('send_config');
        await prefs.remove('receive_config');
      }
    } catch (_) {}
  }
}

final themeSettingProvider = NotifierProvider<ThemeSettingNotifier, ThemeProps>(
  ThemeSettingNotifier.new,
);

class ThemeSettingNotifier extends Notifier<ThemeProps> {
  @override
  ThemeProps build() => ThemeProps();

  Future<SharedPreferences?> _getPrefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  Future<void> load() async {
    final prefs = await _getPrefs();
    if (prefs == null) return;
    final json = prefs.getString('theme_settings');
    if (json != null) {
      try {
        final map = jsonDecode(json) as Map<String, Object?>;
        state = ThemeProps.fromJson(map);
      } catch (_) {
        state = const ThemeProps();
      }
    }
  }

  Future<void> update(ThemeProps Function(ThemeProps) updater) async {
    state = updater(state);
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setString('theme_settings', jsonEncode(state.toJson()));
      }
    } catch (_) {}
  }

  Future<void> resetToDefault() async {
    state = const ThemeProps();
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.remove('theme_settings');
      }
    } catch (_) {}
  }
}
