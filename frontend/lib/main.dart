import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';

import 'auth/tokenHandler.dart';

void main() async {

  // Initialze TokenHandler singleton
  await TokenHandler().init();

  // Run main app
  runApp(const AppRouter());
}
