import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppShellBackground extends StatelessWidget {
  const AppShellBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF142017), Color(0xFF1D2B20)]
              : const [Color(0xFFFFFDF8), AppColors.cream],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -20,
            child: _GlowOrb(
              size: 180,
              color: isDark
                  ? AppColors.leaf.withValues(alpha: 0.14)
                  : AppColors.sage.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            top: 220,
            left: -70,
            child: _GlowOrb(
              size: 160,
              color: isDark
                  ? AppColors.forest.withValues(alpha: 0.18)
                  : AppColors.almond.withValues(alpha: 0.25),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}
