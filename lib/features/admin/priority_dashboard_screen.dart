import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';

class PriorityDashboardScreen extends StatefulWidget {
  const PriorityDashboardScreen({super.key});

  @override
  State<PriorityDashboardScreen> createState() => _PriorityDashboardScreenState();
}

class _PriorityDashboardScreenState extends State<PriorityDashboardScreen> {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildStatsOverview(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PRIORITY QUEUE',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          letterSpacing: 2,
                          color: Colors.white30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.sort_rounded, color: Colors.white30, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildOrderStream()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OBSIDIAN COMMAND',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              letterSpacing: 4,
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Control Tower',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return StreamBuilder<List<OrderModel>>(
      stream: _orderService.getAllOrdersStream(),
      builder: (context, snapshot) {
        final orders = snapshot.data ?? [];
        final pending = orders.where((o) => o.status == OrderStatus.pending).length;
        final ready = orders.where((o) => o.status == OrderStatus.ready).length;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(child: _buildStatItem('Pending', pending.toString(), AppColors.primaryContainer)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatItem('Ready', ready.toString(), const Color(0xFF4ADE80))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatItem('Today', orders.length.toString(), const Color(0xFFC084FC))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(fontSize: 10, letterSpacing: 1, color: color.withOpacity(0.7), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStream() {
    return StreamBuilder<List<OrderModel>>(
      stream: _orderService.getAllOrdersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer));
        }

        final orders = snapshot.data ?? [];
        final activeOrders = orders.where((o) => o.status != OrderStatus.collected && o.status != OrderStatus.cancelled).toList();

        if (activeOrders.isEmpty) {
          return Center(
            child: Text(
              'No active signals detected.',
              style: GoogleFonts.manrope(color: Colors.white24),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
          physics: const BouncingScrollPhysics(),
          itemCount: activeOrders.length,
          itemBuilder: (context, index) => _buildOrderCard(activeOrders[index]),
        );
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final bool isReady = order.status == OrderStatus.ready;
    final bool isLecture = order.isLectureMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.3),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isReady ? const Color(0xFF4ADE80).withOpacity(0.2) : AppColors.outlineVariant.withOpacity(0.05),
          width: 1.5,
        ),
      ),
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
                    order.studentName,
                    style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    'Order #${order.id.substring(0, 8).toUpperCase()}',
                    style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.white30, letterSpacing: 1),
                  ),
                ],
              ),
              _buildStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 20),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${item.quantity}x ${item.name}',
              style: GoogleFonts.manrope(fontSize: 13, color: Colors.white70),
            ),
          )),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isLecture && order.pickupTime != null)
                Row(
                  children: [
                    const Icon(Icons.school_rounded, color: Colors.orangeAccent, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      'PICKUP: ${DateFormat('h:mm a').format(order.pickupTime!)}',
                      style: GoogleFonts.spaceGrotesk(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
              
              if (order.status == OrderStatus.pending)
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () => _orderService.markOrderReady(order.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text('READY FOR COLLECTION', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                )
              else
                Row(
                  children: [
                    const Icon(Icons.hourglass_empty_rounded, color: Color(0xFF4ADE80), size: 14),
                    const SizedBox(width: 8),
                    Text(
                      'WAITING FOR SCAN',
                      style: GoogleFonts.spaceGrotesk(color: const Color(0xFF4ADE80), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color = AppColors.primaryContainer;
    if (status == OrderStatus.ready) color = const Color(0xFF4ADE80);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }
}
