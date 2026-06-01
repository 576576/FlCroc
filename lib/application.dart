import 'dart:convert';
import 'dart:io';

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
      final client = HttpClient();
      try {
        final tag = channel == UpdateChannel.nightly ? 'tags/nightly' : 'releases/latest';
        final uri = Uri.https('api.github.com', '/repos/$repository/$tag');
        final request = await client.getUrl(uri);
        request.headers.set('User-Agent', 'FlCroc');
        request.headers.set('Accept', 'application/vnd.github+json');
        final response = await request.close();
        if (response.statusCode != 200) return;
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final latestTag = (data['tag_name'] as String?)?.replaceFirst(RegExp(r'^v'), '') ?? '';
        if (channel == UpdateChannel.nightly) {
          final title = (data['name'] as String?) ?? '';
          final buildMatch = RegExp(r'\+(\d+)').firstMatch(title);
          final nightlyBuild = buildMatch != null ? int.tryParse(buildMatch.group(1)!) ?? 0 : 0;
          final curBuild = int.tryParse(currentBuild) ?? 0;
          if (nightlyBuild <= curBuild) return;
        } else {
          if (latestTag.isEmpty || _isVersionSameOrOlder(latestTag, currentVer)) return;
        }
        if (!mounted) return;
        final ctx = globalState.navigatorKey.currentContext;
        if (ctx == null) return;
        showDialog(
          context: ctx,
          builder: (ctx2) => AlertDialog(
            title: Text(AppLocalizations.of(ctx)!.newVersionAvailable),
            content: Text('${AppLocalizations.of(ctx)!.latestVersion}: $latestTag\n${AppLocalizations.of(ctx)!.currentVersion}: $currentVer'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx2),
                child: Text(AppLocalizations.of(ctx)!.cancel),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx2);
                  globalState.openUrl('https://github.com/$repository/releases');
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(AppLocalizations.of(ctx)!.update),
              ),
            ],
          ),
        );
      } finally {
        client.close();
      }
    } catch (_) {}
  }

  /// Returns true if [latest] is the same base version as [current] or older.
  static bool _isVersionSameOrOlder(String latest, String current) {
    final latestBase = latest.split(RegExp(r'[-+]')).first;
    final currentBase = current.split(RegExp(r'[-+]')).first;
    final latestParts = latestBase.split('.').map(int.tryParse).toList();
    final currentParts = currentBase.split('.').map(int.tryParse).toList();
    final len = latestParts.length > currentParts.length ? latestParts.length : currentParts.length;
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
