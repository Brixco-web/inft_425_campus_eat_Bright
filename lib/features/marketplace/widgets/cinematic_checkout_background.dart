import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:inft_425_campus_eat_bright/core/widgets/floating_food_element.dart';

/// Full-screen cinematic background for the Checkout flow.
///
/// Layer order (back → front):
///   1. High-res "food explosion" image (cup spilling, burgers flying, bubbles)
///   2. Light dark tint (~20 %) — lets the image show through clearly
///   3. Actual scrollable content (each card applies its OWN BackdropFilter)
///
/// Individual cards use per-card glassmorphism for depth; there is NO
/// global blur layer so the food explosion art stays vivid.
class CinematicCheckoutBackground extends StatelessWidget {
  final Widget child;

  const CinematicCheckoutBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── 1. Base food-explosion image (Receding) ───────────
        Positioned.fill(
          child: Image.asset(
            'assets/images/checkout_food_explosion.png',
            fit: BoxFit.cover,
          ),
        ),

        // ── 2. Subtle Blur for Receding Effect ────────────────
        // Adding a slight blur here makes the background feel further away
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: Colors.transparent),
          ),
        ),

        // ── 3. Deep Cinematic Tint ───────────────────────────
        // High opacity to make the background recede and improve legibility
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.70),
          ),
        ),

        // ── 3. Antigravity food layer (above the blur!) ─────────
        const Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: [
                // Burgers
                FloatingFoodElement(icon: Icons.lunch_dining_rounded, size: 44, color: Colors.amber,       duration: Duration(seconds: 16)),
                FloatingFoodElement(icon: Icons.lunch_dining_rounded, size: 22, color: Colors.white24,     duration: Duration(seconds: 24)),

                // Fries / Chips
                FloatingFoodElement(icon: Icons.fastfood_rounded,     size: 32, color: Colors.orangeAccent, duration: Duration(seconds: 19)),
                FloatingFoodElement(icon: Icons.breakfast_dining_rounded, size: 36, color: Colors.white30, duration: Duration(seconds: 26)),

                // Coffee / Cups
                FloatingFoodElement(icon: Icons.coffee_rounded,       size: 48, color: Colors.redAccent,   duration: Duration(seconds: 13)),
                FloatingFoodElement(icon: Icons.local_cafe_rounded,   size: 28, color: Colors.white24,     duration: Duration(seconds: 30)),

                // Extras – pizza slice, ice cream
                FloatingFoodElement(icon: Icons.local_pizza_rounded,  size: 30, color: Colors.deepOrange,  duration: Duration(seconds: 21)),
                FloatingFoodElement(icon: Icons.icecream_rounded,     size: 26, color: Colors.pinkAccent,  duration: Duration(seconds: 17)),

                // Bubbles & sparkles
                FloatingFoodElement(icon: Icons.blur_on_rounded,      size: 64, color: Colors.white10,     duration: Duration(seconds: 22)),
                FloatingFoodElement(icon: Icons.bubble_chart_rounded, size: 18, color: Colors.white12,     duration: Duration(seconds: 15)),
                FloatingFoodElement(icon: Icons.auto_awesome_rounded, size: 12, color: Colors.yellowAccent,duration: Duration(seconds: 9)),
                FloatingFoodElement(icon: Icons.flare_rounded,        size: 20, color: Colors.white10,     duration: Duration(seconds: 28)),
              ],
            ),
          ),
        ),

        // ── 4. Radial Vignette Overlay ───────────────────────
        // Darkens the edges to make the entire background (including particles) recede
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // ── 5. Actual content ───────────────────────────────────
        child,
      ],
    );
  }
}
