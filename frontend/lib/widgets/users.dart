import 'package:flutter/material.dart';

import '../models.dart';
import '../api.dart';
import '../utils.dart';

/*
* BASE USER PAGE
* - This is the container of the user list page
*/
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
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: UserForm(onUserCreated: () {
                // Optionally trigger refresh if needed
              }),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/*
* USER LIST WIDGET
* - This widget contains the list of all the Users
*/
class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

/*
* State class for @UserList
*/
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

/*
* USER LIST ITEM WIDGET
* - This is the widget for 1 unique user in users list
*/
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

/*
* State class for @UserListItem
*/
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


/*
* USER FORM
* - This widget displays the form to create a new user
*/
class UserForm extends StatefulWidget {
  final VoidCallback? onUserCreated; // Optional callback to refresh the user list

  const UserForm({super.key, this.onUserCreated});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  bool _isSubmitting = false;
  
  // UI vars
  bool _obscurePassword = true;

  Future<void> _submitForm() async {

    // If form not valid return
    if (!_formKey.currentState!.validate()) return;

    // Update state
    setState(() => _isSubmitting = true);

    // Getting inputs values
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final title = _titleController.text.trim();

    // Try to create user
    bool res = await createUser(username, email, password, title);

    // Show message depending of sucess
    ScaffoldMessenger.of(context).showSnackBar(
      createSnackbar(
        dismissText: res ? 'User created successfully' : 'Failed to create user',
        backgroundColor: res ? Colors.deepPurple : Colors.red,
        icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
      ),
    );

    // Clear all inputs
    // if (res) {
    _usernameController.clear();
    _emailController.clear();
    widget.onUserCreated?.call(); // Notify parent widget if provided
    Navigator.of(context).pop(); // Close form if in a dialog
    // }

    // Update state
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create User',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Username required' : null,
                  ),
                ),
                const SizedBox(width: 12), // espace entre les champs
                Expanded(
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      prefix: Text('@'),
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                icon: Icon(Icons.mail),
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email required';
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                return emailRegex.hasMatch(value) ? null : 'Invalid email';
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                icon: const Icon(Icons.lock),
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Password required' : null,
            ),
            const SizedBox(height: 20),
            _isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.save),
                    label: const Text('Create'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
