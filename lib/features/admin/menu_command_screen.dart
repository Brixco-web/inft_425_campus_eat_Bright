import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../models/menu_item_model.dart';
import '../../core/widgets/chef_admin_emblem.dart';
import 'add_edit_menu_item_screen.dart';

class MenuCommandScreen extends StatefulWidget {
  const MenuCommandScreen({super.key});

  @override
  State<MenuCommandScreen> createState() => _MenuCommandScreenState();
}

class _MenuCommandScreenState extends State<MenuCommandScreen> with TickerProviderStateMixin {
  final TextEditingController _promoHeadlineController = TextEditingController(text: 'Oasis Rapid-Pass');
  final TextEditingController _promoDescController = TextEditingController(text: 'Skip the queue with digital vouchers');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSeeding = false;

  late AnimationController _breatheController;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _promoHeadlineController.dispose();
    _promoDescController.dispose();
    _searchController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060606),
      body: Stack(
        children: [
          // ── Layer 1: Atmospheric Ambient Glow ──
          AnimatedBuilder(
            animation: _breatheController,
            builder: (context, child) => Positioned(
              top: -100 + (_breatheController.value * 30),
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryContainer.withValues(alpha: 0.05 + (_breatheController.value * 0.03)),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildModernHeader(),
                _buildCinematicPromo(),
                _buildInventoryHeader(),
                _buildInventoryVault(),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildArchitectFAB(),
    );
  }

  Widget _buildModernHeader() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      sliver: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.architecture_rounded, color: AppColors.primaryContainer, size: 12),
                        const SizedBox(width: 8),
                        Text(
                          'KITCHEN ARCHITECT',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 8,
                            letterSpacing: 2,
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Menu Blueprint',
                    style: GoogleFonts.epilogue(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),
            const ChefAdminEmblem(size: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildCinematicPromo() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'FEATURED BANNER',
                  style: GoogleFonts.spaceGrotesk(fontSize: 10, letterSpacing: 2, color: Colors.white24, fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                _buildSeedButton(context),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: const Color(0xFF111111),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  children: [
                    // Glassmorphic edit controls
                    Row(
                      children: [
                        // Left: Preview Card
                        Container(
                          width: 140,
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/oasis_sips_premium_png_1776598838427.png'),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black54, blurRadius: 15, offset: const Offset(4, 4)),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        // Right: Text Inputs
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _promoInput('Headline', _promoHeadlineController),
                                const SizedBox(height: 12),
                                _promoInput('Description', _promoDescController),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Action button overlay
                    Positioned(
                      bottom: 12, right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'UPDATE LIVE',
                          style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _promoInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.spaceGrotesk(fontSize: 8, color: Colors.white24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: GoogleFonts.manrope(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryContainer)),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryHeader() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DISH INVENTORY',
                  style: GoogleFonts.spaceGrotesk(fontSize: 10, letterSpacing: 2, color: Colors.white24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text('Vault Archives', style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white70)),
              ],
            ),
            Container(
              width: 140,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                style: GoogleFonts.manrope(fontSize: 12, color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 11),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.white24, size: 16),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryVault() {
    return Consumer<MenuViewModel>(
      builder: (context, vm, _) {
        final items = vm.items.where((i) => i.name.toLowerCase().contains(_searchQuery)).toList();
        
        if (vm.isLoading && items.isEmpty) {
          return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primaryContainer)));
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildBlueprintCard(items[index], vm),
              childCount: items.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlueprintCard(MenuItem item, MenuViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          // Cinematic image frame
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  item.isAvailable ? AppColors.primaryContainer.withValues(alpha: 0.3) : Colors.white10,
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                item.imageUrl,
                width: 60, height: 60,
                fit: BoxFit.cover,
                color: item.isAvailable ? null : Colors.black.withValues(alpha: 0.6),
                colorBlendMode: item.isAvailable ? null : BlendMode.darken,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.white10, width: 60, height: 60, child: const Icon(Icons.restaurant_rounded, color: Colors.white10)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.epilogue(
                    fontWeight: FontWeight.w800, 
                    color: item.isAvailable ? Colors.white : Colors.white24,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '₵${item.price.toStringAsFixed(2)}',
                      style: GoogleFonts.spaceGrotesk(color: item.isAvailable ? AppColors.primaryContainer : Colors.white10, fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Flexible(
                        child: Text(
                          item.category.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Stock control
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Transform.scale(
                scale: 0.8,
                child: Switch.adaptive(
                  value: item.isAvailable,
                  onChanged: (val) => vm.saveMenuItem(item.copyWith(isAvailable: val)),
                  activeThumbColor: AppColors.primaryContainer,
                  activeTrackColor: AppColors.primaryContainer.withValues(alpha: 0.3),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.isAvailable ? 'IN STOCK' : 'SOLD OUT',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 7, 
                  fontWeight: FontWeight.w900, 
                  color: item.isAvailable ? const Color(0xFF4ADE80) : Colors.redAccent.withValues(alpha: 0.3),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Colors.white24, size: 22),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditMenuItemScreen(item: item))),
          ),
        ],
      ),
    );
  }

  Widget _buildSeedButton(BuildContext context) {
    return GestureDetector(
      onTap: _isSeeding ? null : () async {
        setState(() => _isSeeding = true);
        final vm = context.read<MenuViewModel>();
        try {
          await vm.seedMenu();
        } finally {
          if (mounted) setState(() => _isSeeding = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isSeeding ? AppColors.primaryContainer.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _isSeeding ? AppColors.primaryContainer.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isSeeding)
              const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(color: AppColors.primaryContainer, strokeWidth: 2))
            else
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryContainer, size: 14),
            const SizedBox(width: 8),
            Text(
              _isSeeding ? 'SEEDING...' : 'RESEED VAULT',
              style: GoogleFonts.spaceGrotesk(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.primaryContainer, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchitectFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditMenuItemScreen())),
        backgroundColor: AppColors.primaryContainer,
        elevation: 10,
        extendedIconLabelSpacing: 10,
        label: Text('NEW BLUEPRINT', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1)),
        icon: const Icon(Icons.add_rounded, color: Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
