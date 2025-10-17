import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bar.dart';

class FooPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Foo Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/bar'),
          child: Text('Go to Bar'),
        ),
      ),
    );
  }
}
