// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingPropsImpl _$$AppSettingPropsImplFromJson(
  Map<String, dynamic> json,
) => _$AppSettingPropsImpl(
  locale: json['locale'] as String?,
  dashboardWidgets: json['dashboardWidgets'] == null
      ? defaultDashboardWidgets
      : const DashboardWidgetListConverter().fromJson(
          json['dashboardWidgets'] as List,
        ),
  autoLaunch: json['autoLaunch'] as bool? ?? false,
  silentLaunch: json['silentLaunch'] as bool? ?? false,
  minimizeOnExit: json['minimizeOnExit'] as bool? ?? false,
  themeMode:
      $enumDecodeNullable(_$ThemeModeOptionEnumMap, json['themeMode']) ??
      ThemeModeOption.system,
  colorSchemeType:
      $enumDecodeNullable(_$ColorSchemeTypeEnumMap, json['colorSchemeType']) ??
      ColorSchemeType.fidelity,
  fontFamily:
      $enumDecodeNullable(_$FontFamilyEnumMap, json['fontFamily']) ??
      FontFamily.system,
  pureBlackMode: json['pureBlackMode'] as bool? ?? false,
  developerMode: json['developerMode'] as bool? ?? false,
  autoCheckUpdate: json['autoCheckUpdate'] as bool? ?? false,
  relayConfig: json['relayConfig'] == null
      ? const RelayConfig()
      : RelayConfig.fromJson(json['relayConfig'] as Map<String, dynamic>),
  defaultSavePath: json['defaultSavePath'] as String? ?? '',
);

Map<String, dynamic> _$$AppSettingPropsImplToJson(
  _$AppSettingPropsImpl instance,
) => <String, dynamic>{
  'locale': instance.locale,
  'dashboardWidgets': const DashboardWidgetListConverter().toJson(
    instance.dashboardWidgets,
  ),
  'autoLaunch': instance.autoLaunch,
  'silentLaunch': instance.silentLaunch,
  'minimizeOnExit': instance.minimizeOnExit,
  'themeMode': _$ThemeModeOptionEnumMap[instance.themeMode]!,
  'colorSchemeType': _$ColorSchemeTypeEnumMap[instance.colorSchemeType]!,
  'fontFamily': _$FontFamilyEnumMap[instance.fontFamily]!,
  'pureBlackMode': instance.pureBlackMode,
  'developerMode': instance.developerMode,
  'autoCheckUpdate': instance.autoCheckUpdate,
  'relayConfig': instance.relayConfig,
  'defaultSavePath': instance.defaultSavePath,
};

const _$ThemeModeOptionEnumMap = {
  ThemeModeOption.system: 'system',
  ThemeModeOption.light: 'light',
  ThemeModeOption.dark: 'dark',
};

const _$ColorSchemeTypeEnumMap = {
  ColorSchemeType.fidelity: 'fidelity',
  ColorSchemeType.expressive: 'expressive',
  ColorSchemeType.rainbow: 'rainbow',
  ColorSchemeType.fruitSalad: 'fruitSalad',
  ColorSchemeType.monochrome: 'monochrome',
};

const _$FontFamilyEnumMap = {
  FontFamily.system: 'system',
  FontFamily.notoSans: 'notoSans',
  FontFamily.roboto: 'roboto',
};

_$ThemePropsImpl _$$ThemePropsImplFromJson(Map<String, dynamic> json) =>
    _$ThemePropsImpl(
      primaryColor:
          (json['primaryColor'] as num?)?.toInt() ?? defaultPrimaryColor,
      useDynamicColor: json['useDynamicColor'] as bool? ?? false,
    );

Map<String, dynamic> _$$ThemePropsImplToJson(_$ThemePropsImpl instance) =>
    <String, dynamic>{
      'primaryColor': instance.primaryColor,
      'useDynamicColor': instance.useDynamicColor,
    };
