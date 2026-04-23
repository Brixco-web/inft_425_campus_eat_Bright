import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/order_model.dart';
import '../../../viewmodels/order_viewmodel.dart';
import '../pickup_pass_screen.dart';

class OrderCard extends StatefulWidget {
  final OrderModel order;

  const OrderCard({super.key, required this.order});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.order.status);
    
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PickupPassScreen(order: widget.order)),
            ),
            borderRadius: BorderRadius.circular(32),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Narrative Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CHRONICLE #${widget.order.id.substring(0, 8).toUpperCase()}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white38,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMMM d, h:mm a').format(widget.order.createdAt),
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: Colors.white24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      _buildAnimatedStatusBadge(statusColor),
                    ],
                  ),
                  
                  const SizedBox(height: 28),

                  // ── Weave Tracking Loom ──
                  _buildWeaveTracker(),

                  const SizedBox(height: 28),

                  // Culinary Manifest (Items)
                  ...widget.order.items.map((item) => _buildManifestItem(item)),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(color: Colors.white10, thickness: 1),
                  ),

                  // Financial Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL CONTRIBUTION',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Colors.white24,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₵${widget.order.totalAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (widget.order.status == OrderStatus.ready)
                        _buildPickupAction(context)
                      else if (widget.order.status == OrderStatus.collected && widget.order.rating == null)
                        _buildRatingAction(context)
                      else if (widget.order.isLectureMode)
                        _buildLectureModeChip(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingAction(BuildContext context) {
    return InkWell(
      onTap: () => _showRatingSheet(context),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.primaryContainer, size: 16),
              const SizedBox(width: 8),
              Text(
                'RATE EXPERIENCE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryContainer,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
      ),
    );
  }

  void _showRatingSheet(BuildContext context) {
    double selectedRating = 5.0;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'HOW WAS THE FLAVOR?',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your feedback helps our chefs refine the VVU culinary experience.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final ratingValue = index + 1.0;
                  return IconButton(
                    icon: Icon(
                      selectedRating >= ratingValue ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: selectedRating >= ratingValue ? AppColors.primaryContainer : Colors.white10,
                      size: 40,
                    ),
                    onPressed: () => setState(() => selectedRating = ratingValue),
                  );
                }),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    await ctx.read<OrderViewModel>().rateOrder(widget.order.id, selectedRating);
                    if (context.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('SUBMIT FEEDBACK', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManifestItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            '${item.quantity}×',
            style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.5),
            ),
          ),
          Text(
            '₵${(item.price * item.quantity).toStringAsFixed(2)}',
            style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white24),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatusBadge(Color color) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2 + (0.3 * _glowController.value))),
            boxShadow: [
              if (widget.order.status == OrderStatus.ready || widget.order.status == OrderStatus.preparing)
                BoxShadow(
                  color: color.withValues(alpha: 0.2 * _glowController.value),
                  blurRadius: 10 * _glowController.value,
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusLabel(widget.order.status),
                style: GoogleFonts.spaceGrotesk(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeaveTracker() {
    final checkpoints = [
      OrderStatus.pending,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.collected,
    ];
    
    int currentIdx = checkpoints.indexOf(widget.order.status);
    if (currentIdx == -1 && widget.order.status == OrderStatus.cancelled) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(checkpoints.length, (index) {
            final isActive = index <= currentIdx;
            final isCurrent = index == currentIdx;
            
            return Expanded(
              child: Row(
                children: [
                  // Checkpoint dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isActive ? _getStatusColor(checkpoints[index]) : Colors.white10,
                      shape: BoxShape.circle,
                      boxShadow: isCurrent ? [
                        BoxShadow(
                          color: _getStatusColor(checkpoints[index]).withValues(alpha: 0.5),
                          blurRadius: 8,
                        )
                      ] : null,
                    ),
                  ),
                  // Connection line
                  if (index < checkpoints.length - 1)
                    Expanded(
                      child: Container(
                        height: 1.5,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              isActive ? _getStatusColor(checkpoints[index]) : Colors.white10,
                              index < currentIdx ? _getStatusColor(checkpoints[index+1]) : Colors.white10,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Text(
          _getNarrativeFeedback(widget.order.status),
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: _getStatusColor(widget.order.status),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'SIGNAL SENT';
      case OrderStatus.preparing: return 'SIZZLING';
      case OrderStatus.ready: return 'RADIANT';
      case OrderStatus.collected: return 'COMPLETE';
      case OrderStatus.cancelled: return 'VOID';
    }
  }

  String _getNarrativeFeedback(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'GATHERING THE INGREDIENTS...';
      case OrderStatus.preparing: return 'OUR CHEFS ARE SIZZLING & BREWING...';
      case OrderStatus.ready: return 'RADIANT & READY FOR ASCENSION (PICKUP)';
      case OrderStatus.collected: return 'THE CULINARY CHRONICLE IS COMPLETE';
      case OrderStatus.cancelled: return 'THE SIGNAL WAS INTERRUPTED';
    }
  }

  Widget _buildPickupAction(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.qr_code_2_rounded, color: Colors.black, size: 18),
            const SizedBox(width: 10),
            Text(
              'COLLECT',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildLectureModeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_stories_rounded, color: Colors.white38, size: 12),
          const SizedBox(width: 8),
          Text(
            'LECTURE MODE',
            style: GoogleFonts.spaceGrotesk(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Colors.orangeAccent;
      case OrderStatus.preparing: return Colors.blueAccent;
      case OrderStatus.ready: return AppColors.primaryContainer;
      case OrderStatus.collected: return const Color(0xFF60A5FA);
      case OrderStatus.cancelled: return const Color(0xFFF87171);
    }
  }

}
