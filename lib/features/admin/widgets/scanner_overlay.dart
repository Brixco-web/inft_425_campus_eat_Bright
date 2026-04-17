import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class ScannerOverlay extends StatelessWidget {
  final bool isScanning;
  final String? status;
  final bool isSuccess;

  const ScannerOverlay({
    super.key,
    required this.isScanning,
    this.status,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isScanning && status == null) return const SizedBox.shrink();

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isSuccess ? Colors.greenAccent : Colors.redAccent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                isSuccess ? 'HANDSHAKE VERIFIED' : 'VERIFICATION FAILED',
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              if (status != null) ...[
                const SizedBox(height: 8),
                Text(
                  status!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
