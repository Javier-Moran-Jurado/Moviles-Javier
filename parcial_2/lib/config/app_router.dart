import 'package:go_router/go_router.dart';
import '../views/dashboard_screen.dart';
import '../views/estadisticas_screen.dart';
import '../views/establecimiento_list_screen.dart';
import '../views/establecimiento_form_screen.dart';
import '../views/establecimiento_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/estadisticas',
      name: 'estadisticas',
      builder: (context, state) => const EstadisticasScreen(),
    ),
    GoRoute(
      path: '/establecimientos',
      name: 'establecimientos',
      builder: (context, state) => const EstablecimientoListScreen(),
    ),
    // La ruta de creación debe ir antes que la de detalle con parámetro
    GoRoute(
      path: '/establecimiento/crear',
      name: 'establecimiento_crear',
      builder: (context, state) => const EstablecimientoFormScreen(),
    ),
    GoRoute(
      path: '/establecimiento/editar/:id',
      name: 'establecimiento_editar',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EstablecimientoFormScreen(id: id);
      },
    ),
    GoRoute(
      path: '/establecimiento/:id',
      name: 'establecimiento_detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EstablecimientoDetailScreen(id: id);
      },
    ),
  ],
);