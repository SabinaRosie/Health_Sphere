import 'package:flutter/material.dart';

/// Displays the official Google logo using the bundled PNG asset.
class GoogleIcon extends StatelessWidget {
  final double size;
  const GoogleIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/google_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
