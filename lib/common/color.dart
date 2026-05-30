import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color get opacity80 => withAlpha(204);
  Color get opacity60 => withAlpha(153);
  Color get opacity15 => withAlpha(38);
  Color get opacity10 => withAlpha(15);
}

/// Cached [ColorScheme.fromSeed] to avoid expensive recomputation.
final Map<int, ColorScheme> _lightCache = {};
final Map<int, ColorScheme> _darkCache = {};

ColorScheme cachedColorScheme(int seed, Brightness brightness) {
  final cache = brightness == Brightness.light ? _lightCache : _darkCache;
  return cache.putIfAbsent(seed, () => ColorScheme.fromSeed(seedColor: Color(seed), brightness: brightness));
}
