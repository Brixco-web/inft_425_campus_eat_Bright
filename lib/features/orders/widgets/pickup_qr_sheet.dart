import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/order_model.dart';

class PickupQRSheet extends StatelessWidget {
  final OrderModel order;

  const PickupQRSheet({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Handshake Payload: orderId:verificationCode
    final String qrData = '${order.id}:${order.verificationCode}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  'READY FOR PICKUP',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'SHOW THIS TO THE CAFETERIA ADMIN',
                  style: GoogleFonts.manrope(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // QR Code Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryContainer.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                    gapless: false,
                    foregroundColor: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Order Info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long, color: AppColors.primaryContainer),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORDER ID: ${order.id.substring(0, 8).toUpperCase()}',
                            style: GoogleFonts.spaceGrotesk(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${order.items.length} Items • GHS ${order.totalAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.manrope(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
