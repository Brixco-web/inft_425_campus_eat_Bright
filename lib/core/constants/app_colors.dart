import 'package:flutter/material.dart';

/// Centralized color palette derived from the "Obsidian Loom" design system.
///
/// These tokens are mapped 1:1 with the Stitch mockup for high fidelity.
class AppColors {
  // Midnight Obsidian Base
  static const Color background = Color(0xFF0D1417);
  static const Color surface = Color(0xFF0D1417);
  static const Color surfaceContainerLowest = Color(0xFF080F12);
  static const Color surfaceContainerLow = Color(0xFF161D20);
  static const Color surfaceContainer = Color(0xFF1A2124);
  static const Color surfaceContainerHigh = Color(0xFF242B2E);
  static const Color surfaceContainerHighest = Color(0xFF2F3639);
  static const Color surfaceVariant = Color(0xFF2F3639);
  static const Color surfaceDim = Color(0xFF0D1417);
  static const Color surfaceBright = Color(0xFF333A3E);

  // Primary & Accents (Heritage Gold)
  static const Color primary = Color(0xFFFFF6DF);
  static const Color primaryContainer = Color(0xFFFFD700); // Saffron Gold
  static const Color primaryFixed = Color(0xFFFFE16D);
  static const Color primaryFixedDim = Color(0xFFE9C400);
  
  // Secondary & Tertiary
  static const Color secondary = Color(0xFFC8C6C5);
  static const Color secondaryContainer = Color(0xFF474746);
  static const Color tertiary = Color(0xFFF1F7FC);
  static const Color tertiaryContainer = Color(0xFFD4DBDF);

  // Typography & States
  static const Color onSurface = Color(0xFFDCE3E8);
  static const Color onSurfaceVariant = Color(0xFFD0C6AB);
  static const Color onPrimary = Color(0xFF3A3000);
  static const Color onPrimaryContainer = Color(0xFF705E00);
  static const Color outline = Color(0xFF999077);
  static const Color outlineVariant = Color(0xFF4D4732);
  
  // Error Feedback
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Custom Effects
  static const Color glassPanel = Color(0x990D1417); // 60% Opacity
  static const Color goldenAura = Color(0x4DFFD700); // 30% Gold Glow

  // Predefined Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

