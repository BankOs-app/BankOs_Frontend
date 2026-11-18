import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'features/home/presentation/screens/details_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/launch/presentation/screens/launch_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';

part 'main.g.dart';

// We create a "provider", which will store a value (here "Hello world").
// By using a provider, this allows us to mock/override the value exposed.
@riverpod
String helloWorld(Ref ref) {
  return 'Hello world';
}

/// The route configuration.
final GoRouter _router = GoRouter(
  initialLocation: '/launch',
  routes: <RouteBase>[
    GoRoute(
      path: '/launch',
      builder: (BuildContext context, GoRouterState state) {
        return const LaunchScreen();
      },
    ),
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'details',
          builder: (BuildContext context, GoRouterState state) {
            return const DetailsScreen();
          },
        ),
      ],
    ),
  ],
);

void main() {
  runApp(
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Extend ConsumerWidget instead of StatelessWidget, which is exposed by Riverpod
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'BankOS',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

// Alias for backwards compatibility
typedef BankOsApp = MyApp;
