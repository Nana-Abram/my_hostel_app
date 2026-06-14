import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/backend/service/auth_service.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final UserModel currentUser;
  /// When true the page is opened as a standalone route (e.g. from the
  /// dashboard header) and renders its own AppBar. When false it is embedded
  /// inside a tab whose parent already supplies an AppBar.
  final bool isOwner;

  const EditProfilePage({
    super.key,
    required this.currentUser,
    this.isOwner = true,
  });

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;

  PlatformFile? _selectedImage;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.currentUser.fullName);
    _emailController = TextEditingController(text: widget.currentUser.email);
    _phoneController = TextEditingController(text: widget.currentUser.phone ?? '');
    _bioController = TextEditingController(text: widget.currentUser.bio ?? '');
    _locationController = TextEditingController(text: widget.currentUser.location ?? '');

    // Rebuild when bio length changes so the character counter stays current
    _bioController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.isOwner ? _buildAppBar(theme) : null,
      body: _isLoading
          ? _buildLoadingState(theme)
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 8.h),
                    _buildProfilePictureSection(theme),
                    SizedBox(height: 32.h),
                    _buildSection(
                      theme: theme,
                      title: 'Personal Information',
                      icon: Icons.person_outline,
                      children: [
                        _buildTextField(
                          theme: theme,
                          controller: _fullNameController,
                          label: 'Full Name',
                          hintText: 'Enter your full name',
                          icon: Icons.person,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter your full name';
                            if (v.length < 2) return 'Name must be at least 2 characters';
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          theme: theme,
                          controller: _emailController,
                          label: 'Email Address',
                          hintText: 'Enter your email address',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter your email address';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          theme: theme,
                          controller: _phoneController,
                          label: 'Phone Number',
                          hintText: 'Enter your phone number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              if (!RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$').hasMatch(v)) {
                                return 'Please enter a valid phone number';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    _buildSection(
                      theme: theme,
                      title: 'Additional Information',
                      icon: Icons.info_outline,
                      children: [
                        _buildTextField(
                          theme: theme,
                          controller: _locationController,
                          label: 'Location',
                          hintText: 'Enter your location',
                          icon: Icons.location_on,
                          validator: (v) {
                            if (v != null && v.isNotEmpty && v.length < 3) {
                              return 'Location must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildBioField(theme),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    _buildSaveButtons(theme),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Edit Profile',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      actions: [
        if (!_isLoading)
          IconButton(
            icon: Icon(Icons.save, color: theme.colorScheme.primary),
            onPressed: _saveProfile,
            tooltip: 'Save Changes',
          ),
      ],
    );
  }

  // ── Profile picture ───────────────────────────────────────────────────────

  Widget _buildProfilePictureSection(ThemeData theme) {
    final double avatarSize = 120.w;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Circle avatar with properly constrained image
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceVariant,
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildProfileImage(theme, avatarSize),
            ),
            // Upload overlay
            if (_isUploadingImage)
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            // Camera button anchored to bottom-right of the circle
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.surface, width: 2.w),
                ),
                child: IconButton(
                  icon: Icon(Icons.camera_alt, size: 16.w, color: theme.colorScheme.onPrimary),
                  onPressed: _isUploadingImage ? null : _showImagePicker,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          'Tap to change photo',
          style: TextStyle(
            fontSize: 12.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        if (_selectedImage != null) ...[
          SizedBox(height: 8.h),
          Text(
            'New image selected',
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileImage(ThemeData theme, double size) {
    if (_selectedImage?.bytes != null) {
      return Image.memory(
        _selectedImage!.bytes!,
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    }

    final imageUrl = widget.currentUser.profileImage;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ImageNetwork(
        key: ValueKey(imageUrl),
        image: imageUrl,
        height: size,
        width: size,
        fitAndroidIos: BoxFit.cover,
        fitWeb: BoxFitWeb.cover,
        onError: _buildPlaceholderAvatar(theme, size),
      );
    }

    return _buildPlaceholderAvatar(theme, size);
  }

  Widget _buildPlaceholderAvatar(ThemeData theme, double size) {
    return Container(
      width: size,
      height: size,
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          Icons.person,
          size: 40.w,
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  // ── Section card ──────────────────────────────────────────────────────────

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, size: 20.w, color: theme.colorScheme.primary),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // ── Text field ────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              prefixIcon: Icon(icon, size: 20.w,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  // ── Bio field ─────────────────────────────────────────────────────────────

  Widget _buildBioField(ThemeData theme) {
    final charCount = _bioController.text.length;
    final isOverLimit = charCount > 500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isOverLimit
                  ? theme.colorScheme.error
                  : theme.colorScheme.outline.withValues(alpha: 0.4),
            ),
          ),
          child: TextFormField(
            controller: _bioController,
            maxLines: 4,
            style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Tell us a little about yourself...',
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              alignLabelWithHint: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12.w),
            ),
            validator: (v) {
              if (v != null && v.isNotEmpty && v.length > 500) {
                return 'Bio must be less than 500 characters';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 4.h),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$charCount/500',
            style: TextStyle(
              fontSize: 11.sp,
              color: isOverLimit
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: isOverLimit ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  // ── Save buttons ──────────────────────────────────────────────────────────

  Widget _buildSaveButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: BorderSide(color: theme.colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Loading state ─────────────────────────────────────────────────────────

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          SizedBox(height: 16.h),
          Text(
            'Updating profile...',
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ── Image picker ──────────────────────────────────────────────────────────

  Future<void> _showImagePicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      if (file.size > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image size should be less than 5MB')),
        );
        return;
      }

      final ext = file.extension?.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a valid image file (JPG, PNG, GIF, WEBP)'),
          ),
        );
        return;
      }

      setState(() => _selectedImage = file);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image selected: ${file.name}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  // ── Image upload ──────────────────────────────────────────────────────────

  Future<String?> _uploadImage() async {
    if (_selectedImage?.bytes == null) return null;

    setState(() => _isUploadingImage = true);

    try {
      final fileName =
          'profile_${widget.currentUser.id}_${DateTime.now().millisecondsSinceEpoch}';
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures/$fileName');

      final task = await ref.putData(
        _selectedImage!.bytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await task.ref.getDownloadURL();
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  // ── Delete old profile image from Storage ────────────────────────────────

  Future<void> _deleteOldProfileImage(String oldUrl) async {
    // Only attempt deletion for Firebase Storage URLs — skip external URLs
    // (e.g. Google/Facebook profile photos) that refFromURL cannot resolve.
    if (!oldUrl.contains('firebasestorage.googleapis.com')) return;
    try {
      await FirebaseStorage.instance.refFromURL(oldUrl).delete();
    } catch (e) {
      debugPrint('⚠️ Could not delete old profile image: $e');
      // Non-fatal — don't block the profile update if deletion fails
    }
  }

  // ── Save profile ──────────────────────────────────────────────────────────

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final oldImageUrl = widget.currentUser.profileImage;
      final newProfileImageUrl =
          _selectedImage != null ? await _uploadImage() : null;

      // Delete old Storage file after new one is confirmed uploaded
      if (newProfileImageUrl != null &&
          oldImageUrl != null &&
          oldImageUrl.isNotEmpty) {
        await _deleteOldProfileImage(oldImageUrl);
      }

      await AuthService().updateUserProfile(
        userId: widget.currentUser.id,
        updates: {
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          if (_phoneController.text.isNotEmpty) 'phone': _phoneController.text,
          if (_bioController.text.isNotEmpty) 'bio': _bioController.text,
          if (_locationController.text.isNotEmpty) 'location': _locationController.text,
          if (newProfileImageUrl != null) 'profileImage': newProfileImageUrl,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      final updatedUser = widget.currentUser.copyWith(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        profileImage: newProfileImageUrl ?? widget.currentUser.profileImage,
      );

      ref.read(authProvider.notifier).updateUser(updatedUser);

      // Clear the local file selection so the widget switches to the new
      // network URL immediately — without this it keeps showing Image.memory
      // and other parts of the app see the stale old URL until restart.
      setState(() => _selectedImage = null);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      // isOwner: false means the page is embedded in a tab — nothing to pop.
      // When true (standalone route), defer the pop to the next frame so
      // Riverpod's rebuild from updateUser() completes before navigation locks the navigator.
      if (widget.isOwner) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context, updatedUser);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
