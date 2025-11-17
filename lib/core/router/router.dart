import 'package:desktop_time_tracker/core/router/routes.dart';
import 'package:flutter/material.dart';

import '../../view/screens/login/screen/login.dart';
import '../../view/screens/signup/screen/signup.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  /// Push with fade transition
  static Future<dynamic> pushNamed(String route, {Object? arguments}) {
    return navigatorKey.currentState!.push(fadeRoute(route, arguments: arguments));
  }

  /// Replace with fade transition
  static Future<dynamic> pushReplacementNamed(String route,
      {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacement(fadeRoute(route, arguments: arguments));
  }

  /// Pop the current screen
  static void pop([Object? result]) {
    navigatorKey.currentState!.pop(result);
  }

  /// Build fade transition route
  static PageRouteBuilder fadeRoute(String route, {Object? arguments}) {
    return PageRouteBuilder(
      settings: RouteSettings(name: route, arguments: arguments),
      pageBuilder: (_, __, ___) => _buildPage(route, arguments),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 250),
    );
  }

  /// Route builder for all named routes
  static Widget _buildPage(String route, Object? args) {
    switch (route) {
      case Routes.login:
        return const LoginView();

      case Routes.register:
        return const SignupView();

      default:
        return Scaffold(
          body: Center(child: Text("No route defined for $route")),
        );
    }
  }
}
