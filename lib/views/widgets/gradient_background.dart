import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

/// Latar gradasi lembut yang mengikuti tema terang/gelap.
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.backgroundColors(brightness),
        ),
      ),
      child: child,
    );
  }
}
