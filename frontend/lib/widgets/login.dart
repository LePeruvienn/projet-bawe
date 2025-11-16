import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../api/auth.dart';
import '../routes.dart';
import '../utils.dart';

/************************
* GLOBALS LOGIN FUNCTIONS
*************************/

void handleLogin(BuildContext context, String username, String password) async {

  bool res = await login(username, password);

  showSnackbar(
    context: context,
    dismissText: res ? 'Sucessfully logged in' : 'Login failed',
    backgroundColor: res ? Colors.deepPurple : Colors.red,
    icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
  );
}

/***********************
* LOGIN PAGE COMPONENTS
***********************/

class _LoginForm extends StatefulWidget {

  const _LoginForm({Key? key}) : super(key: key);

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submitForm() {

    if (!_formKey.currentState!.validate())
      return;

    handleLogin(
      context,
      _usernameController.text.trim(), // Username
      _passwordController.text.trim()  // Password
    );
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Welcome Back !',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ready to FEUR?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 40),
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Username Text Field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
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
              const SizedBox(height: 20),
              // Login Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Login'),
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
                onPressed: () => context.go(SIGNIN_PATH),
                child: const Text(
                  'Don’t have an account? Create one !',
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _InfoBox extends StatelessWidget {

  const _InfoBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.deepPurpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                'Hello 👋',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Are you ready to create a new FEUR?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/************
* LOGIN PAGE
*************/

class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {

        final bool isDesktop = constraints.maxWidth > 800;

        // >>> Desktop View
        if (isDesktop) {

          return Row(
            children: [
              Expanded(
                flex: 1,
                child: const _InfoBox()
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(64.0),
                  child: const _LoginForm(),
                ),
              ),
            ]
          );

        // >>> Mobile View
        } else {

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: const _LoginForm(),
          );
        }
      },
    );
  }
}
