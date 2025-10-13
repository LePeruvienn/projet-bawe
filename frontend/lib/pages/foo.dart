import 'package:flutter/material.dart';

class FooPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Foo Page')),
      body: Center(
        child: ElevatedButton(
          child: Text('Go to Bar'),
          onPressed: () {
            print('Button was pressed!');
          },
        ),
      ),
    );
  }
}
