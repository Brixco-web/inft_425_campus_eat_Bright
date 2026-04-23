import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';

class PickupPassScreen extends StatelessWidget {
  final OrderModel order;

  const PickupPassScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final String qrData = order.id;
    final isReady = order.status == OrderStatus.ready;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Layer 1: Afro-Modernist Base ──
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isReady ? const Color(0xFF10B981).withValues(alpha: 0.1) : AppColors.primaryContainer.withValues(alpha: 0.05),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildStatusHeader(isReady),
                        const SizedBox(height: 48),
                        _buildQRSection(qrData, isReady),
                        const SizedBox(height: 60),
                        _buildManifestDetails(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                _buildChronicleAction(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'PICK-UP PASS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(width: 48), // Balance
        ],
      ),
    );
  }

  Widget _buildStatusHeader(bool isReady) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: (isReady ? const Color(0xFF10B981) : AppColors.primaryContainer).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: (isReady ? const Color(0xFF10B981) : AppColors.primaryContainer).withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: isReady ? const Color(0xFF10B981) : AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isReady ? 'MANIFEST SEALED' : 'IN PREPARATION',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: isReady ? const Color(0xFF10B981) : AppColors.primaryContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isReady ? 'Ready for Collection' : 'Weaving your Flavor',
          style: GoogleFonts.epilogue(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildQRSection(String data, bool isReady) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: (isReady ? const Color(0xFF10B981) : AppColors.primaryContainer).withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 220.0,
              gapless: false,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '#${order.id.substring(0, 8).toUpperCase()}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white38,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManifestDetails() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MANIFEST CONTENT',
            style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 2),
          ),
          const SizedBox(height: 24),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.quantity}x ${item.name.toUpperCase()}',
                  style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white70),
                ),
                Text(
                  '₵${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white24),
                ),
              ],
            ),
          )),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Colors.white10, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 1),
              ),
              Text(
                '₵${order.totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryContainer),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChronicleAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Text(
            'CLOSE PASS',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ),
      ),
    );
  }
}
