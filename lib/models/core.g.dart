// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SendOptionsImpl _$$SendOptionsImplFromJson(Map<String, dynamic> json) =>
    _$SendOptionsImpl(
      filePaths: (json['filePaths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      codePhrase: json['codePhrase'] as String?,
      curve: json['curve'] as String? ?? 'p256',
      hashAlgorithm: json['hashAlgorithm'] as String? ?? 'xxhash',
      noCompress: json['noCompress'] as bool? ?? false,
      overwrite: json['overwrite'] as bool? ?? false,
      zipFolder: json['zipFolder'] as bool? ?? false,
      gitIgnore: json['gitIgnore'] as bool? ?? false,
      onlyLocal: json['onlyLocal'] as bool? ?? false,
      disableLocal: json['disableLocal'] as bool? ?? false,
      sendingText: json['sendingText'] as bool? ?? false,
      textContent: json['textContent'] as String? ?? '',
      socks5Proxy: json['socks5Proxy'] as String? ?? '',
      httpProxy: json['httpProxy'] as String? ?? '',
      throttleUpload: json['throttleUpload'] as String? ?? '',
      exclude:
          (json['exclude'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      relayAddress: json['relayAddress'] as String?,
      relayPassword: json['relayPassword'] as String?,
    );

Map<String, dynamic> _$$SendOptionsImplToJson(_$SendOptionsImpl instance) =>
    <String, dynamic>{
      'filePaths': instance.filePaths,
      'codePhrase': instance.codePhrase,
      'curve': instance.curve,
      'hashAlgorithm': instance.hashAlgorithm,
      'noCompress': instance.noCompress,
      'overwrite': instance.overwrite,
      'zipFolder': instance.zipFolder,
      'gitIgnore': instance.gitIgnore,
      'onlyLocal': instance.onlyLocal,
      'disableLocal': instance.disableLocal,
      'sendingText': instance.sendingText,
      'textContent': instance.textContent,
      'socks5Proxy': instance.socks5Proxy,
      'httpProxy': instance.httpProxy,
      'throttleUpload': instance.throttleUpload,
      'exclude': instance.exclude,
      'relayAddress': instance.relayAddress,
      'relayPassword': instance.relayPassword,
    };

_$ReceiveOptionsImpl _$$ReceiveOptionsImplFromJson(Map<String, dynamic> json) =>
    _$ReceiveOptionsImpl(
      codePhrase: json['codePhrase'] as String,
      overwrite: json['overwrite'] as bool? ?? false,
      onlyLocal: json['onlyLocal'] as bool? ?? false,
      outputPath: json['outputPath'] as String? ?? '',
      relayAddress: json['relayAddress'] as String?,
      relayAddress6: json['relayAddress6'] as String?,
      relayPassword: json['relayPassword'] as String?,
    );

Map<String, dynamic> _$$ReceiveOptionsImplToJson(
  _$ReceiveOptionsImpl instance,
) => <String, dynamic>{
  'codePhrase': instance.codePhrase,
  'overwrite': instance.overwrite,
  'onlyLocal': instance.onlyLocal,
  'outputPath': instance.outputPath,
  'relayAddress': instance.relayAddress,
  'relayAddress6': instance.relayAddress6,
  'relayPassword': instance.relayPassword,
};

_$TransferProgressImpl _$$TransferProgressImplFromJson(
  Map<String, dynamic> json,
) => _$TransferProgressImpl(
  transferId: json['transferId'] as String? ?? '',
  status:
      $enumDecodeNullable(_$TransferProgressStatusEnumMap, json['status']) ??
      TransferProgressStatus.initializing,
  totalFiles: (json['totalFiles'] as num?)?.toInt() ?? 0,
  completedFiles: (json['completedFiles'] as num?)?.toInt() ?? 0,
  totalSize: (json['totalSize'] as num?)?.toInt() ?? 0,
  transferredSize: (json['transferredSize'] as num?)?.toInt() ?? 0,
  currentFile: json['currentFile'] as String? ?? '',
  speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
  codePhrase: json['codePhrase'] as String?,
  error: json['error'] as String?,
);

Map<String, dynamic> _$$TransferProgressImplToJson(
  _$TransferProgressImpl instance,
) => <String, dynamic>{
  'transferId': instance.transferId,
  'status': _$TransferProgressStatusEnumMap[instance.status]!,
  'totalFiles': instance.totalFiles,
  'completedFiles': instance.completedFiles,
  'totalSize': instance.totalSize,
  'transferredSize': instance.transferredSize,
  'currentFile': instance.currentFile,
  'speed': instance.speed,
  'codePhrase': instance.codePhrase,
  'error': instance.error,
};

const _$TransferProgressStatusEnumMap = {
  TransferProgressStatus.initializing: 'initializing',
  TransferProgressStatus.connecting: 'connecting',
  TransferProgressStatus.transferring: 'transferring',
  TransferProgressStatus.completed: 'completed',
  TransferProgressStatus.failed: 'failed',
  TransferProgressStatus.cancelled: 'cancelled',
};
