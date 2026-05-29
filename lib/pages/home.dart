import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/controller.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/widgets/window_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final navigationItems = Navigation().getItems();
        final currentLabel = ref.watch(currentPageProvider);
        final currentIndex =
            navigationItems.indexWhere((item) => item.label == currentLabel);
        final safeIndex = currentIndex >= 0 ? currentIndex : 0;

        // ── Mobile (non-desktop) ──
        if (!isDesktop) {
          final isNarrow = MediaQuery.of(context).size.width < maxMobileWidth;
          final body = Expanded(
            child: IndexedStack(
              index: safeIndex,
              children: navigationItems.map((e) => e.builder(context)).toList(),
            ),
          );
          if (isNarrow) {
            return Column(children: [
              body,
              NavigationBar(
                destinations: navigationItems
                    .map((e) => NavigationDestination(
                          icon: e.icon,
                          label: context.appLocalizations.pageLabel(e.label),
                        ))
                    .toList(),
                onDestinationSelected: (index) =>
                    appController.toPage(navigationItems[index].label),
                selectedIndex: safeIndex,
              ),
            ]);
          }
          return body;
        }

        // ── Desktop: always show WindowTitleBar ──
        final isNarrow = MediaQuery.of(context).size.width < maxMobileWidth;
        final labelStyle = context.textTheme.labelMedium?.copyWith(
          overflow: TextOverflow.ellipsis,
        );

        Widget body;
        if (isNarrow) {
          body = Column(children: [
            Expanded(
              child: IndexedStack(
                index: safeIndex,
                children: navigationItems.map((e) => e.builder(context)).toList(),
              ),
            ),
            NavigationBar(
              destinations: navigationItems
                  .map((e) => NavigationDestination(
                        icon: e.icon,
                        label: context.appLocalizations.pageLabel(e.label),
                      ))
                  .toList(),
              onDestinationSelected: (index) =>
                  appController.toPage(navigationItems[index].label),
              selectedIndex: safeIndex,
            ),
          ]);
        } else {
          body = Row(children: [
            Material(
              color: context.colorScheme.surfaceContainer,
              child: SafeArea(
                child: SizedBox(
                  width: 88,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/icon.png',
                            width: 40, height: 40,
                            errorBuilder: (_, _, _) => Icon(Icons.upload_file, size: 40, color: context.colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: NavigationRail(
                          backgroundColor: Colors.transparent,
                          selectedLabelTextStyle: labelStyle?.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelTextStyle: labelStyle?.copyWith(
                            color: context.colorScheme.onSurface,
                          ),
                          destinations: navigationItems
                              .map((e) => NavigationRailDestination(
                                    icon: e.icon,
                                    label: Text(context.appLocalizations.pageLabel(e.label), overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onDestinationSelected: (index) => appController.toPage(navigationItems[index].label),
                          selectedIndex: safeIndex,
                          labelType: NavigationRailLabelType.all,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: safeIndex,
                children: navigationItems.map((e) => e.builder(context)).toList(),
              ),
            ),
          ]);
        }

        return Container(
          color: context.colorScheme.surface,
          child: Column(children: [
            const WindowTitleBar(),
            Expanded(child: body),
          ]),
        );
      },
    );
  }
}
