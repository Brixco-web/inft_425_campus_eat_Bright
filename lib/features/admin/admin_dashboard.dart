import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import 'admin_scanner_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'OBSIDIAN COMMAND',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _orderService.getAllOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer));
          }

          final orders = snapshot.data ?? [];
          final activeOrders = orders.where((o) => o.status != OrderStatus.collected && o.status != OrderStatus.cancelled).toList();
          final pendingCount = orders.where((o) => o.status == OrderStatus.pending).length;
          final readyCount = orders.where((o) => o.status == OrderStatus.ready).length;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Stats
                Row(
                  children: [
                    _buildStatCard('PENDING', pendingCount.toString(), AppColors.primaryContainer),
                    const SizedBox(width: 16),
                    _buildStatCard('READY', readyCount.toString(), Colors.greenAccent),
                    const SizedBox(width: 16),
                    _buildNavCard('WALLET', Icons.account_balance_wallet, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletManager()));
                    }),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Queue Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PRIORITY QUEUE',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      '${activeOrders.length} ACTIVE',
                      style: GoogleFonts.manrope(
                        color: AppColors.primaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Order List
                Expanded(
                  child: activeOrders.isEmpty
                      ? _buildEmptyQueue()
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: activeOrders.length,
                          itemBuilder: (context, index) {
                            return _buildOrderListItem(activeOrders[index]);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminScannerScreen()),
        ),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.qr_code_scanner),
        label: Text('SCAN PICKUP', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyQueue() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 48, color: AppColors.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'QUEUE IS CLEAR',
            style: GoogleFonts.spaceGrotesk(color: AppColors.onSurfaceVariant, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderListItem(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: order.status == OrderStatus.ready ? Colors.greenAccent.withValues(alpha: 0.3) : AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.studentName.toUpperCase()}',
                style: GoogleFonts.spaceGrotesk(color: AppColors.onSurface, fontWeight: FontWeight.bold),
              ),
              _buildSimpleStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${order.items.length} items • GHS ${order.totalAmount.toStringAsFixed(2)}',
            style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant, fontSize: 12),
          ),
          if (order.isLectureMode && order.pickupTime != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'TARGET: ${DateFormat('h:mm a').format(order.pickupTime!)}',
                style: GoogleFonts.manrope(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 16),
          if (order.status == OrderStatus.pending)
            ElevatedButton(
              onPressed: () => _orderService.markOrderReady(order.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('MARK AS READY', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 12)),
            )
          else
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                SizedBox(width: 8),
                Text('WAITING FOR SCAN', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSimpleStatusBadge(OrderStatus status) {
    return Text(
      status.name.toUpperCase(),
      style: GoogleFonts.spaceGrotesk(
        color: status == OrderStatus.ready ? Colors.greenAccent : AppColors.primaryContainer,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNavCard(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primaryContainer, size: 20),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.onSurface,
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.spaceGrotesk(color: color, fontSize: 10, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.spaceGrotesk(color: AppColors.onSurface, fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
