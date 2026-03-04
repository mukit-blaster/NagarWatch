import 'package:flutter/material.dart';
import 'package:flutter_app_nagar_watch/features/authentication/screens/welcome_screen.dart';
import 'package:flutter_app_nagar_watch/features/navigation/main_navigation_screen.dart';

class AppRouter {
  static const String welcome = "/";
  static const String homeNav = "/homeNav";

  static Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomeScreen(),
    homeNav: (context) => MainNavigationScreen(),
  };
}
