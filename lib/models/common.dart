import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'common.freezed.dart';
part 'common.g.dart';

class NavigationItem {
  final Icon icon;
  final PageLabel label;
  final Widget Function(BuildContext) builder;
  final bool keep;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.builder,
    this.keep = false,
  });
}

class Info {
  final IconData iconData;
  final String label;

  const Info({required this.iconData, required this.label});
}

class GridItem {
  final int crossAxisCellCount;
  final Widget child;

  const GridItem({required this.crossAxisCellCount, required this.child});
}

@freezed
abstract class Result<T> with _$Result<T> {
  const factory Result({
    required T? data,
    required ResultType type,
    required String message,
  }) = _Result;

  factory Result.success(T data) =>
      Result(data: data, type: ResultType.success, message: '');

  factory Result.error(String message) =>
      Result(data: null, type: ResultType.error, message: message);
}

extension ResultExt on Result {
  bool get isError => type == ResultType.error;
  bool get isSuccess => type == ResultType.success;
}

enum ResultType { success, error }

@freezed
abstract class TransferRecord with _$TransferRecord {
  const factory TransferRecord({
    required String id,
    required TransferDirection direction,
    required TransferStatus status,
    required List<FileItem> files,
    required int totalSize,
    int? transferredSize,
    required DateTime startTime,
    DateTime? endTime,
    String? codePhrase,
    String? relayAddress,
    double? speed,
  }) = _TransferRecord;

  factory TransferRecord.fromJson(Map<String, Object?> json) =>
      _$TransferRecordFromJson(json);
}

@freezed
abstract class FileItem with _$FileItem {
  const factory FileItem({
    required String name,
    required String path,
    required int size,
    String? folder,
  }) = _FileItem;

  factory FileItem.fromJson(Map<String, Object?> json) =>
      _$FileItemFromJson(json);
}

@freezed
abstract class RelayConfig with _$RelayConfig {
  const factory RelayConfig({
    @Default(defaultRelay) String address,
    @Default(defaultPassphrase) String password,
    @Default(defaultPort) String port,
    @Default(RelayType.defaultRelay) RelayType type,
  }) = _RelayConfig;

  factory RelayConfig.fromJson(Map<String, Object?> json) =>
      _$RelayConfigFromJson(json);
}

@freezed
abstract class SendConfig with _$SendConfig {
  const factory SendConfig({
    @Default(defaultCurve) String curve,
    @Default(defaultHashAlgorithm) String hashAlgorithm,
    @Default(false) bool noCompress,
    @Default(false) bool overwrite,
    @Default(false) bool zipFolder,
    @Default(false) bool gitIgnore,
    @Default(false) bool onlyLocal,
    @Default(false) bool disableLocal,
    @Default(false) bool showQrCode,

    /// Opt-in: let croc copy the share code to the OS clipboard.
    ///
    /// Defaults to false — a GUI must not silently overwrite the user's
    /// clipboard. (Replaces the old `disableClipboard` flag, which defaulted to
    /// false and therefore kept hijacking the clipboard after upgrading.)
    @Default(false) bool copyCodeToClipboard,
    @Default('') String codePhrase,
    @Default('') String socks5Proxy,
    @Default('') String httpProxy,
    @Default('') String throttleUpload,
    @Default(<String>[]) List<String> exclude,

    /// Sender file-data channel: `auto`, `derp` or `relay` (croc --transport).
    @Default('auto') String transport,
  }) = _SendConfig;

  factory SendConfig.fromJson(Map<String, Object?> json) =>
      _$SendConfigFromJson(json);

  /// SharedPreferences key holding the persisted send options.
  static const prefKey = 'send_config';

  /// Reads the persisted send options.
  ///
  /// Every entry point that can start a send must go through this, otherwise a
  /// transfer started from somewhere else silently ignores the user's choices.
  static SendConfig load() => SendConfig.fromJson(AppPrefs.getJson(prefKey));
}

/// Persistence helper for [SendConfig].
///
/// Declared as an extension because freezed generates its implementation with
/// `implements`, so a concrete instance method on the freezed class itself
/// would also have to be implemented by the generated class.
extension SendConfigPrefs on SendConfig {
  void save() => AppPrefs.setJson(SendConfig.prefKey, toJson());
}

@freezed
abstract class ReceiveConfig with _$ReceiveConfig {
  const factory ReceiveConfig({
    @Default(false) bool overwrite,

    /// Save under an unused name when the destination already exists.
    /// Defaults to true — croc's overwrite prompt cannot be answered without a
    /// stdin, and the empty answer used to make it skip the file entirely.
    @Default(true) bool rename,
    @Default(false) bool onlyLocal,
    @Default('') String outputPath,
    @Default('') String socks5Proxy,
    @Default('') String httpProxy,
  }) = _ReceiveConfig;

  factory ReceiveConfig.fromJson(Map<String, Object?> json) =>
      _$ReceiveConfigFromJson(json);

  /// SharedPreferences key holding the persisted receive options.
  static const prefKey = 'receive_config';

  static ReceiveConfig load() =>
      ReceiveConfig.fromJson(AppPrefs.getJson(prefKey));
}

/// Persistence helper for [ReceiveConfig]. See [SendConfigPrefs] for why this
/// is an extension rather than a method on the class.
extension ReceiveConfigPrefs on ReceiveConfig {
  void save() => AppPrefs.setJson(ReceiveConfig.prefKey, toJson());
}
