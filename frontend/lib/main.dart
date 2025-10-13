import 'package:flutter/material.dart';
import 'pages/foo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Web App',
      home: FooPage(),
    );
  }
}
