// lib/widgets/app_logo.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool onDark;   // true on the navy splash screen

  const AppLogo({super.key, this.size = 80, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: onDark ? Colors.white : AppTheme.primary,
          borderRadius: BorderRadius.circular(size * 0.28),
        ),
        child: Icon(
          Icons.school_outlined,
          size: size * 0.55,
          color: onDark ? AppTheme.primary : Colors.white,
        ),
      ),
    );
  }
}
