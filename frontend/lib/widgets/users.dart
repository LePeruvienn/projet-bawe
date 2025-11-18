import 'package:flutter/material.dart';

import '../auth/authProvider.dart';
import '../models/user.dart';
import '../api/users.dart';
import '../utils.dart';

/************************
* GLOBALS USERS CONSTANTS
*************************/

const USER_LIMIT = 20;
const REFRESH_WHEN_CLOSE_TO = 300;

/************************
* GLOBALS USERS FUNCTIONS
*************************/

void updateWhere(List<User> users, User updatedUser) {

  final index = users.indexWhere((u) => u.id == updatedUser.id);

  if (index != -1)
    users[index] = updatedUser;
}

Future<void> handleCreateUser(BuildContext context, String username, String email, String password, String? title, bool isAdmin, Function(User) onUserCreated) async {

  // Try to create user
  final User? newUser = await createUser(username, email, password, title, isAdmin);

  final bool res = newUser != null;
  final loc = context.loc;

  // Show message depending of sucess
  showSnackbar(
    context: context,
    dismissText: res ? loc.userCreated : loc.userCreationFailed,
    backgroundColor: res ? Colors.deepPurple : Colors.red,
    icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
  );

  // If successful call callback
  if (res)
    onUserCreated(newUser!);
}

Future<void> handleDeleteUser(BuildContext context, User user, Function(User) onUserRemoved) async {

  bool res = await deleteUser(user);

  final loc = context.loc;

  showSnackbar(
    context: context,
    dismissText: res ? loc.deleteSuccess : loc.deleteFailed,
    backgroundColor: res ? Colors.deepPurple : Colors.red,
    icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
  );

  // If successful call callback
  if (res)
    onUserRemoved(user);
}

Future<void> handleUpdateUser(BuildContext context, User user, String? password) async {

  // Try update user
  bool res = await updateUser(user, password);

  final loc = context.loc;

  // Show message depending of sucess
  showSnackbar(
    context: context,
    dismissText: res ? loc.updateSuccess : loc.updateFailed,
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
*/
class UsersPage extends StatelessWidget {

  // Global key to access the UserList state
  final GlobalKey<_UserListState> _userListKey = GlobalKey<_UserListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: UserList(key: _userListKey),
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
              child: UserForm(
                title: context.loc.createUser,
                onUserCreated: _userListKey.currentState?._addUserLocally,
              ),
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

  // Lazy Loading State
  final ScrollController _scrollController = ScrollController();

  final int _limit = USER_LIMIT;
  int _offset = 0;

  bool _isLoading = false;
  bool _hasMore = true;

  List<User> _users = [];
  
  // Future that represents the initial/refresh load
  Future<void>? _initialLoadFuture; 

  @override
  void initState() {
    super.initState();
    _initialLoadFuture = _loadUsers(initial: true); 
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _addUserLocally(User user) {

    setState(() {
      _users.insert(0, user);
      _offset++;
    });
  }

  void _removeUserLocally(User user) {

    setState(() {
      _users.removeWhere((u) => u.id == user.id);
      _offset--;
    });
  }

  void _updateUserLocally(User updatedUser) {

    setState(() {
      updateWhere(_users, updatedUser);
    });
  }
  void _onScroll() {

    final pos = _scrollController.position.pixels;
    final threshold = _scrollController.position.maxScrollExtent - REFRESH_WHEN_CLOSE_TO;

    if (pos >= threshold && !_isLoading && _hasMore)
      _loadUsers();
  }

  // The core loading logic for pagination and refresh
  Future<void> _loadUsers({bool initial = false}) async {

    if (_isLoading)
      return;

    setState(() {
      _isLoading = true;
    });

    if (initial) {
      _users.clear();
      _offset = 0;
      _hasMore = true;
    }

    try {

      final newUsers = await fetchUsers(limit: _limit, offset: _offset);

      if (mounted) {

        setState(() {
          _users.addAll(newUsers);
          _offset += newUsers.length;
          _hasMore = newUsers.length == _limit; 
          _isLoading = false;
        });
      }

    } catch (e) {

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showSnackbar(
          context: context, 
          dismissText: 'Error loading users',
          backgroundColor: Colors.red,
          icon: const Icon(Icons.close, color: Colors.white),
        );
      }
    }
  }

  @override Widget build(BuildContext context) {

    return FutureBuilder<void>(

      future: _initialLoadFuture,
      builder: (context, snapshot) {

        // Loading Widget ...
        if (snapshot.connectionState == ConnectionState.waiting && _users.isEmpty)
          return const Center(child: CircularProgressIndicator());

        // Error Widget
        if (snapshot.hasError && _users.isEmpty)
          return Center(child: Text('Error: ${snapshot.error}'));

        // No posts Widget
        if (_users.isEmpty && !_isLoading && !_hasMore)
          return const Center(child: Text('No users available.'));

        return ListView.builder(
          controller: _scrollController,
          itemCount: _users.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {

            if (index == _users.length) {
              return _hasMore ? const Center(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )) : const SizedBox.shrink(); 
            }

            final user = _users[index];
            return UserListItem(
              user: user,
              onUserRemoved: _removeUserLocally,
              onUserUpdated: _updateUserLocally,
            );
          },
        );
      },
    );
  }
}

/*
* USER LIST ITEM WIDGET
*/
class UserListItem extends StatefulWidget {

  final User user;

  final Function(User) onUserRemoved;
  final Function(User) onUserUpdated;

  UserListItem({
    required this.user,
    required this.onUserRemoved,
    required this.onUserUpdated,
  }) : super(key: ObjectKey(user));

  @override
  State<UserListItem> createState() => _UserListItemState();
}

/*
* State class for @UserListItem
*/
class _UserListItemState extends State<UserListItem> {

  void _deleteUser() async {

    await handleDeleteUser(context, widget.user, widget.onUserRemoved); 
  }

  // Wrapper to show the edit form with refresh callback
  void _showEditForm() {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Pass the refresh callback to the form
        child: UserForm(
          title: context.loc.editUser, 
          user: widget.user,
          onUserUpdated: widget.onUserUpdated,
          callback: () => {}
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        // Bigger padding/size for the card
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            // Bigger Avatar
            CircleAvatar(
              radius: 25,
              child: Text(widget.user.username[0], style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '@${widget.user.username}',
                    style: const TextStyle(fontSize: 16)
                  ),
                ],
              ),
            ),

            // Actions (Clear, visible icons for desktop)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'View Details',
                  onPressed: () => handleInfoUser(context, widget.user),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit User',
                  onPressed: _showEditForm,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Delete User',
                  onPressed: _deleteUser,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


/*
* USER FORM
*/
class UserForm extends StatefulWidget {

  final String title;
  final User? user;

  final VoidCallback? callback;
  final Function(User)? onUserCreated;
  final Function(User)? onUserUpdated;

  const UserForm({
    super.key,
    required this.title,
    this.user = null,
    this.callback = null,
    this.onUserCreated = null,
    this.onUserUpdated = null,
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
  bool _isAdmin = false;

  bool _isSubmitting = false;
  
  bool _obscurePassword = true;

  @override
  void initState() {

    super.initState();

    final user = widget.user;

    if (widget.user != null) {

      _usernameController.text = user!.username;
      _emailController.text = user!.email;
      _isAdmin = user.isAdmin;

      if (user?.title != null)
        _titleController.text = user!.title!;
    }
  }

  void _submitForm() async {

    if (!_formKey.currentState!.validate())
      return;

    setState(() => _isSubmitting = true);

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final title = _titleController.text.trim();
    final isAdmin = _isAdmin;

    // Create user
    if (widget.user == null) {

      handleCreateUser (context, username, email, password, title, isAdmin, (User newUser) {
        widget.onUserCreated?.call(newUser);
      });

    // Update User
    } else {

      final user = User(
        id: widget.user!.id,
        username: username,
        email: email,
        title: title,
        isAdmin: isAdmin,
        createdAt: widget.user!.createdAt,
      );

      await handleUpdateUser(context, user, password);

      widget.onUserUpdated?.call(user);
    }

    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _titleController.clear();

    Navigator.of(context).pop();

    if (widget.callback != null)
      widget.callback?.call();

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                    decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: context.loc.name,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      prefix: Text('@'),
                      labelText: context.loc.username,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? context.loc.usernameRequired : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                icon: Icon(Icons.mail),
                labelText: context.loc.email,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return context.loc.emailRequired;
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                return emailRegex.hasMatch(value) ? null : context.loc.invalidEmail;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                icon: const Icon(Icons.lock),
                labelText: context.loc.password,
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
                  ((value == null || value.isEmpty) && widget.user == null) ? context.loc.passwordRequired : null,
            ),
            // Only show this form is user is admin
            if (AuthProvider().isAdmin)
              const SizedBox(height: 20),
            if (AuthProvider().isAdmin)
              CheckboxListTile(
                title: Text('Is Admin'),
                value: _isAdmin,
                onChanged: (bool? newValue) {
                  setState(() {
                    _isAdmin = newValue ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: 20),
            _isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.save),
                    label: Text(context.loc.save),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
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
                _InfoItem(icon: Icons.lock, label: 'Admin', value: user.title ?? 'Yes'),
            ],
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              title.isNotEmpty ? title[0].toUpperCase() : '?',
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
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
