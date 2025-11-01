import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/posts.dart';
import 'widgets/account.dart';
import 'widgets/users.dart';
import 'widgets/login.dart';
import 'widgets/signin.dart';
import 'widgets/navigation.dart';

class AppRouter extends StatelessWidget {

  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return NavigationShell(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => PostsPage(),
            ),
            GoRoute(
              path: '/notifications',
              builder: (context, state) => LoginPage(),
            ),
            GoRoute(
              path: '/account',
              builder: (context, state) => SigninPage(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => AccountPage(),
            ),
            GoRoute(
              path: '/admin',
              builder: (context, state) => UsersPage(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
