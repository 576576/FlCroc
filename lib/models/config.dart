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

/// Legacy names from the split `quickSend` / `quickReceive` cards, both now
/// collapsed onto the single [DashboardWidget.quickTransfer] card.
const Map<String, DashboardWidget> _legacyDashboardWidgetNames = {
  'quickSend': DashboardWidget.quickTransfer,
  'quickReceive': DashboardWidget.quickTransfer,
};

List<DashboardWidget> _dashboardWidgetsFromJson(List<dynamic>? list) {
  // No key at all = fresh install (or a pre-dashboard config) → the default
  // layout. An explicit `[]` is respected: an empty dashboard is a state the
  // user can reach by deleting every card, so it must not be resurrected.
  if (list == null) return defaultDashboardWidgets;

  final byName = {for (final w in DashboardWidget.values) w.name: w};
  final widgets = <DashboardWidget>[];
  for (final name in list) {
    final w = name is String
        ? (byName[name] ?? _legacyDashboardWidgetNames[name])
        : null;
    // Unrecognised and duplicated entries are dropped one by one, so one unknown
    // name cannot throw away the rest of the saved layout; de-duplicating also
    // keeps two cards from sharing a sibling key.
    if (w != null && !widgets.contains(w)) widgets.add(w);
  }
  return widgets;
}

class const DashboardWidgetListConverter()
    implements JsonConverter<List<DashboardWidget>, List<dynamic>> {
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
