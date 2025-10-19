import 'package:go_router/go_router.dart';
import 'widgets/foo.dart';
import 'widgets/bar.dart';
import 'widgets/home.dart';

class AppRouter {

  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => AppPage()),
      GoRoute(path: '/home', builder: (context, state) => AppPage()),
    ],
  );
}

