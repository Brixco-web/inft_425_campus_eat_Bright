import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../models/order_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'widgets/order_card.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<OrderViewModel>().listenToOrders(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderVM = context.watch<OrderViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Layer 1: Atmospheric Base ──
          Positioned.fill(
            child: Image.asset(
              'assets/images/dashboard_food_hero.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.05),
            ),
          ),

          // ── Layer 2: Main Narrative ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChronicleTabs(),
                
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActiveChronicles(orderVM),
                    _buildPastChronicles(orderVM),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildChronicleTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
        unselectedLabelColor: Colors.white38,
        labelColor: Colors.black,
        indicator: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.2),
              blurRadius: 10,
            ),
          ],
        ),
        tabs: const [
          Tab(text: 'ACTIVE'),
          Tab(text: 'HISTORY'),
        ],
      ),
    );
  }

  Widget _buildActiveChronicles(OrderViewModel vm) {
    final activeOrders = vm.orders.where((o) => o.status != OrderStatus.collected && o.status != OrderStatus.cancelled).toList();

    if (vm.isLoading) return _buildLoadingState();
    if (activeOrders.isEmpty) return _buildEmptyState('NO ACTIVE WEAVES', 'Your current culinary journeys will appear here.');

    return RefreshIndicator(
      onRefresh: () async => vm.listenToOrders(context.read<AuthViewModel>().user!.uid),
      color: AppColors.primaryContainer,
      backgroundColor: AppColors.background,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 10, bottom: 100),
        itemCount: activeOrders.length,
        itemBuilder: (context, index) => OrderCard(order: activeOrders[index]),
      ),
    );
  }

  Widget _buildPastChronicles(OrderViewModel vm) {
    final pastOrders = vm.orders.where((o) => o.status == OrderStatus.collected || o.status == OrderStatus.cancelled).toList();

    if (vm.isLoading) return _buildLoadingState();
    if (pastOrders.isEmpty) return _buildEmptyState('ANCIENT HISTORY', 'Your completed chronicles belong here.');

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 10, bottom: 100),
      itemCount: pastOrders.length,
      itemBuilder: (context, index) => OrderCard(order: pastOrders[index]),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryContainer, strokeWidth: 2),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(36),
            ),
            child: const Icon(Icons.history_edu_rounded, size: 48, color: Colors.white10),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(color: Colors.white24, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 4),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(color: Colors.white10, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
