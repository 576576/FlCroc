import 'package:fl_croc/common/navigation.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationStateProvider = StateProvider<NavigationState>((ref) {
  return NavigationState(
    navigationItems: Navigation().getItems(),
    currentIndex: 0,
  );
});

class NavigationState {
  final List<NavigationItem> navigationItems;
  final int currentIndex;

  const NavigationState({
    required this.navigationItems,
    required this.currentIndex,
  });
}

final isStartProvider = StateProvider<bool>((ref) => false);
final initProvider = StateProvider<bool>((ref) => false);
