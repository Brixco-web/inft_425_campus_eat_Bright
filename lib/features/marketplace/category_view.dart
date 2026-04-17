import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class CategoryViewScreen extends StatelessWidget {
  final String categoryName;
  
  const CategoryViewScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          categoryName.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.primaryFixedDim),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 64, color: AppColors.outlineVariant),
            const SizedBox(height: 24),
            Text(
              'REFINING THE LOOM...',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 3,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Category Specifics Under Construction',
              style: GoogleFonts.manrope(
                color: AppColors.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
