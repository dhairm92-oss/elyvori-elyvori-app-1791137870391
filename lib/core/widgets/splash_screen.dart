import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import 'neon_background.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [BoxShadow(color: AppColors.cyan.withValues(alpha: 0.4), blurRadius: 40)],
            ),
            alignment: Alignment.center,
            child: const Text('E', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: AppColors.obsidian)),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.94, end: 1.04, duration: 900.ms, curve: Curves.easeInOut),
        ),
      ),
    );
  }
}
