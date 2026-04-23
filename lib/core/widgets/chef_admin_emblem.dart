import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// A premium Chef Hat + Letter "A" emblem used throughout the Admin section.
/// Renders entirely in code — no image asset needed.
class ChefAdminEmblem extends StatelessWidget {
  final double size;
  const ChefAdminEmblem({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Glow halo behind the emblem ──
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                    blurRadius: size * 0.6,
                    spreadRadius: size * 0.05,
                  ),
                ],
              ),
            ),
          ),

          // ── Background circle ──
          Positioned(
            bottom: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF0D0D0D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppColors.primaryContainer.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  'A',
                  style: GoogleFonts.epilogue(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryContainer,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
          ),

          // ── Chef hat on top ──
          Positioned(
            top: 0,
            child: CustomPaint(
              size: Size(size * 0.55, size * 0.4),
              painter: _ChefHatPainter(
                hatColor: Colors.white,
                shadowColor: Colors.black26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChefHatPainter extends CustomPainter {
  final Color hatColor;
  final Color shadowColor;

  _ChefHatPainter({required this.hatColor, required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = hatColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final w = size.width;
    final h = size.height;

    // ── Shadow layer ──
    final shadowPath = Path();
    // Hat band (bottom rectangle)
    shadowPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.1, h * 0.7, w * 0.8, h * 0.25),
      const Radius.circular(4),
    ));
    // Hat puff (top part — three overlapping circles)
    shadowPath.addOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.45), width: w * 0.55, height: h * 0.5));
    shadowPath.addOval(Rect.fromCenter(center: Offset(w * 0.28, h * 0.5), width: w * 0.4, height: h * 0.45));
    shadowPath.addOval(Rect.fromCenter(center: Offset(w * 0.72, h * 0.5), width: w * 0.4, height: h * 0.45));
    canvas.drawPath(shadowPath, shadowPaint);

    // ── Hat band (the fold at the bottom) ──
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, h * 0.7, w * 0.8, h * 0.25),
        const Radius.circular(4),
      ),
      paint,
    );

    // ── Hat puff (the puffy top — 3 overlapping ovals) ──
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.28, h * 0.5), width: w * 0.4, height: h * 0.45), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.72, h * 0.5), width: w * 0.4, height: h * 0.45), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.38), width: w * 0.55, height: h * 0.55), paint);

    // ── Subtle band line for detail ──
    final linePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.15, h * 0.72), Offset(w * 0.85, h * 0.72), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
