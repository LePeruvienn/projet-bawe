import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/auth.dart';
import '../routes.dart';
import '../utils.dart';

/************************
* GLOBALS LOGIN FUNCTIONS
*************************/

void handleLogin(BuildContext context, String username, String password) async {

  bool res = await login(username, password);

  final loc = context.loc;

  showSnackbar(
    context: context,
    dismissText: res ? loc.loginSuccess : loc.loginFailed,
    backgroundColor: res ? Colors.deepPurple : Colors.red,
    icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
  );
}

/***********************
* LOGIN FORM COMPONENTS
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
    if (!_formKey.currentState!.validate()) return;

    handleLogin(
      context,
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.loc.welcomeBack,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.loc.readyToFeur,
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 40),
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Username
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: context.loc.username,
                  prefixIcon: Icon(Icons.person, color: colorScheme.primary),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? context.loc.usernameRequired : null,
              ),
              const SizedBox(height: 16),
              // Password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: context.loc.password,
                  prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) =>
                    (value == null || value.isEmpty) ? context.loc.passwordRequired : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(context.loc.login),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(SIGNIN_PATH),
                child: Text(
                  context.loc.dontHaveAccount,
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/***********************
* INFO BOX COMPONENT
***********************/

class _InfoBox extends StatelessWidget {
  const _InfoBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.loc.hello,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.loc.areYouReady,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: colorScheme.onPrimary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/***********************
* LOGIN PAGE
***********************/

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 800;

        if (isDesktop) {
          return Row(
            children: const [
              Expanded(flex: 1, child: _InfoBox()),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(64.0),
                  child: _LoginForm(),
                ),
              ),
            ],
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: _LoginForm(),
          );
        }
      },
    );
  }
}
