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
import '../../core/widgets/app_image.dart';
import 'widgets/cinematic_checkout_background.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLectureMode = false;
  TimeOfDay _pickupTime = const TimeOfDay(hour: 12, minute: 0);
  String _paymentMethod = 'Wallet';

  @override
  void initState() {
    super.initState();
    final walletVM = Provider.of<WalletViewModel>(context, listen: false);
    if (!walletVM.isRegistered) {
      _paymentMethod = 'Cash';
    }
  }

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
      backgroundColor: Colors.black,
      body: CinematicCheckoutBackground(
        child: Stack(
          children: [

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildModernAppBar(context),
              
              if (cartVM.items.isEmpty)
                _buildEmptyState()
              else ...[
                _buildSectionHeader('CULINARY MANIFEST'),
                _buildCartList(cartVM, menuVM),
                
                _buildSectionHeader('TEMPORAL STRATEGY'),
                _buildSmartOptions(),
                
                _buildSectionHeader('SETTLEMENT PATHWAY'),
                _buildPaymentOptions(walletVM),
                
                _buildSectionHeader('SUMMARY OF WEAVE'),
                _buildOrderSummary(subtotal, serviceFee, total),
                
                const SliverToBoxAdapter(child: SizedBox(height: 160)),
              ],
            ],
          ),

          if (cartVM.items.isNotEmpty)
            _buildPremiumFooter(context, authVM, cartVM, menuVM, orderVM, walletVM, total),
            
          if (orderVM.isLoading)
            _buildCinematicLoading(),
        ],
      ),
    ));
  }

  /// Wraps [child] in a ClipRRect + BackdropFilter so the food-explosion
  /// image blurs only directly behind this card.
  Widget _glassCard({
    required Widget child,
    double borderRadius = 24,
    double blurSigma = 12,
    Color? tint,
    Border? border,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: tint ?? Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        'REVIEW MANIFEST',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
          color: AppColors.primaryContainer,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 40, 24, 20),
        child: Row(
          children: [
            Container(width: 4, height: 16, decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                color: Colors.white38,
              ),
            ),
          ],
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
            const Icon(Icons.auto_stories_rounded, size: 80, color: Colors.white10),
            const SizedBox(height: 32),
            Text('Your manifest is unwritten.', style: GoogleFonts.manrope(color: Colors.white24, fontSize: 16)),
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
            return _buildPremiumCartItem(context, cartVM, item, quantity);
          },
          childCount: cartVM.items.length,
        ),
      ),
    );
  }

  Widget _buildPremiumCartItem(BuildContext context, CartViewModel cartVM, MenuItem item, int quantity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _glassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AppImage(
                url: item.imageUrl,
                width: 70,
                height: 70,
                borderRadius: 16,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name.toUpperCase(), style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('₵${item.price.toStringAsFixed(2)}', style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              Text('${quantity}x', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.white24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartOptions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            _buildInteractiveOptionCard(
              icon: Icons.history_edu_rounded,
              title: 'LECTURE MODE',
              subtitle: 'Prioritize prep for class intervals',
              isActive: _isLectureMode,
              onToggle: () => setState(() => _isLectureMode = !_isLectureMode),
            ),
            if (_isLectureMode) ...[
              const SizedBox(height: 12),
              _buildCollectionTimeSelector(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveOptionCard({required IconData icon, required String title, required String subtitle, required bool isActive, required VoidCallback onToggle}) {
    return GestureDetector(
      onTap: onToggle,
      child: _glassCard(
        borderRadius: 32,
        tint: isActive ? AppColors.primaryContainer.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.45),
        border: Border.all(color: isActive ? AppColors.primaryContainer.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: isActive ? AppColors.primaryContainer : Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: isActive ? Colors.black : Colors.white38, size: 20),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: GoogleFonts.manrope(fontSize: 10, color: Colors.white24)),
                  ],
                ),
              ),
              Switch(
                value: isActive, 
                onChanged: (_) => onToggle(),
                activeTrackColor: AppColors.primaryContainer.withValues(alpha: 0.2),
                thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.primaryContainer : null),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionTimeSelector() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: _pickupTime);
        if (time != null) setState(() => _pickupTime = time);
      },
      child: _glassCard(
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.15)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CHRONICLE TIME', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 10, color: Colors.white38, letterSpacing: 1.5)),
              Row(
                children: [
                  Text(_pickupTime.format(context), style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(width: 12),
                  const Icon(Icons.edit_calendar_rounded, color: AppColors.primaryContainer, size: 16),
                ],
              ),
            ],
          ),
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
              child: _buildSettlementCard(
                'OBSIDIAN WALLET', 
                Icons.token_rounded, 
                walletVM.isRegistered ? '₵${walletVM.balance.toStringAsFixed(2)}' : 'LOCKED',
                _paymentMethod == 'Wallet',
                onSelect: walletVM.isRegistered 
                  ? () => setState(() => _paymentMethod = 'Wallet') 
                  : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSettlementCard(
                'PHYSICAL COIN', 
                Icons.payments_rounded, 
                'At Source',
                _paymentMethod == 'Cash',
                onSelect: () => setState(() => _paymentMethod = 'Cash'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementCard(String title, IconData icon, String detail, bool isActive, {required VoidCallback? onSelect}) {
    return GestureDetector(
      onTap: onSelect,
      child: _glassCard(
        borderRadius: 28,
        tint: isActive ? AppColors.primaryContainer.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.45),
        border: Border.all(color: isActive ? AppColors.primaryContainer.withValues(alpha: 0.5) : (onSelect == null ? Colors.white10 : Colors.white.withValues(alpha: 0.08))),
        child: Opacity(
          opacity: onSelect == null ? 0.3 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(icon, color: isActive ? AppColors.primaryContainer : Colors.white10, size: 24),
                const SizedBox(height: 16),
                Text(title, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 8, color: isActive ? Colors.white : Colors.white24, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(detail, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w900, color: isActive ? AppColors.primaryContainer : Colors.white10)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal, double fee, double total) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _glassCard(
          borderRadius: 32,
          blurSigma: 16,
          tint: Colors.black.withValues(alpha: 0.55),
          border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.25)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _rowSummary('Subtotal Contribution', '₵${subtotal.toStringAsFixed(2)}'),
                const SizedBox(height: 12),
                _rowSummary('Ancestral Fee', '₵${fee.toStringAsFixed(2)}'),
                const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white10, thickness: 1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL WEAVE', style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Colors.white38)),
                    Text('₵${total.toStringAsFixed(2)}', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.primaryContainer)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rowSummary(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.spaceGrotesk(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.w600)),
        Text(value, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildPremiumFooter(BuildContext context, AuthViewModel authVM, CartViewModel cartVM, MenuViewModel menuVM, OrderViewModel orderVM, WalletViewModel walletVM, double total) {
    return Positioned(bottom: 0, left: 0, right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.85), border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05)))),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1)),
                      Text('₵${total.toStringAsFixed(2)}', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primaryContainer)),
                    ],
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: 1.02),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: SizedBox(
                        height: 60, width: 220,
                        child: ElevatedButton(
                          onPressed: orderVM.isLoading ? null : () => _handlePlaceOrder(context, authVM, cartVM, menuVM, orderVM, walletVM, total),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: Colors.white10,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 8,
                            shadowColor: AppColors.primaryContainer.withValues(alpha: 0.3),
                          ),
                          child: Text('FINALIZE WEAVE', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 14)),
                        ),
                      ),
                    );
                  },
                  onEnd: () {}, // Not used but builder repeats naturally if we logic it, but TweenAnimationBuilder is one shot unless we use a repeated controller.
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder(BuildContext context, AuthViewModel authVM, CartViewModel cartVM, MenuViewModel menuVM, OrderViewModel orderVM, WalletViewModel walletVM, double total) async {
    final user = authVM.user;
    if (user == null) return;
    
    if (_paymentMethod == 'Wallet' && walletVM.balance < total) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.primaryContainer.withValues(alpha: 0.3))),
          title: Text('INSUFFICIENT WALLET BALANCE', style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontWeight: FontWeight.bold, fontSize: 14)),
          content: Text(
            'Your Obsidian Wallet balance (₵${walletVM.balance.toStringAsFixed(2)}) is lower than the total (₵${total.toStringAsFixed(2)}).\n\nYou may proceed, but you must pay the difference in CASH at pickup.',
            style: GoogleFonts.manrope(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('CANCEL', style: GoogleFonts.spaceGrotesk(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer, foregroundColor: Colors.black),
              child: Text('PROCEED WITH CASH', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      );
      
      if (proceed != true) return;
      // If proceeding, automatically switch preference to cash for admin clarity
      setState(() => _paymentMethod = 'Cash');
    }

    final List<OrderItem> orderItems = [];
    cartVM.items.forEach((itemId, quantity) {
      final item = menuVM.items.firstWhere((m) => m.id == itemId);
      orderItems.add(OrderItem(itemId: itemId, name: item.name, quantity: quantity, price: item.price));
    });
    DateTime? pickup;
    if (_isLectureMode) {
      final now = DateTime.now();
      pickup = DateTime(now.year, now.month, now.day, _pickupTime.hour, _pickupTime.minute);
    }
    
    final method = _paymentMethod == 'Cash' ? PaymentMethod.cash : PaymentMethod.wallet;
    
    final success = await orderVM.placeOrder(
      userId: user.uid, 
      studentName: user.displayName, 
      items: orderItems, 
      totalAmount: total, 
      pickupTime: pickup, 
      isLectureMode: _isLectureMode,
      paymentMethod: method,
    );
    
    if (success && context.mounted) {
      cartVM.clearCart();
      _showSuccessDialog(context);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.primaryContainer, size: 80),
                const SizedBox(height: 32),
                Text('WEAVE SECURED', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4)),
                const SizedBox(height: 16),
                Text('Your culinary chronicle has been added to our legacy.', textAlign: TextAlign.center, style: GoogleFonts.manrope(color: Colors.white70)),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity, height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: Text('VIEW CHRONICLES', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCinematicLoading() {
    return Container(color: Colors.black.withValues(alpha: 0.9), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const CircularProgressIndicator(color: AppColors.primaryContainer, strokeWidth: 2),
      const SizedBox(height: 32),
      Text('WEAVING THE CHRONICLE...', style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, letterSpacing: 4, fontWeight: FontWeight.w900, fontSize: 10)),
    ])));
  }
}

