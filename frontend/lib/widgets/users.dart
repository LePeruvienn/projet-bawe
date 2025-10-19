import 'package:flutter/material.dart';

import '../models.dart';
import '../api.dart';
import '../utils.dart';

class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  // Define your refresh action here
                  print('Refresh Pressed'); // Example action
                },
              ),
            ],
          ),
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
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late Future<List<User>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = fetchUsers();
  }

  // Used to refrech the users after delete / update
  Future<void> _refreshUsers() async {
    setState(() {
      futureUsers = fetchUsers();
    });
  }

  // UserListItem buttons functions :
  void _deleteUser(int id) async {

    bool res = await deleteUser(id);

    ScaffoldMessenger.of(context).showSnackBar(
      createSnackbar(
        dismissText: res ? 'User successfully deleted' : 'Failed to delete user',
        backgroundColor: res ? Colors.deepPurple : Colors.red,
        icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
      ),
    );

    // IDK if let it here
    // _refreshUsers();
  }

  void _editUser(int id) {
    print("Edit user");
  }

  void _infoUser(int id) {
    print("Info user");
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
            children: snapshot.data!.map((user) {
              return UserListItem(
                user: user,
                onDelete: _deleteUser,
                onEdit: _editUser,
                onInfo: _infoUser,
              );
            }).toList(),
          );
        }
      },
    );
  }
}

class UserListItem extends StatefulWidget {

  final User user;
  final Function(int) onDelete;
  final Function(int) onEdit;
  final Function(int) onInfo;

  UserListItem({
    required this.user,
    required this.onDelete,
    required this.onEdit,
    required this.onInfo,
  }) : super(key: ObjectKey(user));

  @override
  _UserListItemState createState() => _UserListItemState();
}

class _UserListItemState extends State<UserListItem> {

  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        color: _isHovered ? Colors.black.withOpacity(0.1) : Colors.transparent,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple.shade100,
            child: Text(widget.user.username[0]),
          ),
          title: Text(widget.user.username),
          trailing: Opacity(
            opacity: _isHovered ? 1.0 : 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () => widget.onInfo(widget.user.id),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => widget.onEdit(widget.user.id),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => widget.onDelete(widget.user.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
