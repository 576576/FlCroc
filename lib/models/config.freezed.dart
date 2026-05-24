// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppSettingProps _$AppSettingPropsFromJson(Map<String, dynamic> json) {
  return _AppSettingProps.fromJson(json);
}

/// @nodoc
mixin _$AppSettingProps {
  String? get locale => throw _privateConstructorUsedError;
  @DashboardWidgetListConverter()
  List<DashboardWidget> get dashboardWidgets =>
      throw _privateConstructorUsedError;
  bool get autoLaunch => throw _privateConstructorUsedError;
  bool get silentLaunch => throw _privateConstructorUsedError;
  bool get minimizeOnExit => throw _privateConstructorUsedError;
  ThemeModeOption get themeMode => throw _privateConstructorUsedError;
  ColorSchemeType get colorSchemeType => throw _privateConstructorUsedError;
  FontFamily get fontFamily => throw _privateConstructorUsedError;
  bool get pureBlackMode => throw _privateConstructorUsedError;
  bool get developerMode => throw _privateConstructorUsedError;
  bool get autoCheckUpdate => throw _privateConstructorUsedError;
  RelayConfig get relayConfig => throw _privateConstructorUsedError;

  /// Serializes this AppSettingProps to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppSettingProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppSettingPropsCopyWith<AppSettingProps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingPropsCopyWith<$Res> {
  factory $AppSettingPropsCopyWith(
    AppSettingProps value,
    $Res Function(AppSettingProps) then,
  ) = _$AppSettingPropsCopyWithImpl<$Res, AppSettingProps>;
  @useResult
  $Res call({
    String? locale,
    @DashboardWidgetListConverter() List<DashboardWidget> dashboardWidgets,
    bool autoLaunch,
    bool silentLaunch,
    bool minimizeOnExit,
    ThemeModeOption themeMode,
    ColorSchemeType colorSchemeType,
    FontFamily fontFamily,
    bool pureBlackMode,
    bool developerMode,
    bool autoCheckUpdate,
    RelayConfig relayConfig,
  });

  $RelayConfigCopyWith<$Res> get relayConfig;
}

/// @nodoc
class _$AppSettingPropsCopyWithImpl<$Res, $Val extends AppSettingProps>
    implements $AppSettingPropsCopyWith<$Res> {
  _$AppSettingPropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppSettingProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locale = freezed,
    Object? dashboardWidgets = null,
    Object? autoLaunch = null,
    Object? silentLaunch = null,
    Object? minimizeOnExit = null,
    Object? themeMode = null,
    Object? colorSchemeType = null,
    Object? fontFamily = null,
    Object? pureBlackMode = null,
    Object? developerMode = null,
    Object? autoCheckUpdate = null,
    Object? relayConfig = null,
  }) {
    return _then(
      _value.copyWith(
            locale: freezed == locale
                ? _value.locale
                : locale // ignore: cast_nullable_to_non_nullable
                      as String?,
            dashboardWidgets: null == dashboardWidgets
                ? _value.dashboardWidgets
                : dashboardWidgets // ignore: cast_nullable_to_non_nullable
                      as List<DashboardWidget>,
            autoLaunch: null == autoLaunch
                ? _value.autoLaunch
                : autoLaunch // ignore: cast_nullable_to_non_nullable
                      as bool,
            silentLaunch: null == silentLaunch
                ? _value.silentLaunch
                : silentLaunch // ignore: cast_nullable_to_non_nullable
                      as bool,
            minimizeOnExit: null == minimizeOnExit
                ? _value.minimizeOnExit
                : minimizeOnExit // ignore: cast_nullable_to_non_nullable
                      as bool,
            themeMode: null == themeMode
                ? _value.themeMode
                : themeMode // ignore: cast_nullable_to_non_nullable
                      as ThemeModeOption,
            colorSchemeType: null == colorSchemeType
                ? _value.colorSchemeType
                : colorSchemeType // ignore: cast_nullable_to_non_nullable
                      as ColorSchemeType,
            fontFamily: null == fontFamily
                ? _value.fontFamily
                : fontFamily // ignore: cast_nullable_to_non_nullable
                      as FontFamily,
            pureBlackMode: null == pureBlackMode
                ? _value.pureBlackMode
                : pureBlackMode // ignore: cast_nullable_to_non_nullable
                      as bool,
            developerMode: null == developerMode
                ? _value.developerMode
                : developerMode // ignore: cast_nullable_to_non_nullable
                      as bool,
            autoCheckUpdate: null == autoCheckUpdate
                ? _value.autoCheckUpdate
                : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
                      as bool,
            relayConfig: null == relayConfig
                ? _value.relayConfig
                : relayConfig // ignore: cast_nullable_to_non_nullable
                      as RelayConfig,
          )
          as $Val,
    );
  }

  /// Create a copy of AppSettingProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RelayConfigCopyWith<$Res> get relayConfig {
    return $RelayConfigCopyWith<$Res>(_value.relayConfig, (value) {
      return _then(_value.copyWith(relayConfig: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppSettingPropsImplCopyWith<$Res>
    implements $AppSettingPropsCopyWith<$Res> {
  factory _$$AppSettingPropsImplCopyWith(
    _$AppSettingPropsImpl value,
    $Res Function(_$AppSettingPropsImpl) then,
  ) = __$$AppSettingPropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? locale,
    @DashboardWidgetListConverter() List<DashboardWidget> dashboardWidgets,
    bool autoLaunch,
    bool silentLaunch,
    bool minimizeOnExit,
    ThemeModeOption themeMode,
    ColorSchemeType colorSchemeType,
    FontFamily fontFamily,
    bool pureBlackMode,
    bool developerMode,
    bool autoCheckUpdate,
    RelayConfig relayConfig,
  });

  @override
  $RelayConfigCopyWith<$Res> get relayConfig;
}

/// @nodoc
class __$$AppSettingPropsImplCopyWithImpl<$Res>
    extends _$AppSettingPropsCopyWithImpl<$Res, _$AppSettingPropsImpl>
    implements _$$AppSettingPropsImplCopyWith<$Res> {
  __$$AppSettingPropsImplCopyWithImpl(
    _$AppSettingPropsImpl _value,
    $Res Function(_$AppSettingPropsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppSettingProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locale = freezed,
    Object? dashboardWidgets = null,
    Object? autoLaunch = null,
    Object? silentLaunch = null,
    Object? minimizeOnExit = null,
    Object? themeMode = null,
    Object? colorSchemeType = null,
    Object? fontFamily = null,
    Object? pureBlackMode = null,
    Object? developerMode = null,
    Object? autoCheckUpdate = null,
    Object? relayConfig = null,
  }) {
    return _then(
      _$AppSettingPropsImpl(
        locale: freezed == locale
            ? _value.locale
            : locale // ignore: cast_nullable_to_non_nullable
                  as String?,
        dashboardWidgets: null == dashboardWidgets
            ? _value._dashboardWidgets
            : dashboardWidgets // ignore: cast_nullable_to_non_nullable
                  as List<DashboardWidget>,
        autoLaunch: null == autoLaunch
            ? _value.autoLaunch
            : autoLaunch // ignore: cast_nullable_to_non_nullable
                  as bool,
        silentLaunch: null == silentLaunch
            ? _value.silentLaunch
            : silentLaunch // ignore: cast_nullable_to_non_nullable
                  as bool,
        minimizeOnExit: null == minimizeOnExit
            ? _value.minimizeOnExit
            : minimizeOnExit // ignore: cast_nullable_to_non_nullable
                  as bool,
        themeMode: null == themeMode
            ? _value.themeMode
            : themeMode // ignore: cast_nullable_to_non_nullable
                  as ThemeModeOption,
        colorSchemeType: null == colorSchemeType
            ? _value.colorSchemeType
            : colorSchemeType // ignore: cast_nullable_to_non_nullable
                  as ColorSchemeType,
        fontFamily: null == fontFamily
            ? _value.fontFamily
            : fontFamily // ignore: cast_nullable_to_non_nullable
                  as FontFamily,
        pureBlackMode: null == pureBlackMode
            ? _value.pureBlackMode
            : pureBlackMode // ignore: cast_nullable_to_non_nullable
                  as bool,
        developerMode: null == developerMode
            ? _value.developerMode
            : developerMode // ignore: cast_nullable_to_non_nullable
                  as bool,
        autoCheckUpdate: null == autoCheckUpdate
            ? _value.autoCheckUpdate
            : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
                  as bool,
        relayConfig: null == relayConfig
            ? _value.relayConfig
            : relayConfig // ignore: cast_nullable_to_non_nullable
                  as RelayConfig,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppSettingPropsImpl implements _AppSettingProps {
  const _$AppSettingPropsImpl({
    this.locale,
    @DashboardWidgetListConverter()
    final List<DashboardWidget> dashboardWidgets = defaultDashboardWidgets,
    this.autoLaunch = false,
    this.silentLaunch = false,
    this.minimizeOnExit = false,
    this.themeMode = ThemeModeOption.system,
    this.colorSchemeType = ColorSchemeType.fidelity,
    this.fontFamily = FontFamily.system,
    this.pureBlackMode = false,
    this.developerMode = false,
    this.autoCheckUpdate = false,
    this.relayConfig = const RelayConfig(),
  }) : _dashboardWidgets = dashboardWidgets;

  factory _$AppSettingPropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingPropsImplFromJson(json);

  @override
  final String? locale;
  final List<DashboardWidget> _dashboardWidgets;
  @override
  @JsonKey()
  @DashboardWidgetListConverter()
  List<DashboardWidget> get dashboardWidgets {
    if (_dashboardWidgets is EqualUnmodifiableListView)
      return _dashboardWidgets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dashboardWidgets);
  }

  @override
  @JsonKey()
  final bool autoLaunch;
  @override
  @JsonKey()
  final bool silentLaunch;
  @override
  @JsonKey()
  final bool minimizeOnExit;
  @override
  @JsonKey()
  final ThemeModeOption themeMode;
  @override
  @JsonKey()
  final ColorSchemeType colorSchemeType;
  @override
  @JsonKey()
  final FontFamily fontFamily;
  @override
  @JsonKey()
  final bool pureBlackMode;
  @override
  @JsonKey()
  final bool developerMode;
  @override
  @JsonKey()
  final bool autoCheckUpdate;
  @override
  @JsonKey()
  final RelayConfig relayConfig;

  @override
  String toString() {
    return 'AppSettingProps(locale: $locale, dashboardWidgets: $dashboardWidgets, autoLaunch: $autoLaunch, silentLaunch: $silentLaunch, minimizeOnExit: $minimizeOnExit, themeMode: $themeMode, colorSchemeType: $colorSchemeType, fontFamily: $fontFamily, pureBlackMode: $pureBlackMode, developerMode: $developerMode, autoCheckUpdate: $autoCheckUpdate, relayConfig: $relayConfig)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingPropsImpl &&
            (identical(other.locale, locale) || other.locale == locale) &&
            const DeepCollectionEquality().equals(
              other._dashboardWidgets,
              _dashboardWidgets,
            ) &&
            (identical(other.autoLaunch, autoLaunch) ||
                other.autoLaunch == autoLaunch) &&
            (identical(other.silentLaunch, silentLaunch) ||
                other.silentLaunch == silentLaunch) &&
            (identical(other.minimizeOnExit, minimizeOnExit) ||
                other.minimizeOnExit == minimizeOnExit) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.colorSchemeType, colorSchemeType) ||
                other.colorSchemeType == colorSchemeType) &&
            (identical(other.fontFamily, fontFamily) ||
                other.fontFamily == fontFamily) &&
            (identical(other.pureBlackMode, pureBlackMode) ||
                other.pureBlackMode == pureBlackMode) &&
            (identical(other.developerMode, developerMode) ||
                other.developerMode == developerMode) &&
            (identical(other.autoCheckUpdate, autoCheckUpdate) ||
                other.autoCheckUpdate == autoCheckUpdate) &&
            (identical(other.relayConfig, relayConfig) ||
                other.relayConfig == relayConfig));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    locale,
    const DeepCollectionEquality().hash(_dashboardWidgets),
    autoLaunch,
    silentLaunch,
    minimizeOnExit,
    themeMode,
    colorSchemeType,
    fontFamily,
    pureBlackMode,
    developerMode,
    autoCheckUpdate,
    relayConfig,
  );

  /// Create a copy of AppSettingProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingPropsImplCopyWith<_$AppSettingPropsImpl> get copyWith =>
      __$$AppSettingPropsImplCopyWithImpl<_$AppSettingPropsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingPropsImplToJson(this);
  }
}

abstract class _AppSettingProps implements AppSettingProps {
  const factory _AppSettingProps({
    final String? locale,
    @DashboardWidgetListConverter()
    final List<DashboardWidget> dashboardWidgets,
    final bool autoLaunch,
    final bool silentLaunch,
    final bool minimizeOnExit,
    final ThemeModeOption themeMode,
    final ColorSchemeType colorSchemeType,
    final FontFamily fontFamily,
    final bool pureBlackMode,
    final bool developerMode,
    final bool autoCheckUpdate,
    final RelayConfig relayConfig,
  }) = _$AppSettingPropsImpl;

  factory _AppSettingProps.fromJson(Map<String, dynamic> json) =
      _$AppSettingPropsImpl.fromJson;

  @override
  String? get locale;
  @override
  @DashboardWidgetListConverter()
  List<DashboardWidget> get dashboardWidgets;
  @override
  bool get autoLaunch;
  @override
  bool get silentLaunch;
  @override
  bool get minimizeOnExit;
  @override
  ThemeModeOption get themeMode;
  @override
  ColorSchemeType get colorSchemeType;
  @override
  FontFamily get fontFamily;
  @override
  bool get pureBlackMode;
  @override
  bool get developerMode;
  @override
  bool get autoCheckUpdate;
  @override
  RelayConfig get relayConfig;

  /// Create a copy of AppSettingProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppSettingPropsImplCopyWith<_$AppSettingPropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ThemeProps _$ThemePropsFromJson(Map<String, dynamic> json) {
  return _ThemeProps.fromJson(json);
}

/// @nodoc
mixin _$ThemeProps {
  int get primaryColor => throw _privateConstructorUsedError;
  bool get useDynamicColor => throw _privateConstructorUsedError;

  /// Serializes this ThemeProps to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ThemeProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ThemePropsCopyWith<ThemeProps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThemePropsCopyWith<$Res> {
  factory $ThemePropsCopyWith(
    ThemeProps value,
    $Res Function(ThemeProps) then,
  ) = _$ThemePropsCopyWithImpl<$Res, ThemeProps>;
  @useResult
  $Res call({int primaryColor, bool useDynamicColor});
}

/// @nodoc
class _$ThemePropsCopyWithImpl<$Res, $Val extends ThemeProps>
    implements $ThemePropsCopyWith<$Res> {
  _$ThemePropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ThemeProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? primaryColor = null, Object? useDynamicColor = null}) {
    return _then(
      _value.copyWith(
            primaryColor: null == primaryColor
                ? _value.primaryColor
                : primaryColor // ignore: cast_nullable_to_non_nullable
                      as int,
            useDynamicColor: null == useDynamicColor
                ? _value.useDynamicColor
                : useDynamicColor // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ThemePropsImplCopyWith<$Res>
    implements $ThemePropsCopyWith<$Res> {
  factory _$$ThemePropsImplCopyWith(
    _$ThemePropsImpl value,
    $Res Function(_$ThemePropsImpl) then,
  ) = __$$ThemePropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int primaryColor, bool useDynamicColor});
}

/// @nodoc
class __$$ThemePropsImplCopyWithImpl<$Res>
    extends _$ThemePropsCopyWithImpl<$Res, _$ThemePropsImpl>
    implements _$$ThemePropsImplCopyWith<$Res> {
  __$$ThemePropsImplCopyWithImpl(
    _$ThemePropsImpl _value,
    $Res Function(_$ThemePropsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ThemeProps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? primaryColor = null, Object? useDynamicColor = null}) {
    return _then(
      _$ThemePropsImpl(
        primaryColor: null == primaryColor
            ? _value.primaryColor
            : primaryColor // ignore: cast_nullable_to_non_nullable
                  as int,
        useDynamicColor: null == useDynamicColor
            ? _value.useDynamicColor
            : useDynamicColor // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ThemePropsImpl implements _ThemeProps {
  const _$ThemePropsImpl({
    this.primaryColor = defaultPrimaryColor,
    this.useDynamicColor = false,
  });

  factory _$ThemePropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ThemePropsImplFromJson(json);

  @override
  @JsonKey()
  final int primaryColor;
  @override
  @JsonKey()
  final bool useDynamicColor;

  @override
  String toString() {
    return 'ThemeProps(primaryColor: $primaryColor, useDynamicColor: $useDynamicColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThemePropsImpl &&
            (identical(other.primaryColor, primaryColor) ||
                other.primaryColor == primaryColor) &&
            (identical(other.useDynamicColor, useDynamicColor) ||
                other.useDynamicColor == useDynamicColor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, primaryColor, useDynamicColor);

  /// Create a copy of ThemeProps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ThemePropsImplCopyWith<_$ThemePropsImpl> get copyWith =>
      __$$ThemePropsImplCopyWithImpl<_$ThemePropsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ThemePropsImplToJson(this);
  }
}

abstract class _ThemeProps implements ThemeProps {
  const factory _ThemeProps({
    final int primaryColor,
    final bool useDynamicColor,
  }) = _$ThemePropsImpl;

  factory _ThemeProps.fromJson(Map<String, dynamic> json) =
      _$ThemePropsImpl.fromJson;

  @override
  int get primaryColor;
  @override
  bool get useDynamicColor;

  /// Create a copy of ThemeProps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ThemePropsImplCopyWith<_$ThemePropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
