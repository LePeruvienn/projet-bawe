import 'package:flutter/material.dart';
import '../models/user.dart';
import '../api/users.dart';

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
    futureUser = fetchUser(1);
  }

  void _searchUser() {

    final input = _controller.text.trim();
    if (input.isEmpty) return;

    final id = int.tryParse(input);
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid user ID')),
      );
      return;
    }

    setState(() {
      futureUser = fetchUser(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search input and button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter user ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _searchUser,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User info (FutureBuilder)
            Expanded(
              child: FutureBuilder<User>(
                future: futureUser,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('No user data available'));
                  }

                  final user = snapshot.data!;
                  return AccountDetails(user: user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountDetails extends StatelessWidget {
  final User user;

  const AccountDetails({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.deepPurple.shade100,
              child: Text(
                user.username[0].toUpperCase(),
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              user.title ?? user.username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(user.email, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 30),

        _InfoCard(
          title: 'User Information',
          items: [
            _InfoItem(icon: Icons.badge, label: 'ID', value: user.id.toString()),
            _InfoItem(icon: Icons.person, label: 'Username', value: user.username),
            _InfoItem(icon: Icons.email, label: 'Email', value: user.email),
            _InfoItem(icon: Icons.lock, label: 'Password', value: user.password),
            _InfoItem(icon: Icons.title, label: 'Title', value: user.title ?? '—'),
            _InfoItem(
              icon: Icons.calendar_today,
              label: 'Created At',
              value: user.createdAt.toLocal().toString().split('.')[0],
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;

  const _InfoCard({required this.title, required this.items});

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
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(item.icon, size: 20, color: Colors.deepPurple),
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
