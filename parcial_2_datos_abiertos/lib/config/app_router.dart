import 'package:go_router/go_router.dart';
import '../views/dashboard_screen.dart';
import '../views/list_screen.dart';
import '../views/detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/list/:endpoint',
      name: 'list',
      builder: (context, state) {
        final endpoint = state.pathParameters['endpoint']!;
        return ListScreen(endpoint: endpoint);
      },
    ),
    GoRoute(
      path: '/detail/:endpoint/:id',
      name: 'detail',
      builder: (context, state) {
        final endpoint = state.pathParameters['endpoint']!;
        final id = state.pathParameters['id']!;
        return DetailScreen(endpoint: endpoint, id: id);
      },
    ),
  ],
);