import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/menu_item_model.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../core/widgets/app_image.dart';

class ItemDetailScreen extends StatefulWidget {
  final MenuItem item;
  
  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _quantity = 1;
  final Set<MenuOption> _selectedOptions = {};
  late ScrollController _scrollController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    for (var opt in widget.item.options) {
      if (opt.isDefault) _selectedOptions.add(opt);
    }
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartViewModel = context.watch<CartViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Cinematic Hero with Parallax
          _buildCinematicHero(size),

          // 2. Narrative Content
          _buildNarrativeContent(context, cartViewModel, size),
          
          // 3. Dynamic Glassmorphic Header (Scroll-Activated)
          _buildDynamicHeader(size),

          // 4. Loom Integration Bar (Floating Action)
          _buildLoomActionButton(cartViewModel),
        ],
      ),
    );
  }

  Widget _buildCinematicHero(Size size) {
    double parallaxOffset = _scrollOffset * 0.4;
    return Positioned(
      top: -parallaxOffset,
      left: 0,
      right: 0,
      height: size.height * 0.55,
      child: Stack(
        children: [
          Hero(
            tag: 'food_${widget.item.id}',
            child: AppImage(
              url: widget.item.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholderColor: AppColors.surfaceContainerLowest,
            ),
          ),
          // Gradient Scrim
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.4),
                    AppColors.background.withValues(alpha: 0.8),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.4, 0.85, 1.0],
                ),
              ),
            ),
          ),
          // Static Title (fades out on scroll)
          Positioned(
            bottom: 24,
            left: 28,
            right: 28,
            child: Opacity(
              opacity: (1 - (_scrollOffset / 300)).clamp(0.0, 1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          widget.item.categoryDisplay.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            color: AppColors.primaryContainer,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      if (widget.item.isVegetarian) ...[
                        const SizedBox(width: 8),
                        _buildDietaryChip('VEGETARIAN', Colors.greenAccent),
                      ],
                      if (widget.item.isVegan) ...[
                        const SizedBox(width: 8),
                        _buildDietaryChip('VEGAN', Colors.lightGreenAccent),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.item.name,
                    style: GoogleFonts.epilogue(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.5,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildDynamicHeader(Size size) {
    // Activate blur/background after 200px scroll
    double headerIntensity = (_scrollOffset / 250).clamp(0.0, 1.0);
    
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15 * headerIntensity, sigmaY: 15 * headerIntensity),
          child: Container(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.4 * headerIntensity),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                  solid: headerIntensity > 0.5,
                ),
                
                // Centered Name (appears on scroll)
                Expanded(
                  child: Opacity(
                    opacity: headerIntensity,
                    child: Center(
                      child: Text(
                        widget.item.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                _buildGlassIconButton(
                  icon: Icons.favorite_border_rounded,
                  onTap: () {},
                  solid: headerIntensity > 0.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassIconButton({required IconData icon, required VoidCallback onTap, bool solid = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: solid ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildNarrativeContent(BuildContext context, CartViewModel cartVM, Size size) {
    return Positioned.fill(
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: size.height * 0.52, bottom: 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBentoSpecs(),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THE CULINARY TALE',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.primaryContainer,
                      letterSpacing: 4,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.item.description,
                    style: GoogleFonts.manrope(
                      color: Colors.white70,
                      height: 1.8,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (widget.item.options.isNotEmpty) ...[
                    Text(
                      'TAILOR YOUR EXPERIENCE',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.primaryContainer,
                        letterSpacing: 4,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...widget.item.options.map((opt) => _buildOptionChronicle(opt)),
                    const SizedBox(height: 40),
                  ],
                  _buildQuantityEngine(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoSpecs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _buildSpecTile(Icons.schedule_rounded, '${widget.item.prepTime}', 'MIN PREP', AppColors.primaryContainer)),
          const SizedBox(width: 12),
          Expanded(child: _buildSpecTile(Icons.star_rounded, '${widget.item.rating}', 'RATING', Colors.amber)),
          const SizedBox(width: 12),
          Expanded(child: _buildSpecTile(Icons.whatshot_rounded, '450', 'KCAL', Colors.orangeAccent)),
        ],
      ),
    );
  }

  Widget _buildSpecTile(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
          Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 7, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildOptionChronicle(MenuOption opt) {
    final isSelected = _selectedOptions.contains(opt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => setState(() => isSelected ? _selectedOptions.remove(opt) : _selectedOptions.add(opt)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? AppColors.primaryContainer : Colors.white24, width: 2),
                ),
                child: isSelected ? const Center(child: Icon(Icons.check, size: 12, color: AppColors.primaryContainer)) : null,
              ),
              const SizedBox(width: 20),
              Text(opt.name.toUpperCase(), style: GoogleFonts.spaceGrotesk(color: isSelected ? Colors.white : Colors.white60, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, fontSize: 13)),
              const Spacer(),
              if (opt.price > 0) Text('+₵${opt.price.toStringAsFixed(2)}', style: GoogleFonts.spaceGrotesk(color: isSelected ? AppColors.primaryContainer : Colors.white24, fontSize: 13, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityEngine() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('BATCH SIZE', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 2)),
          Row(
            children: [
              _buildEngineBtn(Icons.remove_rounded, () { if (_quantity > 1) setState(() => _quantity--); }),
              Container(width: 50, alignment: Alignment.center, child: Text('$_quantity', style: GoogleFonts.epilogue(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white))),
              _buildEngineBtn(Icons.add_rounded, () { if (_quantity < widget.item.stockCount) setState(() => _quantity++); }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEngineBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, color: AppColors.primaryContainer, size: 20),
      ),
    );
  }

  Widget _buildLoomActionButton(CartViewModel cartVM) {
    double total = (widget.item.price * _quantity);
    for (var opt in _selectedOptions) {
      total += (opt.price * _quantity);
    }

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.background.withValues(alpha: 0), AppColors.background]),
        ),
        child: GestureDetector(
            onTap: () {
              for (int i = 0; i < _quantity; i++) {
                cartVM.addItem(widget.item.id);
              }
              Navigator.pop(context);
            },
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Colors.black, size: 20),
                const SizedBox(width: 16),
                Text('WEAVE INTO BASKET — ₵${total.toStringAsFixed(2)}', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.5, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
