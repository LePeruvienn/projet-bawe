import 'package:flutter/material.dart';

import '../models.dart';
import '../api.dart';

class UsersPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'), // Page title
      ),
      body: Column(
        children: [
          Expanded(
            child: UserList(), // Your UserList widget goes here
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Define your button action here
                print('Button Pressed'); // Example action
              },
              child: Text('Take Action'), // Button label
            ),
          ),
        ],
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
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(user.username[0]),
      ),
      title: Text(user.username),
    );
  }
}
