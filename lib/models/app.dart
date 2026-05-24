import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/common.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app.freezed.dart';
part 'app.g.dart';

class SizeConverter implements JsonConverter<Size, Map<String, dynamic>> {
  const SizeConverter();

  @override
  Size fromJson(Map<String, dynamic> json) {
    return Size(
      (json['width'] as num).toDouble(),
      (json['height'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(Size size) {
    return {'width': size.width, 'height': size.height};
  }
}

class BrightnessConverter implements JsonConverter<Brightness, String> {
  const BrightnessConverter();

  @override
  Brightness fromJson(String json) {
    return json == 'dark' ? Brightness.dark : Brightness.light;
  }

  @override
  String toJson(Brightness brightness) {
    return brightness == Brightness.dark ? 'dark' : 'light';
  }
}

@freezed
abstract class AppState with _$AppState {
  const factory AppState({
    @Default(false) bool isInit,
    @Default(PageLabel.dashboard) PageLabel pageLabel,
    @SizeConverter() @Default(Size.zero) Size viewSize,
    @Default(0) double sideWidth,
    @BrightnessConverter() @Default(Brightness.light) Brightness brightness,
    @Default(<TransferRecord>[]) List<TransferRecord> transfers,
    @Default(<TransferRecord>[]) List<TransferRecord> history,
    @Default(CoreStatus.disconnected) CoreStatus coreStatus,
    @Default({}) Map<String, double> speeds,
  }) = _AppState;

  factory AppState.fromJson(Map<String, Object?> json) =>
      _$AppStateFromJson(json);
}
