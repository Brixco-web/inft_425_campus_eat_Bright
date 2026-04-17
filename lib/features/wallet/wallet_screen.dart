import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'OBSIDIAN WALLET',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT BALANCE',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.onPrimary.withValues(alpha: 0.6),
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₵540.00',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.onPrimary,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Spending Analytics Placeholder
            Row(
              children: [
                Text(
                  'EXPENDITURE ANALYTICS',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.primaryContainer,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: const Center(
                child: Icon(Icons.analytics_outlined, size: 48, color: AppColors.outlineVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
