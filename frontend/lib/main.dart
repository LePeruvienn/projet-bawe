import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:provider/provider.dart';

import 'auth/tokenHandler.dart';
import 'auth/authProvider.dart';

import 'routes.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Set URL paths server side (to not have an hashed router)
  setPathUrlStrategy();

  // Initialze TokenHandler singleton
  await TokenHandler().init();

  // Get AuthProvider instance & init it
  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => authProvider,
      child: const AppPage()
    ),
  );
}

class AppPage extends StatelessWidget {

  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'ComicSansMS', 
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
