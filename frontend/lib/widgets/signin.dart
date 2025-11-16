import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/users.dart';
import '../routes.dart';
import '../utils.dart';

/************************
* GLOBALS SIGNIN FUNCTIONS
*************************/

void handleCreateUser(BuildContext context, String username, String email, String password, String? title) async {

  bool res = await createUser(username, email, password, title);

  final loc = context.loc;

  showSnackbar(
    context: context,
    dismissText: res ? loc.userCreated : loc.userCreationFailed,
    backgroundColor: res ? Colors.deepPurple : Colors.red,
    icon: Icon(res ? Icons.done : Icons.close, color: Colors.white),
  );

  if (res) context.go(LOGIN_PATH);
}

/***********************
* SIGNIN FORM COMPONENT
***********************/

class _SigninForm extends StatefulWidget {

  const _SigninForm({Key? key}) : super(key: key);

  @override
  State<_SigninForm> createState() => _SigninFormState();
}

class _SigninFormState extends State<_SigninForm> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatedPasswordController = TextEditingController();

  void _signin(BuildContext context) {

    if (!_formKey.currentState!.validate())
      return;

    handleCreateUser(
      context,
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _titleController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.loc.readyToStart,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.loc.thisIsThePlace,
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
              // Title & Username
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: colorScheme.primary),
                        labelText: context.loc.name,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefix: Text('@', style: TextStyle(color: colorScheme.onSurface)),
                        labelText: context.loc.username,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? context.loc.usernameRequired : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.mail, color: colorScheme.primary),
                  labelText: context.loc.email,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return context.loc.emailRequired;
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return emailRegex.hasMatch(value) ? null : context.loc.invalidEmail;
                },
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
                validator: (value) => (value == null || value.isEmpty) ? context.loc.passwordRequired : null,
              ),
              const SizedBox(height: 16),
              // Repeat Password
              TextFormField(
                controller: _repeatedPasswordController,
                decoration: InputDecoration(
                  labelText: context.loc.repeatPassword,
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return context.loc.repeatPasswordRequired;
                  if (_passwordController.text.trim() != _repeatedPasswordController.text.trim()) {
                    return context.loc.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _signin(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(context.loc.signin),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(LOGIN_PATH),
                child: Text(
                  context.loc.alreadyHaveAccount,
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
                context.loc.signinHeader,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                contex.loc.createAccountMessage,
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
* SIGNIN PAGE
***********************/

class SigninPage extends StatelessWidget {

  const SigninPage({Key? key}) : super(key: key);

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
                  child: _SigninForm(),
                ),
              ),
            ],
          );

        } else {

          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: _SigninForm(),
          );
        }
      },
    );
  }
}
