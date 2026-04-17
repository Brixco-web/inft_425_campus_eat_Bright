import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
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
  MenuCategory _selectedCategory = MenuCategory.campusGems;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descController = TextEditingController(text: widget.item?.description ?? '');
    _priceController = TextEditingController(text: widget.item?.price.toString() ?? '');
    _imageController = TextEditingController(text: widget.item?.imageUrl ?? '');
    _prepTimeController = TextEditingController(text: widget.item?.prepTime.toString() ?? '15');
    _selectedCategory = widget.item?.category ?? MenuCategory.campusGems;
    _isAvailable = widget.item?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _prepTimeController.dispose();
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
        title: Text(
          isEditing ? 'EDIT ITEM' : 'NEW ITEM',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'NAME',
              hint: 'e.g. Jollof Rice Special',
              validator: (v) => v!.isEmpty ? 'Name required' : null,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _descController,
              label: 'DESCRIPTION',
              hint: 'e.g. Spicy Ghanaian jollof with chicken...',
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Description required' : null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _priceController,
                    label: 'PRICE (GHS)',
                    hint: '0.00',
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v!) == null ? 'Invalid price' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _prepTimeController,
                    label: 'PREP (MIN)',
                    hint: '15',
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse(v!) == null ? 'Invalid time' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _imageController,
              label: 'IMAGE URL',
              hint: 'https://...',
              onChanged: (_) => setState(() {}),
              validator: (v) => v!.isEmpty ? 'Image URL required' : null,
            ),
            const SizedBox(height: 24),
            
            // Image Preview
            if (_imageController.text.isNotEmpty)
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  _imageController.text,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.error_outline)),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Category Dropdown
            _buildDropdown(),
            
            const SizedBox(height: 32),
            
            // Save Button
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                isEditing ? 'UPDATE ITEM' : 'PUBLISH ITEM',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
          ],
        ),
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
            fontSize: 12,
            fontWeight: FontWeight.bold,
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
          style: GoogleFonts.manrope(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.manrope(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
          'CATEGORY',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.primaryContainer,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MenuCategory>(
              value: _selectedCategory,
              dropdownColor: AppColors.surfaceContainerHigh,
              isExpanded: true,
              style: GoogleFonts.manrope(color: Colors.white),
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
      isAvailable: _isAvailable,
    );

    await context.read<MenuViewModel>().saveMenuItem(item);
    if (mounted) Navigator.pop(context);
  }
}
