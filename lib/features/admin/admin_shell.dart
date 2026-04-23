import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'priority_dashboard_screen.dart';
import 'menu_command_screen.dart';
import 'financial_command_screen.dart';
import 'magic_scanner_screen.dart';
import 'user_management_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

    final List<Widget> _adminScreens = [
    const PriorityDashboardScreen(),
    const MenuCommandScreen(),
    const UserManagementScreen(),
    const FinancialCommandScreen(),
    const MagicScannerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Cinematic Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/cuisine_hero.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Ambient Faint Brightness (Bloom)
          Positioned(
            top: -100,
            left: -50,
            right: -50,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.05),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: _adminScreens[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: _buildAdminBottomNav(),
    );
  }

  Widget _buildAdminBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF161D20).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _adminNavItem(0, Icons.security_rounded, 'Tower'),
            _adminNavItem(1, Icons.restaurant_menu_rounded, 'Menu'),
            _adminNavItem(2, Icons.hub_rounded, 'Nexus'),
            _adminNavItem(3, Icons.account_balance_wallet_rounded, 'Vault'),
            _adminNavItem(4, Icons.qr_code_scanner_rounded, 'Scan'),
          ],
        ),
      ),
    );
  }

  Widget _adminNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.primaryContainer : Colors.white38,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryContainer : Colors.white24,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
