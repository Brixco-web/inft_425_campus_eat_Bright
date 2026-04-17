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
  final Set<MenuOption> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    // Pre-select default options
    for (var opt in widget.item.options) {
      if (opt.isDefault) _selectedOptions.add(opt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartViewModel = context.watch<CartViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Immersive Hero Image with Parallax-ready height
          _buildHeroHeader(size),

          // 2. Custom Top Navigation
          _buildTopActions(context),

          // 3. Content Panel (Scrollable)
          _buildContentPanel(context, cartViewModel, size),
          
          // 4. Floating Action Bar (Sticky at bottom)
          _buildBottomAction(cartViewModel),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(Size size) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: size.height * 0.5,
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
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  AppColors.background.withValues(alpha: 0.8),
                  AppColors.background,
                ],
                stops: const [0, 0.4, 0.9, 1],
              ),
            ),
            child: widget.item.imageUrl.isEmpty
                ? const Center(child: Icon(Icons.fastfood, size: 80, color: Colors.white10))
                : null,
          ),
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
      top: size.height * 0.35,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Bento
            _buildHeaderBento(),
            const SizedBox(height: 24),

            // Description
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
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                height: 1.6,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 32),

            // Customization Options
            if (widget.item.options.isNotEmpty) ...[
              Text(
                'TAILOR YOUR LOOM',
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.primaryContainer,
                  letterSpacing: 4,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.item.options.map((opt) => _buildOptionTile(opt)),
              const SizedBox(height: 32),
            ],

            // Quantity Selector
            _buildQuantityRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBento() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.item.name,
                  style: GoogleFonts.epilogue(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'GHS ${widget.item.price.toStringAsFixed(2)}',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(Icons.star, '${widget.item.rating}', const Color(0xFFFFD700)),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.timer_outlined, '${widget.item.prepTime} min', AppColors.primaryContainer),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.local_fire_department_rounded, 'Hot', Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(MenuOption opt) {
    final isSelected = _selectedOptions.contains(opt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() {
          if (isSelected) {
            _selectedOptions.remove(opt);
          } else {
            _selectedOptions.add(opt);
          }
        }),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
              ? AppColors.primaryContainer.withValues(alpha: 0.1) 
              : AppColors.surfaceContainerHigh.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                ? AppColors.primaryContainer.withValues(alpha: 0.5) 
                : AppColors.outlineVariant.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                color: isSelected ? AppColors.primaryContainer : Colors.white24,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                opt.name,
                style: GoogleFonts.manrope(
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (opt.price > 0)
                Text(
                  '+GHS ${opt.price.toStringAsFixed(2)}',
                  style: GoogleFonts.manrope(
                    color: isSelected ? AppColors.primaryContainer : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityRow() {
    return Row(
      children: [
        Text(
          'Quantity',
          style: GoogleFonts.epilogue(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        _buildQuantitySelector(),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQtyBtn(Icons.remove, () {
            if (_quantity > 1) setState(() => _quantity--);
          }),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '$_quantity',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: AppColors.primaryContainer),
      splashRadius: 24,
    );
  }

  Widget _buildBottomAction(CartViewModel cartVM) {
    double total = (widget.item.price * _quantity);
    for (var opt in _selectedOptions) {
      total += (opt.price * _quantity);
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background.withValues(alpha: 0),
              AppColors.background.withValues(alpha: 0.95),
              AppColors.background,
            ],
          ),
        ),
        child: SizedBox(
          height: 64,
          child: ElevatedButton(
            onPressed: () {
              for (int i = 0; i < _quantity; i++) {
                cartVM.addItem(widget.item.id);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Woven $_quantity x ${widget.item.name} into basket.'),
                  backgroundColor: AppColors.primaryContainer,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: AppColors.primaryContainer.withValues(alpha: 0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 20),
                const SizedBox(width: 12),
                Text(
                  'ADD TO LOOM - GHS ${total.toStringAsFixed(2)}',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
