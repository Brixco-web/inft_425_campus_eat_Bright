import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'chef_3d_logo.dart';
import 'profile_hover_overlay.dart';
import 'kitchen_controls_overlay.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../features/orders/order_bucket_screen.dart';
import '../utils/time_utils.dart';
import 'package:provider/provider.dart';

class UniversalHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showCart;
  final bool showControls;

  const UniversalHeader({
    super.key,
    this.title = 'Campus Eats',
    this.subtitle,
    this.showCart = true,
    this.showControls = true,
  });

  void _showProfileOverlay(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Profile',
      barrierColor: Colors.black.withValues(alpha: 0.1),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        final authVM = context.read<AuthViewModel>();
        return ProfileHoverOverlay(
          userName: authVM.user?.displayName ?? 'Campus User',
          userId: authVM.user?.studentId ?? 'Guest Access',
          onClose: () => Navigator.pop(context),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    );
  }

  void _showControlsOverlay(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Controls',
      barrierColor: Colors.black.withValues(alpha: 0.1),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return KitchenControlsOverlay(
          onClose: () => Navigator.pop(context),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartVM = context.watch<CartViewModel>();
    final authVM = context.watch<AuthViewModel>();
    
    // Compute dynamic subtitle if not explicitly provided
    String greeting = TimeUtils.getFullGreeting();
    if (authVM.user != null) {
      final nameParts = authVM.user!.displayName.split(' ');
      if (nameParts.isNotEmpty) {
        greeting += ', ${nameParts[0]}';
      }
    }
    final String displaySubtitle = subtitle ?? greeting;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          // 1. Profile Avatar (Left)
          GestureDetector(
            onTap: () => _showProfileOverlay(context),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primaryContainer, AppColors.primaryContainer.withValues(alpha: 0.3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF060606), width: 2),
                  color: const Color(0xFF141B1E),
                ),
                child: authVM.user?.photoUrl != null 
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(authVM.user!.photoUrl!, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.person_rounded, color: AppColors.primaryContainer, size: 20),
              ),
            ),
          ),
          
          const SizedBox(width: 14),
          
          // 2. Title Section or Chef Logo
          Expanded(
            child: Row(
              children: [
                const Chef3DLogo(size: 32),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displaySubtitle,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: Colors.white38,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.epilogue(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Cart & Controls (Right)
          if (showCart) ...[
            _headerAction(
              icon: Icons.shopping_basket_rounded,
              color: Colors.white.withValues(alpha: 0.05),
              iconColor: Colors.white70,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderBucketScreen()),
              ),
              badge: cartVM.itemCount > 0,
            ),
            const SizedBox(width: 10),
          ],
          if (showControls) 
            _headerAction(
              icon: Icons.tune_rounded,
              color: Colors.white.withValues(alpha: 0.05),
              iconColor: AppColors.primaryContainer,
              onTap: () => _showControlsOverlay(context),
            ),
        ],
      ),
    );
  }

  Widget _headerAction({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    bool badge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          if (badge)
            Positioned(
              top: 10, right: 10,
              child: Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B35),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
