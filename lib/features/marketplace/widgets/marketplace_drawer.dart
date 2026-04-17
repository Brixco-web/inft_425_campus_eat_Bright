import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/wallet_viewmodel.dart';
import '../../../models/user_model.dart';
import '../../wallet/wallet_screen.dart';
import '../../orders/my_bookings_screen.dart';
import '../../admin/admin_dashboard.dart';

class MarketplaceDrawer extends StatelessWidget {
  const MarketplaceDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final walletVM = context.watch<WalletViewModel>();
    final user = authVM.user;

    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          // 1. Drawer Header (Pro Profile)
          _buildHeader(context, user),

          // 2. Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'OBSIDIAN WALLET',
                  subtitle: 'GHS ${walletVM.balance.toStringAsFixed(2)}',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
                ),
                const SizedBox(height: 16),
                _buildNavItem(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'MY ORDER BOOK',
                  subtitle: 'Pickup QRs & History',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen())),
                ),

                // 2.a CONDITIONAL ADMIN ENTRY (Restricted)
                if (user?.role == UserRole.admin) ...[
                  const Divider(color: Colors.white10, height: 48),
                  _buildNavItem(
                    context,
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'ADMIN CONSOLE',
                    subtitle: 'Management Dashboard',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard())),
                  ),
                ],

                const Divider(color: Colors.white10, height: 64),
                _buildNavItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'SIGN OUT',
                  subtitle: 'Exit the Loom',
                  destructive: true,
                  onTap: () => authVM.logout(),
                ),
              ],
            ),
          ),

          // 3. App Version / Footer
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'CAMPUS EATS v1.0.0',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white10,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, 32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppColors.primaryContainer, Colors.orangeAccent]),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.surface,
              child: Text(
                (user?.displayName ?? 'S')[0].toUpperCase(),
                style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            user?.displayName?.toUpperCase() ?? 'VALLEY VIEW STUDENT',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            user?.email ?? 'student@vvu.edu.gh',
            style: GoogleFonts.manrope(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final color = destructive ? Colors.redAccent : AppColors.primaryContainer;
    
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close drawer first
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white10, size: 20),
          ],
        ),
      ),
    );
  }
}
