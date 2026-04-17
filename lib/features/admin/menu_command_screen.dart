import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../models/menu_item_model.dart';
import '../../models/promotion_model.dart';
import 'add_edit_menu_item_screen.dart';
import 'add_edit_promotion_screen.dart';

class MenuCommandScreen extends StatefulWidget {
  const MenuCommandScreen({super.key});

  @override
  State<MenuCommandScreen> createState() => _MenuCommandScreenState();
}

class _MenuCommandScreenState extends State<MenuCommandScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Atmosphere
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildCustomTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInventoryTab(),
                      _buildPromotionsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAddFAB(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MENU ARCHITECT',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              letterSpacing: 4,
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Digital Inventory',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white38,
        labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 13),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'INVENTORY'),
          Tab(text: 'PROMOTIONS'),
        ],
      ),
    );
  }

  Widget _buildAddFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100), // Avoid Bottom Nav
      child: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditMenuItemScreen()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditPromotionScreen()));
          }
        },
        backgroundColor: AppColors.primaryContainer,
        child: const Icon(Icons.add_rounded, color: Colors.black),
      ),
    );
  }

  Widget _buildInventoryTab() {
    return Consumer<MenuViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.items.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer));
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          physics: const BouncingScrollPhysics(),
          itemCount: vm.items.length,
          itemBuilder: (context, index) => _buildItemCard(vm.items[index], vm),
        );
      },
    );
  }

  Widget _buildItemCard(MenuItem item, MenuViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.white10, child: const Icon(Icons.fastfood, color: Colors.white38)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.manrope(fontWeight: FontWeight.bold, decoration: item.isAvailable ? null : TextDecoration.lineThrough),
                ),
                Text(
                  'GHS ${item.price.toStringAsFixed(2)}',
                  style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch.adaptive(
                value: item.isAvailable,
                onChanged: (val) => vm.saveMenuItem(item.copyWith(isAvailable: val)),
                activeColor: AppColors.primaryContainer,
              ),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: Colors.white38),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditMenuItemScreen(item: item))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionsTab() {
    return Consumer<MenuViewModel>(
      builder: (context, vm, _) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          physics: const BouncingScrollPhysics(),
          itemCount: vm.activePromotions.length,
          itemBuilder: (context, index) => _buildPromoCard(vm.activePromotions[index], vm),
        );
      },
    );
  }

  Widget _buildPromoCard(PromotionModel promo, MenuViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.campaign_rounded, color: AppColors.primaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promo.title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
                Text(promo.description, style: GoogleFonts.manrope(fontSize: 12, color: Colors.white30), maxLines: 1),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: () => vm.deletePromotion(promo.id),
          ),
        ],
      ),
    );
  }
}
