import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../viewmodels/wallet_viewmodel.dart';
import '../../models/menu_item_model.dart';
import '../../models/order_model.dart';
import '../orders/my_bookings_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLectureMode = false;
  TimeOfDay _pickupTime = TimeOfDay.now();
  String _paymentMethod = 'Wallet'; // Default

  @override
  Widget build(BuildContext context) {
    final cartVM = context.watch<CartViewModel>();
    final menuVM = context.watch<MenuViewModel>();
    final orderVM = context.watch<OrderViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final walletVM = context.watch<WalletViewModel>();
    
    final subtotal = cartVM.calculateTotal(menuVM.items);
    const serviceFee = 2.00;
    final total = subtotal + serviceFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Aesthetic
          _buildBackgroundGradient(),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              
              if (cartVM.items.isEmpty)
                _buildEmptyState()
              else ...[
                _buildSectionHeader('YOUR BASKET'),
                _buildCartList(cartVM, menuVM),
                
                _buildSectionHeader('PICK-UP STRATEGY'),
                _buildSmartOptions(),
                
                _buildSectionHeader('PAYMENT METHOD'),
                _buildPaymentOptions(walletVM),
                
                _buildSectionHeader('ORDER SUMMARY'),
                _buildOrderSummary(subtotal, serviceFee, total),
                
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ],
          ),

          if (cartVM.items.isNotEmpty)
            _buildActionFooter(context, authVM, cartVM, menuVM, orderVM, walletVM, total),
            
          if (orderVM.isLoading)
            _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.8, -0.6),
            radius: 1.2,
            colors: [
              AppColors.primaryContainer.withOpacity(0.08),
              AppColors.background,
            ],
          ),
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
        icon: const Icon(Icons.close_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'SMART CHECKOUT',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
          color: AppColors.primaryContainer,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: Colors.white38,
          ),
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
            Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.white.withOpacity(0.05)),
            const SizedBox(height: 24),
            Text(
              'Your basket is as light as air.',
              style: GoogleFonts.manrope(color: Colors.white24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartList(CartViewModel cartVM, MenuViewModel menuVM) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item.imageUrl,
              width: 70,
              height: 70,
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
                  style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  'GHS ${item.price.toStringAsFixed(2)}',
                  style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildQtyBtn(Icons.remove, () => cartVM.removeItem(item.id)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('$quantity', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
              ),
              _buildQtyBtn(Icons.add, () => cartVM.addItem(item.id)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }

  Widget _buildSmartOptions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            _buildFeatureCard(
              icon: Icons.school_rounded,
              title: 'Lecture Mode',
              subtitle: 'Optimized for back-to-back classes',
              trailing: Switch(
                value: _isLectureMode,
                onChanged: (v) => setState(() => _isLectureMode = v),
                activeColor: AppColors.primaryContainer,
              ),
            ),
            if (_isLectureMode) ...[
              const SizedBox(height: 12),
              _buildTimeSelector(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String subtitle, required Widget trailing}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryContainer, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
                Text(subtitle, style: GoogleFonts.manrope(fontSize: 11, color: Colors.white38)),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryContainer.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Collection Time', style: GoogleFonts.manrope(fontSize: 13)),
            Text(
              _pickupTime.format(context),
              style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptions(WalletViewModel walletVM) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: _buildPaymentTile(
                'Wallet', 
                Icons.account_balance_wallet_rounded, 
                'GHS ${walletVM.balance.toStringAsFixed(2)}',
                _paymentMethod == 'Wallet',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPaymentTile(
                'Cash', 
                Icons.payments_rounded, 
                'At Pickup',
                _paymentMethod == 'Cash',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile(String id, IconData icon, String subtitle, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _paymentMethod = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer.withOpacity(0.1) : AppColors.surfaceContainerHigh.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppColors.primaryContainer : AppColors.outlineVariant.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryContainer : Colors.white24),
            const SizedBox(height: 8),
            Text(id, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(subtitle, style: GoogleFonts.manrope(fontSize: 10, color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal, double fee, double total) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh.withOpacity(0.2),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            _summaryRow('Subtotal', 'GHS ${subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _summaryRow('Service Fee', 'GHS ${fee.toStringAsFixed(2)}'),
            const Divider(color: Colors.white10, height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Payable', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  'GHS ${total.toStringAsFixed(2)}', 
                  style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primaryContainer)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.manrope(color: Colors.white38, fontSize: 13)),
        Text(value, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildActionFooter(
    BuildContext context, 
    AuthViewModel authVM, 
    CartViewModel cartVM, 
    MenuViewModel menuVM, 
    OrderViewModel orderVM,
    WalletViewModel walletVM,
    double total,
  ) {
    final canPay = _paymentMethod == 'Cash' || walletVM.balance >= total;

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
              AppColors.background.withOpacity(0),
              AppColors.background.withOpacity(0.95),
              AppColors.background,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!canPay)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Insufficient funds in Obsidian Wallet',
                  style: GoogleFonts.manrope(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: (orderVM.isLoading || !canPay) ? null : () => _handlePlaceOrder(context, authVM, cartVM, menuVM, orderVM, walletVM, total),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                ),
                child: Text(
                  'CONFIRM ORDER',
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, letterSpacing: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder(
    BuildContext context,
    AuthViewModel authVM,
    CartViewModel cartVM,
    MenuViewModel menuVM,
    OrderViewModel orderVM,
    WalletViewModel walletVM,
    double total,
  ) async {
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
      studentName: user.displayName,
      items: orderItems,
      totalAmount: total,
      pickupTime: pickup,
      isLectureMode: _isLectureMode,
    );

    if (success && context.mounted) {
      // Deduct from wallet if applicable
      if (_paymentMethod == 'Wallet') {
        walletVM.processTransaction(
          title: 'Order Payment',
          amount: total,
          type: TransactionType.debit,
        );
      }
      
      cartVM.clearCart();
      
      // show success then navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loom Order Secured! Track it in your bookings.'),
          backgroundColor: AppColors.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderVM.errorMessage ?? 'Transaction failed in the loom.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryContainer),
            const SizedBox(height: 24),
            Text(
              'WEAVING YOUR ORDER...',
              style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, letterSpacing: 4, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
