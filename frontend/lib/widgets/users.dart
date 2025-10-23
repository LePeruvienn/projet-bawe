import 'package:flutter/material.dart';

import '../models/user.dart';
import '../utils.dart';
import '../api/users.dart';

/************************
* GLOBALS USERS FUNCTIONS
*************************/

void handleCreateUser(BuildContext context, String username, String email, String password, String? title) async {

  // Try to create user
  bool res = await createUser(username, email, password, title);

  // Show message depending of sucess
  showSnackbar(
    context: context,
    dismissText: res ? 'User created successfully' : 'Failed to create user',
    backgroundColor: res ? Colors.deepPurple : Colors.red,
    icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
  );
}

void handleUpdateUser(BuildContext context, User user) async {

  print("HANDLE, UPDATE USER");

  bool res = await updateUser(user);

  // Show message depending of sucess
  showSnackbar(
    context: context,
    dismissText: res ? 'User updated successfully' : 'Failed to update user',
    backgroundColor: res ? Colors.deepPurple : Colors.red,
    icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
  );
}

void handleDeleteUser(BuildContext context, User user) async {

  bool res = await deleteUser(user);

  showSnackbar(
    context: context,
    dismissText: res ? 'User successfully deleted' : 'Failed to delete user',
    backgroundColor: res ? Colors.deepPurple : Colors.red,
    icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
  );
}

void handleInfoUser(BuildContext context, User user) {

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => UserInfoSheet(user: user),
  );
}

/************************
* GLOBALS USERS CLASSES
*************************/

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
              child: UserForm(title: "Create User"),
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
            return UserListItem(user: user);
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

UserListItem({ required this.user }) : super(key: ObjectKey(user));

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
                  onPressed: () => handleInfoUser(context, widget.user),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: UserForm(title: "Update User", user: widget.user),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => handleDeleteUser(context, widget.user),
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

  // Title displayed at the top of the popup
  final String title;

  // User linked to the form (can be null if we are creating an user)
  final User? user;

  const UserForm({
    super.key,
    required this.title,
    this.user = null
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

/*
* State class for UserForm
*/
class _UserFormState extends State<UserForm> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  bool _isSubmitting = false;
  
  // UI vars
  bool _obscurePassword = true;

  @override
  void initState() {

    super.initState();

    final user = widget.user;

    if (widget.user != null) {

      _usernameController.text = user!.username;
      _emailController.text = user!.email;
      _passwordController.text = user!.password;

      if (user?.title != null)
        _titleController.text = user!.title!;
    }
  }

  void _submitForm() async {

    // If form not valid return
    if (!_formKey.currentState!.validate())
      return;

    // Update state
    setState(() => _isSubmitting = true);

    // Getting inputs values
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final title = _titleController.text.trim();

    // Create user
    if (widget.user == null) {

      handleCreateUser (context, username, email, password, title);

    // Update User
    } else {

      final user = User(
        id: widget.user!.id,
        username: username,
        email: email,
        password: password,
        title: title,
        createdAt: widget.user!.createdAt,
      );

      handleUpdateUser(context, user);
    }

    // Clear inputs fields
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _titleController.clear();

    // Close form if in a dialog
    Navigator.of(context).pop();

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
              widget.title,
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
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Username required' : null,
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
                    label: const Text('Save'),
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


/*
* USER INFO SHEET
* - Displays detailed info about a user in a bottom popup
*/
class UserInfoSheet extends StatelessWidget {

  final User user;

  const UserInfoSheet({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoCard(
            title: user.username,
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
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Close'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
* User to display users information in the popup
*/
class _InfoCard extends StatelessWidget {

  static const double titleFontSize = 24;
  static const double itemFontSize = 14;

  final String title;
  final List<_InfoItem> items;

  const _InfoCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurple.shade100,
            child: Text(
              title.isNotEmpty ? title[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: _InfoCard.titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      const Divider(),
        ...items.map((item) => _InfoRow(item: item)),
      ],
    );
  }
}

/*
* Ued to represent each row of the info card
*/
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
              style: const TextStyle(
                fontSize: _InfoCard.itemFontSize,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          Text(
            item.value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: _InfoCard.itemFontSize,
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}

/*
* Info model class
*/
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
