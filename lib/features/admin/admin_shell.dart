import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'priority_dashboard_screen.dart';
import 'menu_command_screen.dart';
import 'financial_command_screen.dart';
import 'magic_scanner_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PriorityDashboardScreen(), // Control Tower
    const MenuCommandScreen(),      // Menu Architect
    const FinancialCommandScreen(), // Financial Command
    const Center(child: Text('Admin Control', style: TextStyle(color: Colors.white))),
  ];

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MagicScannerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildScannerFAB(),
      bottomNavigationBar: _buildAdminBottomNav(),
    );
  }

  Widget _buildScannerFAB() {
    return Container(
      height: 72,
      width: 72,
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, Color(0xFFC084FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openScanner,
          customBorder: const CircleBorder(),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.black,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildAdminBottomNav() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      notchMargin: 12,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, 'Tower'),
                _buildNavItem(1, Icons.restaurant_menu_rounded, 'Menu'),
                const SizedBox(width: 80), // Space for FAB
                _buildNavItem(2, Icons.analytics_rounded, 'Finance'),
                _buildNavItem(3, Icons.settings_rounded, 'Admin'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryContainer : Colors.white38,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.primaryContainer : Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
