import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/users.dart';
import '../routes.dart';
import '../utils.dart';


/************************
* GLOBALS SIGNIN FUNCTIONS
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

  // User created successfully, redirect to /login
  if (res)
    context.go(LOGIN_PATH);
}

/************************
* GLOBALS SIGNIN CLASSES
*************************/

class SigninPage extends StatefulWidget {
  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {

  final _formKey = GlobalKey<FormState>();

  // TextFields Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatedPasswordController = TextEditingController();

  void _signin(BuildContext context) {

    // if form not valid return
    if (!_formKey.currentState!.validate())
      return;

    // Create user
    handleCreateUser(
      context,
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _titleController.text.trim()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title and Subtitle
          const Text(
            'Ready to start ?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),  // Spacing between title and subtitle
          const Text(
            'This is the place to be.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 40),  // Spacing before the form

          Form(
            key: _formKey,
            child: Column(
              children: [
                // Title & Username Text Field
                Row(
                  children: [
                    // Name
                    Expanded(
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12), // espace entre les champs
                    // Username
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
                const SizedBox(height: 16),
                // Email Text Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.mail),
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email required';
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    return emailRegex.hasMatch(value) ? null : 'Invalid email';
                  },
                ),
                const SizedBox(height: 16),
                // Password Text Field
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Reapted Password Text Field
                TextFormField(
                  controller: _repeatedPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Repeat your password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {

                    if (value == null || value.isEmpty)
                      return 'Please repeat your password';

                    if (_passwordController.text.trim() != _repeatedPasswordController.text.trim())
                      return 'Password doesnt match.';

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Signin Button
                ElevatedButton(
                  onPressed: () => _signin(context),
                  child: const Text('Signin'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    backgroundColor: Colors.deepPurple.shade100, // Color for the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded button
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Optional: Add a link to create an account
                TextButton(
                  onPressed: () => context.go(LOGIN_PATH),
                  child: const Text(
                    'Already have an account ? Login',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

