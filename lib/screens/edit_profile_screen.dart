import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/services/auth_service.dart';
import 'package:skincare_app/widgets/app_snackbar.dart';

/// Edit form for the profile's name/email/avatar. Saves via
/// PATCH /profile and returns the confirmed server values (not just
/// local input) via [Navigator.pop] when saved.
class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String? avatarUrl;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController = TextEditingController(text: widget.name);
  late final TextEditingController _emailController = TextEditingController(text: widget.email);
  final _formKey = GlobalKey<FormState>();

  // A freshly picked local file awaiting upload. Until Save succeeds,
  // the server-side avatar (widget.avatarUrl) is unchanged.
  File? _pickedImage;
  bool _isSaving = false;

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

      // Let the user pan/zoom/rotate before it becomes the avatar — a
      // straight center-crop to a circle otherwise tends to cut off the
      // top of the subject's head on portrait photos.
      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Adjust Photo',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColors.primary,
            cropStyle: CropStyle.circle,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Adjust Photo',
            cropStyle: CropStyle.circle,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
        ],
      );
      if (cropped == null || !mounted) return;

      setState(() => _pickedImage = File(cropped.path));
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
              if (_pickedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text("Remove Photo", style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    setState(() => _pickedImage = null);
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);
    final response = await AuthService.instance.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      avatar: _pickedImage,
    );
    if (!mounted) return;

    if (!response.status || response.user == null) {
      setState(() => _isSaving = false);
      AppSnackBar.error(
        context,
        title: 'Update failed',
        message: response.message.isNotEmpty ? response.message : 'Please try again.',
      );
      return;
    }

    Navigator.pop(context, {
      'name': response.user!.name,
      'email': response.user!.email,
      'avatarUrl': response.user!.avatarUrl,
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
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
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
    final ImageProvider? preview = _pickedImage != null
        ? FileImage(_pickedImage!)
        : (widget.avatarUrl != null ? NetworkImage(widget.avatarUrl!) : null);

    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.accent.withValues(alpha: 0.15),
            backgroundImage: preview,
            child: preview == null
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
