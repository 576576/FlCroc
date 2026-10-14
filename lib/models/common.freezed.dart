// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'common.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Result<T> {

 T? get data; ResultType get type; String get message;
/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultCopyWith<T, Result<T>> get copyWith => _$ResultCopyWithImpl<T, Result<T>>(this as Result<T>, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Result<T>;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Result<T>&&const DeepCollectionEquality().equals(other.data, _this.data)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as Result<T>;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.data),_this.type,_this.message);
}

@override
String toString() {
  final _this = this as Result<T>;
  return 'Result<$T>(data: ${_this.data}, type: ${_this.type}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $ResultCopyWith<T,$Res>  {
  factory $ResultCopyWith(Result<T> value, $Res Function(Result<T>) _then) = _$ResultCopyWithImpl;
@useResult
$Res call({
 T? data, ResultType type, String message
});




}
/// @nodoc
class _$ResultCopyWithImpl<T,$Res>
    implements $ResultCopyWith<T, $Res> {
  _$ResultCopyWithImpl(this._self, this._then);

  final Result<T> _self;
  final $Res Function(Result<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,Object? type = null,Object? message = null,}) {
  return _then(Result(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ResultType,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Result].
extension ResultPatterns<T> on Result<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Result<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Result() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Result<T> value)  $default,){
final _that = this;
switch (_that) {
case _Result():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Result<T> value)?  $default,){
final _that = this;
switch (_that) {
case _Result() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( T? data,  ResultType type,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Result() when $default != null:
return $default(_that.data,_that.type,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( T? data,  ResultType type,  String message)  $default,) {final _that = this;
switch (_that) {
case _Result():
return $default(_that.data,_that.type,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( T? data,  ResultType type,  String message)?  $default,) {final _that = this;
switch (_that) {
case _Result() when $default != null:
return $default(_that.data,_that.type,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Result<T> implements Result<T> {
  const _Result({required this.data, required this.type, required this.message});
  

@override final  T? data;
@override final  ResultType type;
@override final  String message;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultCopyWith<T, _Result<T>> get copyWith => __$ResultCopyWithImpl<T, _Result<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Result<T>&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.type, type) || other.type == type)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(data),type,message);
}

@override
String toString() {
    return 'Result<$T>(data: $data, type: $type, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ResultCopyWith<T,$Res> implements $ResultCopyWith<T, $Res> {
  factory _$ResultCopyWith(_Result<T> value, $Res Function(_Result<T>) _then) = __$ResultCopyWithImpl;
@override @useResult
$Res call({
 T? data, ResultType type, String message
});




}
/// @nodoc
class __$ResultCopyWithImpl<T,$Res>
    implements _$ResultCopyWith<T, $Res> {
  __$ResultCopyWithImpl(this._self, this._then);

  final _Result<T> _self;
  final $Res Function(_Result<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,Object? type = null,Object? message = null,}) {
  return _then(_Result<T>(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ResultType,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TransferRecord {

 String get id; TransferDirection get direction; TransferStatus get status; List<FileItem> get files; int get totalSize; int? get transferredSize; DateTime get startTime; DateTime? get endTime; String? get codePhrase; String? get relayAddress; double? get speed;
/// Create a copy of TransferRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferRecordCopyWith<TransferRecord> get copyWith => _$TransferRecordCopyWithImpl<TransferRecord>(this as TransferRecord, _$identity);

  /// Serializes this TransferRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TransferRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferRecord&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.direction, _this.direction) || other.direction == _this.direction)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.files, _this.files)&&(identical(other.totalSize, _this.totalSize) || other.totalSize == _this.totalSize)&&(identical(other.transferredSize, _this.transferredSize) || other.transferredSize == _this.transferredSize)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime)&&(identical(other.codePhrase, _this.codePhrase) || other.codePhrase == _this.codePhrase)&&(identical(other.relayAddress, _this.relayAddress) || other.relayAddress == _this.relayAddress)&&(identical(other.speed, _this.speed) || other.speed == _this.speed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TransferRecord;
  return Object.hash(runtimeType,_this.id,_this.direction,_this.status,const DeepCollectionEquality().hash(_this.files),_this.totalSize,_this.transferredSize,_this.startTime,_this.endTime,_this.codePhrase,_this.relayAddress,_this.speed);
}

@override
String toString() {
  final _this = this as TransferRecord;
  return 'TransferRecord(id: ${_this.id}, direction: ${_this.direction}, status: ${_this.status}, files: ${_this.files}, totalSize: ${_this.totalSize}, transferredSize: ${_this.transferredSize}, startTime: ${_this.startTime}, endTime: ${_this.endTime}, codePhrase: ${_this.codePhrase}, relayAddress: ${_this.relayAddress}, speed: ${_this.speed})';
}


}

/// @nodoc
abstract mixin class $TransferRecordCopyWith<$Res>  {
  factory $TransferRecordCopyWith(TransferRecord value, $Res Function(TransferRecord) _then) = _$TransferRecordCopyWithImpl;
@useResult
$Res call({
 String id, TransferDirection direction, TransferStatus status, List<FileItem> files, int totalSize, int? transferredSize, DateTime startTime, DateTime? endTime, String? codePhrase, String? relayAddress, double? speed
});




}
/// @nodoc
class _$TransferRecordCopyWithImpl<$Res>
    implements $TransferRecordCopyWith<$Res> {
  _$TransferRecordCopyWithImpl(this._self, this._then);

  final TransferRecord _self;
  final $Res Function(TransferRecord) _then;

/// Create a copy of TransferRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? direction = null,Object? status = null,Object? files = null,Object? totalSize = null,Object? transferredSize = freezed,Object? startTime = null,Object? endTime = freezed,Object? codePhrase = freezed,Object? relayAddress = freezed,Object? speed = freezed,}) {
  return _then(TransferRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TransferDirection,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransferStatus,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<FileItem>,totalSize: null == totalSize ? _self.totalSize : totalSize // ignore: cast_nullable_to_non_nullable
as int,transferredSize: freezed == transferredSize ? _self.transferredSize : transferredSize // ignore: cast_nullable_to_non_nullable
as int?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,codePhrase: freezed == codePhrase ? _self.codePhrase : codePhrase // ignore: cast_nullable_to_non_nullable
as String?,relayAddress: freezed == relayAddress ? _self.relayAddress : relayAddress // ignore: cast_nullable_to_non_nullable
as String?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransferRecord].
extension TransferRecordPatterns on TransferRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransferRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransferRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransferRecord value)  $default,){
final _that = this;
switch (_that) {
case _TransferRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransferRecord value)?  $default,){
final _that = this;
switch (_that) {
case _TransferRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TransferDirection direction,  TransferStatus status,  List<FileItem> files,  int totalSize,  int? transferredSize,  DateTime startTime,  DateTime? endTime,  String? codePhrase,  String? relayAddress,  double? speed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransferRecord() when $default != null:
return $default(_that.id,_that.direction,_that.status,_that.files,_that.totalSize,_that.transferredSize,_that.startTime,_that.endTime,_that.codePhrase,_that.relayAddress,_that.speed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TransferDirection direction,  TransferStatus status,  List<FileItem> files,  int totalSize,  int? transferredSize,  DateTime startTime,  DateTime? endTime,  String? codePhrase,  String? relayAddress,  double? speed)  $default,) {final _that = this;
switch (_that) {
case _TransferRecord():
return $default(_that.id,_that.direction,_that.status,_that.files,_that.totalSize,_that.transferredSize,_that.startTime,_that.endTime,_that.codePhrase,_that.relayAddress,_that.speed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TransferDirection direction,  TransferStatus status,  List<FileItem> files,  int totalSize,  int? transferredSize,  DateTime startTime,  DateTime? endTime,  String? codePhrase,  String? relayAddress,  double? speed)?  $default,) {final _that = this;
switch (_that) {
case _TransferRecord() when $default != null:
return $default(_that.id,_that.direction,_that.status,_that.files,_that.totalSize,_that.transferredSize,_that.startTime,_that.endTime,_that.codePhrase,_that.relayAddress,_that.speed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransferRecord implements TransferRecord {
  const _TransferRecord({required this.id, required this.direction, required this.status, required  List<FileItem> files, required this.totalSize, this.transferredSize, required this.startTime, this.endTime, this.codePhrase, this.relayAddress, this.speed}): _files = files;
  factory _TransferRecord.fromJson(Map<String, dynamic> json) => _$TransferRecordFromJson(json);

@override final  String id;
@override final  TransferDirection direction;
@override final  TransferStatus status;
 final  List<FileItem> _files;
@override List<FileItem> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

@override final  int totalSize;
@override final  int? transferredSize;
@override final  DateTime startTime;
@override final  DateTime? endTime;
@override final  String? codePhrase;
@override final  String? relayAddress;
@override final  double? speed;

/// Create a copy of TransferRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransferRecordCopyWith<_TransferRecord> get copyWith => __$TransferRecordCopyWithImpl<_TransferRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransferRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransferRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.files, _files)&&(identical(other.totalSize, totalSize) || other.totalSize == totalSize)&&(identical(other.transferredSize, transferredSize) || other.transferredSize == transferredSize)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.codePhrase, codePhrase) || other.codePhrase == codePhrase)&&(identical(other.relayAddress, relayAddress) || other.relayAddress == relayAddress)&&(identical(other.speed, speed) || other.speed == speed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,direction,status,const DeepCollectionEquality().hash(_files),totalSize,transferredSize,startTime,endTime,codePhrase,relayAddress,speed);
}

@override
String toString() {
    return 'TransferRecord(id: $id, direction: $direction, status: $status, files: $files, totalSize: $totalSize, transferredSize: $transferredSize, startTime: $startTime, endTime: $endTime, codePhrase: $codePhrase, relayAddress: $relayAddress, speed: $speed)';
}


}

/// @nodoc
abstract mixin class _$TransferRecordCopyWith<$Res> implements $TransferRecordCopyWith<$Res> {
  factory _$TransferRecordCopyWith(_TransferRecord value, $Res Function(_TransferRecord) _then) = __$TransferRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, TransferDirection direction, TransferStatus status, List<FileItem> files, int totalSize, int? transferredSize, DateTime startTime, DateTime? endTime, String? codePhrase, String? relayAddress, double? speed
});




}
/// @nodoc
class __$TransferRecordCopyWithImpl<$Res>
    implements _$TransferRecordCopyWith<$Res> {
  __$TransferRecordCopyWithImpl(this._self, this._then);

  final _TransferRecord _self;
  final $Res Function(_TransferRecord) _then;

/// Create a copy of TransferRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? direction = null,Object? status = null,Object? files = null,Object? totalSize = null,Object? transferredSize = freezed,Object? startTime = null,Object? endTime = freezed,Object? codePhrase = freezed,Object? relayAddress = freezed,Object? speed = freezed,}) {
  return _then(_TransferRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TransferDirection,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransferStatus,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<FileItem>,totalSize: null == totalSize ? _self.totalSize : totalSize // ignore: cast_nullable_to_non_nullable
as int,transferredSize: freezed == transferredSize ? _self.transferredSize : transferredSize // ignore: cast_nullable_to_non_nullable
as int?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,codePhrase: freezed == codePhrase ? _self.codePhrase : codePhrase // ignore: cast_nullable_to_non_nullable
as String?,relayAddress: freezed == relayAddress ? _self.relayAddress : relayAddress // ignore: cast_nullable_to_non_nullable
as String?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$FileItem {

 String get name; String get path; int get size; String? get folder;
/// Create a copy of FileItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileItemCopyWith<FileItem> get copyWith => _$FileItemCopyWithImpl<FileItem>(this as FileItem, _$identity);

  /// Serializes this FileItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FileItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileItem&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.folder, _this.folder) || other.folder == _this.folder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FileItem;
  return Object.hash(runtimeType,_this.name,_this.path,_this.size,_this.folder);
}

@override
String toString() {
  final _this = this as FileItem;
  return 'FileItem(name: ${_this.name}, path: ${_this.path}, size: ${_this.size}, folder: ${_this.folder})';
}


}

/// @nodoc
abstract mixin class $FileItemCopyWith<$Res>  {
  factory $FileItemCopyWith(FileItem value, $Res Function(FileItem) _then) = _$FileItemCopyWithImpl;
@useResult
$Res call({
 String name, String path, int size, String? folder
});




}
/// @nodoc
class _$FileItemCopyWithImpl<$Res>
    implements $FileItemCopyWith<$Res> {
  _$FileItemCopyWithImpl(this._self, this._then);

  final FileItem _self;
  final $Res Function(FileItem) _then;

/// Create a copy of FileItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? path = null,Object? size = null,Object? folder = freezed,}) {
  return _then(FileItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,folder: freezed == folder ? _self.folder : folder // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FileItem].
extension FileItemPatterns on FileItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileItem value)  $default,){
final _that = this;
switch (_that) {
case _FileItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileItem value)?  $default,){
final _that = this;
switch (_that) {
case _FileItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String path,  int size,  String? folder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileItem() when $default != null:
return $default(_that.name,_that.path,_that.size,_that.folder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String path,  int size,  String? folder)  $default,) {final _that = this;
switch (_that) {
case _FileItem():
return $default(_that.name,_that.path,_that.size,_that.folder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String path,  int size,  String? folder)?  $default,) {final _that = this;
switch (_that) {
case _FileItem() when $default != null:
return $default(_that.name,_that.path,_that.size,_that.folder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FileItem implements FileItem {
  const _FileItem({required this.name, required this.path, required this.size, this.folder});
  factory _FileItem.fromJson(Map<String, dynamic> json) => _$FileItemFromJson(json);

@override final  String name;
@override final  String path;
@override final  int size;
@override final  String? folder;

/// Create a copy of FileItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileItemCopyWith<_FileItem> get copyWith => __$FileItemCopyWithImpl<_FileItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FileItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileItem&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.size, size) || other.size == size)&&(identical(other.folder, folder) || other.folder == folder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,path,size,folder);
}

@override
String toString() {
    return 'FileItem(name: $name, path: $path, size: $size, folder: $folder)';
}


}

/// @nodoc
abstract mixin class _$FileItemCopyWith<$Res> implements $FileItemCopyWith<$Res> {
  factory _$FileItemCopyWith(_FileItem value, $Res Function(_FileItem) _then) = __$FileItemCopyWithImpl;
@override @useResult
$Res call({
 String name, String path, int size, String? folder
});




}
/// @nodoc
class __$FileItemCopyWithImpl<$Res>
    implements _$FileItemCopyWith<$Res> {
  __$FileItemCopyWithImpl(this._self, this._then);

  final _FileItem _self;
  final $Res Function(_FileItem) _then;

/// Create a copy of FileItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? path = null,Object? size = null,Object? folder = freezed,}) {
  return _then(_FileItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,folder: freezed == folder ? _self.folder : folder // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RelayConfig {

 String get address; String get password; String get port; RelayType get type;
/// Create a copy of RelayConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RelayConfigCopyWith<RelayConfig> get copyWith => _$RelayConfigCopyWithImpl<RelayConfig>(this as RelayConfig, _$identity);

  /// Serializes this RelayConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RelayConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RelayConfig&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.port, _this.port) || other.port == _this.port)&&(identical(other.type, _this.type) || other.type == _this.type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RelayConfig;
  return Object.hash(runtimeType,_this.address,_this.password,_this.port,_this.type);
}

@override
String toString() {
  final _this = this as RelayConfig;
  return 'RelayConfig(address: ${_this.address}, password: ${_this.password}, port: ${_this.port}, type: ${_this.type})';
}


}

/// @nodoc
abstract mixin class $RelayConfigCopyWith<$Res>  {
  factory $RelayConfigCopyWith(RelayConfig value, $Res Function(RelayConfig) _then) = _$RelayConfigCopyWithImpl;
@useResult
$Res call({
 String address, String password, String port, RelayType type
});




}
/// @nodoc
class _$RelayConfigCopyWithImpl<$Res>
    implements $RelayConfigCopyWith<$Res> {
  _$RelayConfigCopyWithImpl(this._self, this._then);

  final RelayConfig _self;
  final $Res Function(RelayConfig) _then;

/// Create a copy of RelayConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = null,Object? password = null,Object? port = null,Object? type = null,}) {
  return _then(RelayConfig(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RelayType,
  ));
}

}


/// Adds pattern-matching-related methods to [RelayConfig].
extension RelayConfigPatterns on RelayConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RelayConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RelayConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RelayConfig value)  $default,){
final _that = this;
switch (_that) {
case _RelayConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RelayConfig value)?  $default,){
final _that = this;
switch (_that) {
case _RelayConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String address,  String password,  String port,  RelayType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RelayConfig() when $default != null:
return $default(_that.address,_that.password,_that.port,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String address,  String password,  String port,  RelayType type)  $default,) {final _that = this;
switch (_that) {
case _RelayConfig():
return $default(_that.address,_that.password,_that.port,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String address,  String password,  String port,  RelayType type)?  $default,) {final _that = this;
switch (_that) {
case _RelayConfig() when $default != null:
return $default(_that.address,_that.password,_that.port,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RelayConfig implements RelayConfig {
  const _RelayConfig({this.address = defaultRelay, this.password = defaultPassphrase, this.port = defaultPort, this.type = RelayType.defaultRelay});
  factory _RelayConfig.fromJson(Map<String, dynamic> json) => _$RelayConfigFromJson(json);

@override@JsonKey() final  String address;
@override@JsonKey() final  String password;
@override@JsonKey() final  String port;
@override@JsonKey() final  RelayType type;

/// Create a copy of RelayConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RelayConfigCopyWith<_RelayConfig> get copyWith => __$RelayConfigCopyWithImpl<_RelayConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RelayConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RelayConfig&&(identical(other.address, address) || other.address == address)&&(identical(other.password, password) || other.password == password)&&(identical(other.port, port) || other.port == port)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,address,password,port,type);
}

@override
String toString() {
    return 'RelayConfig(address: $address, password: $password, port: $port, type: $type)';
}


}

/// @nodoc
abstract mixin class _$RelayConfigCopyWith<$Res> implements $RelayConfigCopyWith<$Res> {
  factory _$RelayConfigCopyWith(_RelayConfig value, $Res Function(_RelayConfig) _then) = __$RelayConfigCopyWithImpl;
@override @useResult
$Res call({
 String address, String password, String port, RelayType type
});




}
/// @nodoc
class __$RelayConfigCopyWithImpl<$Res>
    implements _$RelayConfigCopyWith<$Res> {
  __$RelayConfigCopyWithImpl(this._self, this._then);

  final _RelayConfig _self;
  final $Res Function(_RelayConfig) _then;

/// Create a copy of RelayConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? password = null,Object? port = null,Object? type = null,}) {
  return _then(_RelayConfig(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RelayType,
  ));
}


}


/// @nodoc
mixin _$SendConfig {

 String get curve; String get hashAlgorithm; bool get noCompress; bool get overwrite; bool get zipFolder; bool get gitIgnore; bool get onlyLocal; bool get disableLocal; bool get showQrCode;/// Opt-in: let croc copy the share code to the OS clipboard.
///
/// Defaults to false — a GUI must not silently overwrite the user's
/// clipboard. (Replaces the old `disableClipboard` flag, which defaulted to
/// false and therefore kept hijacking the clipboard after upgrading.)
 bool get copyCodeToClipboard; String get codePhrase; String get socks5Proxy; String get httpProxy; String get throttleUpload; List<String> get exclude;/// Sender file-data channel: `auto`, `derp` or `relay` (croc --transport).
 String get transport;
/// Create a copy of SendConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendConfigCopyWith<SendConfig> get copyWith => _$SendConfigCopyWithImpl<SendConfig>(this as SendConfig, _$identity);

  /// Serializes this SendConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SendConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendConfig&&(identical(other.curve, _this.curve) || other.curve == _this.curve)&&(identical(other.hashAlgorithm, _this.hashAlgorithm) || other.hashAlgorithm == _this.hashAlgorithm)&&(identical(other.noCompress, _this.noCompress) || other.noCompress == _this.noCompress)&&(identical(other.overwrite, _this.overwrite) || other.overwrite == _this.overwrite)&&(identical(other.zipFolder, _this.zipFolder) || other.zipFolder == _this.zipFolder)&&(identical(other.gitIgnore, _this.gitIgnore) || other.gitIgnore == _this.gitIgnore)&&(identical(other.onlyLocal, _this.onlyLocal) || other.onlyLocal == _this.onlyLocal)&&(identical(other.disableLocal, _this.disableLocal) || other.disableLocal == _this.disableLocal)&&(identical(other.showQrCode, _this.showQrCode) || other.showQrCode == _this.showQrCode)&&(identical(other.copyCodeToClipboard, _this.copyCodeToClipboard) || other.copyCodeToClipboard == _this.copyCodeToClipboard)&&(identical(other.codePhrase, _this.codePhrase) || other.codePhrase == _this.codePhrase)&&(identical(other.socks5Proxy, _this.socks5Proxy) || other.socks5Proxy == _this.socks5Proxy)&&(identical(other.httpProxy, _this.httpProxy) || other.httpProxy == _this.httpProxy)&&(identical(other.throttleUpload, _this.throttleUpload) || other.throttleUpload == _this.throttleUpload)&&const DeepCollectionEquality().equals(other.exclude, _this.exclude)&&(identical(other.transport, _this.transport) || other.transport == _this.transport));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SendConfig;
  return Object.hash(runtimeType,_this.curve,_this.hashAlgorithm,_this.noCompress,_this.overwrite,_this.zipFolder,_this.gitIgnore,_this.onlyLocal,_this.disableLocal,_this.showQrCode,_this.copyCodeToClipboard,_this.codePhrase,_this.socks5Proxy,_this.httpProxy,_this.throttleUpload,const DeepCollectionEquality().hash(_this.exclude),_this.transport);
}

@override
String toString() {
  final _this = this as SendConfig;
  return 'SendConfig(curve: ${_this.curve}, hashAlgorithm: ${_this.hashAlgorithm}, noCompress: ${_this.noCompress}, overwrite: ${_this.overwrite}, zipFolder: ${_this.zipFolder}, gitIgnore: ${_this.gitIgnore}, onlyLocal: ${_this.onlyLocal}, disableLocal: ${_this.disableLocal}, showQrCode: ${_this.showQrCode}, copyCodeToClipboard: ${_this.copyCodeToClipboard}, codePhrase: ${_this.codePhrase}, socks5Proxy: ${_this.socks5Proxy}, httpProxy: ${_this.httpProxy}, throttleUpload: ${_this.throttleUpload}, exclude: ${_this.exclude}, transport: ${_this.transport})';
}


}

/// @nodoc
abstract mixin class $SendConfigCopyWith<$Res>  {
  factory $SendConfigCopyWith(SendConfig value, $Res Function(SendConfig) _then) = _$SendConfigCopyWithImpl;
@useResult
$Res call({
 String curve, String hashAlgorithm, bool noCompress, bool overwrite, bool zipFolder, bool gitIgnore, bool onlyLocal, bool disableLocal, bool showQrCode, bool copyCodeToClipboard, String codePhrase, String socks5Proxy, String httpProxy, String throttleUpload, List<String> exclude, String transport
});




}
/// @nodoc
class _$SendConfigCopyWithImpl<$Res>
    implements $SendConfigCopyWith<$Res> {
  _$SendConfigCopyWithImpl(this._self, this._then);

  final SendConfig _self;
  final $Res Function(SendConfig) _then;

/// Create a copy of SendConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? curve = null,Object? hashAlgorithm = null,Object? noCompress = null,Object? overwrite = null,Object? zipFolder = null,Object? gitIgnore = null,Object? onlyLocal = null,Object? disableLocal = null,Object? showQrCode = null,Object? copyCodeToClipboard = null,Object? codePhrase = null,Object? socks5Proxy = null,Object? httpProxy = null,Object? throttleUpload = null,Object? exclude = null,Object? transport = null,}) {
  return _then(SendConfig(
curve: null == curve ? _self.curve : curve // ignore: cast_nullable_to_non_nullable
as String,hashAlgorithm: null == hashAlgorithm ? _self.hashAlgorithm : hashAlgorithm // ignore: cast_nullable_to_non_nullable
as String,noCompress: null == noCompress ? _self.noCompress : noCompress // ignore: cast_nullable_to_non_nullable
as bool,overwrite: null == overwrite ? _self.overwrite : overwrite // ignore: cast_nullable_to_non_nullable
as bool,zipFolder: null == zipFolder ? _self.zipFolder : zipFolder // ignore: cast_nullable_to_non_nullable
as bool,gitIgnore: null == gitIgnore ? _self.gitIgnore : gitIgnore // ignore: cast_nullable_to_non_nullable
as bool,onlyLocal: null == onlyLocal ? _self.onlyLocal : onlyLocal // ignore: cast_nullable_to_non_nullable
as bool,disableLocal: null == disableLocal ? _self.disableLocal : disableLocal // ignore: cast_nullable_to_non_nullable
as bool,showQrCode: null == showQrCode ? _self.showQrCode : showQrCode // ignore: cast_nullable_to_non_nullable
as bool,copyCodeToClipboard: null == copyCodeToClipboard ? _self.copyCodeToClipboard : copyCodeToClipboard // ignore: cast_nullable_to_non_nullable
as bool,codePhrase: null == codePhrase ? _self.codePhrase : codePhrase // ignore: cast_nullable_to_non_nullable
as String,socks5Proxy: null == socks5Proxy ? _self.socks5Proxy : socks5Proxy // ignore: cast_nullable_to_non_nullable
as String,httpProxy: null == httpProxy ? _self.httpProxy : httpProxy // ignore: cast_nullable_to_non_nullable
as String,throttleUpload: null == throttleUpload ? _self.throttleUpload : throttleUpload // ignore: cast_nullable_to_non_nullable
as String,exclude: null == exclude ? _self.exclude : exclude // ignore: cast_nullable_to_non_nullable
as List<String>,transport: null == transport ? _self.transport : transport // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SendConfig].
extension SendConfigPatterns on SendConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SendConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SendConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SendConfig value)  $default,){
final _that = this;
switch (_that) {
case _SendConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SendConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SendConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String curve,  String hashAlgorithm,  bool noCompress,  bool overwrite,  bool zipFolder,  bool gitIgnore,  bool onlyLocal,  bool disableLocal,  bool showQrCode,  bool copyCodeToClipboard,  String codePhrase,  String socks5Proxy,  String httpProxy,  String throttleUpload,  List<String> exclude,  String transport)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SendConfig() when $default != null:
return $default(_that.curve,_that.hashAlgorithm,_that.noCompress,_that.overwrite,_that.zipFolder,_that.gitIgnore,_that.onlyLocal,_that.disableLocal,_that.showQrCode,_that.copyCodeToClipboard,_that.codePhrase,_that.socks5Proxy,_that.httpProxy,_that.throttleUpload,_that.exclude,_that.transport);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String curve,  String hashAlgorithm,  bool noCompress,  bool overwrite,  bool zipFolder,  bool gitIgnore,  bool onlyLocal,  bool disableLocal,  bool showQrCode,  bool copyCodeToClipboard,  String codePhrase,  String socks5Proxy,  String httpProxy,  String throttleUpload,  List<String> exclude,  String transport)  $default,) {final _that = this;
switch (_that) {
case _SendConfig():
return $default(_that.curve,_that.hashAlgorithm,_that.noCompress,_that.overwrite,_that.zipFolder,_that.gitIgnore,_that.onlyLocal,_that.disableLocal,_that.showQrCode,_that.copyCodeToClipboard,_that.codePhrase,_that.socks5Proxy,_that.httpProxy,_that.throttleUpload,_that.exclude,_that.transport);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String curve,  String hashAlgorithm,  bool noCompress,  bool overwrite,  bool zipFolder,  bool gitIgnore,  bool onlyLocal,  bool disableLocal,  bool showQrCode,  bool copyCodeToClipboard,  String codePhrase,  String socks5Proxy,  String httpProxy,  String throttleUpload,  List<String> exclude,  String transport)?  $default,) {final _that = this;
switch (_that) {
case _SendConfig() when $default != null:
return $default(_that.curve,_that.hashAlgorithm,_that.noCompress,_that.overwrite,_that.zipFolder,_that.gitIgnore,_that.onlyLocal,_that.disableLocal,_that.showQrCode,_that.copyCodeToClipboard,_that.codePhrase,_that.socks5Proxy,_that.httpProxy,_that.throttleUpload,_that.exclude,_that.transport);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SendConfig implements SendConfig {
  const _SendConfig({this.curve = defaultCurve, this.hashAlgorithm = defaultHashAlgorithm, this.noCompress = false, this.overwrite = false, this.zipFolder = false, this.gitIgnore = false, this.onlyLocal = false, this.disableLocal = false, this.showQrCode = false, this.copyCodeToClipboard = false, this.codePhrase = '', this.socks5Proxy = '', this.httpProxy = '', this.throttleUpload = '',  List<String> exclude = const <String>[], this.transport = 'auto'}): _exclude = exclude;
  factory _SendConfig.fromJson(Map<String, dynamic> json) => _$SendConfigFromJson(json);

@override@JsonKey() final  String curve;
@override@JsonKey() final  String hashAlgorithm;
@override@JsonKey() final  bool noCompress;
@override@JsonKey() final  bool overwrite;
@override@JsonKey() final  bool zipFolder;
@override@JsonKey() final  bool gitIgnore;
@override@JsonKey() final  bool onlyLocal;
@override@JsonKey() final  bool disableLocal;
@override@JsonKey() final  bool showQrCode;
/// Opt-in: let croc copy the share code to the OS clipboard.
///
/// Defaults to false — a GUI must not silently overwrite the user's
/// clipboard. (Replaces the old `disableClipboard` flag, which defaulted to
/// false and therefore kept hijacking the clipboard after upgrading.)
@override@JsonKey() final  bool copyCodeToClipboard;
@override@JsonKey() final  String codePhrase;
@override@JsonKey() final  String socks5Proxy;
@override@JsonKey() final  String httpProxy;
@override@JsonKey() final  String throttleUpload;
 final  List<String> _exclude;
@override@JsonKey() List<String> get exclude {
  if (_exclude is EqualUnmodifiableListView) return _exclude;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exclude);
}

/// Sender file-data channel: `auto`, `derp` or `relay` (croc --transport).
@override@JsonKey() final  String transport;

/// Create a copy of SendConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendConfigCopyWith<_SendConfig> get copyWith => __$SendConfigCopyWithImpl<_SendConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SendConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendConfig&&(identical(other.curve, curve) || other.curve == curve)&&(identical(other.hashAlgorithm, hashAlgorithm) || other.hashAlgorithm == hashAlgorithm)&&(identical(other.noCompress, noCompress) || other.noCompress == noCompress)&&(identical(other.overwrite, overwrite) || other.overwrite == overwrite)&&(identical(other.zipFolder, zipFolder) || other.zipFolder == zipFolder)&&(identical(other.gitIgnore, gitIgnore) || other.gitIgnore == gitIgnore)&&(identical(other.onlyLocal, onlyLocal) || other.onlyLocal == onlyLocal)&&(identical(other.disableLocal, disableLocal) || other.disableLocal == disableLocal)&&(identical(other.showQrCode, showQrCode) || other.showQrCode == showQrCode)&&(identical(other.copyCodeToClipboard, copyCodeToClipboard) || other.copyCodeToClipboard == copyCodeToClipboard)&&(identical(other.codePhrase, codePhrase) || other.codePhrase == codePhrase)&&(identical(other.socks5Proxy, socks5Proxy) || other.socks5Proxy == socks5Proxy)&&(identical(other.httpProxy, httpProxy) || other.httpProxy == httpProxy)&&(identical(other.throttleUpload, throttleUpload) || other.throttleUpload == throttleUpload)&&const DeepCollectionEquality().equals(other.exclude, _exclude)&&(identical(other.transport, transport) || other.transport == transport));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,curve,hashAlgorithm,noCompress,overwrite,zipFolder,gitIgnore,onlyLocal,disableLocal,showQrCode,copyCodeToClipboard,codePhrase,socks5Proxy,httpProxy,throttleUpload,const DeepCollectionEquality().hash(_exclude),transport);
}

@override
String toString() {
    return 'SendConfig(curve: $curve, hashAlgorithm: $hashAlgorithm, noCompress: $noCompress, overwrite: $overwrite, zipFolder: $zipFolder, gitIgnore: $gitIgnore, onlyLocal: $onlyLocal, disableLocal: $disableLocal, showQrCode: $showQrCode, copyCodeToClipboard: $copyCodeToClipboard, codePhrase: $codePhrase, socks5Proxy: $socks5Proxy, httpProxy: $httpProxy, throttleUpload: $throttleUpload, exclude: $exclude, transport: $transport)';
}


}

/// @nodoc
abstract mixin class _$SendConfigCopyWith<$Res> implements $SendConfigCopyWith<$Res> {
  factory _$SendConfigCopyWith(_SendConfig value, $Res Function(_SendConfig) _then) = __$SendConfigCopyWithImpl;
@override @useResult
$Res call({
 String curve, String hashAlgorithm, bool noCompress, bool overwrite, bool zipFolder, bool gitIgnore, bool onlyLocal, bool disableLocal, bool showQrCode, bool copyCodeToClipboard, String codePhrase, String socks5Proxy, String httpProxy, String throttleUpload, List<String> exclude, String transport
});




}
/// @nodoc
class __$SendConfigCopyWithImpl<$Res>
    implements _$SendConfigCopyWith<$Res> {
  __$SendConfigCopyWithImpl(this._self, this._then);

  final _SendConfig _self;
  final $Res Function(_SendConfig) _then;

/// Create a copy of SendConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? curve = null,Object? hashAlgorithm = null,Object? noCompress = null,Object? overwrite = null,Object? zipFolder = null,Object? gitIgnore = null,Object? onlyLocal = null,Object? disableLocal = null,Object? showQrCode = null,Object? copyCodeToClipboard = null,Object? codePhrase = null,Object? socks5Proxy = null,Object? httpProxy = null,Object? throttleUpload = null,Object? exclude = null,Object? transport = null,}) {
  return _then(_SendConfig(
curve: null == curve ? _self.curve : curve // ignore: cast_nullable_to_non_nullable
as String,hashAlgorithm: null == hashAlgorithm ? _self.hashAlgorithm : hashAlgorithm // ignore: cast_nullable_to_non_nullable
as String,noCompress: null == noCompress ? _self.noCompress : noCompress // ignore: cast_nullable_to_non_nullable
as bool,overwrite: null == overwrite ? _self.overwrite : overwrite // ignore: cast_nullable_to_non_nullable
as bool,zipFolder: null == zipFolder ? _self.zipFolder : zipFolder // ignore: cast_nullable_to_non_nullable
as bool,gitIgnore: null == gitIgnore ? _self.gitIgnore : gitIgnore // ignore: cast_nullable_to_non_nullable
as bool,onlyLocal: null == onlyLocal ? _self.onlyLocal : onlyLocal // ignore: cast_nullable_to_non_nullable
as bool,disableLocal: null == disableLocal ? _self.disableLocal : disableLocal // ignore: cast_nullable_to_non_nullable
as bool,showQrCode: null == showQrCode ? _self.showQrCode : showQrCode // ignore: cast_nullable_to_non_nullable
as bool,copyCodeToClipboard: null == copyCodeToClipboard ? _self.copyCodeToClipboard : copyCodeToClipboard // ignore: cast_nullable_to_non_nullable
as bool,codePhrase: null == codePhrase ? _self.codePhrase : codePhrase // ignore: cast_nullable_to_non_nullable
as String,socks5Proxy: null == socks5Proxy ? _self.socks5Proxy : socks5Proxy // ignore: cast_nullable_to_non_nullable
as String,httpProxy: null == httpProxy ? _self.httpProxy : httpProxy // ignore: cast_nullable_to_non_nullable
as String,throttleUpload: null == throttleUpload ? _self.throttleUpload : throttleUpload // ignore: cast_nullable_to_non_nullable
as String,exclude: null == exclude ? _self._exclude : exclude // ignore: cast_nullable_to_non_nullable
as List<String>,transport: null == transport ? _self.transport : transport // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ReceiveConfig {

 bool get overwrite;/// Save under an unused name when the destination already exists.
/// Defaults to true — croc's overwrite prompt cannot be answered without a
/// stdin, and the empty answer used to make it skip the file entirely.
 bool get rename; bool get onlyLocal; String get outputPath; String get socks5Proxy; String get httpProxy;
/// Create a copy of ReceiveConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiveConfigCopyWith<ReceiveConfig> get copyWith => _$ReceiveConfigCopyWithImpl<ReceiveConfig>(this as ReceiveConfig, _$identity);

  /// Serializes this ReceiveConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReceiveConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiveConfig&&(identical(other.overwrite, _this.overwrite) || other.overwrite == _this.overwrite)&&(identical(other.rename, _this.rename) || other.rename == _this.rename)&&(identical(other.onlyLocal, _this.onlyLocal) || other.onlyLocal == _this.onlyLocal)&&(identical(other.outputPath, _this.outputPath) || other.outputPath == _this.outputPath)&&(identical(other.socks5Proxy, _this.socks5Proxy) || other.socks5Proxy == _this.socks5Proxy)&&(identical(other.httpProxy, _this.httpProxy) || other.httpProxy == _this.httpProxy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReceiveConfig;
  return Object.hash(runtimeType,_this.overwrite,_this.rename,_this.onlyLocal,_this.outputPath,_this.socks5Proxy,_this.httpProxy);
}

@override
String toString() {
  final _this = this as ReceiveConfig;
  return 'ReceiveConfig(overwrite: ${_this.overwrite}, rename: ${_this.rename}, onlyLocal: ${_this.onlyLocal}, outputPath: ${_this.outputPath}, socks5Proxy: ${_this.socks5Proxy}, httpProxy: ${_this.httpProxy})';
}


}

/// @nodoc
abstract mixin class $ReceiveConfigCopyWith<$Res>  {
  factory $ReceiveConfigCopyWith(ReceiveConfig value, $Res Function(ReceiveConfig) _then) = _$ReceiveConfigCopyWithImpl;
@useResult
$Res call({
 bool overwrite, bool rename, bool onlyLocal, String outputPath, String socks5Proxy, String httpProxy
});




}
/// @nodoc
class _$ReceiveConfigCopyWithImpl<$Res>
    implements $ReceiveConfigCopyWith<$Res> {
  _$ReceiveConfigCopyWithImpl(this._self, this._then);

  final ReceiveConfig _self;
  final $Res Function(ReceiveConfig) _then;

/// Create a copy of ReceiveConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? overwrite = null,Object? rename = null,Object? onlyLocal = null,Object? outputPath = null,Object? socks5Proxy = null,Object? httpProxy = null,}) {
  return _then(ReceiveConfig(
overwrite: null == overwrite ? _self.overwrite : overwrite // ignore: cast_nullable_to_non_nullable
as bool,rename: null == rename ? _self.rename : rename // ignore: cast_nullable_to_non_nullable
as bool,onlyLocal: null == onlyLocal ? _self.onlyLocal : onlyLocal // ignore: cast_nullable_to_non_nullable
as bool,outputPath: null == outputPath ? _self.outputPath : outputPath // ignore: cast_nullable_to_non_nullable
as String,socks5Proxy: null == socks5Proxy ? _self.socks5Proxy : socks5Proxy // ignore: cast_nullable_to_non_nullable
as String,httpProxy: null == httpProxy ? _self.httpProxy : httpProxy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReceiveConfig].
extension ReceiveConfigPatterns on ReceiveConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceiveConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceiveConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceiveConfig value)  $default,){
final _that = this;
switch (_that) {
case _ReceiveConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceiveConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ReceiveConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool overwrite,  bool rename,  bool onlyLocal,  String outputPath,  String socks5Proxy,  String httpProxy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceiveConfig() when $default != null:
return $default(_that.overwrite,_that.rename,_that.onlyLocal,_that.outputPath,_that.socks5Proxy,_that.httpProxy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool overwrite,  bool rename,  bool onlyLocal,  String outputPath,  String socks5Proxy,  String httpProxy)  $default,) {final _that = this;
switch (_that) {
case _ReceiveConfig():
return $default(_that.overwrite,_that.rename,_that.onlyLocal,_that.outputPath,_that.socks5Proxy,_that.httpProxy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool overwrite,  bool rename,  bool onlyLocal,  String outputPath,  String socks5Proxy,  String httpProxy)?  $default,) {final _that = this;
switch (_that) {
case _ReceiveConfig() when $default != null:
return $default(_that.overwrite,_that.rename,_that.onlyLocal,_that.outputPath,_that.socks5Proxy,_that.httpProxy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReceiveConfig implements ReceiveConfig {
  const _ReceiveConfig({this.overwrite = false, this.rename = true, this.onlyLocal = false, this.outputPath = '', this.socks5Proxy = '', this.httpProxy = ''});
  factory _ReceiveConfig.fromJson(Map<String, dynamic> json) => _$ReceiveConfigFromJson(json);

@override@JsonKey() final  bool overwrite;
/// Save under an unused name when the destination already exists.
/// Defaults to true — croc's overwrite prompt cannot be answered without a
/// stdin, and the empty answer used to make it skip the file entirely.
@override@JsonKey() final  bool rename;
@override@JsonKey() final  bool onlyLocal;
@override@JsonKey() final  String outputPath;
@override@JsonKey() final  String socks5Proxy;
@override@JsonKey() final  String httpProxy;

/// Create a copy of ReceiveConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiveConfigCopyWith<_ReceiveConfig> get copyWith => __$ReceiveConfigCopyWithImpl<_ReceiveConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiveConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceiveConfig&&(identical(other.overwrite, overwrite) || other.overwrite == overwrite)&&(identical(other.rename, rename) || other.rename == rename)&&(identical(other.onlyLocal, onlyLocal) || other.onlyLocal == onlyLocal)&&(identical(other.outputPath, outputPath) || other.outputPath == outputPath)&&(identical(other.socks5Proxy, socks5Proxy) || other.socks5Proxy == socks5Proxy)&&(identical(other.httpProxy, httpProxy) || other.httpProxy == httpProxy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,overwrite,rename,onlyLocal,outputPath,socks5Proxy,httpProxy);
}

@override
String toString() {
    return 'ReceiveConfig(overwrite: $overwrite, rename: $rename, onlyLocal: $onlyLocal, outputPath: $outputPath, socks5Proxy: $socks5Proxy, httpProxy: $httpProxy)';
}


}

/// @nodoc
abstract mixin class _$ReceiveConfigCopyWith<$Res> implements $ReceiveConfigCopyWith<$Res> {
  factory _$ReceiveConfigCopyWith(_ReceiveConfig value, $Res Function(_ReceiveConfig) _then) = __$ReceiveConfigCopyWithImpl;
@override @useResult
$Res call({
 bool overwrite, bool rename, bool onlyLocal, String outputPath, String socks5Proxy, String httpProxy
});




}
/// @nodoc
class __$ReceiveConfigCopyWithImpl<$Res>
    implements _$ReceiveConfigCopyWith<$Res> {
  __$ReceiveConfigCopyWithImpl(this._self, this._then);

  final _ReceiveConfig _self;
  final $Res Function(_ReceiveConfig) _then;

/// Create a copy of ReceiveConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? overwrite = null,Object? rename = null,Object? onlyLocal = null,Object? outputPath = null,Object? socks5Proxy = null,Object? httpProxy = null,}) {
  return _then(_ReceiveConfig(
overwrite: null == overwrite ? _self.overwrite : overwrite // ignore: cast_nullable_to_non_nullable
as bool,rename: null == rename ? _self.rename : rename // ignore: cast_nullable_to_non_nullable
as bool,onlyLocal: null == onlyLocal ? _self.onlyLocal : onlyLocal // ignore: cast_nullable_to_non_nullable
as bool,outputPath: null == outputPath ? _self.outputPath : outputPath // ignore: cast_nullable_to_non_nullable
as String,socks5Proxy: null == socks5Proxy ? _self.socks5Proxy : socks5Proxy // ignore: cast_nullable_to_non_nullable
as String,httpProxy: null == httpProxy ? _self.httpProxy : httpProxy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
