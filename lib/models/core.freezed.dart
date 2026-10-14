// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'core.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SendOptions {

 List<String> get filePaths; String? get codePhrase; String get curve; String get hashAlgorithm; bool get noCompress; bool get overwrite; bool get zipFolder; bool get gitIgnore; bool get onlyLocal; bool get disableLocal; bool get sendingText; String get textContent; String get tempDir; String get socks5Proxy; String get httpProxy; String get throttleUpload; List<String> get exclude;/// When true (the default) croc must not write the share code into the OS
/// clipboard. croc's CLI does that unconditionally while printing its
/// instructions, which clobbers whatever the user had copied.
 bool get disableClipboard;/// Sender file-data channel: `auto` (default), `derp` (prefer the direct
/// Tailcat/WireGuard path) or `relay`. Sender-only — croc rejects any
/// non-auto value on the receiving side.
 String get transport; String? get relayAddress; String? get relayAddress6; String? get relayPassword; String? get relayPorts;
/// Create a copy of SendOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendOptionsCopyWith<SendOptions> get copyWith => _$SendOptionsCopyWithImpl<SendOptions>(this as SendOptions, _$identity);

  /// Serializes this SendOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SendOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendOptions&&const DeepCollectionEquality().equals(other.filePaths, _this.filePaths)&&(identical(other.codePhrase, _this.codePhrase) || other.codePhrase == _this.codePhrase)&&(identical(other.curve, _this.curve) || other.curve == _this.curve)&&(identical(other.hashAlgorithm, _this.hashAlgorithm) || other.hashAlgorithm == _this.hashAlgorithm)&&(identical(other.noCompress, _this.noCompress) || other.noCompress == _this.noCompress)&&(identical(other.overwrite, _this.overwrite) || other.overwrite == _this.overwrite)&&(identical(other.zipFolder, _this.zipFolder) || other.zipFolder == _this.zipFolder)&&(identical(other.gitIgnore, _this.gitIgnore) || other.gitIgnore == _this.gitIgnore)&&(identical(other.onlyLocal, _this.onlyLocal) || other.onlyLocal == _this.onlyLocal)&&(identical(other.disableLocal, _this.disableLocal) || other.disableLocal == _this.disableLocal)&&(identical(other.sendingText, _this.sendingText) || other.sendingText == _this.sendingText)&&(identical(other.textContent, _this.textContent) || other.textContent == _this.textContent)&&(identical(other.tempDir, _this.tempDir) || other.tempDir == _this.tempDir)&&(identical(other.socks5Proxy, _this.socks5Proxy) || other.socks5Proxy == _this.socks5Proxy)&&(identical(other.httpProxy, _this.httpProxy) || other.httpProxy == _this.httpProxy)&&(identical(other.throttleUpload, _this.throttleUpload) || other.throttleUpload == _this.throttleUpload)&&const DeepCollectionEquality().equals(other.exclude, _this.exclude)&&(identical(other.disableClipboard, _this.disableClipboard) || other.disableClipboard == _this.disableClipboard)&&(identical(other.transport, _this.transport) || other.transport == _this.transport)&&(identical(other.relayAddress, _this.relayAddress) || other.relayAddress == _this.relayAddress)&&(identical(other.relayAddress6, _this.relayAddress6) || other.relayAddress6 == _this.relayAddress6)&&(identical(other.relayPassword, _this.relayPassword) || other.relayPassword == _this.relayPassword)&&(identical(other.relayPorts, _this.relayPorts) || other.relayPorts == _this.relayPorts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SendOptions;
  return Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_this.filePaths),_this.codePhrase,_this.curve,_this.hashAlgorithm,_this.noCompress,_this.overwrite,_this.zipFolder,_this.gitIgnore,_this.onlyLocal,_this.disableLocal,_this.sendingText,_this.textContent,_this.tempDir,_this.socks5Proxy,_this.httpProxy,_this.throttleUpload,const DeepCollectionEquality().hash(_this.exclude),_this.disableClipboard,_this.transport,_this.relayAddress,_this.relayAddress6,_this.relayPassword,_this.relayPorts]);
}

@override
String toString() {
  final _this = this as SendOptions;
  return 'SendOptions(filePaths: ${_this.filePaths}, codePhrase: ${_this.codePhrase}, curve: ${_this.curve}, hashAlgorithm: ${_this.hashAlgorithm}, noCompress: ${_this.noCompress}, overwrite: ${_this.overwrite}, zipFolder: ${_this.zipFolder}, gitIgnore: ${_this.gitIgnore}, onlyLocal: ${_this.onlyLocal}, disableLocal: ${_this.disableLocal}, sendingText: ${_this.sendingText}, textContent: ${_this.textContent}, tempDir: ${_this.tempDir}, socks5Proxy: ${_this.socks5Proxy}, httpProxy: ${_this.httpProxy}, throttleUpload: ${_this.throttleUpload}, exclude: ${_this.exclude}, disableClipboard: ${_this.disableClipboard}, transport: ${_this.transport}, relayAddress: ${_this.relayAddress}, relayAddress6: ${_this.relayAddress6}, relayPassword: ${_this.relayPassword}, relayPorts: ${_this.relayPorts})';
}


}

/// @nodoc
abstract mixin class $SendOptionsCopyWith<$Res>  {
  factory $SendOptionsCopyWith(SendOptions value, $Res Function(SendOptions) _then) = _$SendOptionsCopyWithImpl;
@useResult
$Res call({
 List<String> filePaths, String? codePhrase, String curve, String hashAlgorithm, bool noCompress, bool overwrite, bool zipFolder, bool gitIgnore, bool onlyLocal, bool disableLocal, bool sendingText, String textContent, String tempDir, String socks5Proxy, String httpProxy, String throttleUpload, List<String> exclude, bool disableClipboard, String transport, String? relayAddress, String? relayAddress6, String? relayPassword, String? relayPorts
});




}
/// @nodoc
class _$SendOptionsCopyWithImpl<$Res>
    implements $SendOptionsCopyWith<$Res> {
  _$SendOptionsCopyWithImpl(this._self, this._then);

  final SendOptions _self;
  final $Res Function(SendOptions) _then;

/// Create a copy of SendOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filePaths = null,Object? codePhrase = freezed,Object? curve = null,Object? hashAlgorithm = null,Object? noCompress = null,Object? overwrite = null,Object? zipFolder = null,Object? gitIgnore = null,Object? onlyLocal = null,Object? disableLocal = null,Object? sendingText = null,Object? textContent = null,Object? tempDir = null,Object? socks5Proxy = null,Object? httpProxy = null,Object? throttleUpload = null,Object? exclude = null,Object? disableClipboard = null,Object? transport = null,Object? relayAddress = freezed,Object? relayAddress6 = freezed,Object? relayPassword = freezed,Object? relayPorts = freezed,}) {
  return _then(SendOptions(
filePaths: null == filePaths ? _self.filePaths : filePaths // ignore: cast_nullable_to_non_nullable
as List<String>,codePhrase: freezed == codePhrase ? _self.codePhrase : codePhrase // ignore: cast_nullable_to_non_nullable
as String?,curve: null == curve ? _self.curve : curve // ignore: cast_nullable_to_non_nullable
as String,hashAlgorithm: null == hashAlgorithm ? _self.hashAlgorithm : hashAlgorithm // ignore: cast_nullable_to_non_nullable
as String,noCompress: null == noCompress ? _self.noCompress : noCompress // ignore: cast_nullable_to_non_nullable
as bool,overwrite: null == overwrite ? _self.overwrite : overwrite // ignore: cast_nullable_to_non_nullable
as bool,zipFolder: null == zipFolder ? _self.zipFolder : zipFolder // ignore: cast_nullable_to_non_nullable
as bool,gitIgnore: null == gitIgnore ? _self.gitIgnore : gitIgnore // ignore: cast_nullable_to_non_nullable
as bool,onlyLocal: null == onlyLocal ? _self.onlyLocal : onlyLocal // ignore: cast_nullable_to_non_nullable
as bool,disableLocal: null == disableLocal ? _self.disableLocal : disableLocal // ignore: cast_nullable_to_non_nullable
as bool,sendingText: null == sendingText ? _self.sendingText : sendingText // ignore: cast_nullable_to_non_nullable
as bool,textContent: null == textContent ? _self.textContent : textContent // ignore: cast_nullable_to_non_nullable
as String,tempDir: null == tempDir ? _self.tempDir : tempDir // ignore: cast_nullable_to_non_nullable
as String,socks5Proxy: null == socks5Proxy ? _self.socks5Proxy : socks5Proxy // ignore: cast_nullable_to_non_nullable
as String,httpProxy: null == httpProxy ? _self.httpProxy : httpProxy // ignore: cast_nullable_to_non_nullable
as String,throttleUpload: null == throttleUpload ? _self.throttleUpload : throttleUpload // ignore: cast_nullable_to_non_nullable
as String,exclude: null == exclude ? _self.exclude : exclude // ignore: cast_nullable_to_non_nullable
as List<String>,disableClipboard: null == disableClipboard ? _self.disableClipboard : disableClipboard // ignore: cast_nullable_to_non_nullable
as bool,transport: null == transport ? _self.transport : transport // ignore: cast_nullable_to_non_nullable
as String,relayAddress: freezed == relayAddress ? _self.relayAddress : relayAddress // ignore: cast_nullable_to_non_nullable
as String?,relayAddress6: freezed == relayAddress6 ? _self.relayAddress6 : relayAddress6 // ignore: cast_nullable_to_non_nullable
as String?,relayPassword: freezed == relayPassword ? _self.relayPassword : relayPassword // ignore: cast_nullable_to_non_nullable
as String?,relayPorts: freezed == relayPorts ? _self.relayPorts : relayPorts // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SendOptions].
extension SendOptionsPatterns on SendOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SendOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SendOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SendOptions value)  $default,){
final _that = this;
switch (_that) {
case _SendOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SendOptions value)?  $default,){
final _that = this;
switch (_that) {
case _SendOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> filePaths,  String? codePhrase,  String curve,  String hashAlgorithm,  bool noCompress,  bool overwrite,  bool zipFolder,  bool gitIgnore,  bool onlyLocal,  bool disableLocal,  bool sendingText,  String textContent,  String tempDir,  String socks5Proxy,  String httpProxy,  String throttleUpload,  List<String> exclude,  bool disableClipboard,  String transport,  String? relayAddress,  String? relayAddress6,  String? relayPassword,  String? relayPorts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SendOptions() when $default != null:
return $default(_that.filePaths,_that.codePhrase,_that.curve,_that.hashAlgorithm,_that.noCompress,_that.overwrite,_that.zipFolder,_that.gitIgnore,_that.onlyLocal,_that.disableLocal,_that.sendingText,_that.textContent,_that.tempDir,_that.socks5Proxy,_that.httpProxy,_that.throttleUpload,_that.exclude,_that.disableClipboard,_that.transport,_that.relayAddress,_that.relayAddress6,_that.relayPassword,_that.relayPorts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> filePaths,  String? codePhrase,  String curve,  String hashAlgorithm,  bool noCompress,  bool overwrite,  bool zipFolder,  bool gitIgnore,  bool onlyLocal,  bool disableLocal,  bool sendingText,  String textContent,  String tempDir,  String socks5Proxy,  String httpProxy,  String throttleUpload,  List<String> exclude,  bool disableClipboard,  String transport,  String? relayAddress,  String? relayAddress6,  String? relayPassword,  String? relayPorts)  $default,) {final _that = this;
switch (_that) {
case _SendOptions():
return $default(_that.filePaths,_that.codePhrase,_that.curve,_that.hashAlgorithm,_that.noCompress,_that.overwrite,_that.zipFolder,_that.gitIgnore,_that.onlyLocal,_that.disableLocal,_that.sendingText,_that.textContent,_that.tempDir,_that.socks5Proxy,_that.httpProxy,_that.throttleUpload,_that.exclude,_that.disableClipboard,_that.transport,_that.relayAddress,_that.relayAddress6,_that.relayPassword,_that.relayPorts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> filePaths,  String? codePhrase,  String curve,  String hashAlgorithm,  bool noCompress,  bool overwrite,  bool zipFolder,  bool gitIgnore,  bool onlyLocal,  bool disableLocal,  bool sendingText,  String textContent,  String tempDir,  String socks5Proxy,  String httpProxy,  String throttleUpload,  List<String> exclude,  bool disableClipboard,  String transport,  String? relayAddress,  String? relayAddress6,  String? relayPassword,  String? relayPorts)?  $default,) {final _that = this;
switch (_that) {
case _SendOptions() when $default != null:
return $default(_that.filePaths,_that.codePhrase,_that.curve,_that.hashAlgorithm,_that.noCompress,_that.overwrite,_that.zipFolder,_that.gitIgnore,_that.onlyLocal,_that.disableLocal,_that.sendingText,_that.textContent,_that.tempDir,_that.socks5Proxy,_that.httpProxy,_that.throttleUpload,_that.exclude,_that.disableClipboard,_that.transport,_that.relayAddress,_that.relayAddress6,_that.relayPassword,_that.relayPorts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SendOptions implements SendOptions {
  const _SendOptions({required  List<String> filePaths, this.codePhrase, this.curve = 'p256', this.hashAlgorithm = 'xxhash', this.noCompress = false, this.overwrite = false, this.zipFolder = false, this.gitIgnore = false, this.onlyLocal = false, this.disableLocal = false, this.sendingText = false, this.textContent = '', this.tempDir = '', this.socks5Proxy = '', this.httpProxy = '', this.throttleUpload = '',  List<String> exclude = const <String>[], this.disableClipboard = true, this.transport = 'auto', this.relayAddress, this.relayAddress6, this.relayPassword, this.relayPorts}): _filePaths = filePaths,_exclude = exclude;
  factory _SendOptions.fromJson(Map<String, dynamic> json) => _$SendOptionsFromJson(json);

 final  List<String> _filePaths;
@override List<String> get filePaths {
  if (_filePaths is EqualUnmodifiableListView) return _filePaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filePaths);
}

@override final  String? codePhrase;
@override@JsonKey() final  String curve;
@override@JsonKey() final  String hashAlgorithm;
@override@JsonKey() final  bool noCompress;
@override@JsonKey() final  bool overwrite;
@override@JsonKey() final  bool zipFolder;
@override@JsonKey() final  bool gitIgnore;
@override@JsonKey() final  bool onlyLocal;
@override@JsonKey() final  bool disableLocal;
@override@JsonKey() final  bool sendingText;
@override@JsonKey() final  String textContent;
@override@JsonKey() final  String tempDir;
@override@JsonKey() final  String socks5Proxy;
@override@JsonKey() final  String httpProxy;
@override@JsonKey() final  String throttleUpload;
 final  List<String> _exclude;
@override@JsonKey() List<String> get exclude {
  if (_exclude is EqualUnmodifiableListView) return _exclude;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exclude);
}

/// When true (the default) croc must not write the share code into the OS
/// clipboard. croc's CLI does that unconditionally while printing its
/// instructions, which clobbers whatever the user had copied.
@override@JsonKey() final  bool disableClipboard;
/// Sender file-data channel: `auto` (default), `derp` (prefer the direct
/// Tailcat/WireGuard path) or `relay`. Sender-only — croc rejects any
/// non-auto value on the receiving side.
@override@JsonKey() final  String transport;
@override final  String? relayAddress;
@override final  String? relayAddress6;
@override final  String? relayPassword;
@override final  String? relayPorts;

/// Create a copy of SendOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendOptionsCopyWith<_SendOptions> get copyWith => __$SendOptionsCopyWithImpl<_SendOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SendOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendOptions&&const DeepCollectionEquality().equals(other.filePaths, _filePaths)&&(identical(other.codePhrase, codePhrase) || other.codePhrase == codePhrase)&&(identical(other.curve, curve) || other.curve == curve)&&(identical(other.hashAlgorithm, hashAlgorithm) || other.hashAlgorithm == hashAlgorithm)&&(identical(other.noCompress, noCompress) || other.noCompress == noCompress)&&(identical(other.overwrite, overwrite) || other.overwrite == overwrite)&&(identical(other.zipFolder, zipFolder) || other.zipFolder == zipFolder)&&(identical(other.gitIgnore, gitIgnore) || other.gitIgnore == gitIgnore)&&(identical(other.onlyLocal, onlyLocal) || other.onlyLocal == onlyLocal)&&(identical(other.disableLocal, disableLocal) || other.disableLocal == disableLocal)&&(identical(other.sendingText, sendingText) || other.sendingText == sendingText)&&(identical(other.textContent, textContent) || other.textContent == textContent)&&(identical(other.tempDir, tempDir) || other.tempDir == tempDir)&&(identical(other.socks5Proxy, socks5Proxy) || other.socks5Proxy == socks5Proxy)&&(identical(other.httpProxy, httpProxy) || other.httpProxy == httpProxy)&&(identical(other.throttleUpload, throttleUpload) || other.throttleUpload == throttleUpload)&&const DeepCollectionEquality().equals(other.exclude, _exclude)&&(identical(other.disableClipboard, disableClipboard) || other.disableClipboard == disableClipboard)&&(identical(other.transport, transport) || other.transport == transport)&&(identical(other.relayAddress, relayAddress) || other.relayAddress == relayAddress)&&(identical(other.relayAddress6, relayAddress6) || other.relayAddress6 == relayAddress6)&&(identical(other.relayPassword, relayPassword) || other.relayPassword == relayPassword)&&(identical(other.relayPorts, relayPorts) || other.relayPorts == relayPorts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_filePaths),codePhrase,curve,hashAlgorithm,noCompress,overwrite,zipFolder,gitIgnore,onlyLocal,disableLocal,sendingText,textContent,tempDir,socks5Proxy,httpProxy,throttleUpload,const DeepCollectionEquality().hash(_exclude),disableClipboard,transport,relayAddress,relayAddress6,relayPassword,relayPorts]);
}

@override
String toString() {
    return 'SendOptions(filePaths: $filePaths, codePhrase: $codePhrase, curve: $curve, hashAlgorithm: $hashAlgorithm, noCompress: $noCompress, overwrite: $overwrite, zipFolder: $zipFolder, gitIgnore: $gitIgnore, onlyLocal: $onlyLocal, disableLocal: $disableLocal, sendingText: $sendingText, textContent: $textContent, tempDir: $tempDir, socks5Proxy: $socks5Proxy, httpProxy: $httpProxy, throttleUpload: $throttleUpload, exclude: $exclude, disableClipboard: $disableClipboard, transport: $transport, relayAddress: $relayAddress, relayAddress6: $relayAddress6, relayPassword: $relayPassword, relayPorts: $relayPorts)';
}


}

/// @nodoc
abstract mixin class _$SendOptionsCopyWith<$Res> implements $SendOptionsCopyWith<$Res> {
  factory _$SendOptionsCopyWith(_SendOptions value, $Res Function(_SendOptions) _then) = __$SendOptionsCopyWithImpl;
@override @useResult
$Res call({
 List<String> filePaths, String? codePhrase, String curve, String hashAlgorithm, bool noCompress, bool overwrite, bool zipFolder, bool gitIgnore, bool onlyLocal, bool disableLocal, bool sendingText, String textContent, String tempDir, String socks5Proxy, String httpProxy, String throttleUpload, List<String> exclude, bool disableClipboard, String transport, String? relayAddress, String? relayAddress6, String? relayPassword, String? relayPorts
});




}
/// @nodoc
class __$SendOptionsCopyWithImpl<$Res>
    implements _$SendOptionsCopyWith<$Res> {
  __$SendOptionsCopyWithImpl(this._self, this._then);

  final _SendOptions _self;
  final $Res Function(_SendOptions) _then;

/// Create a copy of SendOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filePaths = null,Object? codePhrase = freezed,Object? curve = null,Object? hashAlgorithm = null,Object? noCompress = null,Object? overwrite = null,Object? zipFolder = null,Object? gitIgnore = null,Object? onlyLocal = null,Object? disableLocal = null,Object? sendingText = null,Object? textContent = null,Object? tempDir = null,Object? socks5Proxy = null,Object? httpProxy = null,Object? throttleUpload = null,Object? exclude = null,Object? disableClipboard = null,Object? transport = null,Object? relayAddress = freezed,Object? relayAddress6 = freezed,Object? relayPassword = freezed,Object? relayPorts = freezed,}) {
  return _then(_SendOptions(
filePaths: null == filePaths ? _self._filePaths : filePaths // ignore: cast_nullable_to_non_nullable
as List<String>,codePhrase: freezed == codePhrase ? _self.codePhrase : codePhrase // ignore: cast_nullable_to_non_nullable
as String?,curve: null == curve ? _self.curve : curve // ignore: cast_nullable_to_non_nullable
as String,hashAlgorithm: null == hashAlgorithm ? _self.hashAlgorithm : hashAlgorithm // ignore: cast_nullable_to_non_nullable
as String,noCompress: null == noCompress ? _self.noCompress : noCompress // ignore: cast_nullable_to_non_nullable
as bool,overwrite: null == overwrite ? _self.overwrite : overwrite // ignore: cast_nullable_to_non_nullable
as bool,zipFolder: null == zipFolder ? _self.zipFolder : zipFolder // ignore: cast_nullable_to_non_nullable
as bool,gitIgnore: null == gitIgnore ? _self.gitIgnore : gitIgnore // ignore: cast_nullable_to_non_nullable
as bool,onlyLocal: null == onlyLocal ? _self.onlyLocal : onlyLocal // ignore: cast_nullable_to_non_nullable
as bool,disableLocal: null == disableLocal ? _self.disableLocal : disableLocal // ignore: cast_nullable_to_non_nullable
as bool,sendingText: null == sendingText ? _self.sendingText : sendingText // ignore: cast_nullable_to_non_nullable
as bool,textContent: null == textContent ? _self.textContent : textContent // ignore: cast_nullable_to_non_nullable
as String,tempDir: null == tempDir ? _self.tempDir : tempDir // ignore: cast_nullable_to_non_nullable
as String,socks5Proxy: null == socks5Proxy ? _self.socks5Proxy : socks5Proxy // ignore: cast_nullable_to_non_nullable
as String,httpProxy: null == httpProxy ? _self.httpProxy : httpProxy // ignore: cast_nullable_to_non_nullable
as String,throttleUpload: null == throttleUpload ? _self.throttleUpload : throttleUpload // ignore: cast_nullable_to_non_nullable
as String,exclude: null == exclude ? _self._exclude : exclude // ignore: cast_nullable_to_non_nullable
as List<String>,disableClipboard: null == disableClipboard ? _self.disableClipboard : disableClipboard // ignore: cast_nullable_to_non_nullable
as bool,transport: null == transport ? _self.transport : transport // ignore: cast_nullable_to_non_nullable
as String,relayAddress: freezed == relayAddress ? _self.relayAddress : relayAddress // ignore: cast_nullable_to_non_nullable
as String?,relayAddress6: freezed == relayAddress6 ? _self.relayAddress6 : relayAddress6 // ignore: cast_nullable_to_non_nullable
as String?,relayPassword: freezed == relayPassword ? _self.relayPassword : relayPassword // ignore: cast_nullable_to_non_nullable
as String?,relayPorts: freezed == relayPorts ? _self.relayPorts : relayPorts // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ReceiveOptions {

 String get codePhrase; bool get overwrite; bool get onlyLocal; String get outputPath; String get curve;/// When the destination name is already taken, save under an unused name
/// instead of letting croc ask "(y/N) Overwrite?" on stdin. Defaults to
/// true: the GUI has no stdin, so croc used to read the empty answer as
/// "no" and silently skip the file.
 bool get rename; String get socks5Proxy; String get httpProxy; String? get relayAddress; String? get relayAddress6; String? get relayPassword; String? get relayPorts;
/// Create a copy of ReceiveOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiveOptionsCopyWith<ReceiveOptions> get copyWith => _$ReceiveOptionsCopyWithImpl<ReceiveOptions>(this as ReceiveOptions, _$identity);

  /// Serializes this ReceiveOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReceiveOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiveOptions&&(identical(other.codePhrase, _this.codePhrase) || other.codePhrase == _this.codePhrase)&&(identical(other.overwrite, _this.overwrite) || other.overwrite == _this.overwrite)&&(identical(other.onlyLocal, _this.onlyLocal) || other.onlyLocal == _this.onlyLocal)&&(identical(other.outputPath, _this.outputPath) || other.outputPath == _this.outputPath)&&(identical(other.curve, _this.curve) || other.curve == _this.curve)&&(identical(other.rename, _this.rename) || other.rename == _this.rename)&&(identical(other.socks5Proxy, _this.socks5Proxy) || other.socks5Proxy == _this.socks5Proxy)&&(identical(other.httpProxy, _this.httpProxy) || other.httpProxy == _this.httpProxy)&&(identical(other.relayAddress, _this.relayAddress) || other.relayAddress == _this.relayAddress)&&(identical(other.relayAddress6, _this.relayAddress6) || other.relayAddress6 == _this.relayAddress6)&&(identical(other.relayPassword, _this.relayPassword) || other.relayPassword == _this.relayPassword)&&(identical(other.relayPorts, _this.relayPorts) || other.relayPorts == _this.relayPorts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReceiveOptions;
  return Object.hash(runtimeType,_this.codePhrase,_this.overwrite,_this.onlyLocal,_this.outputPath,_this.curve,_this.rename,_this.socks5Proxy,_this.httpProxy,_this.relayAddress,_this.relayAddress6,_this.relayPassword,_this.relayPorts);
}

@override
String toString() {
  final _this = this as ReceiveOptions;
  return 'ReceiveOptions(codePhrase: ${_this.codePhrase}, overwrite: ${_this.overwrite}, onlyLocal: ${_this.onlyLocal}, outputPath: ${_this.outputPath}, curve: ${_this.curve}, rename: ${_this.rename}, socks5Proxy: ${_this.socks5Proxy}, httpProxy: ${_this.httpProxy}, relayAddress: ${_this.relayAddress}, relayAddress6: ${_this.relayAddress6}, relayPassword: ${_this.relayPassword}, relayPorts: ${_this.relayPorts})';
}


}

/// @nodoc
abstract mixin class $ReceiveOptionsCopyWith<$Res>  {
  factory $ReceiveOptionsCopyWith(ReceiveOptions value, $Res Function(ReceiveOptions) _then) = _$ReceiveOptionsCopyWithImpl;
@useResult
$Res call({
 String codePhrase, bool overwrite, bool onlyLocal, String outputPath, String curve, bool rename, String socks5Proxy, String httpProxy, String? relayAddress, String? relayAddress6, String? relayPassword, String? relayPorts
});




}
/// @nodoc
class _$ReceiveOptionsCopyWithImpl<$Res>
    implements $ReceiveOptionsCopyWith<$Res> {
  _$ReceiveOptionsCopyWithImpl(this._self, this._then);

  final ReceiveOptions _self;
  final $Res Function(ReceiveOptions) _then;

/// Create a copy of ReceiveOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? codePhrase = null,Object? overwrite = null,Object? onlyLocal = null,Object? outputPath = null,Object? curve = null,Object? rename = null,Object? socks5Proxy = null,Object? httpProxy = null,Object? relayAddress = freezed,Object? relayAddress6 = freezed,Object? relayPassword = freezed,Object? relayPorts = freezed,}) {
  return _then(ReceiveOptions(
codePhrase: null == codePhrase ? _self.codePhrase : codePhrase // ignore: cast_nullable_to_non_nullable
as String,overwrite: null == overwrite ? _self.overwrite : overwrite // ignore: cast_nullable_to_non_nullable
as bool,onlyLocal: null == onlyLocal ? _self.onlyLocal : onlyLocal // ignore: cast_nullable_to_non_nullable
as bool,outputPath: null == outputPath ? _self.outputPath : outputPath // ignore: cast_nullable_to_non_nullable
as String,curve: null == curve ? _self.curve : curve // ignore: cast_nullable_to_non_nullable
as String,rename: null == rename ? _self.rename : rename // ignore: cast_nullable_to_non_nullable
as bool,socks5Proxy: null == socks5Proxy ? _self.socks5Proxy : socks5Proxy // ignore: cast_nullable_to_non_nullable
as String,httpProxy: null == httpProxy ? _self.httpProxy : httpProxy // ignore: cast_nullable_to_non_nullable
as String,relayAddress: freezed == relayAddress ? _self.relayAddress : relayAddress // ignore: cast_nullable_to_non_nullable
as String?,relayAddress6: freezed == relayAddress6 ? _self.relayAddress6 : relayAddress6 // ignore: cast_nullable_to_non_nullable
as String?,relayPassword: freezed == relayPassword ? _self.relayPassword : relayPassword // ignore: cast_nullable_to_non_nullable
as String?,relayPorts: freezed == relayPorts ? _self.relayPorts : relayPorts // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReceiveOptions].
extension ReceiveOptionsPatterns on ReceiveOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceiveOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceiveOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceiveOptions value)  $default,){
final _that = this;
switch (_that) {
case _ReceiveOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceiveOptions value)?  $default,){
final _that = this;
switch (_that) {
case _ReceiveOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String codePhrase,  bool overwrite,  bool onlyLocal,  String outputPath,  String curve,  bool rename,  String socks5Proxy,  String httpProxy,  String? relayAddress,  String? relayAddress6,  String? relayPassword,  String? relayPorts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceiveOptions() when $default != null:
return $default(_that.codePhrase,_that.overwrite,_that.onlyLocal,_that.outputPath,_that.curve,_that.rename,_that.socks5Proxy,_that.httpProxy,_that.relayAddress,_that.relayAddress6,_that.relayPassword,_that.relayPorts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String codePhrase,  bool overwrite,  bool onlyLocal,  String outputPath,  String curve,  bool rename,  String socks5Proxy,  String httpProxy,  String? relayAddress,  String? relayAddress6,  String? relayPassword,  String? relayPorts)  $default,) {final _that = this;
switch (_that) {
case _ReceiveOptions():
return $default(_that.codePhrase,_that.overwrite,_that.onlyLocal,_that.outputPath,_that.curve,_that.rename,_that.socks5Proxy,_that.httpProxy,_that.relayAddress,_that.relayAddress6,_that.relayPassword,_that.relayPorts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String codePhrase,  bool overwrite,  bool onlyLocal,  String outputPath,  String curve,  bool rename,  String socks5Proxy,  String httpProxy,  String? relayAddress,  String? relayAddress6,  String? relayPassword,  String? relayPorts)?  $default,) {final _that = this;
switch (_that) {
case _ReceiveOptions() when $default != null:
return $default(_that.codePhrase,_that.overwrite,_that.onlyLocal,_that.outputPath,_that.curve,_that.rename,_that.socks5Proxy,_that.httpProxy,_that.relayAddress,_that.relayAddress6,_that.relayPassword,_that.relayPorts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReceiveOptions implements ReceiveOptions {
  const _ReceiveOptions({required this.codePhrase, this.overwrite = false, this.onlyLocal = false, this.outputPath = '', this.curve = 'p256', this.rename = true, this.socks5Proxy = '', this.httpProxy = '', this.relayAddress, this.relayAddress6, this.relayPassword, this.relayPorts});
  factory _ReceiveOptions.fromJson(Map<String, dynamic> json) => _$ReceiveOptionsFromJson(json);

@override final  String codePhrase;
@override@JsonKey() final  bool overwrite;
@override@JsonKey() final  bool onlyLocal;
@override@JsonKey() final  String outputPath;
@override@JsonKey() final  String curve;
/// When the destination name is already taken, save under an unused name
/// instead of letting croc ask "(y/N) Overwrite?" on stdin. Defaults to
/// true: the GUI has no stdin, so croc used to read the empty answer as
/// "no" and silently skip the file.
@override@JsonKey() final  bool rename;
@override@JsonKey() final  String socks5Proxy;
@override@JsonKey() final  String httpProxy;
@override final  String? relayAddress;
@override final  String? relayAddress6;
@override final  String? relayPassword;
@override final  String? relayPorts;

/// Create a copy of ReceiveOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiveOptionsCopyWith<_ReceiveOptions> get copyWith => __$ReceiveOptionsCopyWithImpl<_ReceiveOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiveOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceiveOptions&&(identical(other.codePhrase, codePhrase) || other.codePhrase == codePhrase)&&(identical(other.overwrite, overwrite) || other.overwrite == overwrite)&&(identical(other.onlyLocal, onlyLocal) || other.onlyLocal == onlyLocal)&&(identical(other.outputPath, outputPath) || other.outputPath == outputPath)&&(identical(other.curve, curve) || other.curve == curve)&&(identical(other.rename, rename) || other.rename == rename)&&(identical(other.socks5Proxy, socks5Proxy) || other.socks5Proxy == socks5Proxy)&&(identical(other.httpProxy, httpProxy) || other.httpProxy == httpProxy)&&(identical(other.relayAddress, relayAddress) || other.relayAddress == relayAddress)&&(identical(other.relayAddress6, relayAddress6) || other.relayAddress6 == relayAddress6)&&(identical(other.relayPassword, relayPassword) || other.relayPassword == relayPassword)&&(identical(other.relayPorts, relayPorts) || other.relayPorts == relayPorts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,codePhrase,overwrite,onlyLocal,outputPath,curve,rename,socks5Proxy,httpProxy,relayAddress,relayAddress6,relayPassword,relayPorts);
}

@override
String toString() {
    return 'ReceiveOptions(codePhrase: $codePhrase, overwrite: $overwrite, onlyLocal: $onlyLocal, outputPath: $outputPath, curve: $curve, rename: $rename, socks5Proxy: $socks5Proxy, httpProxy: $httpProxy, relayAddress: $relayAddress, relayAddress6: $relayAddress6, relayPassword: $relayPassword, relayPorts: $relayPorts)';
}


}

/// @nodoc
abstract mixin class _$ReceiveOptionsCopyWith<$Res> implements $ReceiveOptionsCopyWith<$Res> {
  factory _$ReceiveOptionsCopyWith(_ReceiveOptions value, $Res Function(_ReceiveOptions) _then) = __$ReceiveOptionsCopyWithImpl;
@override @useResult
$Res call({
 String codePhrase, bool overwrite, bool onlyLocal, String outputPath, String curve, bool rename, String socks5Proxy, String httpProxy, String? relayAddress, String? relayAddress6, String? relayPassword, String? relayPorts
});




}
/// @nodoc
class __$ReceiveOptionsCopyWithImpl<$Res>
    implements _$ReceiveOptionsCopyWith<$Res> {
  __$ReceiveOptionsCopyWithImpl(this._self, this._then);

  final _ReceiveOptions _self;
  final $Res Function(_ReceiveOptions) _then;

/// Create a copy of ReceiveOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? codePhrase = null,Object? overwrite = null,Object? onlyLocal = null,Object? outputPath = null,Object? curve = null,Object? rename = null,Object? socks5Proxy = null,Object? httpProxy = null,Object? relayAddress = freezed,Object? relayAddress6 = freezed,Object? relayPassword = freezed,Object? relayPorts = freezed,}) {
  return _then(_ReceiveOptions(
codePhrase: null == codePhrase ? _self.codePhrase : codePhrase // ignore: cast_nullable_to_non_nullable
as String,overwrite: null == overwrite ? _self.overwrite : overwrite // ignore: cast_nullable_to_non_nullable
as bool,onlyLocal: null == onlyLocal ? _self.onlyLocal : onlyLocal // ignore: cast_nullable_to_non_nullable
as bool,outputPath: null == outputPath ? _self.outputPath : outputPath // ignore: cast_nullable_to_non_nullable
as String,curve: null == curve ? _self.curve : curve // ignore: cast_nullable_to_non_nullable
as String,rename: null == rename ? _self.rename : rename // ignore: cast_nullable_to_non_nullable
as bool,socks5Proxy: null == socks5Proxy ? _self.socks5Proxy : socks5Proxy // ignore: cast_nullable_to_non_nullable
as String,httpProxy: null == httpProxy ? _self.httpProxy : httpProxy // ignore: cast_nullable_to_non_nullable
as String,relayAddress: freezed == relayAddress ? _self.relayAddress : relayAddress // ignore: cast_nullable_to_non_nullable
as String?,relayAddress6: freezed == relayAddress6 ? _self.relayAddress6 : relayAddress6 // ignore: cast_nullable_to_non_nullable
as String?,relayPassword: freezed == relayPassword ? _self.relayPassword : relayPassword // ignore: cast_nullable_to_non_nullable
as String?,relayPorts: freezed == relayPorts ? _self.relayPorts : relayPorts // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TransferProgress {

 String get transferId; TransferProgressStatus get status; int get totalFiles; int get completedFiles; int get totalSize; int get transferredSize; String get currentFile; double get speed; String? get codePhrase; String? get error; bool get isText; String get textContent;
/// Create a copy of TransferProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferProgressCopyWith<TransferProgress> get copyWith => _$TransferProgressCopyWithImpl<TransferProgress>(this as TransferProgress, _$identity);

  /// Serializes this TransferProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TransferProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferProgress&&(identical(other.transferId, _this.transferId) || other.transferId == _this.transferId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.totalFiles, _this.totalFiles) || other.totalFiles == _this.totalFiles)&&(identical(other.completedFiles, _this.completedFiles) || other.completedFiles == _this.completedFiles)&&(identical(other.totalSize, _this.totalSize) || other.totalSize == _this.totalSize)&&(identical(other.transferredSize, _this.transferredSize) || other.transferredSize == _this.transferredSize)&&(identical(other.currentFile, _this.currentFile) || other.currentFile == _this.currentFile)&&(identical(other.speed, _this.speed) || other.speed == _this.speed)&&(identical(other.codePhrase, _this.codePhrase) || other.codePhrase == _this.codePhrase)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.isText, _this.isText) || other.isText == _this.isText)&&(identical(other.textContent, _this.textContent) || other.textContent == _this.textContent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TransferProgress;
  return Object.hash(runtimeType,_this.transferId,_this.status,_this.totalFiles,_this.completedFiles,_this.totalSize,_this.transferredSize,_this.currentFile,_this.speed,_this.codePhrase,_this.error,_this.isText,_this.textContent);
}

@override
String toString() {
  final _this = this as TransferProgress;
  return 'TransferProgress(transferId: ${_this.transferId}, status: ${_this.status}, totalFiles: ${_this.totalFiles}, completedFiles: ${_this.completedFiles}, totalSize: ${_this.totalSize}, transferredSize: ${_this.transferredSize}, currentFile: ${_this.currentFile}, speed: ${_this.speed}, codePhrase: ${_this.codePhrase}, error: ${_this.error}, isText: ${_this.isText}, textContent: ${_this.textContent})';
}


}

/// @nodoc
abstract mixin class $TransferProgressCopyWith<$Res>  {
  factory $TransferProgressCopyWith(TransferProgress value, $Res Function(TransferProgress) _then) = _$TransferProgressCopyWithImpl;
@useResult
$Res call({
 String transferId, TransferProgressStatus status, int totalFiles, int completedFiles, int totalSize, int transferredSize, String currentFile, double speed, String? codePhrase, String? error, bool isText, String textContent
});




}
/// @nodoc
class _$TransferProgressCopyWithImpl<$Res>
    implements $TransferProgressCopyWith<$Res> {
  _$TransferProgressCopyWithImpl(this._self, this._then);

  final TransferProgress _self;
  final $Res Function(TransferProgress) _then;

/// Create a copy of TransferProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transferId = null,Object? status = null,Object? totalFiles = null,Object? completedFiles = null,Object? totalSize = null,Object? transferredSize = null,Object? currentFile = null,Object? speed = null,Object? codePhrase = freezed,Object? error = freezed,Object? isText = null,Object? textContent = null,}) {
  return _then(TransferProgress(
transferId: null == transferId ? _self.transferId : transferId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransferProgressStatus,totalFiles: null == totalFiles ? _self.totalFiles : totalFiles // ignore: cast_nullable_to_non_nullable
as int,completedFiles: null == completedFiles ? _self.completedFiles : completedFiles // ignore: cast_nullable_to_non_nullable
as int,totalSize: null == totalSize ? _self.totalSize : totalSize // ignore: cast_nullable_to_non_nullable
as int,transferredSize: null == transferredSize ? _self.transferredSize : transferredSize // ignore: cast_nullable_to_non_nullable
as int,currentFile: null == currentFile ? _self.currentFile : currentFile // ignore: cast_nullable_to_non_nullable
as String,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,codePhrase: freezed == codePhrase ? _self.codePhrase : codePhrase // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,isText: null == isText ? _self.isText : isText // ignore: cast_nullable_to_non_nullable
as bool,textContent: null == textContent ? _self.textContent : textContent // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TransferProgress].
extension TransferProgressPatterns on TransferProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransferProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransferProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransferProgress value)  $default,){
final _that = this;
switch (_that) {
case _TransferProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransferProgress value)?  $default,){
final _that = this;
switch (_that) {
case _TransferProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String transferId,  TransferProgressStatus status,  int totalFiles,  int completedFiles,  int totalSize,  int transferredSize,  String currentFile,  double speed,  String? codePhrase,  String? error,  bool isText,  String textContent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransferProgress() when $default != null:
return $default(_that.transferId,_that.status,_that.totalFiles,_that.completedFiles,_that.totalSize,_that.transferredSize,_that.currentFile,_that.speed,_that.codePhrase,_that.error,_that.isText,_that.textContent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String transferId,  TransferProgressStatus status,  int totalFiles,  int completedFiles,  int totalSize,  int transferredSize,  String currentFile,  double speed,  String? codePhrase,  String? error,  bool isText,  String textContent)  $default,) {final _that = this;
switch (_that) {
case _TransferProgress():
return $default(_that.transferId,_that.status,_that.totalFiles,_that.completedFiles,_that.totalSize,_that.transferredSize,_that.currentFile,_that.speed,_that.codePhrase,_that.error,_that.isText,_that.textContent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String transferId,  TransferProgressStatus status,  int totalFiles,  int completedFiles,  int totalSize,  int transferredSize,  String currentFile,  double speed,  String? codePhrase,  String? error,  bool isText,  String textContent)?  $default,) {final _that = this;
switch (_that) {
case _TransferProgress() when $default != null:
return $default(_that.transferId,_that.status,_that.totalFiles,_that.completedFiles,_that.totalSize,_that.transferredSize,_that.currentFile,_that.speed,_that.codePhrase,_that.error,_that.isText,_that.textContent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransferProgress implements TransferProgress {
  const _TransferProgress({this.transferId = '', this.status = TransferProgressStatus.initializing, this.totalFiles = 0, this.completedFiles = 0, this.totalSize = 0, this.transferredSize = 0, this.currentFile = '', this.speed = 0.0, this.codePhrase, this.error, this.isText = false, this.textContent = ''});
  factory _TransferProgress.fromJson(Map<String, dynamic> json) => _$TransferProgressFromJson(json);

@override@JsonKey() final  String transferId;
@override@JsonKey() final  TransferProgressStatus status;
@override@JsonKey() final  int totalFiles;
@override@JsonKey() final  int completedFiles;
@override@JsonKey() final  int totalSize;
@override@JsonKey() final  int transferredSize;
@override@JsonKey() final  String currentFile;
@override@JsonKey() final  double speed;
@override final  String? codePhrase;
@override final  String? error;
@override@JsonKey() final  bool isText;
@override@JsonKey() final  String textContent;

/// Create a copy of TransferProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransferProgressCopyWith<_TransferProgress> get copyWith => __$TransferProgressCopyWithImpl<_TransferProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransferProgressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransferProgress&&(identical(other.transferId, transferId) || other.transferId == transferId)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalFiles, totalFiles) || other.totalFiles == totalFiles)&&(identical(other.completedFiles, completedFiles) || other.completedFiles == completedFiles)&&(identical(other.totalSize, totalSize) || other.totalSize == totalSize)&&(identical(other.transferredSize, transferredSize) || other.transferredSize == transferredSize)&&(identical(other.currentFile, currentFile) || other.currentFile == currentFile)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.codePhrase, codePhrase) || other.codePhrase == codePhrase)&&(identical(other.error, error) || other.error == error)&&(identical(other.isText, isText) || other.isText == isText)&&(identical(other.textContent, textContent) || other.textContent == textContent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,transferId,status,totalFiles,completedFiles,totalSize,transferredSize,currentFile,speed,codePhrase,error,isText,textContent);
}

@override
String toString() {
    return 'TransferProgress(transferId: $transferId, status: $status, totalFiles: $totalFiles, completedFiles: $completedFiles, totalSize: $totalSize, transferredSize: $transferredSize, currentFile: $currentFile, speed: $speed, codePhrase: $codePhrase, error: $error, isText: $isText, textContent: $textContent)';
}


}

/// @nodoc
abstract mixin class _$TransferProgressCopyWith<$Res> implements $TransferProgressCopyWith<$Res> {
  factory _$TransferProgressCopyWith(_TransferProgress value, $Res Function(_TransferProgress) _then) = __$TransferProgressCopyWithImpl;
@override @useResult
$Res call({
 String transferId, TransferProgressStatus status, int totalFiles, int completedFiles, int totalSize, int transferredSize, String currentFile, double speed, String? codePhrase, String? error, bool isText, String textContent
});




}
/// @nodoc
class __$TransferProgressCopyWithImpl<$Res>
    implements _$TransferProgressCopyWith<$Res> {
  __$TransferProgressCopyWithImpl(this._self, this._then);

  final _TransferProgress _self;
  final $Res Function(_TransferProgress) _then;

/// Create a copy of TransferProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transferId = null,Object? status = null,Object? totalFiles = null,Object? completedFiles = null,Object? totalSize = null,Object? transferredSize = null,Object? currentFile = null,Object? speed = null,Object? codePhrase = freezed,Object? error = freezed,Object? isText = null,Object? textContent = null,}) {
  return _then(_TransferProgress(
transferId: null == transferId ? _self.transferId : transferId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransferProgressStatus,totalFiles: null == totalFiles ? _self.totalFiles : totalFiles // ignore: cast_nullable_to_non_nullable
as int,completedFiles: null == completedFiles ? _self.completedFiles : completedFiles // ignore: cast_nullable_to_non_nullable
as int,totalSize: null == totalSize ? _self.totalSize : totalSize // ignore: cast_nullable_to_non_nullable
as int,transferredSize: null == transferredSize ? _self.transferredSize : transferredSize // ignore: cast_nullable_to_non_nullable
as int,currentFile: null == currentFile ? _self.currentFile : currentFile // ignore: cast_nullable_to_non_nullable
as String,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,codePhrase: freezed == codePhrase ? _self.codePhrase : codePhrase // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,isText: null == isText ? _self.isText : isText // ignore: cast_nullable_to_non_nullable
as bool,textContent: null == textContent ? _self.textContent : textContent // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
