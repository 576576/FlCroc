// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettingProps {

 String? get locale;@DashboardWidgetListConverter() List<DashboardWidget> get dashboardWidgets; bool get autoLaunch; bool get silentLaunch; bool get minimizeOnExit; ThemeModeOption get themeMode; ColorSchemeType get colorSchemeType; FontFamily get fontFamily; bool get pureBlackMode; bool get noTextMode; bool get disableAnimations; bool get developerMode; bool get autoCheckUpdate; UpdateChannel get updateChannel; RelayConfig get relayConfig; String get defaultSavePath;
/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingPropsCopyWith<AppSettingProps> get copyWith => _$AppSettingPropsCopyWithImpl<AppSettingProps>(this as AppSettingProps, _$identity);

  /// Serializes this AppSettingProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppSettingProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettingProps&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&const DeepCollectionEquality().equals(other.dashboardWidgets, _this.dashboardWidgets)&&(identical(other.autoLaunch, _this.autoLaunch) || other.autoLaunch == _this.autoLaunch)&&(identical(other.silentLaunch, _this.silentLaunch) || other.silentLaunch == _this.silentLaunch)&&(identical(other.minimizeOnExit, _this.minimizeOnExit) || other.minimizeOnExit == _this.minimizeOnExit)&&(identical(other.themeMode, _this.themeMode) || other.themeMode == _this.themeMode)&&(identical(other.colorSchemeType, _this.colorSchemeType) || other.colorSchemeType == _this.colorSchemeType)&&(identical(other.fontFamily, _this.fontFamily) || other.fontFamily == _this.fontFamily)&&(identical(other.pureBlackMode, _this.pureBlackMode) || other.pureBlackMode == _this.pureBlackMode)&&(identical(other.noTextMode, _this.noTextMode) || other.noTextMode == _this.noTextMode)&&(identical(other.disableAnimations, _this.disableAnimations) || other.disableAnimations == _this.disableAnimations)&&(identical(other.developerMode, _this.developerMode) || other.developerMode == _this.developerMode)&&(identical(other.autoCheckUpdate, _this.autoCheckUpdate) || other.autoCheckUpdate == _this.autoCheckUpdate)&&(identical(other.updateChannel, _this.updateChannel) || other.updateChannel == _this.updateChannel)&&(identical(other.relayConfig, _this.relayConfig) || other.relayConfig == _this.relayConfig)&&(identical(other.defaultSavePath, _this.defaultSavePath) || other.defaultSavePath == _this.defaultSavePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppSettingProps;
  return Object.hash(runtimeType,_this.locale,const DeepCollectionEquality().hash(_this.dashboardWidgets),_this.autoLaunch,_this.silentLaunch,_this.minimizeOnExit,_this.themeMode,_this.colorSchemeType,_this.fontFamily,_this.pureBlackMode,_this.noTextMode,_this.disableAnimations,_this.developerMode,_this.autoCheckUpdate,_this.updateChannel,_this.relayConfig,_this.defaultSavePath);
}

@override
String toString() {
  final _this = this as AppSettingProps;
  return 'AppSettingProps(locale: ${_this.locale}, dashboardWidgets: ${_this.dashboardWidgets}, autoLaunch: ${_this.autoLaunch}, silentLaunch: ${_this.silentLaunch}, minimizeOnExit: ${_this.minimizeOnExit}, themeMode: ${_this.themeMode}, colorSchemeType: ${_this.colorSchemeType}, fontFamily: ${_this.fontFamily}, pureBlackMode: ${_this.pureBlackMode}, noTextMode: ${_this.noTextMode}, disableAnimations: ${_this.disableAnimations}, developerMode: ${_this.developerMode}, autoCheckUpdate: ${_this.autoCheckUpdate}, updateChannel: ${_this.updateChannel}, relayConfig: ${_this.relayConfig}, defaultSavePath: ${_this.defaultSavePath})';
}


}

/// @nodoc
abstract mixin class $AppSettingPropsCopyWith<$Res>  {
  factory $AppSettingPropsCopyWith(AppSettingProps value, $Res Function(AppSettingProps) _then) = _$AppSettingPropsCopyWithImpl;
@useResult
$Res call({
 String? locale,@DashboardWidgetListConverter() List<DashboardWidget> dashboardWidgets, bool autoLaunch, bool silentLaunch, bool minimizeOnExit, ThemeModeOption themeMode, ColorSchemeType colorSchemeType, FontFamily fontFamily, bool pureBlackMode, bool noTextMode, bool disableAnimations, bool developerMode, bool autoCheckUpdate, UpdateChannel updateChannel, RelayConfig relayConfig, String defaultSavePath
});


$RelayConfigCopyWith<$Res> get relayConfig;

}
/// @nodoc
class _$AppSettingPropsCopyWithImpl<$Res>
    implements $AppSettingPropsCopyWith<$Res> {
  _$AppSettingPropsCopyWithImpl(this._self, this._then);

  final AppSettingProps _self;
  final $Res Function(AppSettingProps) _then;

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = freezed,Object? dashboardWidgets = null,Object? autoLaunch = null,Object? silentLaunch = null,Object? minimizeOnExit = null,Object? themeMode = null,Object? colorSchemeType = null,Object? fontFamily = null,Object? pureBlackMode = null,Object? noTextMode = null,Object? disableAnimations = null,Object? developerMode = null,Object? autoCheckUpdate = null,Object? updateChannel = null,Object? relayConfig = null,Object? defaultSavePath = null,}) {
  return _then(AppSettingProps(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,dashboardWidgets: null == dashboardWidgets ? _self.dashboardWidgets : dashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,silentLaunch: null == silentLaunch ? _self.silentLaunch : silentLaunch // ignore: cast_nullable_to_non_nullable
as bool,minimizeOnExit: null == minimizeOnExit ? _self.minimizeOnExit : minimizeOnExit // ignore: cast_nullable_to_non_nullable
as bool,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeModeOption,colorSchemeType: null == colorSchemeType ? _self.colorSchemeType : colorSchemeType // ignore: cast_nullable_to_non_nullable
as ColorSchemeType,fontFamily: null == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as FontFamily,pureBlackMode: null == pureBlackMode ? _self.pureBlackMode : pureBlackMode // ignore: cast_nullable_to_non_nullable
as bool,noTextMode: null == noTextMode ? _self.noTextMode : noTextMode // ignore: cast_nullable_to_non_nullable
as bool,disableAnimations: null == disableAnimations ? _self.disableAnimations : disableAnimations // ignore: cast_nullable_to_non_nullable
as bool,developerMode: null == developerMode ? _self.developerMode : developerMode // ignore: cast_nullable_to_non_nullable
as bool,autoCheckUpdate: null == autoCheckUpdate ? _self.autoCheckUpdate : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
as bool,updateChannel: null == updateChannel ? _self.updateChannel : updateChannel // ignore: cast_nullable_to_non_nullable
as UpdateChannel,relayConfig: null == relayConfig ? _self.relayConfig : relayConfig // ignore: cast_nullable_to_non_nullable
as RelayConfig,defaultSavePath: null == defaultSavePath ? _self.defaultSavePath : defaultSavePath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RelayConfigCopyWith<$Res> get relayConfig {
  
  return $RelayConfigCopyWith<$Res>(_self.relayConfig, (value) {
    return _then(_self.copyWith(relayConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppSettingProps].
extension AppSettingPropsPatterns on AppSettingProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettingProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettingProps value)  $default,){
final _that = this;
switch (_that) {
case _AppSettingProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettingProps value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? locale, @DashboardWidgetListConverter()  List<DashboardWidget> dashboardWidgets,  bool autoLaunch,  bool silentLaunch,  bool minimizeOnExit,  ThemeModeOption themeMode,  ColorSchemeType colorSchemeType,  FontFamily fontFamily,  bool pureBlackMode,  bool noTextMode,  bool disableAnimations,  bool developerMode,  bool autoCheckUpdate,  UpdateChannel updateChannel,  RelayConfig relayConfig,  String defaultSavePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that.locale,_that.dashboardWidgets,_that.autoLaunch,_that.silentLaunch,_that.minimizeOnExit,_that.themeMode,_that.colorSchemeType,_that.fontFamily,_that.pureBlackMode,_that.noTextMode,_that.disableAnimations,_that.developerMode,_that.autoCheckUpdate,_that.updateChannel,_that.relayConfig,_that.defaultSavePath);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? locale, @DashboardWidgetListConverter()  List<DashboardWidget> dashboardWidgets,  bool autoLaunch,  bool silentLaunch,  bool minimizeOnExit,  ThemeModeOption themeMode,  ColorSchemeType colorSchemeType,  FontFamily fontFamily,  bool pureBlackMode,  bool noTextMode,  bool disableAnimations,  bool developerMode,  bool autoCheckUpdate,  UpdateChannel updateChannel,  RelayConfig relayConfig,  String defaultSavePath)  $default,) {final _that = this;
switch (_that) {
case _AppSettingProps():
return $default(_that.locale,_that.dashboardWidgets,_that.autoLaunch,_that.silentLaunch,_that.minimizeOnExit,_that.themeMode,_that.colorSchemeType,_that.fontFamily,_that.pureBlackMode,_that.noTextMode,_that.disableAnimations,_that.developerMode,_that.autoCheckUpdate,_that.updateChannel,_that.relayConfig,_that.defaultSavePath);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? locale, @DashboardWidgetListConverter()  List<DashboardWidget> dashboardWidgets,  bool autoLaunch,  bool silentLaunch,  bool minimizeOnExit,  ThemeModeOption themeMode,  ColorSchemeType colorSchemeType,  FontFamily fontFamily,  bool pureBlackMode,  bool noTextMode,  bool disableAnimations,  bool developerMode,  bool autoCheckUpdate,  UpdateChannel updateChannel,  RelayConfig relayConfig,  String defaultSavePath)?  $default,) {final _that = this;
switch (_that) {
case _AppSettingProps() when $default != null:
return $default(_that.locale,_that.dashboardWidgets,_that.autoLaunch,_that.silentLaunch,_that.minimizeOnExit,_that.themeMode,_that.colorSchemeType,_that.fontFamily,_that.pureBlackMode,_that.noTextMode,_that.disableAnimations,_that.developerMode,_that.autoCheckUpdate,_that.updateChannel,_that.relayConfig,_that.defaultSavePath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettingProps implements AppSettingProps {
  const _AppSettingProps({this.locale, @DashboardWidgetListConverter()  List<DashboardWidget> dashboardWidgets = defaultDashboardWidgets, this.autoLaunch = false, this.silentLaunch = false, this.minimizeOnExit = false, this.themeMode = ThemeModeOption.system, this.colorSchemeType = ColorSchemeType.fidelity, this.fontFamily = FontFamily.system, this.pureBlackMode = false, this.noTextMode = false, this.disableAnimations = false, this.developerMode = false, this.autoCheckUpdate = false, this.updateChannel = UpdateChannel.release, this.relayConfig = const RelayConfig(), this.defaultSavePath = ''}): _dashboardWidgets = dashboardWidgets;
  factory _AppSettingProps.fromJson(Map<String, dynamic> json) => _$AppSettingPropsFromJson(json);

@override final  String? locale;
 final  List<DashboardWidget> _dashboardWidgets;
@override@JsonKey()@DashboardWidgetListConverter() List<DashboardWidget> get dashboardWidgets {
  if (_dashboardWidgets is EqualUnmodifiableListView) return _dashboardWidgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dashboardWidgets);
}

@override@JsonKey() final  bool autoLaunch;
@override@JsonKey() final  bool silentLaunch;
@override@JsonKey() final  bool minimizeOnExit;
@override@JsonKey() final  ThemeModeOption themeMode;
@override@JsonKey() final  ColorSchemeType colorSchemeType;
@override@JsonKey() final  FontFamily fontFamily;
@override@JsonKey() final  bool pureBlackMode;
@override@JsonKey() final  bool noTextMode;
@override@JsonKey() final  bool disableAnimations;
@override@JsonKey() final  bool developerMode;
@override@JsonKey() final  bool autoCheckUpdate;
@override@JsonKey() final  UpdateChannel updateChannel;
@override@JsonKey() final  RelayConfig relayConfig;
@override@JsonKey() final  String defaultSavePath;

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingPropsCopyWith<_AppSettingProps> get copyWith => __$AppSettingPropsCopyWithImpl<_AppSettingProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingPropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettingProps&&(identical(other.locale, locale) || other.locale == locale)&&const DeepCollectionEquality().equals(other.dashboardWidgets, _dashboardWidgets)&&(identical(other.autoLaunch, autoLaunch) || other.autoLaunch == autoLaunch)&&(identical(other.silentLaunch, silentLaunch) || other.silentLaunch == silentLaunch)&&(identical(other.minimizeOnExit, minimizeOnExit) || other.minimizeOnExit == minimizeOnExit)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.colorSchemeType, colorSchemeType) || other.colorSchemeType == colorSchemeType)&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily)&&(identical(other.pureBlackMode, pureBlackMode) || other.pureBlackMode == pureBlackMode)&&(identical(other.noTextMode, noTextMode) || other.noTextMode == noTextMode)&&(identical(other.disableAnimations, disableAnimations) || other.disableAnimations == disableAnimations)&&(identical(other.developerMode, developerMode) || other.developerMode == developerMode)&&(identical(other.autoCheckUpdate, autoCheckUpdate) || other.autoCheckUpdate == autoCheckUpdate)&&(identical(other.updateChannel, updateChannel) || other.updateChannel == updateChannel)&&(identical(other.relayConfig, relayConfig) || other.relayConfig == relayConfig)&&(identical(other.defaultSavePath, defaultSavePath) || other.defaultSavePath == defaultSavePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,locale,const DeepCollectionEquality().hash(_dashboardWidgets),autoLaunch,silentLaunch,minimizeOnExit,themeMode,colorSchemeType,fontFamily,pureBlackMode,noTextMode,disableAnimations,developerMode,autoCheckUpdate,updateChannel,relayConfig,defaultSavePath);
}

@override
String toString() {
    return 'AppSettingProps(locale: $locale, dashboardWidgets: $dashboardWidgets, autoLaunch: $autoLaunch, silentLaunch: $silentLaunch, minimizeOnExit: $minimizeOnExit, themeMode: $themeMode, colorSchemeType: $colorSchemeType, fontFamily: $fontFamily, pureBlackMode: $pureBlackMode, noTextMode: $noTextMode, disableAnimations: $disableAnimations, developerMode: $developerMode, autoCheckUpdate: $autoCheckUpdate, updateChannel: $updateChannel, relayConfig: $relayConfig, defaultSavePath: $defaultSavePath)';
}


}

/// @nodoc
abstract mixin class _$AppSettingPropsCopyWith<$Res> implements $AppSettingPropsCopyWith<$Res> {
  factory _$AppSettingPropsCopyWith(_AppSettingProps value, $Res Function(_AppSettingProps) _then) = __$AppSettingPropsCopyWithImpl;
@override @useResult
$Res call({
 String? locale,@DashboardWidgetListConverter() List<DashboardWidget> dashboardWidgets, bool autoLaunch, bool silentLaunch, bool minimizeOnExit, ThemeModeOption themeMode, ColorSchemeType colorSchemeType, FontFamily fontFamily, bool pureBlackMode, bool noTextMode, bool disableAnimations, bool developerMode, bool autoCheckUpdate, UpdateChannel updateChannel, RelayConfig relayConfig, String defaultSavePath
});


@override $RelayConfigCopyWith<$Res> get relayConfig;

}
/// @nodoc
class __$AppSettingPropsCopyWithImpl<$Res>
    implements _$AppSettingPropsCopyWith<$Res> {
  __$AppSettingPropsCopyWithImpl(this._self, this._then);

  final _AppSettingProps _self;
  final $Res Function(_AppSettingProps) _then;

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = freezed,Object? dashboardWidgets = null,Object? autoLaunch = null,Object? silentLaunch = null,Object? minimizeOnExit = null,Object? themeMode = null,Object? colorSchemeType = null,Object? fontFamily = null,Object? pureBlackMode = null,Object? noTextMode = null,Object? disableAnimations = null,Object? developerMode = null,Object? autoCheckUpdate = null,Object? updateChannel = null,Object? relayConfig = null,Object? defaultSavePath = null,}) {
  return _then(_AppSettingProps(
locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,dashboardWidgets: null == dashboardWidgets ? _self._dashboardWidgets : dashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,silentLaunch: null == silentLaunch ? _self.silentLaunch : silentLaunch // ignore: cast_nullable_to_non_nullable
as bool,minimizeOnExit: null == minimizeOnExit ? _self.minimizeOnExit : minimizeOnExit // ignore: cast_nullable_to_non_nullable
as bool,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeModeOption,colorSchemeType: null == colorSchemeType ? _self.colorSchemeType : colorSchemeType // ignore: cast_nullable_to_non_nullable
as ColorSchemeType,fontFamily: null == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as FontFamily,pureBlackMode: null == pureBlackMode ? _self.pureBlackMode : pureBlackMode // ignore: cast_nullable_to_non_nullable
as bool,noTextMode: null == noTextMode ? _self.noTextMode : noTextMode // ignore: cast_nullable_to_non_nullable
as bool,disableAnimations: null == disableAnimations ? _self.disableAnimations : disableAnimations // ignore: cast_nullable_to_non_nullable
as bool,developerMode: null == developerMode ? _self.developerMode : developerMode // ignore: cast_nullable_to_non_nullable
as bool,autoCheckUpdate: null == autoCheckUpdate ? _self.autoCheckUpdate : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
as bool,updateChannel: null == updateChannel ? _self.updateChannel : updateChannel // ignore: cast_nullable_to_non_nullable
as UpdateChannel,relayConfig: null == relayConfig ? _self.relayConfig : relayConfig // ignore: cast_nullable_to_non_nullable
as RelayConfig,defaultSavePath: null == defaultSavePath ? _self.defaultSavePath : defaultSavePath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AppSettingProps
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RelayConfigCopyWith<$Res> get relayConfig {
  
  return $RelayConfigCopyWith<$Res>(_self.relayConfig, (value) {
    return _then(_self.copyWith(relayConfig: value));
  });
}
}


/// @nodoc
mixin _$ThemeProps {

 int get primaryColor; bool get useDynamicColor;
/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemePropsCopyWith<ThemeProps> get copyWith => _$ThemePropsCopyWithImpl<ThemeProps>(this as ThemeProps, _$identity);

  /// Serializes this ThemeProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ThemeProps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeProps&&(identical(other.primaryColor, _this.primaryColor) || other.primaryColor == _this.primaryColor)&&(identical(other.useDynamicColor, _this.useDynamicColor) || other.useDynamicColor == _this.useDynamicColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ThemeProps;
  return Object.hash(runtimeType,_this.primaryColor,_this.useDynamicColor);
}

@override
String toString() {
  final _this = this as ThemeProps;
  return 'ThemeProps(primaryColor: ${_this.primaryColor}, useDynamicColor: ${_this.useDynamicColor})';
}


}

/// @nodoc
abstract mixin class $ThemePropsCopyWith<$Res>  {
  factory $ThemePropsCopyWith(ThemeProps value, $Res Function(ThemeProps) _then) = _$ThemePropsCopyWithImpl;
@useResult
$Res call({
 int primaryColor, bool useDynamicColor
});




}
/// @nodoc
class _$ThemePropsCopyWithImpl<$Res>
    implements $ThemePropsCopyWith<$Res> {
  _$ThemePropsCopyWithImpl(this._self, this._then);

  final ThemeProps _self;
  final $Res Function(ThemeProps) _then;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primaryColor = null,Object? useDynamicColor = null,}) {
  return _then(ThemeProps(
primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as int,useDynamicColor: null == useDynamicColor ? _self.useDynamicColor : useDynamicColor // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ThemeProps].
extension ThemePropsPatterns on ThemeProps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeProps value)  $default,){
final _that = this;
switch (_that) {
case _ThemeProps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeProps value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int primaryColor,  bool useDynamicColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that.primaryColor,_that.useDynamicColor);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int primaryColor,  bool useDynamicColor)  $default,) {final _that = this;
switch (_that) {
case _ThemeProps():
return $default(_that.primaryColor,_that.useDynamicColor);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int primaryColor,  bool useDynamicColor)?  $default,) {final _that = this;
switch (_that) {
case _ThemeProps() when $default != null:
return $default(_that.primaryColor,_that.useDynamicColor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThemeProps implements ThemeProps {
  const _ThemeProps({this.primaryColor = defaultPrimaryColor, this.useDynamicColor = false});
  factory _ThemeProps.fromJson(Map<String, dynamic> json) => _$ThemePropsFromJson(json);

@override@JsonKey() final  int primaryColor;
@override@JsonKey() final  bool useDynamicColor;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemePropsCopyWith<_ThemeProps> get copyWith => __$ThemePropsCopyWithImpl<_ThemeProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThemePropsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeProps&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.useDynamicColor, useDynamicColor) || other.useDynamicColor == useDynamicColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,primaryColor,useDynamicColor);
}

@override
String toString() {
    return 'ThemeProps(primaryColor: $primaryColor, useDynamicColor: $useDynamicColor)';
}


}

/// @nodoc
abstract mixin class _$ThemePropsCopyWith<$Res> implements $ThemePropsCopyWith<$Res> {
  factory _$ThemePropsCopyWith(_ThemeProps value, $Res Function(_ThemeProps) _then) = __$ThemePropsCopyWithImpl;
@override @useResult
$Res call({
 int primaryColor, bool useDynamicColor
});




}
/// @nodoc
class __$ThemePropsCopyWithImpl<$Res>
    implements _$ThemePropsCopyWith<$Res> {
  __$ThemePropsCopyWithImpl(this._self, this._then);

  final _ThemeProps _self;
  final $Res Function(_ThemeProps) _then;

/// Create a copy of ThemeProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primaryColor = null,Object? useDynamicColor = null,}) {
  return _then(_ThemeProps(
primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as int,useDynamicColor: null == useDynamicColor ? _self.useDynamicColor : useDynamicColor // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
