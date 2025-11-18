import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

import 'auth/tokenHandler.dart';
import 'auth/authProvider.dart';
import 'routes.dart';

const LOCALE_STORAGE_KEY = 'feur_saved_local';

const DEFAULT_TEXT_SCALE = 1.0;
const TABLET_TEXT_SCALE = 1.1;
const DESKTOP_TEXT_SCALE = 1.25;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy());

  await TokenHandler().init();

  final authProvider = AuthProvider();
  await authProvider.init();

  // Get saved theme mode
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  // Get saved local code
  final prefs = await SharedPreferences.getInstance();
  final savedLocalCode = prefs.getString(LOCALE_STORAGE_KEY);

  runApp(
    ChangeNotifierProvider(
      create: (_) => authProvider,
      child: MyApp(savedThemeMode: savedThemeMode, savedLocalCode: savedLocalCode),
    ),
  );
}

class MyApp extends StatefulWidget {

  final AdaptiveThemeMode? savedThemeMode;
  final String? savedLocalCode;

  const MyApp({super.key, this.savedThemeMode, this.savedLocalCode});

  static _MyAppState of(BuildContext context) {

    // This looks up the tree for the nearest State object of type _MyAppState and returns it.
    return context.findAncestorStateOfType<_MyAppState>()!;
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Locale _locale = const Locale('en');

  @override
  void initState() {

    super.initState();

    final localCode = widget.savedLocalCode;

    if (localCode != null) {

      setState(() {
        _locale = Locale(localCode);
      });
    }

  }

  void setLocale(String localCode) async {

    setState(() {
      _locale = Locale(localCode);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LOCALE_STORAGE_KEY, localCode);
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

        builder: (context, child) { 

          double textScale = DEFAULT_TEXT_SCALE;
          final width = MediaQuery.of(context).size.width;

          if (width >= 600 && width < 1024) textScale = TABLET_TEXT_SCALE;
          if (width >= 1024) textScale = DESKTOP_TEXT_SCALE;

          final originalMediaQuery = MediaQuery.of(context);
          final scaledMediaQuery = originalMediaQuery.copyWith(textScaleFactor: textScale);

          return MediaQuery(
            data: scaledMediaQuery,
            child: child!, 
          );
        }
      )
    );
  }
}
