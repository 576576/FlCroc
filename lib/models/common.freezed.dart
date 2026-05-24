// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'common.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Result<T> {
  T? get data => throw _privateConstructorUsedError;
  ResultType get type => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultCopyWith<T, Result<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultCopyWith<T, $Res> {
  factory $ResultCopyWith(Result<T> value, $Res Function(Result<T>) then) =
      _$ResultCopyWithImpl<T, $Res, Result<T>>;
  @useResult
  $Res call({T? data, ResultType type, String message});
}

/// @nodoc
class _$ResultCopyWithImpl<T, $Res, $Val extends Result<T>>
    implements $ResultCopyWith<T, $Res> {
  _$ResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? type = null,
    Object? message = null,
  }) {
    return _then(
      _value.copyWith(
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as T?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ResultType,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResultImplCopyWith<T, $Res>
    implements $ResultCopyWith<T, $Res> {
  factory _$$ResultImplCopyWith(
    _$ResultImpl<T> value,
    $Res Function(_$ResultImpl<T>) then,
  ) = __$$ResultImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({T? data, ResultType type, String message});
}

/// @nodoc
class __$$ResultImplCopyWithImpl<T, $Res>
    extends _$ResultCopyWithImpl<T, $Res, _$ResultImpl<T>>
    implements _$$ResultImplCopyWith<T, $Res> {
  __$$ResultImplCopyWithImpl(
    _$ResultImpl<T> _value,
    $Res Function(_$ResultImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? type = null,
    Object? message = null,
  }) {
    return _then(
      _$ResultImpl<T>(
        data: freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as T?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ResultType,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ResultImpl<T> implements _Result<T> {
  const _$ResultImpl({
    required this.data,
    required this.type,
    required this.message,
  });

  @override
  final T? data;
  @override
  final ResultType type;
  @override
  final String message;

  @override
  String toString() {
    return 'Result<$T>(data: $data, type: $type, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultImpl<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(data),
    type,
    message,
  );

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultImplCopyWith<T, _$ResultImpl<T>> get copyWith =>
      __$$ResultImplCopyWithImpl<T, _$ResultImpl<T>>(this, _$identity);
}

abstract class _Result<T> implements Result<T> {
  const factory _Result({
    required final T? data,
    required final ResultType type,
    required final String message,
  }) = _$ResultImpl<T>;

  @override
  T? get data;
  @override
  ResultType get type;
  @override
  String get message;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultImplCopyWith<T, _$ResultImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

TransferRecord _$TransferRecordFromJson(Map<String, dynamic> json) {
  return _TransferRecord.fromJson(json);
}

/// @nodoc
mixin _$TransferRecord {
  String get id => throw _privateConstructorUsedError;
  TransferDirection get direction => throw _privateConstructorUsedError;
  TransferStatus get status => throw _privateConstructorUsedError;
  List<FileItem> get files => throw _privateConstructorUsedError;
  int get totalSize => throw _privateConstructorUsedError;
  int? get transferredSize => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  String? get codePhrase => throw _privateConstructorUsedError;
  String? get relayAddress => throw _privateConstructorUsedError;
  double? get speed => throw _privateConstructorUsedError;

  /// Serializes this TransferRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransferRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransferRecordCopyWith<TransferRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransferRecordCopyWith<$Res> {
  factory $TransferRecordCopyWith(
    TransferRecord value,
    $Res Function(TransferRecord) then,
  ) = _$TransferRecordCopyWithImpl<$Res, TransferRecord>;
  @useResult
  $Res call({
    String id,
    TransferDirection direction,
    TransferStatus status,
    List<FileItem> files,
    int totalSize,
    int? transferredSize,
    DateTime startTime,
    DateTime? endTime,
    String? codePhrase,
    String? relayAddress,
    double? speed,
  });
}

/// @nodoc
class _$TransferRecordCopyWithImpl<$Res, $Val extends TransferRecord>
    implements $TransferRecordCopyWith<$Res> {
  _$TransferRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransferRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? direction = null,
    Object? status = null,
    Object? files = null,
    Object? totalSize = null,
    Object? transferredSize = freezed,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? codePhrase = freezed,
    Object? relayAddress = freezed,
    Object? speed = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            direction: null == direction
                ? _value.direction
                : direction // ignore: cast_nullable_to_non_nullable
                      as TransferDirection,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TransferStatus,
            files: null == files
                ? _value.files
                : files // ignore: cast_nullable_to_non_nullable
                      as List<FileItem>,
            totalSize: null == totalSize
                ? _value.totalSize
                : totalSize // ignore: cast_nullable_to_non_nullable
                      as int,
            transferredSize: freezed == transferredSize
                ? _value.transferredSize
                : transferredSize // ignore: cast_nullable_to_non_nullable
                      as int?,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            codePhrase: freezed == codePhrase
                ? _value.codePhrase
                : codePhrase // ignore: cast_nullable_to_non_nullable
                      as String?,
            relayAddress: freezed == relayAddress
                ? _value.relayAddress
                : relayAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            speed: freezed == speed
                ? _value.speed
                : speed // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TransferRecordImplCopyWith<$Res>
    implements $TransferRecordCopyWith<$Res> {
  factory _$$TransferRecordImplCopyWith(
    _$TransferRecordImpl value,
    $Res Function(_$TransferRecordImpl) then,
  ) = __$$TransferRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    TransferDirection direction,
    TransferStatus status,
    List<FileItem> files,
    int totalSize,
    int? transferredSize,
    DateTime startTime,
    DateTime? endTime,
    String? codePhrase,
    String? relayAddress,
    double? speed,
  });
}

/// @nodoc
class __$$TransferRecordImplCopyWithImpl<$Res>
    extends _$TransferRecordCopyWithImpl<$Res, _$TransferRecordImpl>
    implements _$$TransferRecordImplCopyWith<$Res> {
  __$$TransferRecordImplCopyWithImpl(
    _$TransferRecordImpl _value,
    $Res Function(_$TransferRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TransferRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? direction = null,
    Object? status = null,
    Object? files = null,
    Object? totalSize = null,
    Object? transferredSize = freezed,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? codePhrase = freezed,
    Object? relayAddress = freezed,
    Object? speed = freezed,
  }) {
    return _then(
      _$TransferRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        direction: null == direction
            ? _value.direction
            : direction // ignore: cast_nullable_to_non_nullable
                  as TransferDirection,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TransferStatus,
        files: null == files
            ? _value._files
            : files // ignore: cast_nullable_to_non_nullable
                  as List<FileItem>,
        totalSize: null == totalSize
            ? _value.totalSize
            : totalSize // ignore: cast_nullable_to_non_nullable
                  as int,
        transferredSize: freezed == transferredSize
            ? _value.transferredSize
            : transferredSize // ignore: cast_nullable_to_non_nullable
                  as int?,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        codePhrase: freezed == codePhrase
            ? _value.codePhrase
            : codePhrase // ignore: cast_nullable_to_non_nullable
                  as String?,
        relayAddress: freezed == relayAddress
            ? _value.relayAddress
            : relayAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        speed: freezed == speed
            ? _value.speed
            : speed // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TransferRecordImpl implements _TransferRecord {
  const _$TransferRecordImpl({
    required this.id,
    required this.direction,
    required this.status,
    required final List<FileItem> files,
    required this.totalSize,
    this.transferredSize,
    required this.startTime,
    this.endTime,
    this.codePhrase,
    this.relayAddress,
    this.speed,
  }) : _files = files;

  factory _$TransferRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransferRecordImplFromJson(json);

  @override
  final String id;
  @override
  final TransferDirection direction;
  @override
  final TransferStatus status;
  final List<FileItem> _files;
  @override
  List<FileItem> get files {
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_files);
  }

  @override
  final int totalSize;
  @override
  final int? transferredSize;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  final String? codePhrase;
  @override
  final String? relayAddress;
  @override
  final double? speed;

  @override
  String toString() {
    return 'TransferRecord(id: $id, direction: $direction, status: $status, files: $files, totalSize: $totalSize, transferredSize: $transferredSize, startTime: $startTime, endTime: $endTime, codePhrase: $codePhrase, relayAddress: $relayAddress, speed: $speed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransferRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._files, _files) &&
            (identical(other.totalSize, totalSize) ||
                other.totalSize == totalSize) &&
            (identical(other.transferredSize, transferredSize) ||
                other.transferredSize == transferredSize) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.codePhrase, codePhrase) ||
                other.codePhrase == codePhrase) &&
            (identical(other.relayAddress, relayAddress) ||
                other.relayAddress == relayAddress) &&
            (identical(other.speed, speed) || other.speed == speed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    direction,
    status,
    const DeepCollectionEquality().hash(_files),
    totalSize,
    transferredSize,
    startTime,
    endTime,
    codePhrase,
    relayAddress,
    speed,
  );

  /// Create a copy of TransferRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransferRecordImplCopyWith<_$TransferRecordImpl> get copyWith =>
      __$$TransferRecordImplCopyWithImpl<_$TransferRecordImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TransferRecordImplToJson(this);
  }
}

abstract class _TransferRecord implements TransferRecord {
  const factory _TransferRecord({
    required final String id,
    required final TransferDirection direction,
    required final TransferStatus status,
    required final List<FileItem> files,
    required final int totalSize,
    final int? transferredSize,
    required final DateTime startTime,
    final DateTime? endTime,
    final String? codePhrase,
    final String? relayAddress,
    final double? speed,
  }) = _$TransferRecordImpl;

  factory _TransferRecord.fromJson(Map<String, dynamic> json) =
      _$TransferRecordImpl.fromJson;

  @override
  String get id;
  @override
  TransferDirection get direction;
  @override
  TransferStatus get status;
  @override
  List<FileItem> get files;
  @override
  int get totalSize;
  @override
  int? get transferredSize;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  String? get codePhrase;
  @override
  String? get relayAddress;
  @override
  double? get speed;

  /// Create a copy of TransferRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransferRecordImplCopyWith<_$TransferRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FileItem _$FileItemFromJson(Map<String, dynamic> json) {
  return _FileItem.fromJson(json);
}

/// @nodoc
mixin _$FileItem {
  String get name => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  String? get folder => throw _privateConstructorUsedError;

  /// Serializes this FileItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FileItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FileItemCopyWith<FileItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FileItemCopyWith<$Res> {
  factory $FileItemCopyWith(FileItem value, $Res Function(FileItem) then) =
      _$FileItemCopyWithImpl<$Res, FileItem>;
  @useResult
  $Res call({String name, String path, int size, String? folder});
}

/// @nodoc
class _$FileItemCopyWithImpl<$Res, $Val extends FileItem>
    implements $FileItemCopyWith<$Res> {
  _$FileItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FileItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? path = null,
    Object? size = null,
    Object? folder = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as int,
            folder: freezed == folder
                ? _value.folder
                : folder // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FileItemImplCopyWith<$Res>
    implements $FileItemCopyWith<$Res> {
  factory _$$FileItemImplCopyWith(
    _$FileItemImpl value,
    $Res Function(_$FileItemImpl) then,
  ) = __$$FileItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String path, int size, String? folder});
}

/// @nodoc
class __$$FileItemImplCopyWithImpl<$Res>
    extends _$FileItemCopyWithImpl<$Res, _$FileItemImpl>
    implements _$$FileItemImplCopyWith<$Res> {
  __$$FileItemImplCopyWithImpl(
    _$FileItemImpl _value,
    $Res Function(_$FileItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FileItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? path = null,
    Object? size = null,
    Object? folder = freezed,
  }) {
    return _then(
      _$FileItemImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as int,
        folder: freezed == folder
            ? _value.folder
            : folder // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FileItemImpl implements _FileItem {
  const _$FileItemImpl({
    required this.name,
    required this.path,
    required this.size,
    this.folder,
  });

  factory _$FileItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$FileItemImplFromJson(json);

  @override
  final String name;
  @override
  final String path;
  @override
  final int size;
  @override
  final String? folder;

  @override
  String toString() {
    return 'FileItem(name: $name, path: $path, size: $size, folder: $folder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.folder, folder) || other.folder == folder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, path, size, folder);

  /// Create a copy of FileItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FileItemImplCopyWith<_$FileItemImpl> get copyWith =>
      __$$FileItemImplCopyWithImpl<_$FileItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FileItemImplToJson(this);
  }
}

abstract class _FileItem implements FileItem {
  const factory _FileItem({
    required final String name,
    required final String path,
    required final int size,
    final String? folder,
  }) = _$FileItemImpl;

  factory _FileItem.fromJson(Map<String, dynamic> json) =
      _$FileItemImpl.fromJson;

  @override
  String get name;
  @override
  String get path;
  @override
  int get size;
  @override
  String? get folder;

  /// Create a copy of FileItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FileItemImplCopyWith<_$FileItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RelayConfig _$RelayConfigFromJson(Map<String, dynamic> json) {
  return _RelayConfig.fromJson(json);
}

/// @nodoc
mixin _$RelayConfig {
  String get address => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get port => throw _privateConstructorUsedError;
  RelayType get type => throw _privateConstructorUsedError;

  /// Serializes this RelayConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RelayConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RelayConfigCopyWith<RelayConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RelayConfigCopyWith<$Res> {
  factory $RelayConfigCopyWith(
    RelayConfig value,
    $Res Function(RelayConfig) then,
  ) = _$RelayConfigCopyWithImpl<$Res, RelayConfig>;
  @useResult
  $Res call({String address, String password, String port, RelayType type});
}

/// @nodoc
class _$RelayConfigCopyWithImpl<$Res, $Val extends RelayConfig>
    implements $RelayConfigCopyWith<$Res> {
  _$RelayConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RelayConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = null,
    Object? password = null,
    Object? port = null,
    Object? type = null,
  }) {
    return _then(
      _value.copyWith(
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
            port: null == port
                ? _value.port
                : port // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as RelayType,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RelayConfigImplCopyWith<$Res>
    implements $RelayConfigCopyWith<$Res> {
  factory _$$RelayConfigImplCopyWith(
    _$RelayConfigImpl value,
    $Res Function(_$RelayConfigImpl) then,
  ) = __$$RelayConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String address, String password, String port, RelayType type});
}

/// @nodoc
class __$$RelayConfigImplCopyWithImpl<$Res>
    extends _$RelayConfigCopyWithImpl<$Res, _$RelayConfigImpl>
    implements _$$RelayConfigImplCopyWith<$Res> {
  __$$RelayConfigImplCopyWithImpl(
    _$RelayConfigImpl _value,
    $Res Function(_$RelayConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RelayConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = null,
    Object? password = null,
    Object? port = null,
    Object? type = null,
  }) {
    return _then(
      _$RelayConfigImpl(
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
        port: null == port
            ? _value.port
            : port // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as RelayType,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RelayConfigImpl implements _RelayConfig {
  const _$RelayConfigImpl({
    this.address = defaultRelay,
    this.password = defaultPassphrase,
    this.port = defaultPort,
    this.type = RelayType.defaultRelay,
  });

  factory _$RelayConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$RelayConfigImplFromJson(json);

  @override
  @JsonKey()
  final String address;
  @override
  @JsonKey()
  final String password;
  @override
  @JsonKey()
  final String port;
  @override
  @JsonKey()
  final RelayType type;

  @override
  String toString() {
    return 'RelayConfig(address: $address, password: $password, port: $port, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RelayConfigImpl &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, address, password, port, type);

  /// Create a copy of RelayConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RelayConfigImplCopyWith<_$RelayConfigImpl> get copyWith =>
      __$$RelayConfigImplCopyWithImpl<_$RelayConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RelayConfigImplToJson(this);
  }
}

abstract class _RelayConfig implements RelayConfig {
  const factory _RelayConfig({
    final String address,
    final String password,
    final String port,
    final RelayType type,
  }) = _$RelayConfigImpl;

  factory _RelayConfig.fromJson(Map<String, dynamic> json) =
      _$RelayConfigImpl.fromJson;

  @override
  String get address;
  @override
  String get password;
  @override
  String get port;
  @override
  RelayType get type;

  /// Create a copy of RelayConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RelayConfigImplCopyWith<_$RelayConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SendConfig _$SendConfigFromJson(Map<String, dynamic> json) {
  return _SendConfig.fromJson(json);
}

/// @nodoc
mixin _$SendConfig {
  String get curve => throw _privateConstructorUsedError;
  String get hashAlgorithm => throw _privateConstructorUsedError;
  bool get noCompress => throw _privateConstructorUsedError;
  bool get overwrite => throw _privateConstructorUsedError;
  bool get zipFolder => throw _privateConstructorUsedError;
  bool get gitIgnore => throw _privateConstructorUsedError;
  bool get onlyLocal => throw _privateConstructorUsedError;
  bool get disableLocal => throw _privateConstructorUsedError;
  bool get showQrCode => throw _privateConstructorUsedError;
  bool get disableClipboard => throw _privateConstructorUsedError;
  String get codePhrase => throw _privateConstructorUsedError;
  String get socks5Proxy => throw _privateConstructorUsedError;
  String get httpProxy => throw _privateConstructorUsedError;
  String get throttleUpload => throw _privateConstructorUsedError;
  List<String> get exclude => throw _privateConstructorUsedError;

  /// Serializes this SendConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SendConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SendConfigCopyWith<SendConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SendConfigCopyWith<$Res> {
  factory $SendConfigCopyWith(
    SendConfig value,
    $Res Function(SendConfig) then,
  ) = _$SendConfigCopyWithImpl<$Res, SendConfig>;
  @useResult
  $Res call({
    String curve,
    String hashAlgorithm,
    bool noCompress,
    bool overwrite,
    bool zipFolder,
    bool gitIgnore,
    bool onlyLocal,
    bool disableLocal,
    bool showQrCode,
    bool disableClipboard,
    String codePhrase,
    String socks5Proxy,
    String httpProxy,
    String throttleUpload,
    List<String> exclude,
  });
}

/// @nodoc
class _$SendConfigCopyWithImpl<$Res, $Val extends SendConfig>
    implements $SendConfigCopyWith<$Res> {
  _$SendConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SendConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? curve = null,
    Object? hashAlgorithm = null,
    Object? noCompress = null,
    Object? overwrite = null,
    Object? zipFolder = null,
    Object? gitIgnore = null,
    Object? onlyLocal = null,
    Object? disableLocal = null,
    Object? showQrCode = null,
    Object? disableClipboard = null,
    Object? codePhrase = null,
    Object? socks5Proxy = null,
    Object? httpProxy = null,
    Object? throttleUpload = null,
    Object? exclude = null,
  }) {
    return _then(
      _value.copyWith(
            curve: null == curve
                ? _value.curve
                : curve // ignore: cast_nullable_to_non_nullable
                      as String,
            hashAlgorithm: null == hashAlgorithm
                ? _value.hashAlgorithm
                : hashAlgorithm // ignore: cast_nullable_to_non_nullable
                      as String,
            noCompress: null == noCompress
                ? _value.noCompress
                : noCompress // ignore: cast_nullable_to_non_nullable
                      as bool,
            overwrite: null == overwrite
                ? _value.overwrite
                : overwrite // ignore: cast_nullable_to_non_nullable
                      as bool,
            zipFolder: null == zipFolder
                ? _value.zipFolder
                : zipFolder // ignore: cast_nullable_to_non_nullable
                      as bool,
            gitIgnore: null == gitIgnore
                ? _value.gitIgnore
                : gitIgnore // ignore: cast_nullable_to_non_nullable
                      as bool,
            onlyLocal: null == onlyLocal
                ? _value.onlyLocal
                : onlyLocal // ignore: cast_nullable_to_non_nullable
                      as bool,
            disableLocal: null == disableLocal
                ? _value.disableLocal
                : disableLocal // ignore: cast_nullable_to_non_nullable
                      as bool,
            showQrCode: null == showQrCode
                ? _value.showQrCode
                : showQrCode // ignore: cast_nullable_to_non_nullable
                      as bool,
            disableClipboard: null == disableClipboard
                ? _value.disableClipboard
                : disableClipboard // ignore: cast_nullable_to_non_nullable
                      as bool,
            codePhrase: null == codePhrase
                ? _value.codePhrase
                : codePhrase // ignore: cast_nullable_to_non_nullable
                      as String,
            socks5Proxy: null == socks5Proxy
                ? _value.socks5Proxy
                : socks5Proxy // ignore: cast_nullable_to_non_nullable
                      as String,
            httpProxy: null == httpProxy
                ? _value.httpProxy
                : httpProxy // ignore: cast_nullable_to_non_nullable
                      as String,
            throttleUpload: null == throttleUpload
                ? _value.throttleUpload
                : throttleUpload // ignore: cast_nullable_to_non_nullable
                      as String,
            exclude: null == exclude
                ? _value.exclude
                : exclude // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SendConfigImplCopyWith<$Res>
    implements $SendConfigCopyWith<$Res> {
  factory _$$SendConfigImplCopyWith(
    _$SendConfigImpl value,
    $Res Function(_$SendConfigImpl) then,
  ) = __$$SendConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String curve,
    String hashAlgorithm,
    bool noCompress,
    bool overwrite,
    bool zipFolder,
    bool gitIgnore,
    bool onlyLocal,
    bool disableLocal,
    bool showQrCode,
    bool disableClipboard,
    String codePhrase,
    String socks5Proxy,
    String httpProxy,
    String throttleUpload,
    List<String> exclude,
  });
}

/// @nodoc
class __$$SendConfigImplCopyWithImpl<$Res>
    extends _$SendConfigCopyWithImpl<$Res, _$SendConfigImpl>
    implements _$$SendConfigImplCopyWith<$Res> {
  __$$SendConfigImplCopyWithImpl(
    _$SendConfigImpl _value,
    $Res Function(_$SendConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SendConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? curve = null,
    Object? hashAlgorithm = null,
    Object? noCompress = null,
    Object? overwrite = null,
    Object? zipFolder = null,
    Object? gitIgnore = null,
    Object? onlyLocal = null,
    Object? disableLocal = null,
    Object? showQrCode = null,
    Object? disableClipboard = null,
    Object? codePhrase = null,
    Object? socks5Proxy = null,
    Object? httpProxy = null,
    Object? throttleUpload = null,
    Object? exclude = null,
  }) {
    return _then(
      _$SendConfigImpl(
        curve: null == curve
            ? _value.curve
            : curve // ignore: cast_nullable_to_non_nullable
                  as String,
        hashAlgorithm: null == hashAlgorithm
            ? _value.hashAlgorithm
            : hashAlgorithm // ignore: cast_nullable_to_non_nullable
                  as String,
        noCompress: null == noCompress
            ? _value.noCompress
            : noCompress // ignore: cast_nullable_to_non_nullable
                  as bool,
        overwrite: null == overwrite
            ? _value.overwrite
            : overwrite // ignore: cast_nullable_to_non_nullable
                  as bool,
        zipFolder: null == zipFolder
            ? _value.zipFolder
            : zipFolder // ignore: cast_nullable_to_non_nullable
                  as bool,
        gitIgnore: null == gitIgnore
            ? _value.gitIgnore
            : gitIgnore // ignore: cast_nullable_to_non_nullable
                  as bool,
        onlyLocal: null == onlyLocal
            ? _value.onlyLocal
            : onlyLocal // ignore: cast_nullable_to_non_nullable
                  as bool,
        disableLocal: null == disableLocal
            ? _value.disableLocal
            : disableLocal // ignore: cast_nullable_to_non_nullable
                  as bool,
        showQrCode: null == showQrCode
            ? _value.showQrCode
            : showQrCode // ignore: cast_nullable_to_non_nullable
                  as bool,
        disableClipboard: null == disableClipboard
            ? _value.disableClipboard
            : disableClipboard // ignore: cast_nullable_to_non_nullable
                  as bool,
        codePhrase: null == codePhrase
            ? _value.codePhrase
            : codePhrase // ignore: cast_nullable_to_non_nullable
                  as String,
        socks5Proxy: null == socks5Proxy
            ? _value.socks5Proxy
            : socks5Proxy // ignore: cast_nullable_to_non_nullable
                  as String,
        httpProxy: null == httpProxy
            ? _value.httpProxy
            : httpProxy // ignore: cast_nullable_to_non_nullable
                  as String,
        throttleUpload: null == throttleUpload
            ? _value.throttleUpload
            : throttleUpload // ignore: cast_nullable_to_non_nullable
                  as String,
        exclude: null == exclude
            ? _value._exclude
            : exclude // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SendConfigImpl implements _SendConfig {
  const _$SendConfigImpl({
    this.curve = defaultCurve,
    this.hashAlgorithm = defaultHashAlgorithm,
    this.noCompress = false,
    this.overwrite = false,
    this.zipFolder = false,
    this.gitIgnore = false,
    this.onlyLocal = false,
    this.disableLocal = false,
    this.showQrCode = false,
    this.disableClipboard = false,
    this.codePhrase = '',
    this.socks5Proxy = '',
    this.httpProxy = '',
    this.throttleUpload = '',
    final List<String> exclude = const <String>[],
  }) : _exclude = exclude;

  factory _$SendConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$SendConfigImplFromJson(json);

  @override
  @JsonKey()
  final String curve;
  @override
  @JsonKey()
  final String hashAlgorithm;
  @override
  @JsonKey()
  final bool noCompress;
  @override
  @JsonKey()
  final bool overwrite;
  @override
  @JsonKey()
  final bool zipFolder;
  @override
  @JsonKey()
  final bool gitIgnore;
  @override
  @JsonKey()
  final bool onlyLocal;
  @override
  @JsonKey()
  final bool disableLocal;
  @override
  @JsonKey()
  final bool showQrCode;
  @override
  @JsonKey()
  final bool disableClipboard;
  @override
  @JsonKey()
  final String codePhrase;
  @override
  @JsonKey()
  final String socks5Proxy;
  @override
  @JsonKey()
  final String httpProxy;
  @override
  @JsonKey()
  final String throttleUpload;
  final List<String> _exclude;
  @override
  @JsonKey()
  List<String> get exclude {
    if (_exclude is EqualUnmodifiableListView) return _exclude;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exclude);
  }

  @override
  String toString() {
    return 'SendConfig(curve: $curve, hashAlgorithm: $hashAlgorithm, noCompress: $noCompress, overwrite: $overwrite, zipFolder: $zipFolder, gitIgnore: $gitIgnore, onlyLocal: $onlyLocal, disableLocal: $disableLocal, showQrCode: $showQrCode, disableClipboard: $disableClipboard, codePhrase: $codePhrase, socks5Proxy: $socks5Proxy, httpProxy: $httpProxy, throttleUpload: $throttleUpload, exclude: $exclude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendConfigImpl &&
            (identical(other.curve, curve) || other.curve == curve) &&
            (identical(other.hashAlgorithm, hashAlgorithm) ||
                other.hashAlgorithm == hashAlgorithm) &&
            (identical(other.noCompress, noCompress) ||
                other.noCompress == noCompress) &&
            (identical(other.overwrite, overwrite) ||
                other.overwrite == overwrite) &&
            (identical(other.zipFolder, zipFolder) ||
                other.zipFolder == zipFolder) &&
            (identical(other.gitIgnore, gitIgnore) ||
                other.gitIgnore == gitIgnore) &&
            (identical(other.onlyLocal, onlyLocal) ||
                other.onlyLocal == onlyLocal) &&
            (identical(other.disableLocal, disableLocal) ||
                other.disableLocal == disableLocal) &&
            (identical(other.showQrCode, showQrCode) ||
                other.showQrCode == showQrCode) &&
            (identical(other.disableClipboard, disableClipboard) ||
                other.disableClipboard == disableClipboard) &&
            (identical(other.codePhrase, codePhrase) ||
                other.codePhrase == codePhrase) &&
            (identical(other.socks5Proxy, socks5Proxy) ||
                other.socks5Proxy == socks5Proxy) &&
            (identical(other.httpProxy, httpProxy) ||
                other.httpProxy == httpProxy) &&
            (identical(other.throttleUpload, throttleUpload) ||
                other.throttleUpload == throttleUpload) &&
            const DeepCollectionEquality().equals(other._exclude, _exclude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    curve,
    hashAlgorithm,
    noCompress,
    overwrite,
    zipFolder,
    gitIgnore,
    onlyLocal,
    disableLocal,
    showQrCode,
    disableClipboard,
    codePhrase,
    socks5Proxy,
    httpProxy,
    throttleUpload,
    const DeepCollectionEquality().hash(_exclude),
  );

  /// Create a copy of SendConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SendConfigImplCopyWith<_$SendConfigImpl> get copyWith =>
      __$$SendConfigImplCopyWithImpl<_$SendConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SendConfigImplToJson(this);
  }
}

abstract class _SendConfig implements SendConfig {
  const factory _SendConfig({
    final String curve,
    final String hashAlgorithm,
    final bool noCompress,
    final bool overwrite,
    final bool zipFolder,
    final bool gitIgnore,
    final bool onlyLocal,
    final bool disableLocal,
    final bool showQrCode,
    final bool disableClipboard,
    final String codePhrase,
    final String socks5Proxy,
    final String httpProxy,
    final String throttleUpload,
    final List<String> exclude,
  }) = _$SendConfigImpl;

  factory _SendConfig.fromJson(Map<String, dynamic> json) =
      _$SendConfigImpl.fromJson;

  @override
  String get curve;
  @override
  String get hashAlgorithm;
  @override
  bool get noCompress;
  @override
  bool get overwrite;
  @override
  bool get zipFolder;
  @override
  bool get gitIgnore;
  @override
  bool get onlyLocal;
  @override
  bool get disableLocal;
  @override
  bool get showQrCode;
  @override
  bool get disableClipboard;
  @override
  String get codePhrase;
  @override
  String get socks5Proxy;
  @override
  String get httpProxy;
  @override
  String get throttleUpload;
  @override
  List<String> get exclude;

  /// Create a copy of SendConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SendConfigImplCopyWith<_$SendConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReceiveConfig _$ReceiveConfigFromJson(Map<String, dynamic> json) {
  return _ReceiveConfig.fromJson(json);
}

/// @nodoc
mixin _$ReceiveConfig {
  bool get overwrite => throw _privateConstructorUsedError;
  bool get onlyLocal => throw _privateConstructorUsedError;
  String get outputPath => throw _privateConstructorUsedError;

  /// Serializes this ReceiveConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReceiveConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReceiveConfigCopyWith<ReceiveConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceiveConfigCopyWith<$Res> {
  factory $ReceiveConfigCopyWith(
    ReceiveConfig value,
    $Res Function(ReceiveConfig) then,
  ) = _$ReceiveConfigCopyWithImpl<$Res, ReceiveConfig>;
  @useResult
  $Res call({bool overwrite, bool onlyLocal, String outputPath});
}

/// @nodoc
class _$ReceiveConfigCopyWithImpl<$Res, $Val extends ReceiveConfig>
    implements $ReceiveConfigCopyWith<$Res> {
  _$ReceiveConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReceiveConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overwrite = null,
    Object? onlyLocal = null,
    Object? outputPath = null,
  }) {
    return _then(
      _value.copyWith(
            overwrite: null == overwrite
                ? _value.overwrite
                : overwrite // ignore: cast_nullable_to_non_nullable
                      as bool,
            onlyLocal: null == onlyLocal
                ? _value.onlyLocal
                : onlyLocal // ignore: cast_nullable_to_non_nullable
                      as bool,
            outputPath: null == outputPath
                ? _value.outputPath
                : outputPath // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReceiveConfigImplCopyWith<$Res>
    implements $ReceiveConfigCopyWith<$Res> {
  factory _$$ReceiveConfigImplCopyWith(
    _$ReceiveConfigImpl value,
    $Res Function(_$ReceiveConfigImpl) then,
  ) = __$$ReceiveConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool overwrite, bool onlyLocal, String outputPath});
}

/// @nodoc
class __$$ReceiveConfigImplCopyWithImpl<$Res>
    extends _$ReceiveConfigCopyWithImpl<$Res, _$ReceiveConfigImpl>
    implements _$$ReceiveConfigImplCopyWith<$Res> {
  __$$ReceiveConfigImplCopyWithImpl(
    _$ReceiveConfigImpl _value,
    $Res Function(_$ReceiveConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceiveConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overwrite = null,
    Object? onlyLocal = null,
    Object? outputPath = null,
  }) {
    return _then(
      _$ReceiveConfigImpl(
        overwrite: null == overwrite
            ? _value.overwrite
            : overwrite // ignore: cast_nullable_to_non_nullable
                  as bool,
        onlyLocal: null == onlyLocal
            ? _value.onlyLocal
            : onlyLocal // ignore: cast_nullable_to_non_nullable
                  as bool,
        outputPath: null == outputPath
            ? _value.outputPath
            : outputPath // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReceiveConfigImpl implements _ReceiveConfig {
  const _$ReceiveConfigImpl({
    this.overwrite = false,
    this.onlyLocal = false,
    this.outputPath = '',
  });

  factory _$ReceiveConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReceiveConfigImplFromJson(json);

  @override
  @JsonKey()
  final bool overwrite;
  @override
  @JsonKey()
  final bool onlyLocal;
  @override
  @JsonKey()
  final String outputPath;

  @override
  String toString() {
    return 'ReceiveConfig(overwrite: $overwrite, onlyLocal: $onlyLocal, outputPath: $outputPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiveConfigImpl &&
            (identical(other.overwrite, overwrite) ||
                other.overwrite == overwrite) &&
            (identical(other.onlyLocal, onlyLocal) ||
                other.onlyLocal == onlyLocal) &&
            (identical(other.outputPath, outputPath) ||
                other.outputPath == outputPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, overwrite, onlyLocal, outputPath);

  /// Create a copy of ReceiveConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiveConfigImplCopyWith<_$ReceiveConfigImpl> get copyWith =>
      __$$ReceiveConfigImplCopyWithImpl<_$ReceiveConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceiveConfigImplToJson(this);
  }
}

abstract class _ReceiveConfig implements ReceiveConfig {
  const factory _ReceiveConfig({
    final bool overwrite,
    final bool onlyLocal,
    final String outputPath,
  }) = _$ReceiveConfigImpl;

  factory _ReceiveConfig.fromJson(Map<String, dynamic> json) =
      _$ReceiveConfigImpl.fromJson;

  @override
  bool get overwrite;
  @override
  bool get onlyLocal;
  @override
  String get outputPath;

  /// Create a copy of ReceiveConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiveConfigImplCopyWith<_$ReceiveConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
