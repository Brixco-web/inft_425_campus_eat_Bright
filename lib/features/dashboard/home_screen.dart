import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../models/menu_item_model.dart';
import '../../core/widgets/app_image.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _breatheController;
  late PageController _heroPageController;
  Timer? _heroTimer;
  int _currentHeroIndex = 1000; // Large center for infinite scrolling

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _heroPageController = PageController(initialPage: _currentHeroIndex);
    _startHeroTimer();
  }

  void _startHeroTimer() {
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_heroPageController.hasClients) {
        _heroPageController.animateToPage(
          _heroPageController.page!.toInt() + 1,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _breatheController.dispose();
    _heroPageController.dispose();
    _heroTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuVM = context.watch<MenuViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header Removed (Now in StudentShell)
              SliverToBoxAdapter(child: _buildQuickActionStrip()),
              SliverToBoxAdapter(child: _buildInfiniteHeroSlider()),
              SliverToBoxAdapter(child: _buildSectionHeader('Trending Now', icon: Icons.local_fire_department_rounded, iconColor: const Color(0xFFFF6B35))),
              SliverToBoxAdapter(child: _buildTrendingList(menuVM)),
              SliverToBoxAdapter(child: _buildSectionHeader('Best of Menu', icon: Icons.restaurant_menu_rounded, iconColor: const Color(0xFFC084FC))),
              _buildClassicsList(menuVM),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════
  //  2. QUICK ACTION STRIP — pill-shaped horizontal actions
  // ════════════════════════════════════════════════════
  Widget _buildQuickActionStrip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          _quickAction(Icons.flash_on_rounded, 'Quick Order', AppColors.primaryContainer),
          const SizedBox(width: 10),
          _quickAction(Icons.access_time_filled_rounded, 'Schedule', const Color(0xFFC084FC)),
          const SizedBox(width: 10),
          _quickAction(Icons.local_offer_rounded, 'Deals', const Color(0xFF4ADE80)),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11, fontWeight: FontWeight.w800,
                color: color, letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  //  3. INFINITE HERO SLIDER — cinematic promotional carousel
  // ════════════════════════════════════════════════════
  Widget _buildInfiniteHeroSlider() {
    final List<Map<String, String>> slides = [
      {
        'title': 'Heritage\nJollof',
        'subtitle': 'SIGNATURE PLATE',
        'price': '₵35.00',
        'image': 'assets/images/heritage_jollof.png',
        'color': '#FFB700',
      },
      {
        'title': 'Midnight\nFeast',
        'subtitle': 'LATE NIGHT SPECIAL',
        'price': 'FROM ₵25',
        'image': 'assets/images/culinary_promo_midnight_1776725489798.png',
        'color': '#FFD700',
      },
      {
        'title': 'Special\nDeals',
        'subtitle': 'EXCLUSIVE OFFER',
        'price': 'UP TO 50% OFF',
        'image': 'assets/images/culinary_promo_vibrant_deal_1776725973852.png',
        'color': '#FF6B35',
      },
    ];

    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _heroPageController,
        onPageChanged: (index) => setState(() => _currentHeroIndex = index),
        itemBuilder: (context, index) {
          final slide = slides[index % slides.length];
          return _buildHeroSlide(slide);
        },
      ),
    );
  }

  Widget _buildHeroSlide(Map<String, String> slide) {
    final accentColor = Color(int.parse(slide['color']!.replaceFirst('#', '0xFF')));
    
    return AnimatedBuilder(
      animation: _breatheController,
      builder: (_, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: const Color(0xFF161616),
            image: DecorationImage(
              image: AssetImage(slide['image']!),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.6), BlendMode.darken),
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.1 + (_breatheController.value * 0.08)),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(color: accentColor.withValues(alpha: 0.15), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Left gradient scrim
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.95),
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: accentColor, size: 11),
                            const SizedBox(width: 4),
                            Text(
                              slide['subtitle']!,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 8, fontWeight: FontWeight.w900,
                                color: accentColor, letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        slide['title']!,
                        style: GoogleFonts.epilogue(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.05,
                          letterSpacing: -1,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              'ORDER NOW',
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w900, fontSize: 11,
                                color: Colors.black, letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            slide['price']!,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18, fontWeight: FontWeight.w900,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════
  //  4. SECTION HEADER — with icon accent
  // ════════════════════════════════════════════════════
  Widget _buildSectionHeader(String title, {IconData? icon, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 14),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primaryContainer).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.primaryContainer, size: 14),
            ),
            const SizedBox(width: 10),
          ],
          Text(
            title,
            style: GoogleFonts.epilogue(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'See All',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11, fontWeight: FontWeight.w900,
                color: AppColors.primaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════
  //  5. TRENDING LIST — premium cards with rating, delivery time
  // ════════════════════════════════════════════════════
  Widget _buildTrendingList(MenuViewModel vm) {
    final items = vm.trendingItems;

    return SizedBox(
      height: 265,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.isEmpty ? 6 : items.length,
        itemBuilder: (context, index) {
          if (items.isEmpty) return _buildPlaceholderTrendingCard(index);
          return _buildTrendingCard(items[index], context);
        },
      ),
    );
  }

  Widget _buildTrendingCard(MenuItem item, BuildContext context) {
    return Container(
      width: 190,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with rating overlay
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                    child: AppImage(url: item.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                // Gradient overlay at bottom
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, const Color(0xFF111111).withValues(alpha: 0.8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Rating pill
                Positioned(
                  top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.primaryContainer, size: 12),
                        const SizedBox(width: 3),
                        Text('4.8', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                // Heart icon
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Icon(Icons.favorite_border_rounded, color: Colors.white70, size: 14),
                  ),
                ),
              ],
            ),
          ),
          // Info section
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: Colors.white.withValues(alpha: 0.2), size: 12),
                    const SizedBox(width: 4),
                    Text('15-20 min', style: GoogleFonts.manrope(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.white12, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('Hot', style: GoogleFonts.manrope(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₵${item.price.toStringAsFixed(2)}',
                      style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryContainer),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.read<CartViewModel>().addItem(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} added to cart!'),
                            backgroundColor: AppColors.primaryContainer,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.black, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTrendingCard(int index) {
    final names = ['Glazed Royal Burger', 'Basil Artisan Pizza', 'Oasis Tropical Sips', 'Ghanaian Heritage'];
    final prices = [45.50, 65.00, 25.00, 35.00];
    final times = ['15-20 min', '20-25 min', '5-10 min', '30 min'];
    final ratings = ['4.8', '4.9', '4.5', '4.7'];
    final images = [
      'assets/images/dashboard_food_hero.png',
      'assets/images/cuisine_hero.png',
      'assets/images/oasis_sips.png',
      'assets/images/waakye_thursday.png',
    ];

    return Container(
      width: 190,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                    child: Image.asset(images[index % 4], fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, const Color(0xFF111111).withValues(alpha: 0.8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.primaryContainer, size: 12),
                        const SizedBox(width: 3),
                        Text(ratings[index % 4], style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Icon(Icons.favorite_border_rounded, color: Colors.white70, size: 14),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(names[index % 4], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: Colors.white.withValues(alpha: 0.2), size: 12),
                    const SizedBox(width: 4),
                    Text(times[index % 4], style: GoogleFonts.manrope(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.white12, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('Hot', style: GoogleFonts.manrope(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₵${prices[index % 4].toStringAsFixed(2)}', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryContainer)),
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.add_rounded, color: Colors.black, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════
  //  6. CLASSICS LIST — elevated horizontal rows with glassmorphic details
  // ════════════════════════════════════════════════════
  Widget _buildClassicsList(MenuViewModel vm) {
    if (vm.items.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildPlaceholderClassicCard(index),
            childCount: 4,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildClassicCard(vm.items[index], context),
          childCount: vm.items.take(6).length,
        ),
      ),
    );
  }

  Widget _buildClassicCard(MenuItem item, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          // Rounded image with gradient border
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [AppColors.primaryContainer.withValues(alpha: 0.4), Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AppImage(url: item.imageUrl, width: 60, height: 60, fit: BoxFit.cover, borderRadius: 14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.primaryContainer, size: 12),
                    const SizedBox(width: 3),
                    Text('4.7', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white54)),
                    const SizedBox(width: 8),
                    Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.white12, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('20 min', style: GoogleFonts.manrope(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₵${item.price.toStringAsFixed(2)}',
                style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primaryContainer),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  context.read<CartViewModel>().addItem(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.name} added to cart!'),
                      backgroundColor: AppColors.primaryContainer,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white54, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderClassicCard(int index) {
    final names = ['Midnight Pizza', 'Plantain Platter', 'Espresso Shot', 'Double Cheese Burger'];
    final prices = [35.50, 45.00, 15.00, 55.00];
    final ratings = ['4.6', '4.8', '4.3', '4.9'];
    final times = ['20 min', '15 min', '5 min', '25 min'];
    final images = [
      'assets/images/cuisine_hero.png',
      'assets/images/waakye_thursday.png',
      'assets/images/oasis_sips.png',
      'assets/images/dashboard_food_hero.png',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [AppColors.primaryContainer.withValues(alpha: 0.4), Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(images[index % 4], width: 60, height: 60, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(names[index % 4], style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.primaryContainer, size: 12),
                    const SizedBox(width: 3),
                    Text(ratings[index % 4], style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white54)),
                    const SizedBox(width: 8),
                    Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.white12, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(times[index % 4], style: GoogleFonts.manrope(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₵${prices[index % 4].toStringAsFixed(2)}', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primaryContainer)),
              const SizedBox(height: 6),
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add_rounded, color: Colors.white54, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
