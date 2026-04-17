import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class AdminMenuManager extends StatelessWidget {
  const AdminMenuManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'MENU ARCHITECT',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryContainer),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Flier Manager Section Placeholder
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ACTIVE PROMOTIONS',
                        style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                      const Icon(Icons.timer_outlined, color: AppColors.onSurfaceVariant, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Manage seasonal fliers and 24-hour timed announcements.',
                    style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Menu Items List Placeholder
            Center(
              child: Column(
                children: [
                  const Icon(Icons.restaurant_menu, size: 64, color: AppColors.outlineVariant),
                  const SizedBox(height: 24),
                  Text(
                    'BUILDING THE MENU...',
                    style: GoogleFonts.spaceGrotesk(color: AppColors.onSurfaceVariant, letterSpacing: 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
