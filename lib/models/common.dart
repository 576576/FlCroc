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
    @Default(false) bool disableClipboard,
    @Default('') String codePhrase,
    @Default('') String socks5Proxy,
    @Default('') String httpProxy,
    @Default('') String throttleUpload,
    @Default(<String>[]) List<String> exclude,
  }) = _SendConfig;

  factory SendConfig.fromJson(Map<String, Object?> json) =>
      _$SendConfigFromJson(json);
}

@freezed
abstract class ReceiveConfig with _$ReceiveConfig {
  const factory ReceiveConfig({
    @Default(false) bool overwrite,
    @Default(false) bool onlyLocal,
    @Default('') String outputPath,
  }) = _ReceiveConfig;

  factory ReceiveConfig.fromJson(Map<String, Object?> json) =>
      _$ReceiveConfigFromJson(json);
}
