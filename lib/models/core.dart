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

    /// When true (the default) croc must not write the share code into the OS
    /// clipboard. croc's CLI does that unconditionally while printing its
    /// instructions, which clobbers whatever the user had copied.
    @Default(true) bool disableClipboard,

    /// Sender file-data channel: `auto` (default), `derp` (prefer the direct
    /// Tailcat/WireGuard path) or `relay`. Sender-only — croc rejects any
    /// non-auto value on the receiving side.
    @Default('auto') String transport,
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

    /// When the destination name is already taken, save under an unused name
    /// instead of letting croc ask "(y/N) Overwrite?" on stdin. Defaults to
    /// true: the GUI has no stdin, so croc used to read the empty answer as
    /// "no" and silently skip the file.
    @Default(true) bool rename,
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
