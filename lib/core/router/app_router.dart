import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/details_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/launch/presentation/screens/launch_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

abstract class AppRouter {
  static const String launchPath = '/launch';
  static const String onboardingPath = '/onboarding';
  static const String homePath = '/';
  static const String detailsPath = 'details';

  static final GoRouter router = GoRouter(
    initialLocation: launchPath,
    routes: <RouteBase>[
      GoRoute(
        path: launchPath,
        builder: (BuildContext context, GoRouterState state) =>
            const LaunchScreen(),
      ),
      GoRoute(
        path: onboardingPath,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      GoRoute(
        path: homePath,
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: detailsPath,
            builder: (BuildContext context, GoRouterState state) =>
                const DetailsScreen(),
          ),
        ],
      ),
    ],
  );
}
