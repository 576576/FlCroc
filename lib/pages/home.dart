import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final navigationItems = Navigation().getItems();
        final currentLabel = ref.watch(currentPageProvider);

        final currentIndex = navigationItems
            .indexWhere((item) => item.label == currentLabel);
        final safeIndex = currentIndex >= 0 ? currentIndex : 0;

        final bottomNav = NavigationBar(
          destinations: navigationItems
              .map((e) => NavigationDestination(
                    icon: e.icon,
                    label: e.label.name,
                  ))
              .toList(),
          onDestinationSelected: (index) {
            appController.toPage(navigationItems[index].label);
          },
          selectedIndex: safeIndex,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < maxMobileWidth;

            if (isMobile) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  systemNavigationBarColor:
                      context.colorScheme.surfaceContainer,
                ),
                child: Scaffold(
                  body: IndexedStack(
                    index: safeIndex,
                    children: navigationItems
                        .map((e) => e.builder(context))
                        .toList(),
                  ),
                  bottomNavigationBar: MediaQuery.removePadding(
                    removeTop: true,
                    removeBottom: true,
                    context: context,
                    child: bottomNav,
                  ),
                ),
              );
            }

            // Desktop/tablet: sidebar layout
            return Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: safeIndex,
                    onDestinationSelected: (index) {
                      appController
                          .toPage(navigationItems[index].label);
                    },
                    labelType: NavigationRailLabelType.all,
                    destinations: navigationItems
                        .map((e) => NavigationRailDestination(
                              icon: e.icon,
                              label: Text(e.label.name),
                            ))
                        .toList(),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: IndexedStack(
                      index: safeIndex,
                      children: navigationItems
                          .map((e) => e.builder(context))
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
