import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../models/menu_item_model.dart';
import '../../viewmodels/menu_viewmodel.dart';

class AddEditMenuItemScreen extends StatefulWidget {
  final MenuItem? item;

  const AddEditMenuItemScreen({super.key, this.item});

  @override
  State<AddEditMenuItemScreen> createState() => _AddEditMenuItemScreenState();
}

class _AddEditMenuItemScreenState extends State<AddEditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  late TextEditingController _prepTimeController;
  late TextEditingController _stockController;
  late TextEditingController _ingredientsController;
  
  MenuCategory _selectedCategory = MenuCategory.campusGems;
  bool _isAvailable = true;
  bool _isTrending = false;
  bool _isPromoted = false;
  bool _isVegetarian = false;
  bool _isVegan = false;
  
  List<MenuOption> _options = [];
  File? _localImageFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descController = TextEditingController(text: widget.item?.description ?? '');
    _priceController = TextEditingController(text: widget.item?.price.toString() ?? '');
    _imageController = TextEditingController(text: widget.item?.imageUrl ?? '');
    _prepTimeController = TextEditingController(text: widget.item?.prepTime.toString() ?? '15');
    _stockController = TextEditingController(text: widget.item?.stockCount.toString() ?? '50');
    _ingredientsController = TextEditingController(text: widget.item?.ingredients.join(', ') ?? '');
    
    _selectedCategory = widget.item?.category ?? MenuCategory.campusGems;
    _isAvailable = widget.item?.isAvailable ?? true;
    _isTrending = widget.item?.isTrending ?? false;
    _isPromoted = widget.item?.isPromoted ?? false;
    _isVegetarian = widget.item?.isVegetarian ?? false;
    _isVegan = widget.item?.isVegan ?? false;
    _options = widget.item?.options != null ? List.from(widget.item!.options) : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _prepTimeController.dispose();
    _stockController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'REFINE BLUEPRINT' : 'NEW MENU ARCHITECT',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            letterSpacing: 2,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: _showDeleteConfirmation,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: [
            _buildSectionHeader('CORE SPECS'),
            _buildTextField(
              controller: _nameController,
              label: 'DESIGNATION',
              hint: 'e.g. Royal Waakye Special',
              validator: (v) => v!.isEmpty ? 'Item name required' : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _descController,
              label: 'NARRATIVE DESCRIPTION',
              hint: 'Describe the flavor profile and heritage...',
              maxLines: 4,
              validator: (v) => v!.isEmpty ? 'Description required' : null,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('METRICS & DIRECTORY'),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _priceController,
                    label: 'PRICE (₵)',
                    hint: '0.00',
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v!) == null ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _prepTimeController,
                    label: 'PREP (MINS)',
                    hint: '15',
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse(v!) == null ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _stockController,
                    label: 'INITIAL BATCH',
                    hint: '50',
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse(v!) == null ? 'Invalid' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDropdown(),
            const SizedBox(height: 32),
            _buildSectionHeader('VISUAL ASSETS'),
            _buildImageInput(),
            const SizedBox(height: 32),
            _buildSectionHeader('OPTIONS BUILDER'),
            _buildOptionsEditor(),
            const SizedBox(height: 32),
            _buildSectionHeader('LOGIC FLAGS'),
            _buildFlags(),
            const SizedBox(height: 48),
            _buildSaveButton(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              letterSpacing: 3,
              fontWeight: FontWeight.w900,
              color: Colors.white24,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(color: Colors.white10)),
        ],
      ),
    );
  }

  Widget _buildImageInput() {
    return Column(
      children: [
        _buildTextField(
          controller: _imageController,
          label: 'EXTERNAL IMAGE URL',
          hint: 'https://images.unsplash.com/...',
          onChanged: (_) => setState(() {}),
          validator: (v) => v!.isEmpty ? 'Image URL required' : null,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'OR PICK LOCAL IMAGE',
              style: GoogleFonts.spaceGrotesk(fontSize: 8, color: Colors.white10, fontWeight: FontWeight.w900),
            ),
            TextButton.icon(
              onPressed: _pickImage,
              icon: Icon(_isUploading ? Icons.hourglass_empty_rounded : Icons.camera_alt_outlined, size: 14),
              label: Text(_isUploading ? 'UPLOADING...' : 'PICK FROM GALLERY', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        if (_imageController.text.isNotEmpty || _localImageFile != null)
          Container(
            height: 180,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              image: DecorationImage(
                image: _localImageFile != null
                    ? FileImage(_localImageFile!)
                    : (_imageController.text.startsWith('http')
                        ? NetworkImage(_imageController.text) as ImageProvider
                        : AssetImage(_imageController.text) as ImageProvider),
                fit: BoxFit.cover,
                onError: (e, s) {},
              ),
            ),
            child: _isUploading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
              : null,
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile != null) {
      if (!mounted) return;
      setState(() {
        _localImageFile = File(pickedFile.path);
        _isUploading = true;
      });
      
      try {
        final vm = context.read<MenuViewModel>();
        final fileName = 'menu_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final url = await vm.uploadImage(_localImageFile!, 'menu/$fileName');
        
        if (mounted) {
          setState(() {
            _imageController.text = url;
            _isUploading = false;
          });
        }
      } catch (e) {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  Widget _buildOptionsEditor() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Column(
        children: [
          ..._options.asMap().entries.map((entry) {
            final idx = entry.key;
            final opt = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildMiniField('Add-on Name', opt.name, (v) => _options[idx] = opt.copyWith(name: v)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMiniField('Price', opt.price.toString(), (v) => _options[idx] = opt.copyWith(price: double.tryParse(v) ?? 0)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => setState(() => _options.removeAt(idx)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => setState(() => _options.add(MenuOption(name: '', price: 0))),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text('ADD CUSTOMIZATION', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryContainer,
              side: BorderSide(color: AppColors.primaryContainer.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniField(String hint, String initial, Function(String) onChanged) {
    return TextFormField(
      initialValue: initial,
      onChanged: onChanged,
      style: GoogleFonts.manrope(fontSize: 12, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white10),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildFlags() {
    return Column(
      children: [
        _buildToggleRow('Trending Locally', _isTrending, (v) => setState(() => _isTrending = v)),
        _buildToggleRow('Promote on Hero', _isPromoted, (v) => setState(() => _isPromoted = v)),
        _buildToggleRow('Item is Available', _isAvailable, (v) => setState(() => _isAvailable = v)),
        _buildToggleRow('Vegetarian Friendly', _isVegetarian, (v) => setState(() => _isVegetarian = v)),
        _buildToggleRow('Vegan Selection', _isVegan, (v) => setState(() => _isVegan = v)),
      ],
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.manrope(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          Switch.adaptive(
            value: value, 
            onChanged: onChanged,
            activeTrackColor: AppColors.primaryContainer.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text(
          widget.item == null ? 'COMMISSION BLUEPRINT' : 'SYNC ALTERATIONS',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 13),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('PURGE ARCHIVE?', style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, color: Colors.white)),
        content: Text('This action will permanently remove this culinary blueprint from the vault.', 
          style: GoogleFonts.manrope(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ABORT')),
          TextButton(
            onPressed: () async {
              final itemNav = Navigator.of(context);
              final dialogNav = Navigator.of(ctx);
              final viewModel = context.read<MenuViewModel>();
              await viewModel.deleteMenuItem(widget.item!.id);
              if (mounted) {
                dialogNav.pop();
                itemNav.pop();
              }
            },
            child: const Text('PURGE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          style: GoogleFonts.manrope(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.manrope(color: Colors.white10, fontSize: 12),
            filled: true,
            fillColor: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DIRECTORY',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MenuCategory>(
              value: _selectedCategory,
              dropdownColor: AppColors.surfaceContainerHigh,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryContainer),
              style: GoogleFonts.manrope(color: Colors.white, fontSize: 13),
              items: MenuCategory.values.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
          ),
        ),
      ],
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final item = MenuItem(
      id: widget.item?.id ?? '',
      name: _nameController.text,
      description: _descController.text,
      price: double.parse(_priceController.text),
      imageUrl: _imageController.text,
      category: _selectedCategory,
      prepTime: int.parse(_prepTimeController.text),
      stockCount: int.parse(_stockController.text),
      isAvailable: _isAvailable,
      isTrending: _isTrending,
      isPromoted: _isPromoted,
      isVegetarian: _isVegetarian,
      isVegan: _isVegan,
      options: _options,
      ingredients: _ingredientsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      rating: widget.item?.rating ?? 5.0,
      reviewCount: widget.item?.reviewCount ?? 0,
    );

    await context.read<MenuViewModel>().saveMenuItem(item);
    if (mounted) Navigator.pop(context);
  }
}
