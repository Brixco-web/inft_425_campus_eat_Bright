import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/wallet_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletVM = context.watch<WalletViewModel>();
    final user = context.watch<AuthViewModel>().user;

    return Scaffold(
      backgroundColor: Colors.transparent, // Inherit from Shell Texture
      body: Stack(
        children: [
          // ── Main Content ──
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Header (Redundant since Shell handles it, but kept subtle)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 60, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FINANCIAL VAULT',
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        user?.displayName ?? 'Valued Student',
                        style: GoogleFonts.epilogue(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. The Premium Card (Minimalist "Stealth wealth" style)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: _buildStealthCard(walletVM),
                ),
              ),

              // 3. Quick Actions (Refined)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRefinedAction(Icons.add_rounded, 'Top Up'),
                      _buildRefinedAction(Icons.history_rounded, 'History'),
                      _buildRefinedAction(Icons.security_rounded, 'Vault'),
                      _buildRefinedAction(Icons.headset_mic_rounded, 'Support'),
                    ],
                  ),
                ),
              ),

              // 4. Activity Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LEDGER ACTIVITY',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white38,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildRefinedActivity(),
                    ],
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          // ── Registration Gate Overlay (Blur + Notice) ──
          if (!walletVM.isRegistered && !walletVM.isLoading)
            _buildRegistrationGate(context),
        ],
      ),
    );
  }

  Widget _buildStealthCard(WalletViewModel vm) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: const Color(0xFF161D20), // Solid obsidian
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle corner accent
          Positioned(
            top: 24,
            right: 24,
            child: Icon(Icons.nfc_rounded, color: AppColors.primaryContainer.withValues(alpha: 0.2), size: 24),
          ),
          
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OBSIDIAN BALANCE',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'GH₵',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.primaryContainer,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          vm.balance.toStringAsFixed(2),
                          style: GoogleFonts.epilogue(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'LOOM ID: **** **** **** 4251',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white24,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefinedAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
        const SizedBox(height: 10),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRefinedActivity() {
    return Container(
      padding: const EdgeInsets.all(40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        children: [
          Icon(Icons.blur_on_rounded, color: Colors.white.withValues(alpha: 0.05), size: 48),
          const SizedBox(height: 20),
          Text(
            'The ledger is empty. Start your culinary journey.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: Colors.white24,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationGate(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: Colors.black.withValues(alpha: 0.8),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_person_rounded, color: AppColors.primaryContainer, size: 80),
                  const SizedBox(height: 32),
                  Text(
                    'PERSONAL VAULT LOCKED',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Obsidian Wallet is not yet provisioned. Digital payments are disabled until you visit the Cafeteria Admin for registration.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'CASH PAYMENTS ARE STILL AVAILABLE\nIN THE MARKETPLACE',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryContainer.withValues(alpha: 0.6),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
