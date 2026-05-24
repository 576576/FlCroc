import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/l10n/l10n.dart';
import 'package:fl_croc/manager/theme_manager.dart';
import 'package:fl_croc/models/models.dart';
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
        final themeProps = ref.watch(themeSettingProvider);
        final appSettings = ref.watch(appSettingProvider);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: globalState.navigatorKey,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (_, child) {
            return ThemeManager(child: child!);
          },
          title: appName,
          locale: appSettings.locale != null
              ? Locale(appSettings.locale!)
              : null,
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: _getThemeMode(appSettings.themeMode),
          theme: _buildLightTheme(themeProps),
          darkTheme: _buildDarkTheme(themeProps),
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

  ThemeData _buildLightTheme(ThemeProps props) {
    final seedColor = Color(props.primaryColor);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  ThemeData _buildDarkTheme(ThemeProps props) {
    final seedColor = Color(props.primaryColor);
    final settings = ref.read(appSettingProvider);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: settings.pureBlackMode
          ? Colors.black
          : null,
    );
  }
}
