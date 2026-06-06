import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/controller.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/widgets/window_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final PageController _pageController = PageController();
  bool _isSyncing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Helper: animate to page & sync provider ──

  void _goToPage(int index, List<NavigationItem> items) {
    if (_isSyncing) return;
    final currentPage = _pageController.page?.round() ?? 0;
    if (currentPage == index) return;
    _isSyncing = true;
    _pageController.animateToPage(
      index,
      duration: commonDuration,
      curve: Curves.easeInOut,
    );
    appController.toPage(items[index].label);
    // reset guard after animation completes
    Future.delayed(commonDuration + const Duration(milliseconds: 50), () {
      if (mounted) _isSyncing = false;
    });
  }

  void _onPageChanged(int index, List<NavigationItem> items) {
    if (_isSyncing) return;
    _isSyncing = true;
    appController.toPage(items[index].label);
    // reset guard shortly after
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _isSyncing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationItems = Navigation().getItems();

    final currentLabel = ref.watch(currentPageProvider);
    final currentIndex =
        navigationItems.indexWhere((item) => item.label == currentLabel);
    final safeIndex = currentIndex >= 0 ? currentIndex : 0;
    final isNarrow = MediaQuery.of(context).size.width < maxMobileWidth;
    final noTextMode = ref.watch(appSettingProvider.select((s) => s.noTextMode));

    // Sync PageView when provider changes externally (e.g. share intent)
    if (!_isSyncing && _pageController.hasClients) {
      final currentPage = _pageController.page?.round() ?? 0;
      if (currentPage != safeIndex) {
        _isSyncing = true;
        _pageController.animateToPage(
          safeIndex,
          duration: commonDuration,
          curve: Curves.easeInOut,
        );
        Future.delayed(commonDuration + const Duration(milliseconds: 50), () {
          if (mounted) _isSyncing = false;
        });
      }
    }

    // ── Shared body: PageView with animation ──
    final pages = navigationItems.map((e) => e.builder(context)).toList();
    Widget pageBody = PageView(
      controller: _pageController,
      scrollDirection: isNarrow ? Axis.horizontal : Axis.vertical,
      physics: const PageScrollPhysics(),
      onPageChanged: (index) => _onPageChanged(index, navigationItems),
      children: pages,
    );

    // ── Wide: NavigationRail sidebar ──
    if (!isNarrow) {
      final labelStyle = context.textTheme.labelLarge?.copyWith(
        overflow: TextOverflow.ellipsis,
      );
      final screenHeight = MediaQuery.of(context).size.height;
      final showLogo = screenHeight >= 500;
      Widget label(String text) => noTextMode
          ? const Text('')
          : Text(text, maxLines: 2, overflow: TextOverflow.visible, textAlign: TextAlign.center);

      final rail = Material(
        color: context.colorScheme.surfaceContainer,
        child: SafeArea(
          child: SizedBox(
            width: noTextMode ? 72 : 88,
            child: Column(
              children: [
                if (showLogo) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/icon.png',
                        width: 40, height: 40,
                        errorBuilder: (_, _, _) => Icon(Icons.upload_file, size: 40, color: context.colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
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
                              label: label(context.appLocalizations.pageLabel(e.label)),
                            ))
                        .toList(),
                    onDestinationSelected: (index) => _goToPage(index, navigationItems),
                    selectedIndex: safeIndex,
                    labelType: noTextMode ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
      final wideBody = Row(children: [rail, Expanded(child: pageBody)]);
      if (isDesktop) {
        return Container(
          color: context.colorScheme.surface,
          child: Column(children: [
            const WindowTitleBar(),
            Expanded(child: wideBody),
          ]),
        );
      }
      return wideBody;
    }

    // ── Narrow: bottom NavigationBar ──
    final navBar = Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarTheme.of(context).copyWith(
          height: noTextMode ? 56 : 64,
        ),
      ),
      child: NavigationBar(
      destinations: navigationItems
          .map((e) => NavigationDestination(
                icon: e.icon,
                label: noTextMode ? '' : context.appLocalizations.pageLabel(e.label),
              ))
          .toList(),
      onDestinationSelected: (index) => _goToPage(index, navigationItems),
      selectedIndex: safeIndex,
      labelBehavior: noTextMode ? NavigationDestinationLabelBehavior.alwaysHide : NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
    if (isDesktop) {
      return Container(
        color: context.colorScheme.surface,
        child: Column(children: [
          const WindowTitleBar(),
          Expanded(child: pageBody),
          SafeArea(child: navBar),
        ]),
      );
    }
    // Mobile: use Scaffold so keyboard / system bars are handled correctly
    return Scaffold(
      body: pageBody,
      bottomNavigationBar: navBar,
    );
  }
}
