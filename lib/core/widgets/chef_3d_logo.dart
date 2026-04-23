import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class Chef3DLogo extends StatelessWidget {
  final double size;
  const Chef3DLogo({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryContainer.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.primaryContainer.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          color: AppColors.primaryContainer,
          size: size * 0.5,
        ),
      ),
    );
  }
}
