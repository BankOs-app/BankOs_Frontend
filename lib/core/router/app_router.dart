import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/admin/presentation/screens/admin_home_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/select_tenant_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/launch/presentation/screens/launch_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/operations/presentation/screens/deposit_screen.dart';
import '../../features/operations/presentation/screens/profile_screen.dart';
import '../../features/operations/presentation/screens/transfer_screen.dart';
import '../../features/operations/presentation/screens/withdraw_screen.dart';

abstract class AppRouter {
  static const String launchPath = '/';
  static const String onboardingPath = '/onboarding';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';
  static const String selectTenantPath = '/select-tenant';
  static const String homePath = '/home';
  static const String depositPath = '/deposit';
  static const String withdrawPath = '/withdraw';
  static const String transferPath = '/transfer';
  static const String profilePath = '/profile';
  static const String adminPath = '/admin';

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
        path: loginPath,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: registerPath,
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterScreen(),
      ),
      GoRoute(
        path: forgotPasswordPath,
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: selectTenantPath,
        builder: (BuildContext context, GoRouterState state) =>
            const SelectTenantScreen(),
      ),
      GoRoute(
        path: homePath,
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
      ),
      GoRoute(
        path: depositPath,
        builder: (BuildContext context, GoRouterState state) =>
            const DepositScreen(),
      ),
      GoRoute(
        path: withdrawPath,
        builder: (BuildContext context, GoRouterState state) =>
            const WithdrawScreen(),
      ),
      GoRoute(
        path: transferPath,
        builder: (BuildContext context, GoRouterState state) =>
            const TransferScreen(),
      ),
      GoRoute(
        path: profilePath,
        builder: (BuildContext context, GoRouterState state) =>
            const ProfileScreen(showBackButton: true),
      ),
      GoRoute(
        path: adminPath,
        builder: (BuildContext context, GoRouterState state) =>
            const AdminHomeScreen(),
      ),
    ],
  );
}
