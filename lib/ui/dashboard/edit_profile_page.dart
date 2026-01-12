import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/backend/service/auth_service.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final UserModel currentUser;
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
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;

  PlatformFile? _selectedImage;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.currentUser.fullName,
    );
    _emailController = TextEditingController(text: widget.currentUser.email);
    _phoneController = TextEditingController(
      text: widget.currentUser.phone ?? '',
    );
    _bioController = TextEditingController(text: widget.currentUser.bio ?? '');
    _locationController = TextEditingController(
      text: widget.currentUser.location ?? '',
    );
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

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.isOwner;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: isOwner ? _buildAppBar() : null,
      body: _isLoading
          ? _buildLoadingState()
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const IconAndTextWidget(
                      icon: Icons.arrow_back_ios,
                      text: 'Back to home',
                      iconColor: Colors.blueGrey,
                      isBackArrow: true,
                    ),
                    SizedBox(height: 30.h),
                    // PROFILE PICTURE SECTION
                    _buildProfilePictureSection(),
                    SizedBox(height: 32.h),

                    // PERSONAL INFORMATION
                    _buildSection(
                      title: 'Personal Information',
                      icon: Icons.person_outline,
                      children: [
                        _buildTextField(
                          controller: _fullNameController,
                          label: 'Full Name',
                          hintText: 'Enter your full name',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            if (value.length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hintText: 'Enter your email address',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email address';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hintText: 'Enter your phone number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(
                                r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid phone number';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // ADDITIONAL INFORMATION
                    _buildSection(
                      title: 'Additional Information',
                      icon: Icons.info_outline,
                      children: [
                        _buildTextField(
                          controller: _locationController,
                          label: 'Location',
                          hintText: 'Enter your location',
                          icon: Icons.location_on,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                value.length < 3) {
                              return 'Location must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildBioField(),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // SAVE BUTTONS
                    _buildSaveButtons(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Edit Profile',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      actions: [
        if (!_isLoading)
          IconButton(
            icon: Icon(Icons.save, color: AppColors.blueColor),
            onPressed: _saveProfile,
            tooltip: 'Save Changes',
          ),
      ],
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60.w,
              backgroundColor: Colors.grey[200],
              child: ClipOval(child: _buildProfileImage()),
            ),
            if (_isUploadingImage)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.blueColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                ),
                child: IconButton(
                  icon: Icon(Icons.camera_alt, size: 16.w, color: Colors.white),
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
          style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey),
        ),
        if (_selectedImage != null) ...[
          SizedBox(height: 8.h),
          Text(
            'New image selected',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.blueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileImage() {
    // Show selected image if available
    if (_selectedImage != null) {
      // For web, we can use the bytes directly
      if (_selectedImage!.bytes != null) {
        return Image.memory(_selectedImage!.bytes!, fit: BoxFit.cover);
      }
    }

    // Show current profile image from Firebase
    if (widget.currentUser.profileImage != null &&
        widget.currentUser.profileImage!.isNotEmpty) {
      return SizedBox(
        width: 120.w,
        height: 120.w,
        child: ImageNetwork(
          image: widget.currentUser.profileImage!,
          height: 120.w,
          width: 120.w,
          onError: _buildPlaceholderAvatar(),
          fitAndroidIos: BoxFit.cover,
          fitWeb: BoxFitWeb.cover,
        ),
      );
    }

    // Show placeholder
    return _buildPlaceholderAvatar();
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      color: AppColors.blueColor.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.person,
          size: 40.w,
          color: AppColors.blueColor.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SECTION HEADER
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, size: 20.w, color: AppColors.blueColor),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // SECTION CONTENT
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
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
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
              prefixIcon: Icon(icon, size: 20.w, color: Colors.blueGrey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 14.h,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: _bioController,
            maxLines: 4,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Tell us a little about yourself...',
              hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
              alignLabelWithHint: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12.w),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length > 500) {
                return 'Bio must be less than 500 characters';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${_bioController.text.length}/500 characters',
          style: TextStyle(
            fontSize: 11.sp,
            color: _bioController.text.length > 500
                ? Colors.red
                : Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.blueColor),
          SizedBox(height: 16.h),
          Text(
            'Updating profile...',
            style: TextStyle(fontSize: 16.sp, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  // File Picker Method for Web - Fixed
  Future<void> _showImagePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Validate file size (optional - limit to 5MB)
        if (file.size > 5 * 1024 * 1024) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image size should be less than 5MB')),
            );
          }
          return;
        }

        // Validate file type
        if (![
          'jpg',
          'jpeg',
          'png',
          'gif',
          'webp',
        ].contains(file.extension?.toLowerCase())) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please select a valid image file (JPG, PNG, GIF, WEBP)',
                ),
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImage = file;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Image selected: ${file.name}')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final storage = FirebaseStorage.instance;
      final fileName =
          'profile_${widget.currentUser.id}_${DateTime.now().millisecondsSinceEpoch}';
      final reference = storage.ref().child('profile_pictures/$fileName');

      // For web, we can upload the bytes directly
      if (_selectedImage!.bytes != null) {
        final task = await reference.putData(
          _selectedImage!.bytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        final downloadUrl = await task.ref.getDownloadURL();
        return downloadUrl;
      }

      return null;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      return null;
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  // Save Profile Method with Auto-Refresh
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? newProfileImageUrl;

      // Upload new image if selected
      if (_selectedImage != null) {
        newProfileImageUrl = await _uploadImage();
      }

      // Update user data in Firebase
      final usersService = AuthService();
      await usersService.updateUserProfile(
        userId: widget.currentUser.id,
        updates: {
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          if (_phoneController.text.isNotEmpty) 'phone': _phoneController.text,
          if (_bioController.text.isNotEmpty) 'bio': _bioController.text,
          if (_locationController.text.isNotEmpty)
            'location': _locationController.text,
          if (newProfileImageUrl != null) 'profileImage': newProfileImageUrl,
          'updatedAt': DateTime.now(),
        },
      );

      // AUTO-REFRESH: Update the auth provider immediately
      final updatedUser = widget.currentUser.copyWith(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        location: _locationController.text.isEmpty
            ? null
            : _locationController.text,
        profileImage: newProfileImageUrl ?? widget.currentUser.profileImage,
      );

      // Method 1: Update the entire user object
      ref.read(authProvider.notifier).updateUser(updatedUser);

      // Method 2: Or update specific fields
      // ref.read(authProvider.notifier).updateUserFields({
      //   'fullName': _fullNameController.text,
      //   'email': _emailController.text,
      //   'phoneNumber': _phoneController.text.isEmpty ? null : _phoneController.text,
      //   'bio': _bioController.text.isEmpty ? null : _bioController.text,
      //   'location': _locationController.text.isEmpty ? null : _locationController.text,
      //   'profileImage': newProfileImageUrl ?? widget.currentUser.profileImage,
      // });

      // Method 3: Force refresh from Firebase (if you want latest data)
      // await ref.read(authProvider.notifier).refreshUser();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
