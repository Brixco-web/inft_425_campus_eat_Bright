import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../models/menu_item_model.dart';
import '../orders/order_bucket_screen.dart';
import 'widgets/food_card.dart';
import 'widgets/category_chip.dart';
import 'widgets/marketplace_drawer.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showDietaryFilters = false;
  bool _filterVegetarian = false;
  bool _filterVegan = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuViewModel = context.watch<MenuViewModel>();
    final cartViewModel = context.watch<CartViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _buildCartFAB(context, cartViewModel),
      drawer: const MarketplaceDrawer(),
      body: Stack(
        children: [
          // ── Cinematic Background Texture ──
          _buildBackground(size),

          // ── Main Content ──
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Slim Header & Search
              _buildSliverHeader(context),

              // 2. Categories Horizontal
              _buildSliverCategories(menuViewModel),

              // 3. The Menu Grid
              _buildSliverMenu(menuViewModel),

              // Bottom Padding
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildBackground(Size size) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.03,
        child: Image.asset('assets/images/waakye_thursday.png', fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildCartFAB(BuildContext context, CartViewModel cartVM) {
    if (cartVM.itemCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 80), // Adjust for Bottom Nav
      child: Hero(
        tag: 'cart_fab',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrderBucketScreen()),
            ),
            child: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.shopping_basket_rounded, color: Colors.black, size: 24),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        cartVM.itemCount.toString(),
                        style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildSearchBar()),
                const SizedBox(width: 12),
                _buildFilterToggle(),
              ],
            ),
            if (_showDietaryFilters) _buildDietaryPreferences(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterToggle() {
    final active = _filterVegetarian || _filterVegan;
    return GestureDetector(
      onTap: () => setState(() => _showDietaryFilters = !_showDietaryFilters),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryContainer : AppColors.surfaceContainerHigh.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Icon(
          Icons.tune_rounded,
          size: 18,
          color: active ? Colors.black : AppColors.primaryContainer,
        ),
      ),
    );
  }

  Widget _buildDietaryPreferences() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          _buildTinyFilterPill(
            label: 'VEGETARIAN',
            icon: Icons.eco_rounded,
            isSelected: _filterVegetarian,
            onTap: () {
              setState(() => _filterVegetarian = !_filterVegetarian);
              _updateFilters();
            },
          ),
          const SizedBox(width: 8),
          _buildTinyFilterPill(
            label: 'VEGAN',
            icon: Icons.spa_rounded,
            isSelected: _filterVegan,
            onTap: () {
              setState(() => _filterVegan = !_filterVegan);
              _updateFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTinyFilterPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.4) : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: isSelected ? AppColors.primaryContainer : Colors.white24),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : Colors.white24,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateFilters() {
    context.read<MenuViewModel>().applyDietaryFilters(
      isVegetarian: _filterVegetarian,
      isVegan: _filterVegan,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => context.read<MenuViewModel>().searchItems(val),
        style: GoogleFonts.manrope(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search the culinary loom...',
          hintStyle: GoogleFonts.manrope(color: Colors.white24, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryContainer, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSliverCategories(MenuViewModel vm) {
    return SliverToBoxAdapter(
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(top: 12),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: MenuCategory.values.length,
          itemBuilder: (context, index) {
            final category = MenuCategory.values[index];
            return CategoryChip(
              category: category,
              isSelected: vm.selectedCategory == category,
              onTap: () => vm.setCategory(category),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverMenu(MenuViewModel vm) {
    if (vm.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: AppColors.primaryContainer)),
      );
    }

    if (vm.filteredItems.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'Nothing found in this section.',
            style: GoogleFonts.manrope(color: Colors.white24, fontSize: 13),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => FoodCard(item: vm.filteredItems[index]),
          childCount: vm.filteredItems.length,
        ),
      ),
    );
  }
}
