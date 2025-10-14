import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  final GoRouter _router = AppRouter.router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'My Web App',
    );
  }
}
