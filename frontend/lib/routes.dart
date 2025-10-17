import 'package:go_router/go_router.dart';
import 'widgets/foo.dart';
import 'widgets/bar.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => FooPage()),
      GoRoute(path: '/foo', builder: (context, state) => FooPage()),
      GoRoute(path: '/bar', builder: (context, state) => BarPage()),
    ],
  );
}

