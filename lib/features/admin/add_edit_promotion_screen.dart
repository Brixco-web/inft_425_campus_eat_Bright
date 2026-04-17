import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/promotion_model.dart';
import '../../viewmodels/menu_viewmodel.dart';

class AddEditPromotionScreen extends StatefulWidget {
  final PromotionModel? promotion;

  const AddEditPromotionScreen({super.key, this.promotion});

  @override
  State<AddEditPromotionScreen> createState() => _AddEditPromotionScreenState();
}

class _AddEditPromotionScreenState extends State<AddEditPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _imageController;
  late TextEditingController _priorityController;
  String? _selectedTargetItemId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.promotion?.title ?? '');
    _subtitleController = TextEditingController(text: widget.promotion?.subtitle ?? '');
    _imageController = TextEditingController(text: widget.promotion?.imageUrl ?? '');
    _priorityController = TextEditingController(text: widget.promotion?.priority.toString() ?? '0');
    _selectedTargetItemId = widget.promotion?.targetItemId;
    _isActive = widget.promotion?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _imageController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.promotion != null;
    final menuItems = context.watch<MenuViewModel>().items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditing ? 'EDIT FLIER' : 'NEW FLIER',
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
              controller: _titleController,
              label: 'TITLE',
              hint: 'e.g. WAAKYE THURSDAY',
              validator: (v) => v!.isEmpty ? 'Title required' : null,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _subtitleController,
              label: 'SUBTITLE',
              hint: 'e.g. 20% Off All Local Dishes',
              validator: (v) => v!.isEmpty ? 'Subtitle required' : null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _priorityController,
                    label: 'PRIORITY',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse(v!) == null ? 'Invalid number' : null,
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.primaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Switch(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      activeThumbColor: AppColors.primaryContainer,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _imageController,
              label: 'BANNER IMAGE URL',
              hint: 'https://...',
              onChanged: (_) => setState(() {}),
              validator: (v) => v!.isEmpty ? 'Image URL required' : null,
            ),
            
            const SizedBox(height: 24),
            
            // Preview
            if (_imageController.text.isNotEmpty)
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  _imageController.text,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error_outline)),
                ),
              ),

            const SizedBox(height: 24),
            
            // Target Item Dropdown
            _buildTargetDropdown(menuItems),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                isEditing ? 'UPDATE FLIER' : 'LAUNCH PROMOTION',
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
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          style: GoogleFonts.manrope(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.manrope(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetDropdown(List menuItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TARGET ITEM (OPTIONAL)',
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
            child: DropdownButton<String?>(
              value: _selectedTargetItemId,
              dropdownColor: AppColors.surfaceContainerHigh,
              isExpanded: true,
              hint: Text('Select an item to link', style: GoogleFonts.manrope(color: Colors.white30, fontSize: 14)),
              style: GoogleFonts.manrope(color: Colors.white),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('NONE (Information Only)')),
                ...menuItems.map((item) => DropdownMenuItem(value: item.id, child: Text(item.name))),
              ],
              onChanged: (val) => setState(() => _selectedTargetItemId = val),
            ),
          ),
        ),
      ],
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final promo = PromotionModel(
      id: widget.promotion?.id ?? '',
      title: _titleController.text,
      subtitle: _subtitleController.text,
      imageUrl: _imageController.text,
      priority: int.parse(_priorityController.text),
      isActive: _isActive,
      targetItemId: _selectedTargetItemId,
    );

    await context.read<MenuViewModel>().savePromotion(promo);
    if (mounted) Navigator.pop(context);
  }
}
