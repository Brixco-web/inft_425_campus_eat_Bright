import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A professional background overlay that provides a "Culinary Fiber" texture.
/// 
/// This widget uses a high-end, extremely low-opacity asset overlay
/// to give screens a unique, professional depth beyond simple gradients.
class CulinaryTexture extends StatelessWidget {
  final Widget? child;
  final String? textureAsset;
  final double opacity;

  const CulinaryTexture({
    super.key,
    this.child,
    this.textureAsset = 'assets/images/waakye_thursday.png',
    this.opacity = AppColors.textureOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Base Obsidian Layer
        Positioned.fill(
          child: Container(color: AppColors.background),
        ),
        
        // 2. Texture Layer (Professional Grain)
        Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: Image.asset(
              textureAsset!,
              fit: BoxFit.cover,
              color: Colors.black, // Darken the texture slightly
              colorBlendMode: BlendMode.darken,
            ),
          ),
        ),

        // 3. Subtle Vignette
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ),

        ?child,
      ],
    );
  }
}
