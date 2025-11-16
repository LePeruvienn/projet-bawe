import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'l10n/app_localizations.dart';

import 'auth/tokenHandler.dart';
import 'auth/authProvider.dart';
import 'routes.dart';

const DEFAULT_TEXT_SCALE = 1.0;
const TABLET_TEXT_SCALE = 1.1;
const DESKTOP_TEXT_SCALE = 1.25;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  await TokenHandler().init();

  final authProvider = AuthProvider();
  await authProvider.init();

  // Get saved theme mode
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(
    ChangeNotifierProvider(
      create: (_) => authProvider,
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class MyApp extends StatefulWidget {

  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  static _MyAppState of(BuildContext context) {
    // This looks up the tree for the nearest State object of type _MyAppState
    // and returns it.
    return context.findAncestorStateOfType<_MyAppState>()!;
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {

    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {

    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: 'ComicSansMS',
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'ComicSansMS',
      ),
      initial: widget.savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
        ],
        routerConfig: router,
      ),
    );
  }
}
