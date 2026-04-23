import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/chef_admin_emblem.dart';
import 'admin_wallet_manager.dart';
import 'user_management_screen.dart';

class FinancialCommandScreen extends StatefulWidget {
  const FinancialCommandScreen({super.key});

  @override
  State<FinancialCommandScreen> createState() => _FinancialCommandScreenState();
}

class _FinancialCommandScreenState extends State<FinancialCommandScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _userSearchController = TextEditingController();
  String _userQuery = '';
  late AnimationController _pulseController;
  bool _filterHighBalance = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _userSearchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060606),
      body: Stack(
        children: [
          // ── Layer 1: Culinary Kitchen Atmosphere ──
          Positioned.fill(
            child: Image.asset(
              'assets/images/dashboard_food_hero.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.06),
            ),
          ),
          // ── Layer 2: Deep gradient scrim ──
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF060606),
                    const Color(0xFF060606).withValues(alpha: 0.85),
                    const Color(0xFF0D1117).withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildKitchenHeader(),
                _buildLiveRevenueStrip(),
                _buildRevenueBarChart(),
                _buildOperationalMetrics(),
                _buildMonitoringHeader(),
                _buildUserMonitorList(),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════
  //  1. KITCHEN HEAD HEADER
  // ════════════════════════════════════════════════════
  Widget _buildKitchenHeader() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 8),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4ADE80).withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, child) => Opacity(
                          opacity: 0.5 + (_pulseController.value * 0.5),
                          child: child,
                        ),
                        child: Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'KITCHEN REVENUE HQ',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9,
                          letterSpacing: 2.5,
                          color: const Color(0xFF4ADE80),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'TODAY',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9, fontWeight: FontWeight.w900,
                      color: Colors.white24, letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Revenue\nCommand',
                    style: GoogleFonts.epilogue(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),
                const ChefAdminEmblem(size: 56),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Kitchen operations financial intelligence',
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: Colors.white30,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  //  2. LIVE REVENUE STRIP — 4 compact glassmorphic KPI blocks
  // ════════════════════════════════════════════════════
  Widget _buildLiveRevenueStrip() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: Color(0xFF4ADE80), size: 16),
                const SizedBox(width: 8),
                Text(
                  'FINANCIAL PULSE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9, letterSpacing: 2.5,
                    color: const Color(0xFF4ADE80), fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildKPIBlock('₵1,240', 'Net Today', const Color(0xFF4ADE80), Icons.trending_up_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildKPIBlock('₵8,450', 'This Week', AppColors.primaryContainer, Icons.calendar_view_week_rounded)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildKPIBlock('₵32K', 'Monthly', const Color(0xFFC084FC), Icons.insights_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildKPIBlock('74', 'Orders Today', Colors.white60, Icons.shopping_bag_rounded)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIBlock(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18, fontWeight: FontWeight.w900, color: color,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 10, color: Colors.white24, fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════
  //  3. WEEKLY REVENUE BAR CHART — professional POS-grade
  // ════════════════════════════════════════════════════
  Widget _buildRevenueBarChart() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEKLY THROUGHPUT',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9, letterSpacing: 2.5,
                        color: Colors.white24, fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₵ 8,450.00',
                      style: GoogleFonts.epilogue(
                        fontSize: 24, fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward_rounded, color: Color(0xFF4ADE80), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '+12.4%',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11, fontWeight: FontWeight.w900,
                          color: const Color(0xFF4ADE80),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 2000,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.surfaceContainerHigh,
                      getTooltipItem: (group, gIdx, rod, rIdx) {
                        return BarTooltipItem(
                          '₵${rod.toY.toInt()}',
                          GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt()],
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9, color: Colors.white24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 500,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withValues(alpha: 0.03),
                      strokeWidth: 1,
                    ),
                  ),
                  barGroups: [
                    _makeBar(0, 1200, AppColors.primaryContainer),
                    _makeBar(1, 980, AppColors.primaryContainer),
                    _makeBar(2, 1450, const Color(0xFF4ADE80)),
                    _makeBar(3, 1780, const Color(0xFF4ADE80)),
                    _makeBar(4, 1100, AppColors.primaryContainer),
                    _makeBar(5, 650, AppColors.primaryContainer.withValues(alpha: 0.5)),
                    _makeBar(6, 1290, AppColors.primaryContainer),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 18,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 2000,
            color: Colors.white.withValues(alpha: 0.02),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════
  //  4. OPERATIONAL METRICS — Transaction Flow + Wallet Velocity
  // ════════════════════════════════════════════════════
  Widget _buildOperationalMetrics() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                'Wallet\nVelocity',
                '86%',
                'Wallet-paid orders',
                const Color(0xFFC084FC),
                0.86,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                'Cash\nRatio',
                '14%',
                'Cash-at-pickup',
                Colors.orangeAccent,
                0.14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, String pct, String subtitle, Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.epilogue(
              fontSize: 16, fontWeight: FontWeight.w900,
              color: Colors.white, height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                pct,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28, fontWeight: FontWeight.w900, color: color,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  subtitle,
                  style: GoogleFonts.manrope(fontSize: 9, color: Colors.white24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════
  //  5. STUDENT CONTROL HUB + WALLET REGISTRY ENTRY
  // ════════════════════════════════════════════════════
  Widget _buildMonitoringHeader() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_alt_rounded, color: Colors.white24, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'USER CONTROL HUB',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10, letterSpacing: 2,
                        color: Colors.white24, fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildFilterPill('ALL', !_filterHighBalance, () => setState(() => _filterHighBalance = false)),
                    const SizedBox(width: 8),
                    _buildFilterPill('HIGH MONEY', _filterHighBalance, () => setState(() => _filterHighBalance = true)),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 140,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: TextField(
                    controller: _userSearchController,
                    onChanged: (val) => setState(() => _userQuery = val.toLowerCase()),
                    style: GoogleFonts.manrope(fontSize: 11, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search id...',
                      hintStyle: TextStyle(color: Colors.white10, fontSize: 10),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.white10, size: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletManager()));
                },
                icon: const Icon(Icons.account_balance_wallet_rounded, size: 18),
                label: Text(
                  'OPEN WALLET REGISTRY',
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12),
                ),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: AppColors.primaryContainer,
                   foregroundColor: Colors.black,
                   padding: const EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                   elevation: 0,
                 ),
               ),
             ),
             const SizedBox(height: 12),
             Center(
               child: TextButton(
                 onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen()));
                 },
                child: Text(
                  'SEE ALL CITIZENS',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white12,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryContainer.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.primaryContainer.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: active ? AppColors.primaryContainer : Colors.white24,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  //  6. USER MONITOR LIST
  // ════════════════════════════════════════════════════
  Widget _buildUserMonitorList() {
    final mockUsers = [
      {'name': 'Isaac Newton', 'id': 'VVU-2023-0128', 'balance': '₵ 120.50', 'status': 'ACTIVE', 'orders': '12'},
      {'name': 'Marie Curie', 'id': 'VVU-2023-0942', 'balance': '₵ 45.00', 'status': 'FROZEN', 'orders': '3'},
      {'name': 'Albert Einstein', 'id': 'VVU-2023-0512', 'balance': '₵ 210.00', 'status': 'ACTIVE', 'orders': '28'},
      {'name': 'Ada Lovelace', 'id': 'VVU-2023-0781', 'balance': '₵ 8.20', 'status': 'LOW_BAL', 'orders': '7'},
      {'name': 'Nikola Tesla', 'id': 'VVU-2023-1023', 'balance': '₵ 175.00', 'status': 'ACTIVE', 'orders': '19'},
    ];

    var filtered = mockUsers.where((s) => s['id']!.toLowerCase().contains(_userQuery)).toList();
    
    if (_filterHighBalance) {
      filtered = filtered.where((s) {
        final bal = double.tryParse(s['balance']!.replaceAll('₵ ', '').replaceAll(',', '')) ?? 0.0;
        return bal > 100.0;
      }).toList();
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildUserCard(filtered[index]),
          childCount: filtered.length,
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, String> user) {
    Color statusColor = const Color(0xFF4ADE80);
    if (user['status'] == 'FROZEN') statusColor = Colors.redAccent;
    if (user['status'] == 'LOW_BAL') statusColor = Colors.orangeAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withValues(alpha: 0.15), statusColor.withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.person_rounded, color: statusColor.withValues(alpha: 0.6), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name']!.toUpperCase(),
                  style: GoogleFonts.epilogue(
                    fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      user['id']!,
                      style: GoogleFonts.spaceGrotesk(fontSize: 9, color: Colors.white12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${user['orders']} orders',
                      style: GoogleFonts.manrope(fontSize: 9, color: Colors.white24),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                user['balance']!,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, fontWeight: FontWeight.w900,
                  color: AppColors.primaryContainer,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  user['status']!,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 7, fontWeight: FontWeight.w900, color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
