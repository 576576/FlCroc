import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/l10n/l10n.dart';
import 'package:fl_croc/manager/theme_manager.dart';
import 'package:fl_croc/pages/pages.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    });
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (_, child) {
            return ThemeManager(child: child!);
          },
          title: appName,
          locale: locale != null ? Locale(locale) : _resolveSystemLocale(),
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: _getThemeMode(appSettings.themeMode),
          theme: _buildLightTheme(themeProps.primaryColor),
          darkTheme: _buildDarkTheme(themeProps.primaryColor, appSettings.pureBlackMode),
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

  /// Resolve the system locale against supported locales. Defaults to English.
  Locale _resolveSystemLocale() {
    final system = WidgetsBinding.instance.platformDispatcher.locale;
    final supported = AppLocalizations.supportedLocales;

    // Exact match (language + country)
    for (final loc in supported) {
      if (loc.languageCode == system.languageCode &&
          (loc.countryCode == null || loc.countryCode == system.countryCode)) {
        return loc;
      }
    }
    // Language-only match
    for (final loc in supported) {
      if (loc.languageCode == system.languageCode && loc.countryCode == null) {
        return loc;
      }
    }
    return const Locale('en');
  }

  ThemeData _buildLightTheme(int primaryColor) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: cachedColorScheme(primaryColor, Brightness.light),
      fontFamilyFallback: const ['Microsoft YaHei', 'PingFang SC', 'Noto Sans CJK SC'],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  ThemeData _buildDarkTheme(int primaryColor, bool isPureBlack) {
    var scheme = cachedColorScheme(primaryColor, Brightness.dark);
    if (isPureBlack) {
      scheme = scheme.copyWith(
        surface: const Color(0xFF0A0A0A),
        surfaceContainer: const Color(0xFF111111),
        surfaceContainerHighest: const Color(0xFF181818),
      );
    }
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamilyFallback: const ['Microsoft YaHei', 'PingFang SC', 'Noto Sans CJK SC'],
      scaffoldBackgroundColor: isPureBlack ? Colors.black : null,
    );
  }
}
