import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeManager extends ConsumerWidget {
  final Widget child;

  const ThemeManager({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingProvider);
    final themeProps = ref.watch(themeSettingProvider);

    return NotificationListener<ThemeNotification>(
      onNotification: (notification) {
        ref.read(themeSettingProvider.notifier).update((state) {
          return state.copyWith(primaryColor: notification.primaryColor);
        });
        return true;
      },
      child: child,
    );
  }
}

class ThemeNotification extends Notification {
  final int primaryColor;
  const ThemeNotification({required this.primaryColor});
}
