import 'package:freezed_annotation/freezed_annotation.dart';

part 'core.freezed.dart';
part 'core.g.dart';

@freezed
abstract class SendOptions with _$SendOptions {
  const factory SendOptions({
    required List<String> filePaths,
    String? codePhrase,
    @Default('p256') String curve,
    @Default('xxhash') String hashAlgorithm,
    @Default(false) bool noCompress,
    @Default(false) bool overwrite,
    @Default(false) bool zipFolder,
    @Default(false) bool gitIgnore,
    @Default(false) bool onlyLocal,
    @Default(false) bool disableLocal,
    @Default(false) bool sendingText,
    @Default('') String textContent,
    @Default('') String tempDir,
    @Default('') String socks5Proxy,
    @Default('') String httpProxy,
    @Default('') String throttleUpload,
    @Default(<String>[]) List<String> exclude,
    String? relayAddress,
    String? relayAddress6,
    String? relayPassword,
    String? relayPorts,
  }) = _SendOptions;

  factory SendOptions.fromJson(Map<String, Object?> json) =>
      _$SendOptionsFromJson(json);
}

@freezed
abstract class ReceiveOptions with _$ReceiveOptions {
  const factory ReceiveOptions({
    required String codePhrase,
    @Default(false) bool overwrite,
    @Default(false) bool onlyLocal,
    @Default('') String outputPath,
    @Default('p256') String curve,
    String? relayAddress,
    String? relayAddress6,
    String? relayPassword,
    String? relayPorts,
  }) = _ReceiveOptions;

  factory ReceiveOptions.fromJson(Map<String, Object?> json) =>
      _$ReceiveOptionsFromJson(json);
}

@freezed
abstract class TransferProgress with _$TransferProgress {
  const factory TransferProgress({
    @Default('') String transferId,
    @Default(TransferProgressStatus.initializing)
    TransferProgressStatus status,
    @Default(0) int totalFiles,
    @Default(0) int completedFiles,
    @Default(0) int totalSize,
    @Default(0) int transferredSize,
    @Default('') String currentFile,
    @Default(0.0) double speed,
    String? codePhrase,
    String? error,
    @Default(false) bool isText,
    @Default('') String textContent,
  }) = _TransferProgress;

  factory TransferProgress.fromJson(Map<String, Object?> json) =>
      _$TransferProgressFromJson(json);
}

enum TransferProgressStatus {
  initializing,
  connecting,
  transferring,
  completed,
  failed,
  cancelled,
}
