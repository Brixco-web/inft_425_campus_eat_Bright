import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/wallet_viewmodel.dart';
import 'admin_wallet_manager.dart';

class FinancialCommandScreen extends StatefulWidget {
  const FinancialCommandScreen({super.key});

  @override
  State<FinancialCommandScreen> createState() => _FinancialCommandScreenState();
}

class _FinancialCommandScreenState extends State<FinancialCommandScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Atmosphere
          Positioned(
            top: 100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC084FC).withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverHeader(context),
                _buildSliverRevenueCards(),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                _buildSliverActions(context),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                _buildSliverRecentTransactions(),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FINANCIAL COMMAND',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                letterSpacing: 4,
                color: const Color(0xFFC084FC),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Revenue Center',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverRevenueCards() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.surfaceContainerHigh.withOpacity(0.8),
                AppColors.surfaceContainerLow.withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Text(
                'TOTAL LIQUIDITY',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  letterSpacing: 2,
                  color: Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'GHS 12,450.00',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat('Sales', 'GHS 8.2k', Colors.greenAccent),
                  _buildMiniStat('Credits', 'GHS 4.2k', AppColors.primaryContainer),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.white24, letterSpacing: 1),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(fontSize: 18, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSliverActions(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Student Top-up',
                color: AppColors.primaryContainer,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletManager())),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.receipt_long_rounded,
                label: 'View Reports',
                color: const Color(0xFFC084FC),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverRecentTransactions() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LATEST TRANSFERS',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                letterSpacing: 2,
                color: Colors.white30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(5, (index) => _buildTransactionItem()),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_upward_rounded, color: Colors.greenAccent, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Top-up',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Today, 2:45 PM',
                  style: GoogleFonts.manrope(fontSize: 11, color: Colors.white30),
                ),
              ],
            ),
          ),
          Text(
            '+GHS 50.00',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }
}
