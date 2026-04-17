import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SECURE CHECKOUT',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Lecture Mode Section Shell
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school_outlined, color: AppColors.primaryFixedDim),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LECTURE MODE', style: GoogleFonts.spaceGrotesk(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                        Text('Auto-pick alert when class ends', style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant, fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(value: false, onChanged: (v) {}),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('FINALIZE ORDER'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
