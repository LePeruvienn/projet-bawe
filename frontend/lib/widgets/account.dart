import 'package:flutter/material.dart';

import '../auth/authProvider.dart';
import '../models/user.dart';
import '../api/users.dart';
import '../api/auth.dart';
import '../utils.dart';
import 'users.dart';

/************************
* GLOBALS ACCOUNT FUNCTIONS
*************************/

void handleLogout(BuildContext context) async {

  await AuthProvider().logout();

  showSnackbar(
    context: context,
    dismissText: context.loc.logoutSuccess,
    backgroundColor: Colors.deepPurple,
    icon: Icon(Icons.done, color: Colors.white),
  );
}

/************************
* GLOBALS ACCOUNT CLASSES
*************************/

class AccountPage extends StatefulWidget {

  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  late Future<User> futureUser;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureUser = fetchConnectedUser();
  }

  void refreshUser() {
    setState(() {
      futureUser = fetchConnectedUser();
    });
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SizedBox(
        width: 800, 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<User>(
                  future: futureUser,
                  builder: (context, snapshot) {

                    // While we are waiting show progression
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Center(child: CircularProgressIndicator());

                    // When error, show error message at center
                    else if (snapshot.hasError)
                      return Center(child: Text(context.loc.error(snapshot.error.toString())));

                    // If we have no data return no data error
                    else if (!snapshot.hasData)
                      //TODO: ERROR WIDGET
                      return Center(child: ErrorText(
                        header: context.loc.areYouAGhost, 
                        message: context.loc.noUserDataAvaible,
                        color: colorScheme.primary
                      ));

                    // Ge fetched user
                    final user = snapshot.data!;

                    // Create AccountDetails component with it
                    return AccountDetails(user: user, onUserUpdate: refreshUser);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountDetails extends StatelessWidget {

  final User user;
  final VoidCallback onUserUpdate;

  const AccountDetails({
    super.key,
    required this.user,
    required this.onUserUpdate
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                user.username[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              user.title ?? user.username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 30),

        _InfoCard(
          title: context.loc.userInformation,
          user: user,
          items: [
            _InfoItem(icon: Icons.badge, label: context.loc.id, value: user.id.toString()),
            _InfoItem(icon: Icons.person, label: context.loc.username, value: user.username),
            _InfoItem(icon: Icons.email, label: context.loc.email, value: user.email),
            _InfoItem(icon: Icons.title, label: context.loc.title, value: user.title ?? '—'),
            _InfoItem(
              icon: Icons.calendar_today,
              label: context.loc.createdAt,
              value: user.createdAt.toLocal().toString().split('.')[0],
            ),
            if (user.isAdmin)
              _InfoItem(icon: Icons.lock, label: context.loc.admin, value: user.title ?? context.loc.yes),
          ],
          onUserUpdate: onUserUpdate
        ),
        // Logout Button
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => handleLogout(context),
          child: Text(context.loc.logout),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  
  final String title;
  final User user;
  final List<_InfoItem> items;

  final VoidCallback onUserUpdate;

  const _InfoCard({
    required this.title,
    required this.user,
    required this.items,
    required this.onUserUpdate
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                IconButton(
                  icon: const Icon(Icons.edit), // Use an appropriate icon
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: UserForm(title: context.loc.editUser, user: user, callback: onUserUpdate),
                      ),
                    );
                  },
                )
              ]
            ),
            const Divider(),
            ...items.map((item) => _InfoRow(item: item)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final _InfoItem item;

  const _InfoRow({required this.item});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(item.icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(item.value, textAlign: TextAlign.right),
        ],
      ),
    );
  }
}

class _InfoItem {

  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({

    required this.icon,
    required this.label,
    required this.value,
  });
}
