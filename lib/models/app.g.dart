// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppStateImpl _$$AppStateImplFromJson(Map<String, dynamic> json) =>
    _$AppStateImpl(
      isInit: json['isInit'] as bool? ?? false,
      pageLabel:
          $enumDecodeNullable(_$PageLabelEnumMap, json['pageLabel']) ??
          PageLabel.dashboard,
      viewSize: json['viewSize'] == null
          ? Size.zero
          : const SizeConverter().fromJson(
              json['viewSize'] as Map<String, dynamic>,
            ),
      sideWidth: (json['sideWidth'] as num?)?.toDouble() ?? 0,
      brightness: json['brightness'] == null
          ? Brightness.light
          : const BrightnessConverter().fromJson(json['brightness'] as String),
      transfers:
          (json['transfers'] as List<dynamic>?)
              ?.map((e) => TransferRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TransferRecord>[],
      history:
          (json['history'] as List<dynamic>?)
              ?.map((e) => TransferRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TransferRecord>[],
      coreStatus:
          $enumDecodeNullable(_$CoreStatusEnumMap, json['coreStatus']) ??
          CoreStatus.disconnected,
      speeds:
          (json['speeds'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
    );

Map<String, dynamic> _$$AppStateImplToJson(_$AppStateImpl instance) =>
    <String, dynamic>{
      'isInit': instance.isInit,
      'pageLabel': _$PageLabelEnumMap[instance.pageLabel]!,
      'viewSize': const SizeConverter().toJson(instance.viewSize),
      'sideWidth': instance.sideWidth,
      'brightness': const BrightnessConverter().toJson(instance.brightness),
      'transfers': instance.transfers,
      'history': instance.history,
      'coreStatus': _$CoreStatusEnumMap[instance.coreStatus]!,
      'speeds': instance.speeds,
    };

const _$PageLabelEnumMap = {
  PageLabel.dashboard: 'dashboard',
  PageLabel.send: 'send',
  PageLabel.receive: 'receive',
  PageLabel.history: 'history',
  PageLabel.settings: 'settings',
};

const _$CoreStatusEnumMap = {
  CoreStatus.disconnected: 'disconnected',
  CoreStatus.connecting: 'connecting',
  CoreStatus.connected: 'connected',
  CoreStatus.error: 'error',
};
