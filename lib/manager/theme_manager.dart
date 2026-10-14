import 'package:fl_croc/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class const ThemeManager({super.key, required this.child})
    extends ConsumerWidget {
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class const ThemeNotification({required this.primaryColor})
    extends Notification {
  final int primaryColor;
}
