import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemId;
  
  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.surfaceContainerLowest,
                child: const Center(
                  child: Icon(Icons.fastfood_outlined, size: 80, color: AppColors.primaryContainer),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ITEM SPECIFICATION',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.primaryContainer,
                      letterSpacing: 4,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Authentic Waakye Special',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.stars_outlined, color: AppColors.primaryContainer, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '4.8 (120 Student Reviews)',
                        style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant),
                      ),
                    ],
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
