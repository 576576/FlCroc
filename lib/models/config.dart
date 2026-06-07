import 'package:fl_croc/common/constant.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'config.freezed.dart';
part 'config.g.dart';

const List<DashboardWidget> defaultDashboardWidgets = [
  DashboardWidget.quickTransfer,
  DashboardWidget.transferStats,
  DashboardWidget.recentTransfers,
];

@freezed
abstract class AppSettingProps with _$AppSettingProps {
  const factory AppSettingProps({
    String? locale,
    @Default(defaultDashboardWidgets)
    @DashboardWidgetListConverter()
    List<DashboardWidget> dashboardWidgets,
    @Default(false) bool autoLaunch,
    @Default(false) bool silentLaunch,
    @Default(false) bool minimizeOnExit,
    @Default(ThemeModeOption.system) ThemeModeOption themeMode,
    @Default(ColorSchemeType.fidelity) ColorSchemeType colorSchemeType,
    @Default(FontFamily.system) FontFamily fontFamily,
    @Default(false) bool pureBlackMode,
    @Default(false) bool noTextMode,
    @Default(false) bool disableAnimations,
    @Default(false) bool developerMode,
    @Default(false) bool autoCheckUpdate,
    @Default(UpdateChannel.release) UpdateChannel updateChannel,
    @Default(RelayConfig()) RelayConfig relayConfig,
    @Default('') String defaultSavePath,
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

class DashboardWidgetListConverter
    implements JsonConverter<List<DashboardWidget>, List<dynamic>> {
  const DashboardWidgetListConverter();

  @override
  List<DashboardWidget> fromJson(List<dynamic> json) =>
      _dashboardWidgetsFromJson(json);

  @override
  List<dynamic> toJson(List<DashboardWidget> list) =>
      list.map((w) => w.name).toList();
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
