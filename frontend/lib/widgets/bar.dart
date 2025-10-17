import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'foo.dart';

class BarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bar Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/foo'),
          child: Text('Go to Foo'),
        ),
      ),
    );
  }
}
