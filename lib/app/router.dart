import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/wattwise_prefs_repository.dart';
import '../features/dashboard/view/dashboard_screen.dart';
import '../features/onboarding/view/onboarding_shell.dart';
import '../features/settings/view/settings_page.dart';

class AppRouter {
  static GoRouter createRouter() {
    final prefsRepository = WattwisePrefsRepository();

    return GoRouter(
      initialLocation: '/',
      redirect: (BuildContext context, GoRouterState state) {
        final onboardingComplete = prefsRepository.onboardingComplete;

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
