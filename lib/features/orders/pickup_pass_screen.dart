import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';

class PickUpPassScreen extends StatelessWidget {
  final OrderModel order;

  const PickUpPassScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'PICK-UP PASS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryContainer,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Glow
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 40),
              
              // Animated Status Badge
              _buildStatusBadge(),
              
              const SizedBox(height: 32),

              // Glass QR Container
              _buildQrContainer(),

              const SizedBox(height: 32),

              // Order Details
              _buildOrderInfo(),

              const Spacer(),

              // Instructions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Text(
                  'Show this QR code at the collection point once your order is marked "Ready".',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.onSurfaceVariant.withOpacity(0.6),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = _getStatusColor(order.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            order.status.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrContainer() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.4),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Corner accents
          ..._buildCorners(),

          QrImageView(
            data: order.id,
            version: QrVersions.auto,
            size: 200.0,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.white,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const double size = 20;
    const double offset = -10;
    return [
      Positioned(top: offset, left: offset, child: _corner(0)),
      Positioned(top: offset, right: offset, child: _corner(1)),
      Positioned(bottom: offset, left: offset, child: _corner(2)),
      Positioned(bottom: offset, right: offset, child: _corner(3)),
    ];
  }

  Widget _corner(int index) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: (index == 0 || index == 1) ? const BorderSide(color: AppColors.primaryContainer, width: 3) : BorderSide.none,
          bottom: (index == 2 || index == 3) ? const BorderSide(color: AppColors.primaryContainer, width: 3) : BorderSide.none,
          left: (index == 0 || index == 2) ? const BorderSide(color: AppColors.primaryContainer, width: 3) : BorderSide.none,
          right: (index == 1 || index == 3) ? const BorderSide(color: AppColors.primaryContainer, width: 3) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            'Order #${order.id.substring(0, 8).toUpperCase()}',
            style: GoogleFonts.epilogue(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${order.items.length} Items · GHS ${order.totalAmount.toStringAsFixed(2)}',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ready':
        return const Color(0xFF4ADE80);
      case 'processing':
        return AppColors.primaryContainer;
      case 'pending':
        return const Color(0xFFFACC15);
      default:
        return AppColors.onSurfaceVariant;
    }
  }
}
