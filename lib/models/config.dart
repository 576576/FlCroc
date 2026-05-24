import 'package:fl_croc/common/constant.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'config.freezed.dart';
part 'config.g.dart';

const List<DashboardWidget> defaultDashboardWidgets = [
  DashboardWidget.transferSpeed,
  DashboardWidget.totalTransferred,
  DashboardWidget.quickSend,
  DashboardWidget.recentTransfers,
  DashboardWidget.crocStatus,
];

@freezed
abstract class AppSettingProps with _$AppSettingProps {
  const factory AppSettingProps({
    String? locale,
    @Default(defaultDashboardWidgets)
    @JsonKey(fromJson: _dashboardWidgetsFromJson)
    List<DashboardWidget> dashboardWidgets,
    @Default(false) bool autoLaunch,
    @Default(false) bool silentLaunch,
    @Default(false) bool minimizeOnExit,
    @Default(ThemeModeOption.system) ThemeModeOption themeMode,
    @Default(ColorSchemeType.fidelity) ColorSchemeType colorSchemeType,
    @Default(FontFamily.system) FontFamily fontFamily,
    @Default(false) bool pureBlackMode,
    @Default(false) bool developerMode,
    @Default(false) bool autoCheckUpdate,
    @Default(RelayConfig()) RelayConfig relayConfig,
  }) = _AppSettingProps;

  factory AppSettingProps.fromJson(Map<String, Object?> json) =>
      _$AppSettingPropsFromJson(json);
}

List<DashboardWidget> _dashboardWidgetsFromJson(List<dynamic>? list) {
  if (list == null) return defaultDashboardWidgets;
  try {
    return list.map((e) => DashboardWidget.values.firstWhere((w) => w.name == e)).toList();
  } catch (_) {
    return defaultDashboardWidgets;
  }
}

@freezed
abstract class ThemeProps with _$ThemeProps {
  const factory ThemeProps({
    @Default(defaultPrimaryColor) int primaryColor,
    @Default(false) bool useDynamicColor,
  }) = _ThemeProps;

  factory ThemeProps.fromJson(Map<String, Object?> json) =>
      _$ThemePropsFromJson(json);
}
