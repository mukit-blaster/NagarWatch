import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../features/authentication/screens/welcome_screen.dart';
import '../features/authentication/screens/login_screen.dart';
import '../features/authentication/screens/admin_login_screen.dart';
import '../features/authentication/screens/register_screen.dart';
import '../features/authentication/screens/ward_selection_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return _slide(const WelcomeScreen());
      case AppRoutes.login:
        return _slide(const LoginScreen());
      case AppRoutes.adminLogin:
        return _slide(const AdminLoginScreen());
      case AppRoutes.register:
        return _slide(const RegisterScreen());
      case AppRoutes.wardSelection:
        return _slide(const WardSelectionScreen());
      // TODO: Add remaining routes as features are implemented
      default:
        return _slide(const WelcomeScreen());
    }
  }

  static PageRouteBuilder _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
