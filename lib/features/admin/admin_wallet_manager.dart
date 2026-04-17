import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/wallet_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class AdminWalletManager extends StatefulWidget {
  const AdminWalletManager({super.key});

  @override
  State<AdminWalletManager> createState() => _AdminWalletManagerState();
}

class _AdminWalletManagerState extends State<AdminWalletManager> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  
  DocumentSnapshot? _selectedUser;
  bool _isSearching = false;

  Future<void> _searchUser() async {
    if (_searchController.text.isEmpty) return;
    
    setState(() => _isSearching = true);
    
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('fullName', isGreaterThanOrEqualTo: _searchController.text)
          .where('fullName', isLessThanOrEqualTo: _searchController.text + '\uf8ff')
          .limit(1)
          .get();
          
      if (query.docs.isNotEmpty) {
        setState(() => _selectedUser = query.docs.first);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student not found.'))
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _processTopUp() async {
    if (_selectedUser == null || _amountController.text.isEmpty) return;
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final walletVM = context.read<WalletViewModel>();
    final adminId = context.read<AuthViewModel>().user?.uid ?? 'unknown';

    await walletVM.topUp(_selectedUser!.id, amount, adminId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully topped up GHS ${amount.toStringAsFixed(2)} for ${_selectedUser!['fullName']}'))
      );
      _amountController.clear();
      _selectedUser = null;
      _searchController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'WALLET MANAGEMENT',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchSection(),
            const SizedBox(height: 32),
            if (_selectedUser != null) _buildTopUpSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FIND STUDENT',
          style: GoogleFonts.spaceGrotesk(color: AppColors.onSurface, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter student name...',
            hintStyle: const TextStyle(color: AppColors.outlineVariant),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            suffixIcon: IconButton(
              icon: Icon(_isSearching ? Icons.hourglass_empty : Icons.search, color: AppColors.primaryContainer),
              onPressed: _searchUser,
            ),
          ),
          onSubmitted: (_) => _searchUser(),
        ),
      ],
    );
  }

  Widget _buildTopUpSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(backgroundColor: AppColors.primaryContainer, child: Icon(Icons.person, color: Colors.black)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(_selectedUser!['fullName'], style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                   Text(_selectedUser!['email'], style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('TOP UP AMOUNT (GHS)', style: GoogleFonts.spaceGrotesk(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: 'GHS ',
              prefixStyle: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontSize: 24),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _processTopUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('RECORD ADVANCE PAYMENT', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
