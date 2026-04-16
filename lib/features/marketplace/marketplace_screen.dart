import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../models/menu_item_model.dart';
import '../../models/promotion_model.dart';
import 'widgets/category_chip.dart';
import 'widgets/food_card.dart';
import 'widgets/promo_banner.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuViewModel = context.watch<MenuViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Immersive Background
          _buildImmersiveBackground(size),

          // 2. Atmospheric Orbs
          _buildAtmosphericOrbs(size),

          // 3. Main Content (Scrollable)
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header & Search
              _buildSliverHeader(context),

              // Promotional Carousel (Waakye Thursday, etc.)
              _buildSliverPromotions(menuViewModel),

              // Categories Selector
              _buildSliverCategories(menuViewModel),

              // Menu Grid
              _buildSliverMenu(menuViewModel),

              // Bottom Padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImmersiveBackground(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.8, -0.6),
          radius: 1.2,
          colors: [
            AppColors.primaryContainer.withValues(alpha: 0.05),
            AppColors.surfaceContainerLowest,
          ],
        ),
      ),
    );
  }

  Widget _buildAtmosphericOrbs(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryContainer.withValues(alpha: 0.03),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 180,
      floating: true,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OBSIDIAN LOOM',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          letterSpacing: 4.0,
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Marketplace',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                  _buildProfileBadge(),
                ],
              ),
              const SizedBox(height: 24),
              _buildSearchBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileBadge() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: const CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.surfaceContainerHigh,
        child: Icon(Icons.person_outline, color: AppColors.primaryContainer, size: 20),
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.4),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => context.read<MenuViewModel>().searchItems(val),
            style: GoogleFonts.manrope(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search for Delights...',
              hintStyle: GoogleFonts.manrope(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: AppColors.primaryContainer, size: 20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverPromotions(MenuViewModel vm) {
    // Priority 1: Admin-defined active promotions (Static Pushes)
    // Priority 2: Automated Spotlight items (Ratings >= 4.5)
    final promos = vm.activePromotions;
    final spotlights = vm.spotlightItems;
    
    final displayItems = promos.isNotEmpty ? promos : spotlights;
    
    if (displayItems.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: CarouselSlider.builder(
          itemCount: displayItems.length,
          itemBuilder: (context, index, realIndex) {
            final item = displayItems[index];
            if (item is PromotionModel) {
              return PromoBanner(promo: item);
            } else {
              return PromoBanner(item: item as MenuItem);
            }
          },
          options: CarouselOptions(
            height: 200,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverCategories(MenuViewModel vm) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
            'No items found in the Loom.',
            style: GoogleFonts.spaceGrotesk(color: Colors.white38),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => FoodCard(item: vm.filteredItems[index]),
          childCount: vm.filteredItems.length,
        ),
      ),
    );
  }
}
