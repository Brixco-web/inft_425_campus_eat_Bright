import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../../services/order_service.dart';

class MagicScannerScreen extends StatefulWidget {
  const MagicScannerScreen({super.key});

  @override
  State<MagicScannerScreen> createState() => _MagicScannerScreenState();
}

class _MagicScannerScreenState extends State<MagicScannerScreen> {
  final OrderService _orderService = OrderService();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isProcessing = true);
        
        final orderId = barcode.rawValue!;
        try {
          // In a real app, you'd verify if the QR is a valid Obsidian Order ID
          await _orderService.collectOrder(orderId);
          
          if (mounted) {
            _showSuccessDialog();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to process signal: $e'))
            );
            setState(() => _isProcessing = false);
          }
        }
        break;
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 64),
              const SizedBox(height: 24),
              Text(
                'ORDER COLLECTED',
                style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              Text(
                'The student has successfully retrieved their items.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close scanner
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('CONTINUE COMMAND', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The Scanner
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
              facing: CameraFacing.back,
            ),
            onDetect: _onDetect,
          ),

          // Custom Overlay
          _buildOverlay(),

          // Close Button
          Positioned(
            top: 60,
            left: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.white.withOpacity(0.1),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        // Darkened areas
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scanning Frame
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryContainer.withOpacity(0.5), width: 2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Stack(
              children: [
                 // Scanning line animation would go here
              ],
            ),
          ),
        ),
        
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                'MAGIC SCANNER',
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Place student QR within the frame',
                style: GoogleFonts.manrope(color: Colors.white30),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
