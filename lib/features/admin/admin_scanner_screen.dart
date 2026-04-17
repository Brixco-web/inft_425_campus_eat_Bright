import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class AdminScannerScreen extends StatelessWidget {
  const AdminScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'VERIFICATION SCANNER',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Scanner UI Mockup
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryContainer, width: 2),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                children: [
                   // Animated Scan Line Placeholder
                   const Center(child: Icon(Icons.qr_code_scanner, size: 100, color: AppColors.outlineVariant)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    'READY FOR HANDSHAKE',
                    style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Position the student QR within the frame to verify pickup and deduct from wallet.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
