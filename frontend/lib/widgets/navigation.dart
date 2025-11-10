import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/authProvider.dart';
import '../routes.dart';
import '../utils.dart';

/****************************
* GLOBAL NAVIGATION CONSTANTS
*****************************/

/*
 * All destinations widgets :
 */

const HOME_DESTINSATION = NavigationDestinationWithPath(
                            selectedIcon: Icon(Icons.home),
                            icon: Icon(Icons.home_outlined),
                            label: 'Home',
                            path: HOME_PATH
                          );

const LOGIN_DESTINATION = NavigationDestinationWithPath(
                            selectedIcon: Icon(Icons.person),
                            icon: Icon(Icons.person_outlined),
                            label: 'Login',
                            path: LOGIN_PATH
                          );


const SIGNIN_DESTINATION = NavigationDestinationWithPath(
                            selectedIcon: Icon(Icons.person_add),
                            icon: Icon(Icons.person_add_outlined),
                            label: 'Signin',
                            path: SIGNIN_PATH
                          );

const ACCOUNT_DESTINATION = NavigationDestinationWithPath(
                              selectedIcon: Icon(Icons.person),
                              icon: Icon(Icons.person_outlined),
                              label: 'Acccount',
                              path: ACCOUNT_PATH
                            );
const ADMIN_DESTINATION = NavigationDestinationWithPath(
                            selectedIcon: Icon(Icons.shield),
                            icon: Icon(Icons.shield_outlined),
                            label: 'Admin',
                            path: ADMIN_PATH
                          );

/*
 * All groupes of destinations sorted depending of auth state :
 */

const DEFAULT_DESTINATIONS = [
  HOME_DESTINSATION,
  LOGIN_DESTINATION,
  SIGNIN_DESTINATION
];

const CONNECTED_DESTINATIONS = [
  HOME_DESTINSATION,
  ACCOUNT_DESTINATION
];

const CONNECTED_ADMIN_DESTINATIONS = [
  HOME_DESTINSATION,
  ACCOUNT_DESTINATION,
  ADMIN_DESTINATION
];

/****************************
* GLOBAL NAVIGATION FUNCTIONS
*****************************/

/*
 * Get destinations depending of current user auth state
 */
List<NavigationDestinationWithPath> getDestinations(AuthProvider auth) {

  // If not logged in returns default destinations
  if (!auth.isLoggedIn)
    return DEFAULT_DESTINATIONS;

  // If logged in but not admin return connected destinations
  if (!auth.isAdmin)
    return CONNECTED_DESTINATIONS;

  // If connected & admin return admin destinations
  return CONNECTED_ADMIN_DESTINATIONS;
}

/****************************
* GLOBAL NAVIGATION CLASSES
*****************************/

class NavigationShell extends StatefulWidget {

  final Widget child;
  const NavigationShell({super.key, required this.child});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {

  @override
  Widget build(BuildContext context) {

    // Get destinations depending of the authentification state
    final auth = context.watch<AuthProvider>();
    final _destinations = getDestinations(auth);

    // Find selected index depending of router path
    final String currentPath = GoRouterState.of(context).matchedLocation;
    final int index = _destinations.indexWhere((destination) => destination.path == currentPath);

    // Build Navigation Widget
    return Scaffold(
      appBar: AppBar(
        title: const Text('FeurX'),
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (index) {
          context.go(_destinations[index].path);
        },
        destinations: _destinations,
      )
    );
  }
}
