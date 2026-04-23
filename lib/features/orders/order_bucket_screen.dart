import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/culinary_texture.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../models/menu_item_model.dart';
import '../../features/marketplace/checkout_screen.dart';

class OrderBucketScreen extends StatelessWidget {
  const OrderBucketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CulinaryTexture(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildItemList(context),
              ),
              _buildCheckoutSummary(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ORDER BUCKET',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Review Selection',
                style: GoogleFonts.epilogue(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(BuildContext context) {
    final cartVM = context.watch<CartViewModel>();
    final menuVM = context.watch<MenuViewModel>();
    
    // Resolve IDs to MenuItem objects
    final cartEntries = cartVM.items.entries.toList();

    if (cartEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 20),
            Text(
              'Your bucket is empty',
              style: GoogleFonts.manrope(color: Colors.white38, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: cartEntries.length,
      itemBuilder: (context, index) {
        final entry = cartEntries[index];
        final itemId = entry.key;
        final quantity = entry.value;
        
        final item = menuVM.allItems.firstWhere(
          (m) => m.id == itemId,
          orElse: () => MenuItem(
            id: itemId, name: 'Unknown Dish', description: '', price: 0, imageUrl: '', 
            category: MenuCategory.campusGems
          ),
        );

        return Dismissible(
          key: Key(itemId),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => cartVM.deleteItem(itemId),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    item.imageUrl,
                    width: 70, height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70, height: 70,
                      color: Colors.white.withValues(alpha: 0.05),
                      child: const Icon(Icons.restaurant_rounded, color: Colors.white10),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.epilogue(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₵${item.price.toStringAsFixed(2)}',
                        style: GoogleFonts.spaceGrotesk(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _quantityBtn(Icons.remove, () => cartVM.decrementQuantity(itemId)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '$quantity',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _quantityBtn(Icons.add, () => cartVM.incrementQuantity(itemId)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _quantityBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white70, size: 14),
      ),
    );
  }

  Widget _buildCheckoutSummary(BuildContext context) {
    final cartVM = context.watch<CartViewModel>();
    final menuVM = context.watch<MenuViewModel>();
    
    if (cartVM.itemCount == 0) return const SizedBox.shrink();

    final subtotal = cartVM.calculateTotal(menuVM.allItems);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1416).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', '₵${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _summaryRow('Service Fee', '₵2.50'),
          const Divider(height: 32, color: Colors.white10),
          _summaryRow('Total Price', '₵${(subtotal + 2.50).toStringAsFixed(2)}', isTotal: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Text(
                'PROCEED TO CHECKOUT',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: isTotal ? Colors.white : Colors.white38,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            fontSize: isTotal ? 16 : 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            color: isTotal ? AppColors.primaryContainer : Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: isTotal ? 20 : 14,
          ),
        ),
      ],
    );
  }
}
