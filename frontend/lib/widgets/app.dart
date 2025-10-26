import 'package:flutter/material.dart';
import 'account.dart';
import 'users.dart';
import 'posts.dart';
import 'login.dart';
import 'signin.dart';

// The mange page this is gonna contain the page rendererd + navigation bar
class AppPage extends StatelessWidget {

  // Contructor
  const AppPage({super.key});

  // Built Widget
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Navigation());
  }
}

// StatefulWidget That is gonna update depending of NavigationState
class Navigation extends StatefulWidget {

  const Navigation({super.key});

  // State Contructor
  @override
  State<Navigation> createState() => _NavigationState();
}

// Navigation State handling actions when triggering event
class _NavigationState extends State<Navigation> {

  // Current page Index
  int currentPageIndex = 0;

  // Current Widget is built with body is the main page and a bottomNavigationBar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: _getPage(currentPageIndex),
    );
  }

  // Builded Navigation Bar
  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          currentPageIndex = index;
        });
      },
      indicatorColor: Colors.deepPurple.shade100,
      selectedIndex: currentPageIndex,
      destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.notifications_sharp)),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.person)),
            label: 'Account',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.settings)),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.shield)),
            label: 'Admin',
          ),
      ],
    );
  }

  Widget _getPage(int index) {
    // Replace with your actual page widgets
    List<Widget> pages = [
      PostsPage(),
      LoginPage(),
      SigninPage(),
      AccountPage(),
      UsersPage(),
    ];

    return pages[index];
  }
}
