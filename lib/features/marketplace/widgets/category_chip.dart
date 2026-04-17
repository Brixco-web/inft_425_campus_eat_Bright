import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/menu_item_model.dart';

class CategoryChip extends StatelessWidget {
  final MenuCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Elegant name formatting (e.g., CampusGems -> Campus Gems)
    final label = _formatCategoryName(category.name);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primaryContainer.withOpacity(0.15)
                : AppColors.surface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primaryContainer.withOpacity(0.5)
                  : AppColors.outlineVariant.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              color: isSelected ? AppColors.primaryContainer : Colors.white60,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  String _formatCategoryName(String name) {
    final result = name.replaceAllMapped(
      RegExp(r'([A-Z])'), 
      (match) => ' ${match.group(0)}'
    );
    return result[0].toUpperCase() + result.substring(1).trim();
  }
}
