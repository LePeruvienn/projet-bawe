import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';

import 'auth/tokenHandler.dart';
import 'auth/authProvider.dart';

import 'routes.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Set URL paths server side (to not have an hashed router)
  setPathUrlStrategy();

  // Initialze TokenHandler singleton
  await TokenHandler().init();
  await AuthProvider().init();

  // Run main app
  runApp(const AppRouter());
}
