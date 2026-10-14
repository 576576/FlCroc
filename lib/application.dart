import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/l10n/l10n.dart';
import 'package:fl_croc/manager/theme_manager.dart';
import 'package:fl_croc/pages/pages.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class Application extends ConsumerStatefulWidget {
  const Application({super.key});

  @override
  ConsumerState<Application> createState() => _ApplicationState();
}

class _ApplicationState extends ConsumerState<Application> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appController.attach(context, ref);
      _autoCheckUpdate();
    });
  }

  Future<void> _autoCheckUpdate() async {
    final settings = ref.read(appSettingProvider);
    if (!settings.autoCheckUpdate) return;
    final currentVer = globalState.packageInfo.version;
    final currentBuild = globalState.packageInfo.buildNumber;
    final channel = settings.updateChannel;
    try {
      final data = channel == UpdateChannel.nightly
          ? await fetchLatestPrerelease(repository)
          : await fetchLatestRelease(repository);
      if (data == null) return;
      final latestTag =
          (data['tag_name'] as String?)?.replaceFirst(RegExp(r'^v'), '') ?? '';
      if (channel == UpdateChannel.nightly) {
        final title = (data['name'] as String?) ?? '';
        final buildMatch = RegExp(r'\+(\d+)').firstMatch(title);
        final nightlyBuild = buildMatch != null
            ? int.tryParse(buildMatch.group(1)!) ?? 0
            : 0;
        final curBuild = int.tryParse(currentBuild) ?? 0;
        if (nightlyBuild <= curBuild) return;
      } else {
        if (latestTag.isEmpty || _isVersionSameOrOlder(latestTag, currentVer)) {
          return;
        }
      }
      if (!mounted) return;
      final ctx = globalState.navigatorKey.currentContext;
      // ctx 不是本 State 的 context，!mounted 拦不住它 —— 必须查它自己的 mounted。
      if (ctx == null || !ctx.mounted) return;
      showDialog(
        context: ctx,
        builder: (ctx2) => AlertDialog(
          title: Text(AppLocalizations.of(ctx).newVersionAvailable),
          content: Text(
            '${AppLocalizations.of(ctx).latestVersion}: $latestTag\n${AppLocalizations.of(ctx).currentVersion}: $currentVer',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx2),
              child: Text(AppLocalizations.of(ctx).cancel),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx2);
                globalState.openUrl('https://github.com/$repository/releases');
              },
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(AppLocalizations.of(ctx).update),
            ),
          ],
        ),
      );
    } catch (_) {}
  }

  /// Returns true if [latest] is the same base version as [current] or older.
  static bool _isVersionSameOrOlder(String latest, String current) {
    final latestBase = latest.split(RegExp(r'[-+]')).first;
    final currentBase = current.split(RegExp(r'[-+]')).first;
    final latestParts = latestBase.split('.').map(int.tryParse).toList();
    final currentParts = currentBase.split('.').map(int.tryParse).toList();
    final len = latestParts.length > currentParts.length
        ? latestParts.length
        : currentParts.length;
    for (int i = 0; i < len; i++) {
      final l = i < latestParts.length ? (latestParts[i] ?? 0) : 0;
      final c = i < currentParts.length ? (currentParts[i] ?? 0) : 0;
      if (l > c) return false;
      if (l < c) return true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, child) {
        final locale = ref.watch(
          appSettingProvider.select((state) => state.locale),
        );
        final appSettings = ref.watch(appSettingProvider);
        final themeProps = ref.watch(themeSettingProvider);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: globalState.navigatorKey,
          // GlobalMaterialLocalizations.delegates 已包含 Cupertino 与 Widgets 委托。
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          builder: (_, child) {
            // 依赖里仍有包在用旧的核心 material（super_sliver_list、qr_flutter、
            // fluttertoast、desktop_drop、defer_pointer 等），桥负责把新包的 ThemeData
            // 映射回去，让那些 widget 还能取到 legacy 的 Theme 与 Localizations。
            // 桥自身已标记废弃（它是过渡工具，依赖迁完就该删），但我们的依赖还没迁完，
            // 现在必须留着它。
            // ignore: deprecated_member_use
            return MaterialUiCompatibilityBridge(
              child: ThemeManager(child: child!),
            );
          },
          scrollBehavior: const _NaturalScrollBehavior(),
          title: appName,
          locale: locale != null
              ? _parseLocale(locale)
              : _resolveSystemLocale(),
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: _getThemeMode(appSettings.themeMode),
          theme: _buildLightTheme(
            themeProps.primaryColor,
            appSettings.disableAnimations,
          ),
          darkTheme: _buildDarkTheme(
            themeProps.primaryColor,
            appSettings.pureBlackMode,
            appSettings.disableAnimations,
          ),
          home: const HomePage(),
        );
      },
    );
  }

  ThemeMode _getThemeMode(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  /// Parse a locale string like 'zh-Hant' into a proper [Locale] with scriptCode.
  Locale _parseLocale(String s) {
    final parts = s.split('-');
    if (parts.length >= 3) {
      return Locale.fromSubtags(
        languageCode: parts[0],
        scriptCode: parts[1],
        countryCode: parts[2],
      );
    } else if (parts.length == 2) {
      // Could be script or country — try script (uppercase 4-char = script)
      return (parts[1].length == 4)
          ? Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1])
          : Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  /// Resolve the system locale against supported locales. Defaults to English.
  /// Matches by scriptCode first, then languageCode + countryCode.
  Locale _resolveSystemLocale() {
    final system = WidgetsBinding.instance.platformDispatcher.locale;
    final supported = AppLocalizations.supportedLocales;

    // Exact match (language + script + country)
    for (final loc in supported) {
      if (loc.languageCode == system.languageCode &&
          (loc.scriptCode == null || loc.scriptCode == system.scriptCode) &&
          (loc.countryCode == null || loc.countryCode == system.countryCode)) {
        return loc;
      }
    }
    // Language + script match
    for (final loc in supported) {
      if (loc.languageCode == system.languageCode &&
          loc.scriptCode != null &&
          loc.scriptCode == system.scriptCode) {
        return loc;
      }
    }
    // Language + country match
    for (final loc in supported) {
      if (loc.languageCode == system.languageCode &&
          (loc.countryCode == null || loc.countryCode == system.countryCode)) {
        return loc;
      }
    }
    // Language-only match
    for (final loc in supported) {
      if (loc.languageCode == system.languageCode &&
          loc.countryCode == null &&
          loc.scriptCode == null) {
        return loc;
      }
    }
    return const Locale('en');
  }

  ThemeData _buildLightTheme(int primaryColor, bool disableAnimations) {
    return _buildBaseTheme(
      cachedColorScheme(primaryColor, Brightness.light),
      disableAnimations,
    );
  }

  ThemeData _buildDarkTheme(
    int primaryColor,
    bool isPureBlack,
    bool disableAnimations,
  ) {
    var scheme = cachedColorScheme(primaryColor, Brightness.dark);
    if (isPureBlack) {
      scheme = scheme.copyWith(
        surface: Colors.black,
        surfaceContainer: const Color(0xFF0A0A0A),
        surfaceContainerHighest: const Color(0xFF111111),
        surfaceContainerLow: const Color(0xFF050505),
        surfaceContainerHigh: const Color(0xFF151515),
      );
    }
    return _buildBaseTheme(
      scheme,
      disableAnimations,
    ).copyWith(scaffoldBackgroundColor: isPureBlack ? Colors.black : null);
  }

  ThemeData _buildBaseTheme(ColorScheme colorScheme, bool disableAnimations) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamilyFallback: const [
        'Microsoft YaHei',
        'PingFang SC',
        'Noto Sans CJK SC',
      ],
      pageTransitionsTheme: PageTransitionsTheme(
        builders: disableAnimations
            ? {
                for (final p in TargetPlatform.values)
                  p: const _NoTransitionBuilder(),
              }
            : {
                for (final p in TargetPlatform.values)
                  p: const CupertinoPageTransitionsBuilder(),
              },
      ),
    );
  }
}

/// No-op page transition — skips all animations.
class _NoTransitionBuilder extends PageTransitionsBuilder {
  const _NoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

/// Smoother, more natural scroll physics on all platforms.
class _NaturalScrollBehavior extends MaterialScrollBehavior {
  const _NaturalScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(
        decelerationRate: ScrollDecelerationRate.normal,
      );
}
