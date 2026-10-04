import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/agents/presentation/screens/agents_dashboard_screen.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/records/presentation/screens/records_screen.dart';
import '../../features/registry.dart';
import '../widgets/splash_screen.dart';

abstract final class Routes {
  static const splash = '/';
  static const signIn = '/sign-in';
  static const dashboard = '/dashboard';
  static const home = '/home';
  static const records = '/records/:key';
}

/// Rebuilds the router's redirect whenever the auth state changes.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref<Object?> ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable(ref);
  ref.onDispose(listenable.dispose);
  final moduleRoute = GoRoute(
    path: Routes.records,
    builder: (_, state) => RecordsScreen(resourceKey: state.pathParameters['key'] ?? ''),
  );

  if (!useElyvoriAgents) {
    return GoRouter(
      initialLocation: Routes.home,
      routes: [GoRoute(path: Routes.home, builder: (_, __) => const HomeScreen()), moduleRoute],
    );
  }

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: listenable,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      if (auth.isLoading) return location == Routes.splash ? null : Routes.splash;
      final signedIn = auth.valueOrNull != null;
      if (!signedIn) return location == Routes.signIn ? null : Routes.signIn;
      if (location == Routes.signIn || location == Routes.splash) return Routes.dashboard;
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: Routes.signIn, builder: (_, __) => const SignInScreen()),
      GoRoute(path: Routes.dashboard, builder: (_, __) => const AgentsDashboardScreen()),
      moduleRoute,
    ],
  );
});
