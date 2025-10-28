import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';

import 'auth/tokenHandler.dart';

void main() async {

  // Initialze TokenHandler singleton
  await TokenHandler().init();

  // Run main app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final GoRouter _router = AppRouter.router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'FeurX',
    );
  }
}
