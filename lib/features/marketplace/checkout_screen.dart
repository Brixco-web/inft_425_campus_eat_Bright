import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../orders/my_bookings_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLectureMode = false;
  TimeOfDay _pickupTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    final cartVM = context.watch<CartViewModel>();
    final menuVM = context.watch<MenuViewModel>();
    final orderVM = context.watch<OrderViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final total = cartVM.calculateTotal(menuVM.items);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Decor
          _buildBackgroundDecor(),

          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              
              if (cartVM.items.isEmpty)
                _buildEmptyState()
              else ...[
                _buildCartList(cartVM, menuVM),
                _buildSmartFeatures(),
                _buildOrderSummary(total),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ],
          ),

          if (cartVM.items.isNotEmpty)
            _buildStickyFooter(context, authVM, cartVM, menuVM, orderVM, total),
            
          if (orderVM.isLoading)
            _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryContainer),
      ),
    );
  }

  Widget _buildBackgroundDecor() {
    return Positioned(
      top: -100,
      right: -50,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryContainer.withValues(alpha: 0.05),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'CHECKOUT BASKET',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              'Your basket is empty.',
              style: GoogleFonts.spaceGrotesk(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartList(CartViewModel cartVM, MenuViewModel menuVM) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final itemId = cartVM.items.keys.elementAt(index);
            final quantity = cartVM.items[itemId]!;
            final item = menuVM.items.firstWhere((m) => m.id == itemId);

            return _buildCartItem(context, cartVM, item, quantity);
          },
          childCount: cartVM.items.length,
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartViewModel cartVM, MenuItem item, int quantity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.white10, child: const Icon(Icons.fastfood)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '₵ ${item.price.toStringAsFixed(2)}',
                  style: GoogleFonts.manrope(color: AppColors.primaryContainer, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildQtyAction(Icons.add, () => cartVM.addItem(item.id)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(quantity.toString(), style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
              ),
              _buildQtyAction(Icons.remove, () => cartVM.removeItem(item.id)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildSmartFeatures() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: Colors.white10, height: 40),
            Text(
              'SMART FEATURES',
              style: GoogleFonts.spaceGrotesk(letterSpacing: 2, fontSize: 12, color: AppColors.primaryContainer),
            ),
            const SizedBox(height: 16),
            _buildFeatureTile(
              title: 'Lecture Mode',
              subtitle: 'Schedule pickup around your class',
              icon: Icons.school_outlined,
              trailing: Switch(
                value: _isLectureMode,
                onChanged: (val) => setState(() => _isLectureMode = val),
                activeColor: AppColors.primaryContainer,
              ),
            ),
            if (_isLectureMode) ...[
              const SizedBox(height: 8),
              _buildTimeSelector(),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({required String title, required String subtitle, required IconData icon, required Widget trailing}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                Text(subtitle, style: GoogleFonts.manrope(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: _pickupTime);
        if (time != null) setState(() => _pickupTime = time);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pickup at:', style: GoogleFonts.manrope()),
            Text(
              _pickupTime.format(context),
              style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double total) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _summaryRow('Subtotal', '₵ ${total.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _summaryRow('Loom Service Fee', '₵ 2.00'),
            const Divider(color: Colors.white10, height: 32),
            _summaryRow('Grand Total', '₵ ${(total + 2.00).toStringAsFixed(2)}', isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    final style = isBold
        ? GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 18)
        : GoogleFonts.manrope(color: AppColors.onSurfaceVariant);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }

  Widget _buildStickyFooter(
    BuildContext context,
    AuthViewModel authVM,
    CartViewModel cartVM,
    MenuViewModel menuVM,
    OrderViewModel orderVM,
    double total,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColors.background.withValues(alpha: 0.95),
              AppColors.background,
            ],
          ),
        ),
        child: ElevatedButton(
          onPressed: () async {
            final user = authVM.user;
            if (user == null) return;

            final List<OrderItem> orderItems = [];
            cartVM.items.forEach((itemId, quantity) {
              final item = menuVM.items.firstWhere((m) => m.id == itemId);
              orderItems.add(OrderItem(
                itemId: itemId,
                name: item.name,
                quantity: quantity,
                price: item.price,
              ));
            });

            DateTime? pickup;
            if (_isLectureMode) {
              final now = DateTime.now();
              pickup = DateTime(now.year, now.month, now.day, _pickupTime.hour, _pickupTime.minute);
            }

            final success = await orderVM.placeOrder(
              userId: user.uid,
              studentName: user.displayName ?? 'Student',
              items: orderItems,
              totalAmount: total + 2.00,
              pickupTime: pickup,
              isLectureMode: _isLectureMode,
            );

            if (success && context.mounted) {
              cartVM.clearCart();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
              );
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(orderVM.errorMessage ?? 'Order placement failed.'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(
            'PAY WITH OBSIDIAN WALLET',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
      ),
    );
  }
}
