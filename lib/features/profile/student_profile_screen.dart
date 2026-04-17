import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../viewmodels/wallet_viewmodel.dart';
import '../orders/pickup_pass_screen.dart';
import '../../models/wallet_model.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final walletVm = context.watch<WalletViewModel>();
    final orderVm = context.watch<OrderViewModel>();
    final user = authVm.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient
          _buildBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(context, user?.displayName ?? 'Student'),
                  const SizedBox(height: 24),
                  
                  // Wallet Card
                  _buildWalletCard(context, walletVm),
                  const SizedBox(height: 24),

                  // Quick Actions Bento
                  _buildQuickActions(context, orderVm),
                  const SizedBox(height: 32),

                  // Recent Activity
                  _buildRecentActivity(context, walletVm),
                  const SizedBox(height: 100), // Padding for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryContainer.withValues(alpha: 0.05),
              AppColors.background,
              AppColors.background,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Row(
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
              'My Account',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.read<AuthViewModel>().logout(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard(BuildContext context, WalletViewModel vm) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1614850523296-d8c1af93d400?q=80&w=2070&auto=format&fit=crop'),
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DIGITAL WALLET',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        letterSpacing: 2,
                        color: Colors.white70,
                      ),
                    ),
                    const Icon(Icons.nfc_rounded, color: AppColors.primaryContainer, size: 20),
                  ],
                ),
                const Spacer(),
                Text(
                  'GHS ${vm.balance.toStringAsFixed(2)}',
                  style: GoogleFonts.epilogue(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBalanceBadge('Ready to Spend'),
                    const SizedBox(width: 8),
                    _buildBalanceBadge('Verified'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryContainer,
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, OrderViewModel orderVm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.epilogue(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionItem(
                context,
                Icons.qr_code_rounded,
                'My Pass',
                orderVm.hasActiveOrder ? 'Active Pass' : 'No active pass',
                AppColors.primaryContainer,
                onTap: () {
                  if (orderVm.hasActiveOrder) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PickUpPassScreen(order: orderVm.activeOrders.first),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No active orders to collect.')),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionItem(
                context,
                Icons.card_giftcard_rounded,
                'Rewards',
                '120 Points',
                const Color(0xFFFACC15),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color accent, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.epilogue(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, WalletViewModel vm) {
    final transactions = vm.transactions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'View All',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppColors.primaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (transactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'No transactions yet.',
                style: GoogleFonts.manrope(color: Colors.white38),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return _buildTransactionItem(tx);
            },
          ),
      ],
    );
  }

  Widget _buildTransactionItem(WalletTransaction tx) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              tx.type == TransactionType.purchase ? Icons.shopping_bag_outlined : Icons.account_balance_wallet_outlined,
              color: tx.type == TransactionType.purchase ? AppColors.secondaryContainer : AppColors.primaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  tx.timestamp.toString().split(' ')[0],
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${tx.type == TransactionType.purchase ? '-' : '+'}GHS ${tx.amount.toStringAsFixed(2)}',
            style: GoogleFonts.epilogue(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: tx.type == TransactionType.purchase ? Colors.white : AppColors.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
