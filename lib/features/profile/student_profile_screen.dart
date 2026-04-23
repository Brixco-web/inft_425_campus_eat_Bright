import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inft_425_campus_eat_bright/core/widgets/culinary_texture.dart';
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
      backgroundColor: Colors.transparent,
      body: CulinaryTexture(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top Branding
              _buildPremiumTopBar(),

              // Identity Section
              _buildIdentitySection(user?.displayName ?? 'Student'),

              // The Obsidian Ledger (Wallet)
              _buildObsidianLedger(context, walletVm),

              // Premium Actions Bento
              _buildBentoActions(context, orderVm),

              // Recent Chronicles (Transactions)
              _buildRecentChronicles(walletVm),

              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumTopBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STUDENT EXPERIENCE',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: AppColors.primaryContainer,
              ),
            ),
            _buildPulseIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4ADE80).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4ADE80).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF4ADE80),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'ENCRYPTED',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF4ADE80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitySection(String name) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryContainer.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: Icon(
                  Icons.school_rounded,
                  color: AppColors.primaryContainer,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.epilogue(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'VVU ELITE MERCHANT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryContainer,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObsidianLedger(BuildContext context, WalletViewModel vm) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL BALANCE',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white38,
                            letterSpacing: 2,
                          ),
                        ),
                        const Icon(
                          Icons.security_rounded,
                          color: AppColors.primaryContainer,
                          size: 18,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '₵ ${vm.balance.toStringAsFixed(2)}',
                      style: GoogleFonts.epilogue(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _buildLedgerAction(
                          Icons.add_circle_outline_rounded,
                          'TOP UP',
                        ),
                        const SizedBox(width: 12),
                        _buildLedgerAction(Icons.send_rounded, 'TRANSFER'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLedgerAction(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoActions(BuildContext context, OrderViewModel orderVm) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            // Active Pass (Wide Portal)
            _buildBentoPortal(
              title: orderVm.hasActiveOrder
                  ? 'ACTIVE PICKUP PASS'
                  : 'NO ACTIVE PASS',
              subtitle: orderVm.hasActiveOrder
                  ? 'Ready for collection'
                  : 'Browse the kitchen',
              icon: Icons.qr_code_2_rounded,
              color: orderVm.hasActiveOrder
                  ? const Color(0xFF4ADE80)
                  : Colors.white24,
              onTap: () {
                if (orderVm.hasActiveOrder) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PickupPassScreen(order: orderVm.activeOrders.first),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMiniBento(
                    title: 'ORDER HISTORY',
                    icon: Icons.auto_awesome_mosaic_rounded,
                    color: Colors.orangeAccent,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMiniBento(
                    title: 'APP SETTINGS',
                    icon: Icons.tune_rounded,
                    color: Colors.white,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoPortal({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBento({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentChronicles(WalletViewModel vm) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EXPERIENCE CHRONICLES',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.white24,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            if (vm.transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No chronicles found.',
                    style: GoogleFonts.manrope(color: Colors.white10),
                  ),
                ),
              )
            else
              ...vm.transactions.take(5).map((tx) => _buildChronicleTile(tx)),
          ],
        ),
      ),
    );
  }

  Widget _buildChronicleTile(WalletTransaction tx) {
    final isPurchase = tx.type == TransactionType.purchase;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPurchase
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isPurchase
                  ? Icons.receipt_long_rounded
                  : Icons.account_balance_wallet_rounded,
              color: isPurchase ? Colors.white38 : AppColors.primaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  tx.timestamp.toString().split(' ')[0],
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPurchase ? '-' : '+'}₵${tx.amount.toStringAsFixed(2)}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isPurchase ? Colors.white54 : AppColors.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
