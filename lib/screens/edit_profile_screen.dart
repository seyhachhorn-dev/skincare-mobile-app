import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/widgets/app_snackbar.dart';

/// Simple edit form for the profile's name/email/avatar. Returns a
/// map of the updated values via [Navigator.pop] when saved.
class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String? imagePath;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
    this.imagePath,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController = TextEditingController(text: widget.name);
  late final TextEditingController _emailController = TextEditingController(text: widget.email);
  final _formKey = GlobalKey<FormState>();

  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // close the source-picker sheet
    try {
      final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (picked == null || !mounted) return;
      setState(() => _imagePath = picked.path);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        title: 'Unavailable',
        message: "Couldn't open ${source == ImageSource.camera ? 'camera' : 'gallery'} on this device",
      );
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined, color: AppColors.textDark),
                title: const Text("Take Photo"),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.textDark),
                title: const Text("Choose from Gallery"),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              if (_imagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text("Remove Photo", style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    setState(() => _imagePath = null);
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'imagePath': _imagePath,
    });
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: _buildAvatarPicker()),
                      const SizedBox(height: 28),
                      _buildField(
                        label: AppString.name,
                        controller: _nameController,
                        icon: Icons.person_outline_rounded,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? "Name can't be empty" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: AppString.email,
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Email can't be empty";
                          if (!value.contains('@')) return "Enter a valid email";
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          ),
                          child: const Text(
                            AppString.saveChanges,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
          const Expanded(
            child: Text(
              AppString.editProfile,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ---------- AVATAR PICKER ----------
  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.accent.withValues(alpha: 0.15),
            backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
            child: _imagePath == null
                ? const Icon(Icons.person_outline_rounded, size: 50, color: AppColors.accent)
                : null,
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textGrey),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(prefixIcon: Icon(icon, color: AppColors.textGrey)),
        ),
      ],
    );
  }
}
