import 'package:fl_croc/common/context.dart';
import 'package:flutter/material.dart';

class CommonTheme {
  final BuildContext context;

  CommonTheme(this.context);

  Color get surface => context.colorScheme.surface;
  Color get primary => context.colorScheme.primary;
  Color get onSurface => context.colorScheme.onSurface;
  Color get outline => context.colorScheme.outline;

  Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
