import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/posts.dart';
import 'widgets/account.dart';
import 'widgets/users.dart';
import 'widgets/login.dart';
import 'widgets/signin.dart';
import 'widgets/navigation.dart';
import 'auth/authProvider.dart';

/************************
* GLOBAL ROUTES CONSTANTS
*************************/

const HOME_PATH    = '/home';
const LOGIN_PATH   = '/login';
const SIGNIN_PATH  = '/signin';
const ACCOUNT_PATH = '/account';
const ADMIN_PATH   = '/admin';

/************************
* GLOBAL ROUTES FINALS
*************************/

final appRoutes = [
  GoRoute(path: HOME_PATH, builder: (_, __) => PostsPage()),
  GoRoute(path: LOGIN_PATH, builder: (_, __) => LoginPage()),
  GoRoute(path: SIGNIN_PATH, builder: (_, __) => SigninPage()),
  GoRoute(path: ACCOUNT_PATH, builder: (_, __) => AccountPage()),
  GoRoute(path: ADMIN_PATH, builder: (_, __) => UsersPage()),
];

// To get the singleton instance once
final authProvider = AuthProvider();

final GoRouter router = GoRouter(

  initialLocation: HOME_PATH,
  refreshListenable: authProvider,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return NavigationShell(child: child);
      },
      routes: appRoutes
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {

    // Get the current location the user is trying to go
    final String location = state.matchedLocation;

    // Protected routes
    final bool isGoingToAuthPage = location == LOGIN_PATH || location == SIGNIN_PATH;
    final bool isGoingToAccountPage = location == ACCOUNT_PATH;
    final bool isGoingToAdminPage = location == ADMIN_PATH;

    // If user logged in and tries to login / signin 
    if (authProvider.isLoggedIn && isGoingToAuthPage)
      return HOME_PATH;

    // If user is not logged in and tries to go to admin or account page
    if (!authProvider.isLoggedIn && (isGoingToAccountPage || isGoingToAdminPage))
      return LOGIN_PATH;

    // If user is not admin and tries to go to admin page
    if (authProvider.isLoggedIn && !authProvider.isAdmin && isGoingToAdminPage)
      return HOME_PATH;

    // Return null if no redirection needed
    return null;
  }
);

/************************
* GLOBAL ROUTES CLASSES
*************************/

class AppRouter extends StatelessWidget {

  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
