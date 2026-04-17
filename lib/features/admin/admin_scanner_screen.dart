import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../../services/order_service.dart';
import 'widgets/scanner_overlay.dart';

class AdminScannerScreen extends StatefulWidget {
  const AdminScannerScreen({super.key});

  @override
  State<AdminScannerScreen> createState() => _AdminScannerScreenState();
}

class _AdminScannerScreenState extends State<AdminScannerScreen> {
  final OrderService _orderService = OrderService();
  final MobileScannerController _controller = MobileScannerController();
  
  bool _isProcessing = false;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String? code) async {
    if (code == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'VERIFYING HANDSHAKE...';
    });

    try {
      // Data format: orderId:verificationCode
      final parts = code.split(':');
      if (parts.length != 2) throw Exception('INVALID QR FORMAT');

      final orderId = parts[0];
      final verificationCode = parts[1];

      await _orderService.completeOrderHandshake(orderId, verificationCode);

      setState(() {
        _isSuccess = true;
        _statusMessage = 'ORDER COLLECTED SUCCESSFULLY';
      });

      // Reset after 3 seconds to allow next scan
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _statusMessage = null;
            _isSuccess = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _statusMessage = e.toString().contains('Exception') 
            ? e.toString().split(':').last.trim() 
            : 'VERIFICATION FAILED';
      });

      // Reset after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _statusMessage = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for scanner
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'VERIFICATION SCANNER',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Mobile Scanner
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                _handleScan(barcode.rawValue);
              }
            },
          ),

          // Scanning UI Overlays
          _buildScannerFrame(),

          // Status Information Overlay
          if (_statusMessage != null)
            ScannerOverlay(
              isScanning: _isProcessing,
              status: _statusMessage,
              isSuccess: _isSuccess,
            ),
            
          _buildInstructionOverlay(),
        ],
      ),
    );
  }

  Widget _buildScannerFrame() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryContainer, width: 2),
          borderRadius: BorderRadius.circular(32),
        ),
        child: _isProcessing 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
          : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildInstructionOverlay() {
    return Positioned(
      bottom: 40,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              'READY TO VERIFY',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.primaryContainer, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Align the student pickup QR within the square frame.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
