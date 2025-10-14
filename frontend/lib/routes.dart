import 'package:go_router/go_router.dart';
import 'pages/foo.dart';
import 'pages/bar.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => FooPage()),
      GoRoute(path: '/foo', builder: (context, state) => FooPage()),
      GoRoute(path: '/bar', builder: (context, state) => BarPage()),
    ],
  );
}

