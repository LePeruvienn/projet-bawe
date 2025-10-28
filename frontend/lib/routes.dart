import 'package:go_router/go_router.dart';
import 'widgets/app.dart';

class AppRouter {

  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => AppPage()),
      GoRoute(path: '/home', builder: (context, state) => AppPage()),
    ],
  );
}

