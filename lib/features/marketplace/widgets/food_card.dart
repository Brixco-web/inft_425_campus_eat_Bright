import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/menu_item_model.dart';
import '../../../core/widgets/app_image.dart';
import '../../../viewmodels/cart_viewmodel.dart';
import '../item_detail_screen.dart';

class FoodCard extends StatelessWidget {
  final MenuItem item;

  const FoodCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ItemDetailScreen(item: item),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // 1. Food Image
            Positioned.fill(
              child: Hero(
                tag: 'food_${item.id}',
                child: AppImage(
                  url: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholderColor: AppColors.surfaceContainerHigh,
                ),
              ),
            ),

            // 2. Heat Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Status Badges (Heatmap)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item.isTrending)
                    Flexible(
                      child: _buildBadge(
                        icon: Icons.whatshot,
                        text: 'TRENDING',
                        color: Colors.orangeAccent,
                      ),
                    ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: _buildBadge(
                      icon: Icons.inventory_2_outlined,
                      text: '${item.stockCount} LEFT',
                      color: item.stockCount < 5 ? Colors.redAccent : AppColors.primaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            // 3.5 Dietary Badges (Side)
            Positioned(
              top: 50,
              right: 12,
              child: Column(
                children: [
                  if (item.isVegetarian)
                    _buildDietaryBadge(Icons.eco_rounded, Colors.greenAccent),
                  if (item.isVegan)
                    const SizedBox(height: 8),
                  if (item.isVegan)
                    _buildDietaryBadge(Icons.spa_rounded, Colors.lightGreenAccent),
                ],
              ),
            ),

            // 4. Content (Footer)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildFooter(),
            ),

            // 5. Quick Add Button (+)
            Positioned(
              bottom: 12,
              right: 12,
              child: _QuickAddButton(item: item),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBadge({required IconData icon, required String text, Color? color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Colors.black.withValues(alpha: 0.4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color ?? AppColors.primaryContainer, size: 12),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDietaryBadge(IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(6),
          color: Colors.black45,
          child: Icon(icon, color: color, size: 14),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.name,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GH₵ ${item.price.toStringAsFixed(2)}',
                style: GoogleFonts.manrope(
                  color: AppColors.primaryContainer,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    item.rating.toString(),
                    style: GoogleFonts.manrope(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAddButton extends StatefulWidget {
  final MenuItem item;
  const _QuickAddButton({required this.item});

  @override
  State<_QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<_QuickAddButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        HapticFeedback.mediumImpact();
        context.read<CartViewModel>().addItem(widget.item.id);
        
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.item.name} added to cart'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            width: 250,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.9),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
