import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/chef_admin_emblem.dart';
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
          .where('fullName', isLessThanOrEqualTo: '${_searchController.text}\uf8ff')
          .limit(1)
          .get();
          
      if (query.docs.isNotEmpty) {
        setState(() => _selectedUser = query.docs.first);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student not found.'))
          );
          setState(() => _selectedUser = null);
        }
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _registerNewStudent(String name, String email, String password, double initialDeposit) async {
    final walletVM = context.read<WalletViewModel>();
    final adminId = context.read<AuthViewModel>().user?.uid ?? 'admin';
    try {
      // In a real app we'd trigger a cloud function to create the Auth user safely without
      // logging out the admin. For the prototype, we create the user document directly.
      final docRef = FirebaseFirestore.instance.collection('users').doc();
      await docRef.set({
        'fullName': name,
        'email': email,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      if (initialDeposit > 0) {
        await walletVM.topUp(docRef.id, initialDeposit, adminId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student Registered successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _updateStudent(String newName, String newEmail) async {
    if (_selectedUser == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(_selectedUser!.id).update({
        'fullName': newName,
        'email': newEmail,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student Updated!')));
        _searchUser(); // refresh
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteStudent() async {
    if (_selectedUser == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(_selectedUser!.id).delete();
      setState(() {
        _selectedUser = null;
        _searchController.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student permanently removed.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: ChefAdminEmblem(size: 36),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRegisterAction(),
            const SizedBox(height: 32),
            _buildSearchSection(),
            const SizedBox(height: 32),
            if (_selectedUser != null) _buildTopUpSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primaryContainer, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Student Vault', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Create a fresh account & wallet', style: GoogleFonts.manrope(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showRegisterModal(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.black,
            ),
            child: Text('REGISTER', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRegisterModal() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final depCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('REGISTER STUDENT', style: GoogleFonts.spaceGrotesk(color: AppColors.primaryContainer, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
            const SizedBox(height: 24),
            _buildTextField('Full Name', nameCtrl),
            const SizedBox(height: 16),
            _buildTextField('Email Address', emailCtrl),
            const SizedBox(height: 16),
            _buildTextField('Temporary Password', passCtrl, obscure: true),
            const SizedBox(height: 16),
            _buildTextField('Initial Cash Deposit (GHS)', depCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _registerNewStudent(nameCtrl.text, emailCtrl.text, passCtrl.text, double.tryParse(depCtrl.text) ?? 0.0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('CREATE VAULT', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscure = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.outlineVariant),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(_selectedUser!['fullName'], style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                     Text(_selectedUser!['email'], style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit_rounded, color: Colors.white54), onPressed: _showEditModal),
              IconButton(icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent), onPressed: () => _confirmDelete()),
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

  void _showEditModal() {
    final nCtrl = TextEditingController(text: _selectedUser!['fullName']);
    final eCtrl = TextEditingController(text: _selectedUser!['email']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Edit Student', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Full Name', nCtrl),
            const SizedBox(height: 12),
            _buildTextField('Email Address', eCtrl),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateStudent(nCtrl.text, eCtrl.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer, foregroundColor: Colors.black),
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('CRITICAL WARNING', style: GoogleFonts.spaceGrotesk(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to permanently delete ${_selectedUser!['fullName']}?', style: GoogleFonts.manrope(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteStudent();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('PERMANENTLY DELETE'),
          ),
        ],
      ),
    );
  }
}
