import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class KitchenControlsOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const KitchenControlsOverlay({super.key, required this.onClose});

  @override
  State<KitchenControlsOverlay> createState() => _KitchenControlsOverlayState();
}

class _KitchenControlsOverlayState extends State<KitchenControlsOverlay> {
  bool _gridMode = true;
  double _ambientLevel = 1.0;
  bool _orderPulse = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 1. Backdrop Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
          ),

          // 2. Control Panel
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF161D20).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    blurRadius: 100,
                    spreadRadius: -20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KITCHEN PREFERENCES',
                            style: GoogleFonts.spaceGrotesk(
                              color: AppColors.primaryContainer,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            'Tune your Loom',
                            style: GoogleFonts.epilogue(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close_rounded, color: Colors.white30),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Option 1: Plating Style
                  _buildControlItem(
                    icon: Icons.auto_awesome_mosaic_rounded,
                    title: 'Plating Style',
                    subtitle: _gridMode ? 'Standard Cinematic Grid' : 'Executive List',
                    trailing: Switch(
                      value: _gridMode,
                      onChanged: (val) => setState(() => _gridMode = val),
                      activeThumbColor: AppColors.primaryContainer,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Option 2: Ambient Temperature
                  _buildControlItem(
                    icon: Icons.thermostat_rounded,
                    title: 'Ambient Bloom',
                    subtitle: 'Intensity of misty effects',
                    trailing: Expanded(
                      child: Slider(
                        value: _ambientLevel,
                        onChanged: (val) => setState(() => _ambientLevel = val),
                        activeColor: AppColors.primaryContainer,
                        inactiveColor: Colors.white10,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Option 3: Order Pulse
                  _buildControlItem(
                    icon: Icons.sensors_rounded,
                    title: 'Order Pulse',
                    subtitle: 'Live status animations',
                    trailing: Switch(
                      value: _orderPulse,
                      onChanged: (val) => setState(() => _orderPulse = val),
                      activeThumbColor: AppColors.primaryContainer,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Reset Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        'RESTORE DEFAULT LOOM',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white54,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.primaryContainer, size: 20),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.manrope(
                  color: Colors.white24,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        trailing,
      ],
    );
  }
}
