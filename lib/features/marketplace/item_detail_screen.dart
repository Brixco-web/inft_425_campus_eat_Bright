import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/menu_item_model.dart';
import '../../viewmodels/cart_viewmodel.dart';

class ItemDetailScreen extends StatefulWidget {
  final MenuItem item;
  
  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final cartViewModel = context.watch<CartViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Immersive Hero Image
          _buildHeroHeader(size),

          // 2. Custom Back Button
          _buildTopActions(context),

          // 3. Content Panel
          _buildContentPanel(context, cartViewModel, size),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(Size size) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: size.height * 0.45,
      child: Hero(
        tag: 'food_${widget.item.id}',
        child: Container(
          decoration: BoxDecoration(
            image: widget.item.imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(widget.item.imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
            color: AppColors.surfaceContainerLowest,
          ),
          child: widget.item.imageUrl.isEmpty
              ? const Center(child: Icon(Icons.fastfood, size: 80, color: Colors.white10))
              : null,
        ),
      ),
    );
  }

  Widget _buildTopActions(BuildContext context) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleAction(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.pop(context),
          ),
          _buildCircleAction(
            icon: Icons.favorite_border,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction({required IconData icon, required VoidCallback onTap}) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildContentPanel(BuildContext context, CartViewModel cartVM, Size size) {
    return Positioned.fill(
      top: size.height * 0.4,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 40, 32, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heat Badges
                  Row(
                    children: [
                      if (widget.item.isTrending)
                        _buildStatusBadge('TRENDING', Colors.orangeAccent),
                      const SizedBox(width: 8),
                      _buildStatusBadge('${widget.item.stockCount} IN STOCK', AppColors.primaryContainer),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.name,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        '₵ ${widget.item.price.toStringAsFixed(2)}',
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating & Time
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.item.rating} (${widget.item.reviewCount} reviews)',
                        style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.timer_outlined, color: AppColors.onSurfaceVariant, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.item.prepTime} mins',
                        style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Text(
                    'THE EXPERIENCE',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.primaryContainer,
                      letterSpacing: 4,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.item.description,
                    style: GoogleFonts.manrope(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                      height: 1.6,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildQuantitySelector(),
                  
                  const SizedBox(height: 48),
                  _buildAddToCartButton(cartVM),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQtyBtn(Icons.remove, () {
            if (_quantity > 1) setState(() => _quantity--);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _quantity.toString().padLeft(2, '0'),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ),
          _buildQtyBtn(Icons.add, () {
            if (_quantity < widget.item.stockCount) setState(() => _quantity++);
          }),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: AppColors.onSurface),
      ),
    );
  }

  Widget _buildAddToCartButton(CartViewModel cartVM) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () {
          for (int i = 0; i < _quantity; i++) {
            cartVM.addItem(widget.item.id);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $_quantity ${widget.item.name} to loom.'),
              backgroundColor: AppColors.primaryContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_basket_outlined),
            const SizedBox(width: 12),
            Text('WOVE INTO BASKET - ₵ ${(widget.item.price * _quantity).toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
