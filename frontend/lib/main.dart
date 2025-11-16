import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'auth/tokenHandler.dart';
import 'auth/authProvider.dart';
import 'routes.dart';

const DEFAULT_TEXT_SCALE = 1.00;
const TABLET_TEXT_SCALE  = 1.10;
const DESKTOP_TEXT_SCALE = 1.25;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  await TokenHandler().init();

  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => authProvider,
      child: const AppPage(),
    ),
  );
}

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isTablet = width >= 600 && width < 1024;
    final bool isDesktop = width >= 1024;

    double textScale = DEFAULT_TEXT_SCALE;
    if (isTablet) textScale = TABLET_TEXT_SCALE;
    if (isDesktop) textScale = DESKTOP_TEXT_SCALE;

    final originalMediaQueryData = MediaQuery.of(context);
    final scaledMediaQueryData = originalMediaQueryData.copyWith(
      textScaler: TextScaler.linear(textScale),
    );

    return MediaQuery(
      data: scaledMediaQueryData,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'ComicSansMS',
          useMaterial3: true,
        ),

        // 👇 i18n configuration
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
