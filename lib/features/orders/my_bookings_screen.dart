import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'widgets/order_card.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<OrderViewModel>().listenToOrders(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderVM = context.watch<OrderViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ORDER HISTORY',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: orderVM.isLoading && orderVM.orders.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
          : orderVM.orders.isEmpty
              ? _buildEmptyState()
              : _buildOrdersList(orderVM),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.outlineVariant),
          const SizedBox(height: 24),
          Text(
            'TRACKING THE WEB...',
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 3,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your collection of past & active looms',
            style: GoogleFonts.manrope(
              color: AppColors.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(OrderViewModel orderVM) {
    return RefreshIndicator(
      onRefresh: () async {
        final user = context.read<AuthViewModel>().user;
        if (user != null) {
          orderVM.listenToOrders(user.uid);
        }
      },
      color: AppColors.primaryContainer,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100, top: 20),
        itemCount: orderVM.orders.length,
        itemBuilder: (context, index) {
          return OrderCard(order: orderVM.orders[index]);
        },
      ),
    );
  }
}
