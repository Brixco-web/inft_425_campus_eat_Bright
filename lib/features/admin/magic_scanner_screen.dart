import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../core/widgets/chef_admin_emblem.dart';

class MagicScannerScreen extends StatefulWidget {
  const MagicScannerScreen({super.key});

  @override
  State<MagicScannerScreen> createState() => _MagicScannerScreenState();
}

class _MagicScannerScreenState extends State<MagicScannerScreen> with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  bool _isProcessing = false;
  late AnimationController _scannerAnimationController;

  @override
  void initState() {
    super.initState();
    _scannerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _scannerAnimationController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isProcessing = true);
        
        final orderId = barcode.rawValue!;
        try {
          final orderStream = await _orderService.getAllOrdersStream().first;
          final order = orderStream.firstWhere((o) => o.id == orderId || o.verificationCode == orderId);
          if (mounted) _showPaymentConfirmationDialog(order);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Signal Error: Signal Not Found', style: GoogleFonts.manrope(color: Colors.white)),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ));
            setState(() => _isProcessing = false);
          }
        }
        break;
      }
    }
  }

  void _showPaymentConfirmationDialog(OrderModel order) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AlertDialog(
            backgroundColor: const Color(0xFF0F0F0F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(36),
              side: BorderSide(color: AppColors.primaryContainer.withValues(alpha: 0.15)),
            ),
            contentPadding: const EdgeInsets.all(32),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    'SIGNAL CAPTURED',
                    style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  order.studentName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.epilogue(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'VALUED AT ₵${order.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.spaceGrotesk(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 32),
                Text(
                  'SETTLEMENT PROTOCOL',
                  style: GoogleFonts.spaceGrotesk(color: Colors.white24, fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _finalizeHandshake(order, PaymentMethod.wallet),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primaryContainer, size: 24),
                              const SizedBox(height: 8),
                              Text('WALLET', style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontWeight: FontWeight.w900, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _finalizeHandshake(order, PaymentMethod.cash),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.payments_rounded, color: Colors.white70, size: 24),
                              const SizedBox(height: 8),
                              Text('CASH', style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _isProcessing = false);
                  },
                  child: Text('ABORT HANDSHAKE', style: GoogleFonts.spaceGrotesk(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _finalizeHandshake(OrderModel order, PaymentMethod method) async {
    Navigator.pop(context); // Close dialog
    try {
      await _orderService.completeOrderHandshake(order.id, order.verificationCode, method);
      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: GoogleFonts.manrope(color: Colors.white))));
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AlertDialog(
            backgroundColor: const Color(0xFF0F0F0F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(36),
              side: BorderSide(color: AppColors.primaryContainer.withValues(alpha: 0.15)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded, color: AppColors.primaryContainer, size: 56),
                ),
                const SizedBox(height: 24),
                Text(
                  'AUTH VALIDATED',
                  style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _isProcessing = false);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'RESUME FEED',
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060606),
      body: Stack(
        children: [
          // ── Atmospheric Glow ──
          Positioned(
            top: -100, right: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.primaryContainer.withValues(alpha: 0.04), Colors.transparent],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildPremiumHeader(),
                  const SizedBox(height: 32),
                  _buildScannerConfinement(),
                  const SizedBox(height: 32),
                  _buildActionsGrid(),
                  const SizedBox(height: 32),
                  _buildValidationStatus(),
                  const SizedBox(height: 32),
                  _buildSessionMetrics(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE FEED',
                    style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.redAccent, letterSpacing: 2),
                  ),
                ],
              ),
              Text(
                'Verification Portal',
                style: GoogleFonts.epilogue(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
              ),
            ],
          ),
        ),
        const ChefAdminEmblem(size: 40),
      ],
    );
  }

  Widget _buildScannerConfinement() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 40, offset: const Offset(0, 20)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          children: [
            MobileScanner(
              controller: MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates, facing: CameraFacing.back),
              onDetect: _onDetect,
            ),
            // Sci-fi Viewfinder
            CustomPaint(
              painter: ScannerOverlayPainter(),
              child: Container(),
            ),
            _animatedScanLine(),
            if (_isProcessing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.8),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primaryContainer, strokeWidth: 2),
                      const SizedBox(height: 20),
                      Text('ANALYZING SIGNAL...', style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 10)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionBtn(Icons.flash_on_rounded, 'FLASH', false),
        _buildActionBtn(Icons.history_rounded, 'LOGS', false),
        _buildActionBtn(Icons.keyboard_alt_rounded, 'MANUAL', false),
        _buildActionBtn(Icons.report_problem_rounded, 'ALERT', true),
      ],
    );
  }

  Widget _buildActionBtn(IconData icon, String label, bool isWarning) {
    return Column(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: isWarning ? Colors.redAccent.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isWarning ? Colors.redAccent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.06)),
          ),
          child: Icon(icon, color: isWarning ? Colors.redAccent : Colors.white70, size: 24),
        ),
        const SizedBox(height: 10),
        Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildValidationStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sensors_rounded, color: AppColors.primaryContainer, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WAITING FOR SIGNAL', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primaryContainer, letterSpacing: 2)),
                const SizedBox(height: 4),
                Text('Scan Student QR to authenticate handshake', style: GoogleFonts.manrope(fontSize: 12, color: Colors.white24, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("DASHBOARD STATS", style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 2)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetricTile('SCANNED', '148', AppColors.primaryContainer)),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricTile('ISSUES', '02', Colors.redAccent)),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 8, color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.epilogue(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -1)),
        ],
      ),
    );
  }

  Widget _animatedScanLine() {
    return AnimatedBuilder(
      animation: _scannerAnimationController,
      builder: (context, child) {
        return Positioned(
          top: 60 + (200 * _scannerAnimationController.value),
          left: 40,
          right: 40,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.6), blurRadius: 15, spreadRadius: 1)],
              color: AppColors.primaryContainer,
            ),
          ),
        );
      },
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryContainer.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const cornerLength = 30.0;
    const padding = 60.0;
    final r = Rect.fromLTWH(padding, padding, size.width - 2 * padding, size.height - 2 * padding);
    
    // Top Left
    canvas.drawLine(Offset(r.left, r.top), Offset(r.left + cornerLength, r.top), paint);
    canvas.drawLine(Offset(r.left, r.top), Offset(r.left, r.top + cornerLength), paint);
    
    // Top Right
    canvas.drawLine(Offset(r.right, r.top), Offset(r.right - cornerLength, r.top), paint);
    canvas.drawLine(Offset(r.right, r.top), Offset(r.right, r.top + cornerLength), paint);
    
    // Bottom Left
    canvas.drawLine(Offset(r.left, r.bottom), Offset(r.left + cornerLength, r.bottom), paint);
    canvas.drawLine(Offset(r.left, r.bottom), Offset(r.left, r.bottom - cornerLength), paint);
    
    // Bottom Right
    canvas.drawLine(Offset(r.right, r.bottom), Offset(r.right - cornerLength, r.bottom), paint);
    canvas.drawLine(Offset(r.right, r.bottom), Offset(r.right, r.bottom - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
