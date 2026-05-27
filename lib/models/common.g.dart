// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransferRecordImpl _$$TransferRecordImplFromJson(Map<String, dynamic> json) =>
    _$TransferRecordImpl(
      id: json['id'] as String,
      direction: $enumDecode(_$TransferDirectionEnumMap, json['direction']),
      status: $enumDecode(_$TransferStatusEnumMap, json['status']),
      files: (json['files'] as List<dynamic>)
          .map((e) => FileItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalSize: (json['totalSize'] as num).toInt(),
      transferredSize: (json['transferredSize'] as num?)?.toInt(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      codePhrase: json['codePhrase'] as String?,
      relayAddress: json['relayAddress'] as String?,
      speed: (json['speed'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$TransferRecordImplToJson(
  _$TransferRecordImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'direction': _$TransferDirectionEnumMap[instance.direction]!,
  'status': _$TransferStatusEnumMap[instance.status]!,
  'files': instance.files,
  'totalSize': instance.totalSize,
  'transferredSize': instance.transferredSize,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'codePhrase': instance.codePhrase,
  'relayAddress': instance.relayAddress,
  'speed': instance.speed,
};

const _$TransferDirectionEnumMap = {
  TransferDirection.sent: 'sent',
  TransferDirection.received: 'received',
};

const _$TransferStatusEnumMap = {
  TransferStatus.pending: 'pending',
  TransferStatus.transferring: 'transferring',
  TransferStatus.completed: 'completed',
  TransferStatus.failed: 'failed',
  TransferStatus.cancelled: 'cancelled',
};

_$FileItemImpl _$$FileItemImplFromJson(Map<String, dynamic> json) =>
    _$FileItemImpl(
      name: json['name'] as String,
      path: json['path'] as String,
      size: (json['size'] as num).toInt(),
      folder: json['folder'] as String?,
    );

Map<String, dynamic> _$$FileItemImplToJson(_$FileItemImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'size': instance.size,
      'folder': instance.folder,
    };

_$RelayConfigImpl _$$RelayConfigImplFromJson(Map<String, dynamic> json) =>
    _$RelayConfigImpl(
      address: json['address'] as String? ?? defaultRelay,
      password: json['password'] as String? ?? defaultPassphrase,
      port: json['port'] as String? ?? defaultPort,
      type:
          $enumDecodeNullable(_$RelayTypeEnumMap, json['type']) ??
          RelayType.defaultRelay,
    );

Map<String, dynamic> _$$RelayConfigImplToJson(_$RelayConfigImpl instance) =>
    <String, dynamic>{
      'address': instance.address,
      'password': instance.password,
      'port': instance.port,
      'type': _$RelayTypeEnumMap[instance.type]!,
    };

const _$RelayTypeEnumMap = {
  RelayType.defaultRelay: 'defaultRelay',
  RelayType.customRelay: 'customRelay',
  RelayType.noRelay: 'noRelay',
};

_$SendConfigImpl _$$SendConfigImplFromJson(Map<String, dynamic> json) =>
    _$SendConfigImpl(
      curve: json['curve'] as String? ?? defaultCurve,
      hashAlgorithm: json['hashAlgorithm'] as String? ?? defaultHashAlgorithm,
      noCompress: json['noCompress'] as bool? ?? false,
      overwrite: json['overwrite'] as bool? ?? false,
      zipFolder: json['zipFolder'] as bool? ?? false,
      gitIgnore: json['gitIgnore'] as bool? ?? false,
      onlyLocal: json['onlyLocal'] as bool? ?? false,
      disableLocal: json['disableLocal'] as bool? ?? false,
      showQrCode: json['showQrCode'] as bool? ?? false,
      disableClipboard: json['disableClipboard'] as bool? ?? false,
      codePhrase: json['codePhrase'] as String? ?? '',
      socks5Proxy: json['socks5Proxy'] as String? ?? '',
      httpProxy: json['httpProxy'] as String? ?? '',
      throttleUpload: json['throttleUpload'] as String? ?? '',
      exclude:
          (json['exclude'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$SendConfigImplToJson(_$SendConfigImpl instance) =>
    <String, dynamic>{
      'curve': instance.curve,
      'hashAlgorithm': instance.hashAlgorithm,
      'noCompress': instance.noCompress,
      'overwrite': instance.overwrite,
      'zipFolder': instance.zipFolder,
      'gitIgnore': instance.gitIgnore,
      'onlyLocal': instance.onlyLocal,
      'disableLocal': instance.disableLocal,
      'showQrCode': instance.showQrCode,
      'disableClipboard': instance.disableClipboard,
      'codePhrase': instance.codePhrase,
      'socks5Proxy': instance.socks5Proxy,
      'httpProxy': instance.httpProxy,
      'throttleUpload': instance.throttleUpload,
      'exclude': instance.exclude,
    };

_$ReceiveConfigImpl _$$ReceiveConfigImplFromJson(Map<String, dynamic> json) =>
    _$ReceiveConfigImpl(
      overwrite: json['overwrite'] as bool? ?? false,
      onlyLocal: json['onlyLocal'] as bool? ?? false,
      outputPath: json['outputPath'] as String? ?? '',
    );

Map<String, dynamic> _$$ReceiveConfigImplToJson(_$ReceiveConfigImpl instance) =>
    <String, dynamic>{
      'overwrite': instance.overwrite,
      'onlyLocal': instance.onlyLocal,
      'outputPath': instance.outputPath,
    };
