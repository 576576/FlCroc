import 'dart:convert';

import 'package:fl_croc/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appSettingProvider =
    StateNotifierProvider<AppSettingNotifier, AppSettingProps>((ref) {
  return AppSettingNotifier();
});

class AppSettingNotifier extends StateNotifier<AppSettingProps> {
  AppSettingNotifier() : super(const AppSettingProps());

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_settings', jsonEncode(state.toJson()));
  }
}

final themeSettingProvider =
    StateNotifierProvider<ThemeSettingNotifier, ThemeProps>((ref) {
  return ThemeSettingNotifier();
});

class ThemeSettingNotifier extends StateNotifier<ThemeProps> {
  ThemeSettingNotifier() : super(ThemeProps());

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_settings', jsonEncode(state.toJson()));
  }
}
