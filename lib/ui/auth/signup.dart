
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pinController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscurePin = true;
  UserRole _selectedRole = UserRole.student;

  static const _bgColor = Color(0xFFF0EDEE);
  static const _fieldFill = Color(0xFFEAECF4);
  static const _labelColor = Color(0xFF555555);
  static const _subtitleColor = Color(0xFF888888);
  static const _headingColor = Color(0xFF1A1A2E);

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // ── Validators ─────────────────────────────────────────────────────────────

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your full name';
    if (value.trim().split(' ').length < 2) {
      return 'Please enter first and last name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? _validatePin(String? value) {
    if (_selectedRole == UserRole.student) return null;
    if (value == null || value.isEmpty) return 'Please enter the security PIN';
    if (value.length != 4) return 'PIN must be 4 digits';
    return null;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      ref.read(authLoadingProvider.notifier).state = true;
      final authService = ref.read(authServiceProvider);
      await authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        role: _selectedRole,
        pin: _selectedRole != UserRole.student
            ? _pinController.text.trim()
            : null,
      );
      GoRouter.of(context).goNamed('login');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created! Please sign in.'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
          content: Text(e.toString(), style: TextStyle(fontSize: 13.sp, color: Colors.white)),
          backgroundColor: const Color(0xFFE57373),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          // margin: EdgeInsets.fromLTRB(30.w, 0, 30.w, 16.h),/
          width: 400.w,
          duration: const Duration(seconds: 3),
        ),
        );
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _signUpWithGoogle() async {
    try {
      ref.read(authLoadingProvider.notifier).state = true;
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
      GoRouter.of(context).goNamed('dashboard');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Successfully signed in with Google!'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign up failed: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(theme),
                  SizedBox(height: 32.h),
                  _buildFormCard(theme, isLoading),
                  SizedBox(height: 24.h),
                  _buildBackLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.home_work_rounded, size: 28.w, color: Colors.white),
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          'HOSTELHUB',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Join thousands of students on HostelHub',
          style: TextStyle(fontSize: 13.sp, color: _subtitleColor),
        ),
      ],
    );
  }

  // ── Form card ──────────────────────────────────────────────────────────────

  Widget _buildFormCard(ThemeData theme, bool isLoading) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: _headingColor,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Fill in your details to get started.',
              style: TextStyle(fontSize: 13.sp, color: _subtitleColor),
            ),
            SizedBox(height: 24.h),

            // Role selector
            Text(
              'I am a:',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: _labelColor,
              ),
            ),
            SizedBox(height: 10.h),
            _buildRoleSelector(theme),

            // PIN warning for privileged roles
            if (_selectedRole != UserRole.student) ...[
              SizedBox(height: 12.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16.w, color: theme.colorScheme.error),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '${_selectedRole.displayName} accounts require a security PIN.',
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 22.h),

            _buildField(
              theme: theme,
              controller: _fullNameController,
              label: 'Full Name',
              hint: 'John Doe',
              validator: _validateFullName,
            ),
            SizedBox(height: 16.h),

            _buildField(
              theme: theme,
              controller: _emailController,
              label: 'Email Address',
              hint: 'your@email.com',
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            SizedBox(height: 16.h),

            _buildField(
              theme: theme,
              controller: _phoneController,
              label: 'Phone Number (Optional)',
              hint: '+233 XX XXX XXXX',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.h),

            _buildField(
              theme: theme,
              controller: _passwordController,
              label: 'Password',
              hint: 'Min. 6 characters',
              obscure: _obscurePassword,
              validator: _validatePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20.w,
                  color: _subtitleColor,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            SizedBox(height: 16.h),

            _buildField(
              theme: theme,
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Re-enter your password',
              obscure: _obscureConfirmPassword,
              validator: _validateConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20.w,
                  color: _subtitleColor,
                ),
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),

            if (_selectedRole != UserRole.student) ...[
              SizedBox(height: 16.h),
              _buildField(
                theme: theme,
                controller: _pinController,
                label: 'Security PIN',
                hint: '4-digit PIN',
                obscure: _obscurePin,
                keyboardType: TextInputType.number,
                validator: _validatePin,
                maxLength: 4,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePin
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20.w,
                    color: _subtitleColor,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePin = !_obscurePin),
                ),
              ),
            ],
            SizedBox(height: 20.h),

            // Terms notice
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14.w, color: _subtitleColor),
                SizedBox(width: 8.w),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _subtitleColor,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'By signing up you agree to our '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            _buildPrimaryButton(
              theme: theme,
              label: 'Create Account',
              isLoading: isLoading,
              onPressed: _signUpWithEmail,
            ),
            SizedBox(height: 22.h),

            _buildDivider('or sign up with'),
            SizedBox(height: 18.h),

            _buildGoogleButton(theme, isLoading),
            SizedBox(height: 24.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style:
                      TextStyle(fontSize: 13.sp, color: _subtitleColor),
                ),
                TextButton(
                  onPressed: () => GoRouter.of(context).goNamed('login'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                  ),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                        fontSize: 13.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackLink() {
    return TextButton.icon(
      onPressed: () => GoRouter.of(context).goNamed('home'),
      icon: Icon(Icons.arrow_back, size: 15.w, color: _subtitleColor),
      label: Text(
        'Back to Home',
        style: TextStyle(fontSize: 13.sp, color: _subtitleColor),
      ),
      style: TextButton.styleFrom(foregroundColor: _subtitleColor),
    );
  }

  // ── Role selector ──────────────────────────────────────────────────────────

  Widget _buildRoleSelector(ThemeData theme) {
    return Row(
      children: UserRole.values.map((role) {
        final isSelected = _selectedRole == role;
        final icon = switch (role) {
          UserRole.student => Icons.school_outlined,
          UserRole.hostelOwner => Icons.home_work_outlined,
          UserRole.admin => Icons.admin_panel_settings_outlined,
        };
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedRole = role;
                _pinController.clear();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding:
                  EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.08)
                    : _fieldFill,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 20.w,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : _subtitleColor,
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    role.displayName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : _headingColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Shared UI builders ─────────────────────────────────────────────────────

  Widget _buildField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: _labelColor),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          maxLength: maxLength,
          buildCounter: maxLength != null
              ? (_, {required currentLength, required isFocused, maxLength}) =>
                  const SizedBox.shrink()
              : null,
          style: TextStyle(fontSize: 14.sp, color: _headingColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 13.sp, color: const Color(0xFFAAAAAA)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: _fieldFill,
            contentPadding:
                EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide:
                  BorderSide(color: theme.colorScheme.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required ThemeData theme,
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.65),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r)),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider(String label) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFDDDDDD))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: _subtitleColor),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFDDDDDD))),
      ],
    );
  }

  Widget _buildGoogleButton(ThemeData theme, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: isLoading ? null : _signUpWithGoogle,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.2),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                'G',
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Continue with Google',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _headingColor),
            ),
          ],
        ),
      ),
    );
  }
}
