import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/wallet_service.dart';

class UserVaultDetailScreen extends StatelessWidget {
  final UserModel user;
  final WalletService _walletService = WalletService();

  UserVaultDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060606),
      body: Stack(
        children: [
          // Cinematic Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/cuisine_hero.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.05),
            ),
          ),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              _buildUserHero(),
              _buildBalanceCard(),
              _buildTransactionheader(),
              _buildTransactionHistory(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildUserHero() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Hero(
              tag: 'user-avatar-${user.uid}',
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryContainer, width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 5),
                  ],
                  gradient: LinearGradient(
                    colors: [AppColors.primaryContainer.withValues(alpha: 0.2), Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    user.displayName[0].toUpperCase(),
                    style: GoogleFonts.epilogue(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.primaryContainer),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user.displayName.toUpperCase(),
              style: GoogleFonts.epilogue(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
            ),
            Text(
              'VAULT IDENTITY: ${user.studentId}',
              style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white24, letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return SliverToBoxAdapter(
      child: StreamBuilder(
        stream: _walletService.getWalletStream(user.uid),
        builder: (context, snapshot) {
          final balance = snapshot.hasData ? snapshot.data!.balance : 0.0;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: [
                Text(
                  'CURRENT HOLDINGS',
                  style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 3),
                ),
                const SizedBox(height: 12),
                Text(
                  '₵${balance.toStringAsFixed(2)}',
                  style: GoogleFonts.epilogue(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primaryContainer),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildQuickAction(Icons.add_rounded, 'TOP UP'),
                    const SizedBox(width: 40),
                    _buildQuickAction(Icons.history_rounded, 'LOGS'),
                    const SizedBox(width: 40),
                    _buildQuickAction(Icons.lock_outline_rounded, 'FREEZE'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildTransactionheader() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(28, 40, 24, 16),
      sliver: SliverToBoxAdapter(
        child: Text(
          'TRANSACTION ARCHIVE',
          style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 2),
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Placeholder transactions
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_rounded, color: Colors.white24, size: 16),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ORDER SETTLEMENT',
                          style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white70),
                        ),
                        Text(
                          '24 APR • 12:45 PM',
                          style: GoogleFonts.manrope(fontSize: 9, color: Colors.white12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '-₵14.50',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.redAccent.withValues(alpha: 0.6), fontSize: 13),
                  ),
                ],
              ),
            );
          },
          childCount: 5,
        ),
      ),
    );
  }
}
