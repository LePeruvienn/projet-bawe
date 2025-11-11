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

const HOME_DESTINSATION = DestinationData(
                            selectedIcon: Icons.home,
                            icon: Icons.home_outlined,
                            text: 'Home',
                            path: HOME_PATH
                          );

const LOGIN_DESTINATION = DestinationData(
                            selectedIcon: Icons.person,
                            icon: Icons.person_outlined,
                            text: 'Login',
                            path: LOGIN_PATH
                          );


const SIGNIN_DESTINATION = DestinationData(
                            selectedIcon: Icons.person_add,
                            icon: Icons.person_add_outlined,
                            text: 'Signin',
                            path: SIGNIN_PATH
                          );

const ACCOUNT_DESTINATION = DestinationData(
                              selectedIcon: Icons.person,
                              icon: Icons.person_outlined,
                              text: 'Acccount',
                              path: ACCOUNT_PATH
                            );
const ADMIN_DESTINATION = DestinationData(
                            selectedIcon: Icons.shield,
                            icon: Icons.shield_outlined,
                            text: 'Admin',
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
List<DestinationData> getDestinations(AuthProvider auth) {

  // If not logged in returns default destinations
  if (!auth.isLoggedIn)
    return DEFAULT_DESTINATIONS;

  // If logged in but not admin return connected destinations
  if (!auth.isAdmin)
    return CONNECTED_DESTINATIONS;

  // If connected & admin return admin destinations
  return CONNECTED_ADMIN_DESTINATIONS;
}

/******************
* NAVIGATION LAYOUT
*******************/

class FeurAppBar extends StatelessWidget implements PreferredSizeWidget {

  const FeurAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'FEUR',
        style: TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      centerTitle: true,
      elevation: 0, // remove default shadow if you want
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
        ),
      ),
    );
  }
}

class _DesktopShell extends StatelessWidget {

  final List<DestinationData> destinations;
  final int selectedIndex;
  final Widget child;

  const _DesktopShell({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const FeurAppBar(),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: colorScheme.surface, // Use default surface color
            child: Column(
              children: [
                SizedBox(height: 8),
                // Navigation items
                Expanded(
                  child: ListView.builder(
                    itemCount: destinations.length,
                    itemBuilder: (context, index) {

                      final d = destinations[index];
                      final isSelected = selectedIndex == index;

                      return InkWell(
                        onTap: () => context.go(d.path),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: colorScheme.primaryContainer
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(24),
                                ) : null,
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? d.selectedIcon : d.icon,
                                size: 36,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                d.text,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Text(
                    "Made with ❤️",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {

  final List<DestinationData> destinations;
  final int selectedIndex;
  final Widget child;

  const _MobileShell({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {

    // Parse NavigationDestination to -> NavigationRailDestination objects
    final _destinations =
      destinations.map((d) => NavigationDestination(
        icon: Icon(d.icon),
        selectedIcon: Icon(d.selectedIcon),
        label: d.text,
      ))
      .toList();

    return Scaffold(
      appBar: const FeurAppBar(),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          context.go(destinations[index].path);
        },
        destinations: _destinations,
      )
    );
  }
}

/****************
* NAVIGATION PAGE
*****************/

class NavigationShell extends StatefulWidget {

  final Widget child;
  const NavigationShell({super.key, required this.child});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {

  @override
  Widget build(BuildContext context) {

    final auth = context.watch<AuthProvider>();
    final _destinations = getDestinations(auth);
    final String currentPath = GoRouterState.of(context).matchedLocation;
    final int index = _destinations.indexWhere((destination) => destination.path == currentPath);

    return LayoutBuilder(
      builder: (context, constraints) {

        final bool isDesktop = constraints.maxWidth > 800;

        // >>> Deskstop
        if (isDesktop) {

          return _DesktopShell(
            destinations: _destinations,
            selectedIndex: index,
            child: widget.child,
          );

        // >>> Mobile
        } else {

          return _MobileShell(
            destinations: _destinations,
            selectedIndex: index,
            child: widget.child,
          );
        }
      },
    );
  }
}
