import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/wallet_viewmodel.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/wallet_service.dart';
import 'dart:ui';
import 'user_vault_detail_screen.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final WalletService _walletService = WalletService();
  final OrderService _orderService = OrderService();
  
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    
    try {
      // Fetch users from Firestore based on studentId or Name
      final users = await _firestoreService.searchUsers(query);
      setState(() {
        _searchResults = users;
        _isSearching = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserRegistryTab(),
                _buildOrderLedgerTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CIVIC NEXUS',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryContainer,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Vault Personnel & Identity Registry',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: Colors.white24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Add User Button
          GestureDetector(
            onTap: () => _showAddUserSheet(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_add_rounded, color: AppColors.primaryContainer, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'ADD USER',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1,
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.2)),
        ),
        labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 12),
        labelColor: AppColors.primaryContainer,
        unselectedLabelColor: Colors.white24,
        tabs: const [
          Tab(text: 'USER REGISTRY'),
          Tab(text: 'ORDER LEDGER'),
        ],
      ),
    );
  }

  Widget _buildOrderLedgerTab() {
    return Column(
      children: [
        _buildLedgerHeader(),
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: _orderService.getAllOrdersStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer));
              final orders = snapshot.data!;
              if (orders.isEmpty) return _buildEmptyLedger();
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildLedgerTile(order);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLedgerHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'SYSTEM-WIDE LOG',
            style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 2),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'REALT-TIME',
              style: GoogleFonts.spaceGrotesk(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.primaryContainer, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerTile(OrderModel order) {
    final isCash = order.paymentMethod == PaymentMethod.cash;
    final statusColor = _getStatusColor(order.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (isCash ? Colors.orangeAccent : AppColors.primaryContainer).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCash ? Icons.payments_rounded : Icons.account_balance_wallet_rounded,
              color: isCash ? Colors.orangeAccent : AppColors.primaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.studentName.toUpperCase(),
                  style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, color: Colors.white70, fontSize: 13),
                ),
                Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: GoogleFonts.spaceGrotesk(color: Colors.white12, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₵${order.totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.status.name.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(fontSize: 7, fontWeight: FontWeight.w900, color: statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.preparing: return AppColors.primaryContainer;
      case OrderStatus.ready: return Colors.blue;
      case OrderStatus.collected: return Colors.green;
      case OrderStatus.cancelled: return Colors.red;
    }
  }

  Widget _buildEmptyLedger() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_edu_rounded, size: 64, color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 16),
          Text('No order history recorded in the vault.', style: GoogleFonts.manrope(color: Colors.white24, fontSize: 13)),
        ],
      ),
    );
  }

  void _showAddUserSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF0F1115),
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'IDENTITY PROVISION',
                style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryContainer, letterSpacing: 4),
              ),
              const SizedBox(height: 8),
              Text('Initialize a new citizen identity into the ecosystem.', style: GoogleFonts.manrope(color: Colors.white24, fontSize: 13)),
              const SizedBox(height: 32),
              _ManualEntryForm(
                onSuccess: (name) {
                  Navigator.pop(context);
                  _searchController.text = name;
                  _performSearch(name);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserRegistryTab() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
              : _searchResults.isEmpty
                  ? _buildEmptyState()
                  : _buildUserList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: _performSearch,
          style: GoogleFonts.manrope(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Lookup Student ID or Name...',
            hintStyle: GoogleFonts.manrope(color: Colors.white24, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryContainer, size: 18),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 64, color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 16),
          Text(
            'Search for a student to \nmanage vault permissions',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserVaultDetailScreen(user: user)),
        ),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Hero(
                tag: 'user-avatar-${user.uid}',
                child: CircleAvatar(
                  backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.1),
                  child: Text(
                    user.displayName[0].toUpperCase(),
                    style: TextStyle(color: AppColors.primaryContainer, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName.toUpperCase(),
                      style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      'ID: ${user.studentId}',
                      style: GoogleFonts.spaceGrotesk(color: Colors.white24, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _buildWalletAction(user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletAction(UserModel user) {
    return StreamBuilder(
      stream: _walletService.getWalletStream(user.uid),
      builder: (context, snapshot) {
        final registered = snapshot.hasData && snapshot.data!.balance >= 0;
        
        if (!registered) {
          return ElevatedButton(
            onPressed: () => _provisionWallet(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text('PROVISION', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 11)),
          );
        }

        return IconButton(
          onPressed: () => _showTopUpDialog(user, snapshot.data!.balance),
          icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryContainer),
        );
      },
    );
  }

  Future<void> _provisionWallet(UserModel user) async {
    await _walletService.topUpBalance(user.uid, 0.0, 'ADMIN');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wallet provisioned for ${user.displayName}')),
      );
    }
  }

  void _showTopUpDialog(UserModel user, double currentBalance) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: const Color(0xFF161D20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(color: AppColors.primaryContainer.withValues(alpha: 0.2))),
          title: Text('MANUAL ADVANCE', 
              style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Recording physical payment for ${user.displayName}', style: GoogleFonts.manrope(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 24),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  prefixText: '₵ ',
                  hintText: '0.00',
                  hintStyle: TextStyle(color: Colors.white10),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryContainer)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: GoogleFonts.spaceGrotesk(color: Colors.white24)),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  await _walletService.topUpBalance(user.uid, amount, 'ADMIN');
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer, foregroundColor: Colors.black),
              child: Text('CONFIRM TOP-UP', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualEntryForm extends StatefulWidget {
  final Function(String) onSuccess;
  const _ManualEntryForm({required this.onSuccess});

  @override
  State<_ManualEntryForm> createState() => _ManualEntryFormState();
}

class _ManualEntryFormState extends State<_ManualEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '0.00');
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final name = _nameController.text.trim();
      final id = _idController.text.trim();
      final email = _emailController.text.trim();
      final balance = double.tryParse(_initialBalanceController.text) ?? 0.0;

      // Logic: Create user in Firestore + Provision Wallet
      await context.read<WalletViewModel>().manuallyOnboardStudent(
        displayName: name,
        studentId: id,
        email: email,
        initialBalance: balance,
      );

      widget.onSuccess(name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enrollment failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildField(
            controller: _nameController,
            label: 'FULL LEGAL NAME',
            hint: 'e.g. KOFI BONSU',
            icon: Icons.person_outline_rounded,
            validator: (v) => v!.isEmpty ? 'Name required' : null,
          ),
          const SizedBox(height: 24),
          _buildField(
            controller: _idController,
            label: 'STUDENT IDENTIFICATION',
            hint: 'e.g. 222VU001',
            icon: Icons.badge_outlined,
            validator: (v) => v!.isEmpty ? 'Valid ID required' : null,
          ),
          const SizedBox(height: 24),
          _buildField(
            controller: _emailController,
            label: 'EMAIL ADDRESS',
            hint: 'student@vvu.edu.gh',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          _buildField(
            controller: _initialBalanceController,
            label: 'INITIAL WALLET LOAD (₵)',
            hint: '0.00',
            icon: Icons.account_balance_wallet_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 56),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isSubmitting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : Text('ENROLL INTO ECOSYSTEM', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.white38,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: GoogleFonts.manrope(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white10),
              prefixIcon: Icon(icon, color: AppColors.primaryContainer, size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
