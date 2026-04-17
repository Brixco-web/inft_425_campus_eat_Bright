import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'OBSIDIAN COMMAND',
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
            // Priority Queue Summary Shell
            Row(
              children: [
                _buildStatCard('PENDING', '12', AppColors.primaryContainer),
                const SizedBox(width: 16),
                _buildStatCard('READY', '5', Colors.greenAccent),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                ),
                child: Center(
                  child: Text(
                    'PRIORITY QUEUE INCOMING...',
                    style: GoogleFonts.spaceGrotesk(color: AppColors.onSurfaceVariant, letterSpacing: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.spaceGrotesk(color: color, fontSize: 10, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.spaceGrotesk(color: AppColors.onSurface, fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
