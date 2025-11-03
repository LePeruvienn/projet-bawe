import 'package:flutter/material.dart';

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

  void _signin() {
    if (_formKey.currentState!.validate()) {
      // Handle signin logic here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signing in...'),
          backgroundColor: Colors.deepPurple,
        ),
      );
      // You can add authentication logic here.
    }
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
                  onPressed: _signin,
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
                  onPressed: () {
                    // Navigate to signup page
                  },
                  child: const Text(
                    'Already have an account ? signin',
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

