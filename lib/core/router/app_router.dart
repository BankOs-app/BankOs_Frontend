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

  /// Transición cinematográfica limpia, sutil y suave tipo Fade (eliminando saltos abruptos de color)
  static CustomTransitionPage<void> _buildFadePage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          child: child,
        );
      },
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: launchPath,
    routes: <RouteBase>[
      GoRoute(
        path: launchPath,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _buildFadePage(
          key: state.pageKey,
          child: const LaunchScreen(),
        ),
      ),
      GoRoute(
        path: onboardingPath,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _buildFadePage(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: loginPath,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _buildFadePage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: registerPath,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _buildFadePage(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: forgotPasswordPath,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _buildFadePage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: selectTenantPath,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _buildFadePage(
          key: state.pageKey,
          child: const SelectTenantScreen(),
        ),
      ),
      GoRoute(
        path: homePath,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _buildFadePage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: depositPath,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _buildFadePage(
          key: state.pageKey,
          child: const DepositScreen(),
        ),
      ),
      GoRoute(
        path: withdrawPath,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _buildFadePage(
          key: state.pageKey,
          child: const WithdrawScreen(),
        ),
      ),
      GoRoute(
        path: transferPath,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _buildFadePage(
          key: state.pageKey,
          child: const TransferScreen(),
        ),
      ),
      GoRoute(
        path: profilePath,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _buildFadePage(
          key: state.pageKey,
          child: const ProfileScreen(showBackButton: true),
        ),
      ),
      GoRoute(
        path: adminPath,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _buildFadePage(
          key: state.pageKey,
          child: const AdminHomeScreen(),
        ),
      ),
    ],
  );
}
