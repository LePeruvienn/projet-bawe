import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationShell extends StatefulWidget {

  final Widget child;
  const NavigationShell({super.key, required this.child});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;

  final _paths = [
    '/home',
    '/notifications',
    '/account',
    '/settings',
    '/admin',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child, // Contenu de la page changée
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          context.go(_paths[index]); // Change l’URL sans recharger
        },
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_sharp),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
