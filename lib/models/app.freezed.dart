// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppState _$AppStateFromJson(Map<String, dynamic> json) {
  return _AppState.fromJson(json);
}

/// @nodoc
mixin _$AppState {
  bool get isInit => throw _privateConstructorUsedError;
  PageLabel get pageLabel => throw _privateConstructorUsedError;
  @SizeConverter()
  Size get viewSize => throw _privateConstructorUsedError;
  double get sideWidth => throw _privateConstructorUsedError;
  @BrightnessConverter()
  Brightness get brightness => throw _privateConstructorUsedError;
  List<TransferRecord> get transfers => throw _privateConstructorUsedError;
  List<TransferRecord> get history => throw _privateConstructorUsedError;
  CoreStatus get coreStatus => throw _privateConstructorUsedError;
  Map<String, double> get speeds => throw _privateConstructorUsedError;

  /// Serializes this AppState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppStateCopyWith<AppState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppStateCopyWith<$Res> {
  factory $AppStateCopyWith(AppState value, $Res Function(AppState) then) =
      _$AppStateCopyWithImpl<$Res, AppState>;
  @useResult
  $Res call({
    bool isInit,
    PageLabel pageLabel,
    @SizeConverter() Size viewSize,
    double sideWidth,
    @BrightnessConverter() Brightness brightness,
    List<TransferRecord> transfers,
    List<TransferRecord> history,
    CoreStatus coreStatus,
    Map<String, double> speeds,
  });
}

/// @nodoc
class _$AppStateCopyWithImpl<$Res, $Val extends AppState>
    implements $AppStateCopyWith<$Res> {
  _$AppStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isInit = null,
    Object? pageLabel = null,
    Object? viewSize = null,
    Object? sideWidth = null,
    Object? brightness = null,
    Object? transfers = null,
    Object? history = null,
    Object? coreStatus = null,
    Object? speeds = null,
  }) {
    return _then(
      _value.copyWith(
            isInit: null == isInit
                ? _value.isInit
                : isInit // ignore: cast_nullable_to_non_nullable
                      as bool,
            pageLabel: null == pageLabel
                ? _value.pageLabel
                : pageLabel // ignore: cast_nullable_to_non_nullable
                      as PageLabel,
            viewSize: null == viewSize
                ? _value.viewSize
                : viewSize // ignore: cast_nullable_to_non_nullable
                      as Size,
            sideWidth: null == sideWidth
                ? _value.sideWidth
                : sideWidth // ignore: cast_nullable_to_non_nullable
                      as double,
            brightness: null == brightness
                ? _value.brightness
                : brightness // ignore: cast_nullable_to_non_nullable
                      as Brightness,
            transfers: null == transfers
                ? _value.transfers
                : transfers // ignore: cast_nullable_to_non_nullable
                      as List<TransferRecord>,
            history: null == history
                ? _value.history
                : history // ignore: cast_nullable_to_non_nullable
                      as List<TransferRecord>,
            coreStatus: null == coreStatus
                ? _value.coreStatus
                : coreStatus // ignore: cast_nullable_to_non_nullable
                      as CoreStatus,
            speeds: null == speeds
                ? _value.speeds
                : speeds // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppStateImplCopyWith<$Res>
    implements $AppStateCopyWith<$Res> {
  factory _$$AppStateImplCopyWith(
    _$AppStateImpl value,
    $Res Function(_$AppStateImpl) then,
  ) = __$$AppStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isInit,
    PageLabel pageLabel,
    @SizeConverter() Size viewSize,
    double sideWidth,
    @BrightnessConverter() Brightness brightness,
    List<TransferRecord> transfers,
    List<TransferRecord> history,
    CoreStatus coreStatus,
    Map<String, double> speeds,
  });
}

/// @nodoc
class __$$AppStateImplCopyWithImpl<$Res>
    extends _$AppStateCopyWithImpl<$Res, _$AppStateImpl>
    implements _$$AppStateImplCopyWith<$Res> {
  __$$AppStateImplCopyWithImpl(
    _$AppStateImpl _value,
    $Res Function(_$AppStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isInit = null,
    Object? pageLabel = null,
    Object? viewSize = null,
    Object? sideWidth = null,
    Object? brightness = null,
    Object? transfers = null,
    Object? history = null,
    Object? coreStatus = null,
    Object? speeds = null,
  }) {
    return _then(
      _$AppStateImpl(
        isInit: null == isInit
            ? _value.isInit
            : isInit // ignore: cast_nullable_to_non_nullable
                  as bool,
        pageLabel: null == pageLabel
            ? _value.pageLabel
            : pageLabel // ignore: cast_nullable_to_non_nullable
                  as PageLabel,
        viewSize: null == viewSize
            ? _value.viewSize
            : viewSize // ignore: cast_nullable_to_non_nullable
                  as Size,
        sideWidth: null == sideWidth
            ? _value.sideWidth
            : sideWidth // ignore: cast_nullable_to_non_nullable
                  as double,
        brightness: null == brightness
            ? _value.brightness
            : brightness // ignore: cast_nullable_to_non_nullable
                  as Brightness,
        transfers: null == transfers
            ? _value._transfers
            : transfers // ignore: cast_nullable_to_non_nullable
                  as List<TransferRecord>,
        history: null == history
            ? _value._history
            : history // ignore: cast_nullable_to_non_nullable
                  as List<TransferRecord>,
        coreStatus: null == coreStatus
            ? _value.coreStatus
            : coreStatus // ignore: cast_nullable_to_non_nullable
                  as CoreStatus,
        speeds: null == speeds
            ? _value._speeds
            : speeds // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppStateImpl implements _AppState {
  const _$AppStateImpl({
    this.isInit = false,
    this.pageLabel = PageLabel.dashboard,
    @SizeConverter() this.viewSize = Size.zero,
    this.sideWidth = 0,
    @BrightnessConverter() this.brightness = Brightness.light,
    final List<TransferRecord> transfers = const <TransferRecord>[],
    final List<TransferRecord> history = const <TransferRecord>[],
    this.coreStatus = CoreStatus.disconnected,
    final Map<String, double> speeds = const {},
  }) : _transfers = transfers,
       _history = history,
       _speeds = speeds;

  factory _$AppStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppStateImplFromJson(json);

  @override
  @JsonKey()
  final bool isInit;
  @override
  @JsonKey()
  final PageLabel pageLabel;
  @override
  @JsonKey()
  @SizeConverter()
  final Size viewSize;
  @override
  @JsonKey()
  final double sideWidth;
  @override
  @JsonKey()
  @BrightnessConverter()
  final Brightness brightness;
  final List<TransferRecord> _transfers;
  @override
  @JsonKey()
  List<TransferRecord> get transfers {
    if (_transfers is EqualUnmodifiableListView) return _transfers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transfers);
  }

  final List<TransferRecord> _history;
  @override
  @JsonKey()
  List<TransferRecord> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  @override
  @JsonKey()
  final CoreStatus coreStatus;
  final Map<String, double> _speeds;
  @override
  @JsonKey()
  Map<String, double> get speeds {
    if (_speeds is EqualUnmodifiableMapView) return _speeds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_speeds);
  }

  @override
  String toString() {
    return 'AppState(isInit: $isInit, pageLabel: $pageLabel, viewSize: $viewSize, sideWidth: $sideWidth, brightness: $brightness, transfers: $transfers, history: $history, coreStatus: $coreStatus, speeds: $speeds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppStateImpl &&
            (identical(other.isInit, isInit) || other.isInit == isInit) &&
            (identical(other.pageLabel, pageLabel) ||
                other.pageLabel == pageLabel) &&
            (identical(other.viewSize, viewSize) ||
                other.viewSize == viewSize) &&
            (identical(other.sideWidth, sideWidth) ||
                other.sideWidth == sideWidth) &&
            (identical(other.brightness, brightness) ||
                other.brightness == brightness) &&
            const DeepCollectionEquality().equals(
              other._transfers,
              _transfers,
            ) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            (identical(other.coreStatus, coreStatus) ||
                other.coreStatus == coreStatus) &&
            const DeepCollectionEquality().equals(other._speeds, _speeds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isInit,
    pageLabel,
    viewSize,
    sideWidth,
    brightness,
    const DeepCollectionEquality().hash(_transfers),
    const DeepCollectionEquality().hash(_history),
    coreStatus,
    const DeepCollectionEquality().hash(_speeds),
  );

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppStateImplCopyWith<_$AppStateImpl> get copyWith =>
      __$$AppStateImplCopyWithImpl<_$AppStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppStateImplToJson(this);
  }
}

abstract class _AppState implements AppState {
  const factory _AppState({
    final bool isInit,
    final PageLabel pageLabel,
    @SizeConverter() final Size viewSize,
    final double sideWidth,
    @BrightnessConverter() final Brightness brightness,
    final List<TransferRecord> transfers,
    final List<TransferRecord> history,
    final CoreStatus coreStatus,
    final Map<String, double> speeds,
  }) = _$AppStateImpl;

  factory _AppState.fromJson(Map<String, dynamic> json) =
      _$AppStateImpl.fromJson;

  @override
  bool get isInit;
  @override
  PageLabel get pageLabel;
  @override
  @SizeConverter()
  Size get viewSize;
  @override
  double get sideWidth;
  @override
  @BrightnessConverter()
  Brightness get brightness;
  @override
  List<TransferRecord> get transfers;
  @override
  List<TransferRecord> get history;
  @override
  CoreStatus get coreStatus;
  @override
  Map<String, double> get speeds;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppStateImplCopyWith<_$AppStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
