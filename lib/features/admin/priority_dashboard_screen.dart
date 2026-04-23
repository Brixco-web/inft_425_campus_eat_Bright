import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../core/widgets/chef_admin_emblem.dart';
import '../../viewmodels/menu_viewmodel.dart';
import 'package:provider/provider.dart';

class PriorityDashboardScreen extends StatefulWidget {
  const PriorityDashboardScreen({super.key});

  @override
  State<PriorityDashboardScreen> createState() => _PriorityDashboardScreenState();
}

class _PriorityDashboardScreenState extends State<PriorityDashboardScreen> with TickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  late AnimationController _pulseController;
  late AnimationController _breatheController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060606),
      body: Stack(
        children: [
          // ── Layer 1: Atmospheric Command Base ──
          AnimatedBuilder(
            animation: _breatheController,
            builder: (context, child) => Positioned(
              bottom: -50 + (_breatheController.value * 20),
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFEF4444).withValues(alpha: 0.04 + (_breatheController.value * 0.02)),
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
                _buildMetricsGrid(),
                _buildQueueHeader(),
                _buildPriorityQueue(),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
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
                        FadeTransition(
                          opacity: _pulseController,
                          child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'KITCHEN COMMAND UNIT',
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
                    'SECURITY CLEARANCE: ADMIN',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: Colors.white24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Command Tower',
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
            // Notification Bell
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: const Icon(Icons.notifications_none_rounded, color: Colors.white70),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Sync Button (Admin Utility)
            GestureDetector(
              onTap: () async {
                try {
                  await context.read<MenuViewModel>().seedMenu();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Culinary Ledger Synchronized Successfully'),
                        backgroundColor: AppColors.primaryContainer,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sync Error: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.sync_rounded, color: AppColors.primaryContainer),
              ),
            ),
            const SizedBox(width: 12),
            const ChefAdminEmblem(size: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      sliver: SliverToBoxAdapter(
        child: StreamBuilder<List<OrderModel>>(
          stream: _orderService.getAllOrdersStream(),
          builder: (context, snapshot) {
            final orders = snapshot.data ?? [];
            final today = DateTime.now();
            final todayOrders = orders.where((o) => 
                o.createdAt.year == today.year && 
                o.createdAt.month == today.month && 
                o.createdAt.day == today.day).toList();
            
            final pending = todayOrders.where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.preparing).length;
            final completed = todayOrders.where((o) => o.status == OrderStatus.collected).length;
            final totalGHS = todayOrders.fold(0.0, (sum, o) => sum + o.totalAmount);

            return SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildTerminalMetric('PENDING', pending.toString(), AppColors.primaryContainer),
                  const SizedBox(width: 12),
                  _buildTerminalMetric('COMPLETED', completed.toString(), const Color(0xFF4ADE80)),
                  const SizedBox(width: 12),
                  _buildTerminalMetric('REVENUE', '₵${totalGHS.toStringAsFixed(0)}', Colors.white70),
                  const SizedBox(width: 12),
                  _buildTerminalMetric('ALL TIME', orders.length.toString(), const Color(0xFFC084FC)),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildTerminalMetric(String label, String value, Color color) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 1.5),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.epilogue(fontSize: 22, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
        child: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: AppColors.primaryContainer, size: 20),
            const SizedBox(width: 8),
            Text(
              'LIVE DISPATCH',
              style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
              child: Text('14 ACTIVE', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primaryContainer)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityQueue() {
    return StreamBuilder<List<OrderModel>>(
      stream: _orderService.getAllOrdersStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SliverToBoxAdapter(child: SizedBox.shrink());
        final orders = snapshot.data!.where((o) => o.status != OrderStatus.collected).toList();
        
        final asapOrders = orders.where((o) => !o.isLectureMode).toList();
        final batchedOrders = orders.where((o) => o.isLectureMode).toList();
        
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (asapOrders.isNotEmpty) ...asapOrders.map(_buildASAPCard),
              const SizedBox(height: 24),
              _buildBatchSection(batchedOrders),
              const SizedBox(height: 32),
              _buildKitchenCapacity(),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildASAPCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.person_outline_rounded, color: AppColors.primaryContainer, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.studentName.toUpperCase(),
                      style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ORD-${order.id.substring(0, 4).toUpperCase()}',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white24),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(order.status),
                  const SizedBox(height: 4),
                  Text('03:45', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Items list with bullet indicators
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Text('${item.quantity}x', style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontSize: 13, fontWeight: FontWeight.w900)),
                const SizedBox(width: 8),
                Text(item.name, style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const Spacer(),
                const Icon(Icons.info_outline_rounded, color: Colors.white12, size: 14),
              ],
            ),
          )),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(order),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.more_horiz_rounded, color: Colors.white54, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatchSection(List<OrderModel> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.school_rounded, color: Colors.white24, size: 18),
            const SizedBox(width: 8),
            Text(
              'LECTURE DISPATCH',
              style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 1),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildBatchCard("12:30 BATCH", "Hall A • Main Block", "8 Orders", true),
        const SizedBox(height: 12),
        _buildBatchCard("13:15 BATCH", "Lab C • Science Wing", "12 Orders", false),
      ],
    );
  }

  Widget _buildBatchCard(String title, String location, String count, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isActive ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: isActive ? Colors.blueAccent.withValues(alpha: 0.1) : Colors.white10,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(isActive ? Icons.timer_rounded : Icons.lock_outline_rounded, color: isActive ? Colors.blueAccent : Colors.white12, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.epilogue(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 4),
                Text(location, style: GoogleFonts.manrope(fontSize: 12, color: Colors.white24, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(count, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w900, color: isActive ? Colors.white : Colors.white10)),
              if (isActive)
                Text('In Prep', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF4ADE80))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    String text = 'ASAP';
    Color color = const Color(0xFFFF6B35);
    
    switch (status) {
      case OrderStatus.preparing:
        text = 'SIZZLING';
        color = Colors.blueAccent;
        break;
      case OrderStatus.ready:
        text = 'READY';
        color = const Color(0xFF4ADE80);
        break;
      case OrderStatus.collected:
        text = 'COMPLETED';
        color = Colors.white24;
        break;
      default:
        break;
    }
    
    return Text(text, style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900, color: color));
  }

  Widget _buildActionButton(OrderModel order) {
    String label = 'MARK READY';
    VoidCallback? action;
    Color color = AppColors.primaryContainer;
    Color textColor = Colors.black;

    if (order.status == OrderStatus.pending) {
      label = 'START PREPARING';
      action = () => _orderService.markOrderPreparing(order.id);
    } else if (order.status == OrderStatus.preparing) {
      label = 'MARK READY';
      action = () => _orderService.markOrderReady(order.id);
    } else if (order.status == OrderStatus.ready) {
      label = 'AWAITING PICKUP';
      color = Colors.white10;
      textColor = Colors.white38;
      action = null; // No action needed here, handled by scanner
    }

    return GestureDetector(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: action != null ? [
            BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 5)),
          ] : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label, 
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900, 
            color: textColor, 
            letterSpacing: 1
          )
        ),
      ),
    );
  }

  Widget _buildKitchenCapacity() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('KITCHEN CAPACITY', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 2)),
              Text('78%', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primaryContainer)),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(width: double.infinity, height: 6, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(3))),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.78,
                child: Container(
                  height: 6, 
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer, 
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.3), blurRadius: 10)],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Reaching peak throughout. Automated throttling active for new incoming signals.',
            style: GoogleFonts.manrope(fontSize: 11, color: Colors.white24, height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
