import 'package:flutter/material.dart';
import 'package:health_sphere/core/theme/app_colors.dart';
import 'package:health_sphere/screens/splash_screen.dart';
import 'package:health_sphere/utils/route_generator.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const HealthSphereApp());
}

class HealthSphereApp extends StatelessWidget {
  const HealthSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Sphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
      home: const SplashScreen(),
    );
  }
}
