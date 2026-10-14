// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppState {

 bool get isInit; PageLabel get pageLabel;@SizeConverter() Size get viewSize; double get sideWidth;@BrightnessConverter() Brightness get brightness; List<TransferRecord> get transfers; List<TransferRecord> get history; CoreStatus get coreStatus; Map<String, double> get speeds;
/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppStateCopyWith<AppState> get copyWith => _$AppStateCopyWithImpl<AppState>(this as AppState, _$identity);

  /// Serializes this AppState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppState&&(identical(other.isInit, _this.isInit) || other.isInit == _this.isInit)&&(identical(other.pageLabel, _this.pageLabel) || other.pageLabel == _this.pageLabel)&&(identical(other.viewSize, _this.viewSize) || other.viewSize == _this.viewSize)&&(identical(other.sideWidth, _this.sideWidth) || other.sideWidth == _this.sideWidth)&&(identical(other.brightness, _this.brightness) || other.brightness == _this.brightness)&&const DeepCollectionEquality().equals(other.transfers, _this.transfers)&&const DeepCollectionEquality().equals(other.history, _this.history)&&(identical(other.coreStatus, _this.coreStatus) || other.coreStatus == _this.coreStatus)&&const DeepCollectionEquality().equals(other.speeds, _this.speeds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppState;
  return Object.hash(runtimeType,_this.isInit,_this.pageLabel,_this.viewSize,_this.sideWidth,_this.brightness,const DeepCollectionEquality().hash(_this.transfers),const DeepCollectionEquality().hash(_this.history),_this.coreStatus,const DeepCollectionEquality().hash(_this.speeds));
}

@override
String toString() {
  final _this = this as AppState;
  return 'AppState(isInit: ${_this.isInit}, pageLabel: ${_this.pageLabel}, viewSize: ${_this.viewSize}, sideWidth: ${_this.sideWidth}, brightness: ${_this.brightness}, transfers: ${_this.transfers}, history: ${_this.history}, coreStatus: ${_this.coreStatus}, speeds: ${_this.speeds})';
}


}

/// @nodoc
abstract mixin class $AppStateCopyWith<$Res>  {
  factory $AppStateCopyWith(AppState value, $Res Function(AppState) _then) = _$AppStateCopyWithImpl;
@useResult
$Res call({
 bool isInit, PageLabel pageLabel,@SizeConverter() Size viewSize, double sideWidth,@BrightnessConverter() Brightness brightness, List<TransferRecord> transfers, List<TransferRecord> history, CoreStatus coreStatus, Map<String, double> speeds
});




}
/// @nodoc
class _$AppStateCopyWithImpl<$Res>
    implements $AppStateCopyWith<$Res> {
  _$AppStateCopyWithImpl(this._self, this._then);

  final AppState _self;
  final $Res Function(AppState) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isInit = null,Object? pageLabel = null,Object? viewSize = null,Object? sideWidth = null,Object? brightness = null,Object? transfers = null,Object? history = null,Object? coreStatus = null,Object? speeds = null,}) {
  return _then(AppState(
isInit: null == isInit ? _self.isInit : isInit // ignore: cast_nullable_to_non_nullable
as bool,pageLabel: null == pageLabel ? _self.pageLabel : pageLabel // ignore: cast_nullable_to_non_nullable
as PageLabel,viewSize: null == viewSize ? _self.viewSize : viewSize // ignore: cast_nullable_to_non_nullable
as Size,sideWidth: null == sideWidth ? _self.sideWidth : sideWidth // ignore: cast_nullable_to_non_nullable
as double,brightness: null == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as Brightness,transfers: null == transfers ? _self.transfers : transfers // ignore: cast_nullable_to_non_nullable
as List<TransferRecord>,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<TransferRecord>,coreStatus: null == coreStatus ? _self.coreStatus : coreStatus // ignore: cast_nullable_to_non_nullable
as CoreStatus,speeds: null == speeds ? _self.speeds : speeds // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}

}


/// Adds pattern-matching-related methods to [AppState].
extension AppStatePatterns on AppState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppState value)  $default,){
final _that = this;
switch (_that) {
case _AppState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppState value)?  $default,){
final _that = this;
switch (_that) {
case _AppState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isInit,  PageLabel pageLabel, @SizeConverter()  Size viewSize,  double sideWidth, @BrightnessConverter()  Brightness brightness,  List<TransferRecord> transfers,  List<TransferRecord> history,  CoreStatus coreStatus,  Map<String, double> speeds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppState() when $default != null:
return $default(_that.isInit,_that.pageLabel,_that.viewSize,_that.sideWidth,_that.brightness,_that.transfers,_that.history,_that.coreStatus,_that.speeds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isInit,  PageLabel pageLabel, @SizeConverter()  Size viewSize,  double sideWidth, @BrightnessConverter()  Brightness brightness,  List<TransferRecord> transfers,  List<TransferRecord> history,  CoreStatus coreStatus,  Map<String, double> speeds)  $default,) {final _that = this;
switch (_that) {
case _AppState():
return $default(_that.isInit,_that.pageLabel,_that.viewSize,_that.sideWidth,_that.brightness,_that.transfers,_that.history,_that.coreStatus,_that.speeds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isInit,  PageLabel pageLabel, @SizeConverter()  Size viewSize,  double sideWidth, @BrightnessConverter()  Brightness brightness,  List<TransferRecord> transfers,  List<TransferRecord> history,  CoreStatus coreStatus,  Map<String, double> speeds)?  $default,) {final _that = this;
switch (_that) {
case _AppState() when $default != null:
return $default(_that.isInit,_that.pageLabel,_that.viewSize,_that.sideWidth,_that.brightness,_that.transfers,_that.history,_that.coreStatus,_that.speeds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppState implements AppState {
  const _AppState({this.isInit = false, this.pageLabel = PageLabel.dashboard, @SizeConverter() this.viewSize = Size.zero, this.sideWidth = 0, @BrightnessConverter() this.brightness = Brightness.light,  List<TransferRecord> transfers = const <TransferRecord>[],  List<TransferRecord> history = const <TransferRecord>[], this.coreStatus = CoreStatus.disconnected,  Map<String, double> speeds = const {}}): _transfers = transfers,_history = history,_speeds = speeds;
  factory _AppState.fromJson(Map<String, dynamic> json) => _$AppStateFromJson(json);

@override@JsonKey() final  bool isInit;
@override@JsonKey() final  PageLabel pageLabel;
@override@JsonKey()@SizeConverter() final  Size viewSize;
@override@JsonKey() final  double sideWidth;
@override@JsonKey()@BrightnessConverter() final  Brightness brightness;
 final  List<TransferRecord> _transfers;
@override@JsonKey() List<TransferRecord> get transfers {
  if (_transfers is EqualUnmodifiableListView) return _transfers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transfers);
}

 final  List<TransferRecord> _history;
@override@JsonKey() List<TransferRecord> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override@JsonKey() final  CoreStatus coreStatus;
 final  Map<String, double> _speeds;
@override@JsonKey() Map<String, double> get speeds {
  if (_speeds is EqualUnmodifiableMapView) return _speeds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_speeds);
}


/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppStateCopyWith<_AppState> get copyWith => __$AppStateCopyWithImpl<_AppState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppState&&(identical(other.isInit, isInit) || other.isInit == isInit)&&(identical(other.pageLabel, pageLabel) || other.pageLabel == pageLabel)&&(identical(other.viewSize, viewSize) || other.viewSize == viewSize)&&(identical(other.sideWidth, sideWidth) || other.sideWidth == sideWidth)&&(identical(other.brightness, brightness) || other.brightness == brightness)&&const DeepCollectionEquality().equals(other.transfers, _transfers)&&const DeepCollectionEquality().equals(other.history, _history)&&(identical(other.coreStatus, coreStatus) || other.coreStatus == coreStatus)&&const DeepCollectionEquality().equals(other.speeds, _speeds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,isInit,pageLabel,viewSize,sideWidth,brightness,const DeepCollectionEquality().hash(_transfers),const DeepCollectionEquality().hash(_history),coreStatus,const DeepCollectionEquality().hash(_speeds));
}

@override
String toString() {
    return 'AppState(isInit: $isInit, pageLabel: $pageLabel, viewSize: $viewSize, sideWidth: $sideWidth, brightness: $brightness, transfers: $transfers, history: $history, coreStatus: $coreStatus, speeds: $speeds)';
}


}

/// @nodoc
abstract mixin class _$AppStateCopyWith<$Res> implements $AppStateCopyWith<$Res> {
  factory _$AppStateCopyWith(_AppState value, $Res Function(_AppState) _then) = __$AppStateCopyWithImpl;
@override @useResult
$Res call({
 bool isInit, PageLabel pageLabel,@SizeConverter() Size viewSize, double sideWidth,@BrightnessConverter() Brightness brightness, List<TransferRecord> transfers, List<TransferRecord> history, CoreStatus coreStatus, Map<String, double> speeds
});




}
/// @nodoc
class __$AppStateCopyWithImpl<$Res>
    implements _$AppStateCopyWith<$Res> {
  __$AppStateCopyWithImpl(this._self, this._then);

  final _AppState _self;
  final $Res Function(_AppState) _then;

/// Create a copy of AppState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isInit = null,Object? pageLabel = null,Object? viewSize = null,Object? sideWidth = null,Object? brightness = null,Object? transfers = null,Object? history = null,Object? coreStatus = null,Object? speeds = null,}) {
  return _then(_AppState(
isInit: null == isInit ? _self.isInit : isInit // ignore: cast_nullable_to_non_nullable
as bool,pageLabel: null == pageLabel ? _self.pageLabel : pageLabel // ignore: cast_nullable_to_non_nullable
as PageLabel,viewSize: null == viewSize ? _self.viewSize : viewSize // ignore: cast_nullable_to_non_nullable
as Size,sideWidth: null == sideWidth ? _self.sideWidth : sideWidth // ignore: cast_nullable_to_non_nullable
as double,brightness: null == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as Brightness,transfers: null == transfers ? _self._transfers : transfers // ignore: cast_nullable_to_non_nullable
as List<TransferRecord>,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<TransferRecord>,coreStatus: null == coreStatus ? _self.coreStatus : coreStatus // ignore: cast_nullable_to_non_nullable
as CoreStatus,speeds: null == speeds ? _self._speeds : speeds // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}


}

// dart format on
