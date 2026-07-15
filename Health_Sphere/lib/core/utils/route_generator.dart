import 'package:flutter/material.dart';
import 'package:health_sphere/screens/appointments_screen.dart';
import 'package:health_sphere/screens/authentication/login_screen.dart';
import 'package:health_sphere/screens/authentication/signup_screen.dart';
import 'package:health_sphere/screens/home_screen.dart';
import 'package:health_sphere/screens/main_wrapper.dart';

import 'package:health_sphere/screens/splash_screen.dart';
import 'package:health_sphere/screens/walkthrough_screen.dart';
import 'package:health_sphere/core/utils/route_constants.dart';

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.splash:
        return _fadeRoute(const SplashScreen(), settings);

      case RouteConstants.walkthrough:
        return _fadeRoute(const WalkthroughScreen(), settings);

      case RouteConstants.login:
        return _slideRoute(const LoginScreen(), settings);

      case RouteConstants.signup:
        return _slideRoute(const SignupScreen(), settings);

      case RouteConstants.home:
        return _slideRoute(const MainWrapper(), settings);

      case RouteConstants.appointments:
        return _slideRoute(const AppointmentsScreen(), settings);

      default:
        return _errorRoute(settings.name);
    }
  }

  /// Fade transition
  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Slide-up + fade transition
  static PageRouteBuilder _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0.0, 0.08),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  /// Fallback error route
  static MaterialPageRoute _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            'No route defined for: $routeName',
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
