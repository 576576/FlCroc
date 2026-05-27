import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color get opacity80 => withAlpha(204);
  Color get opacity60 => withAlpha(153);
  Color get opacity15 => withAlpha(38);
  Color get opacity10 => withAlpha(15);
}
