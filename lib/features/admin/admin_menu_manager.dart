import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_image.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../models/menu_item_model.dart';
import '../../models/promotion_model.dart';
import 'add_edit_menu_item_screen.dart';
import 'add_edit_promotion_screen.dart';

class AdminMenuManager extends StatefulWidget {
  const AdminMenuManager({super.key});

  @override
  State<AdminMenuManager> createState() => _AdminMenuManagerState();
}

class _AdminMenuManagerState extends State<AdminMenuManager> with SingleTickerProviderStateMixin {
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'MENU ARCHITECT',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_motion_rounded, color: AppColors.primaryContainer),
            tooltip: 'Restore Blueprint',
            onPressed: () => _showSeedConfirm(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryContainer,
          labelColor: AppColors.primaryContainer,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          tabs: const [
            Tab(text: 'INVENTORY'),
            Tab(text: 'TIMED FLIERS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInventoryTab(),
          _buildFliersTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditMenuItemScreen()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditPromotionScreen()));
          }
        },
        backgroundColor: AppColors.primaryContainer,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildInventoryTab() {
    return Consumer<MenuViewModel>(
      builder: (context, menuVM, _) {
        if (menuVM.isLoading && menuVM.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: menuVM.items.length,
          itemBuilder: (context, index) {
            final item = menuVM.items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildItemCard(item, menuVM),
            );
          },
        );
      },
    );
  }

  Widget _buildFliersTab() {
    return Consumer<MenuViewModel>(
      builder: (context, menuVM, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: menuVM.activePromotions.length,
          itemBuilder: (context, index) {
            final promo = menuVM.activePromotions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPromoCard(promo, menuVM),
            );
          },
        );
      },
    );
  }

  Widget _buildItemCard(MenuItem item, MenuViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AppImage(
                    url: item.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₵${item.price.toStringAsFixed(2)}',
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      item.isAvailable ? 'ACTIVE' : 'OFFLINE',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: item.isAvailable ? Colors.greenAccent : Colors.redAccent,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Switch(
                      value: item.isAvailable,
                      onChanged: (val) => vm.saveMenuItem(item.copyWith(isAvailable: val)),
                      activeThumbColor: Colors.greenAccent,
                      activeTrackColor: Colors.greenAccent.withValues(alpha: 0.2),
                      inactiveTrackColor: Colors.white10,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded, color: Colors.white38),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddEditMenuItemScreen(item: item)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoCard(PromotionModel promo, MenuViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.campaign, color: AppColors.primaryContainer, size: 32),
        title: Text(promo.title, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text('ID: ${promo.id.substring(0, 8)}', style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant, fontSize: 10)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => vm.deletePromotion(promo.id),
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditPromotionScreen(promotion: promo))),
      ),
    );
  }

  void _showSeedConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'RESTORE BLUEPRINT?',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white),
        ),
        content: Text(
          'This will re-sync the live menu with the codebase blueprint, including the new Campus Gems updates. Existing custom modifications may be overwritten.',
          style: GoogleFonts.manrope(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.spaceGrotesk(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final menuVM = context.read<MenuViewModel>();
              
              nav.pop();
              await menuVM.seedMenu();
              
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Marketplace synchronized with Obsidian Blueprint.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('PROCEED', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
