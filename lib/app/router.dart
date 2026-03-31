import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../features/dashboard/view/dashboard_screen.dart';
import '../features/onboarding/view/onboarding_shell.dart';
import '../features/settings/view/settings_page.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      redirect: (BuildContext context, GoRouterState state) {
        final box = Hive.box<dynamic>('wattwise_prefs');
        final onboardingComplete =
            (box.get('onboarding_complete', defaultValue: false) as bool?) ??
            false;

        if (state.matchedLocation == '/') {
          return onboardingComplete ? '/dashboard' : '/onboarding';
        }

        if (!onboardingComplete && state.matchedLocation == '/dashboard') {
          return '/onboarding';
        }

        if (onboardingComplete && state.matchedLocation == '/onboarding') {
          return '/dashboard';
        }

        return null;
      },
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (_, __) => const SizedBox.shrink()),
        GoRoute(
          path: '/onboarding',
          builder: (BuildContext context, GoRouterState state) {
            return const OnboardingShell();
          },
        ),
        GoRoute(
          path: '/dashboard',
          builder: (BuildContext context, GoRouterState state) {
            return const DashboardScreen();
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsPage();
          },
        ),
      ],
    );
  }
}
