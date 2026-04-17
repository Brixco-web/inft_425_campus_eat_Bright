import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ORDER HISTORY',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.outlineVariant),
            const SizedBox(height: 24),
            Text(
              'TRACKING THE WEB...',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 3,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your collection of past & active looms',
              style: GoogleFonts.manrope(
                color: AppColors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
