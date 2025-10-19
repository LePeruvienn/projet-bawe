import 'package:flutter/material.dart';

import '../models.dart';
import '../api.dart';

class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: Column(
        children: [
          Expanded(
            child: UserList(), // Your UserList widget goes here
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Define your button action here
          print('Button Pressed'); // Example action
        },
        child: const Icon(Icons.add), // Button label
      ),
    );
  }
}

class UserList extends StatefulWidget {

  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListeState();
}

class _UserListeState extends State<UserList> {

  late Future<List<User>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: futureUsers,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {

          return Center(child: CircularProgressIndicator());

        } else if (snapshot.hasError) {

          return Center(child: Text('Error: ${snapshot.error}'));

        } else {
          return ListView(

            children: snapshot.data!.map((user) => UserListItem(user: user)).toList(),
          );
        }
      },
    );
  }
}

class UserListItem extends StatelessWidget  {

  final User user;

  UserListItem({
    required this.user
  }) : super(key: ObjectKey(user));

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple.shade100,
        child: Text(user.username[0]),
      ),
      title: Text(user.username),
    );
  }
}
