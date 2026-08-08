import 'package:flutter/material.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';

/// Full address form — province/district/commune, house number, nearby
/// pickup point, address type, and default toggle. All location fields
/// are free text (no province/district/commune API to back a picker
/// yet). Returns a formatted address string via [Navigator.pop] when saved.
class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressType {
  final String label;
  final IconData icon;
  const _AddressType(this.label, this.icon);
}

class _AddressScreenState extends State<AddressScreen> {
  static const List<_AddressType> _types = [
    _AddressType(AppString.addressHome, Icons.home_outlined),
    _AddressType(AppString.addressOffice, Icons.work_outline),
    _AddressType(AppString.addressSchool, Icons.school_outlined),
    _AddressType(AppString.addressOther, Icons.more_horiz),
  ];

  int _selectedType = 0;
  bool _isDefault = false;

  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _communeController = TextEditingController();
  final _houseNoController = TextEditingController();
  final _pickupPointController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _provinceController.dispose();
    _districtController.dispose();
    _communeController.dispose();
    _houseNoController.dispose();
    _pickupPointController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _save() {
    if (_houseNoController.text.trim().isEmpty || _communeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppString.incompleteAddress),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textDark,
        ),
      );
      return;
    }

    final parts = [
      _houseNoController.text.trim(),
      _communeController.text.trim(),
      _districtController.text.trim(),
    ].where((part) => part.isNotEmpty);

    Navigator.pop(context, parts.join(", "));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextRow(
                      icon: Icons.location_on_outlined,
                      controller: _provinceController,
                      hint: AppString.selectProvince,
                    ),
                    const SizedBox(height: 12),
                    _buildTextRow(
                      icon: Icons.location_on_outlined,
                      controller: _districtController,
                      hint: AppString.selectDistrict,
                    ),
                    const SizedBox(height: 12),
                    _buildTextRow(
                      icon: Icons.location_on_outlined,
                      controller: _communeController,
                      hint: AppString.selectCommune,
                    ),
                    const SizedBox(height: 12),
                    _buildTextRow(
                      icon: Icons.edit_outlined,
                      controller: _houseNoController,
                      hint: AppString.houseNoHint,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(AppString.chooseLocationSection),
                    const SizedBox(height: 10),
                    _buildTextRow(
                      icon: Icons.store_mall_directory_outlined,
                      controller: _pickupPointController,
                      hint: AppString.selectPickupPoint,
                    ),
                    const SizedBox(height: 12),
                    _buildTextRow(
                      icon: Icons.location_on_outlined,
                      controller: _locationController,
                      hint: AppString.location,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(AppString.typeOfAddress),
                    const SizedBox(height: 12),
                    _buildTypeSelector(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          AppString.setAsDefaultAddress,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                        Switch(
                          value: _isDefault,
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.accent,
                          onChanged: (value) => setState(() => _isDefault = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ---------- HEADER ----------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: const Icon(Icons.arrow_back, size: 22, color: AppColors.textDark),
            ),
          ),
          const Expanded(
            child: Text(
              AppString.createAddress,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
    );
  }

  // ---------- TEXT ROW (free text input) ----------
  Widget _buildTextRow({
    required IconData icon,
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }

  // ---------- ADDRESS TYPE CHIPS ----------
  Widget _buildTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_types.length, (index) {
        final type = _types[index];
        final isSelected = _selectedType == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = index),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? AppColors.accent : AppColors.border, width: isSelected ? 1.5 : 1),
                  color: isSelected ? AppColors.accent.withValues(alpha: 0.08) : Colors.white,
                ),
                child: Icon(type.icon, color: isSelected ? AppColors.accent : AppColors.textGrey),
              ),
              const SizedBox(height: 6),
              Text(
                type.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.accent : AppColors.textGrey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ---------- SAVE ----------
  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          ),
          child: const Text(
            AppString.save,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
