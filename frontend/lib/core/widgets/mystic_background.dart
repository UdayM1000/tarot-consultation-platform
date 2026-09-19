import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MysticBackground extends StatelessWidget {
  final Widget child;

  const MysticBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.mysticalGradient,
      ),
      child: Stack(
        children: [
          // Ambient cosmic glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sacredPurple.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.astralGold.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}
