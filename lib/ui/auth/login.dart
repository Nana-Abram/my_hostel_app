// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/ui/core/app_logger.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _redirectUrl;

  static const _bgColor = Color(0xFFF0EDEE);
  static const _fieldFill = Color(0xFFEAECF4);
  static const _labelColor = Color(0xFF555555);
  static const _subtitleColor = Color(0xFF888888);
  static const _headingColor = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouterState.of(context).uri;
      final redirect = uri.queryParameters['redirect'];
      if (redirect != null && redirect.isNotEmpty) {
        setState(() => _redirectUrl = redirect);
        AppLogger.info('Redirect URL detected: $_redirectUrl');
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      ref.read(authLoadingProvider.notifier).state = true;
      final authService = ref.read(authServiceProvider);
      await authService.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      _handleLoginSuccess();
    } catch (e) {
      _showError(e.toString());
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(fontSize: 13.sp, color: Colors.white)),
          backgroundColor: const Color(0xFFE57373),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          // margin: EdgeInsets.fromLTRB(30.w, 0, 30.w, 16.h),/
          width: 400.w,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static const _allowedRedirectPaths = {
    '/',
    '/dashboard',
    '/profile',
    '/student-dashboard',
    '/my-bookings',
  };

  bool _isAllowedRedirect(String path) {
    if (_allowedRedirectPaths.contains(path)) return true;
    if (path.startsWith('/hostel-details/')) return true;
    if (path.startsWith('/booking/')) return true;
    if (path.startsWith('/tabs/')) return true;
    return false;
  }

  void _handleLoginSuccess() {
    final redirect = _redirectUrl;
    if (redirect != null &&
        redirect.isNotEmpty &&
        _isAllowedRedirect(redirect)) {
      context.go(redirect);
    } else {
      GoRouter.of(context).goNamed('dashboard');
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      ref.read(authLoadingProvider.notifier).state = true;
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
      _handleLoginSuccess();
    } catch (e) {
      _showError(e.toString());
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) =>
          ForgotPasswordDialog(initialEmail: _emailController.text.trim()),
    );
  }

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
            child: Icon(Icons.home_work_rounded, size: 28.w, color: Colors.white),
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
          'Find your perfect hostel',
          style: TextStyle(fontSize: 13.sp, color: _subtitleColor),
        ),
      ],
    );
  }

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
              'Sign In',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: _headingColor,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Enter your credentials to continue.',
              style: TextStyle(fontSize: 13.sp, color: _subtitleColor),
            ),

            if (_redirectUrl != null) ...[
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: theme.colorScheme.primary, size: 15.w),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'You will be redirected after login',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 28.h),

            _buildField(
              theme: theme,
              controller: _emailController,
              label: 'Email',
              hint: 'your@email.com',
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            SizedBox(height: 18.h),

            _buildField(
              theme: theme,
              controller: _passwordController,
              label: 'Password',
              hint: '••••••••',
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

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotPasswordDialog,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                ),
                child: Text(
                  'Forgot Password?',
                  style:
                      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 8.h),

            _buildPrimaryButton(
              theme: theme,
              label: 'Sign In',
              isLoading: isLoading,
              onPressed: _loginWithEmail,
            ),
            SizedBox(height: 24.h),

            _buildDivider('or continue with'),
            SizedBox(height: 18.h),

            _buildGoogleButton(theme, isLoading),
            SizedBox(height: 24.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(fontSize: 13.sp, color: _subtitleColor),
                ),
                TextButton(
                  onPressed: () {
                    final param = _redirectUrl != null
                        ? '?redirect=${Uri.encodeComponent(_redirectUrl!)}'
                        : '';
                    context.go('/signup$param');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                  ),
                  child: Text(
                    'Sign Up',
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
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      icon: Icon(Icons.arrow_back, size: 15.w, color: _subtitleColor),
      label: Text(
        'Back to Home',
        style: TextStyle(fontSize: 13.sp, color: _subtitleColor),
      ),
      style: TextButton.styleFrom(foregroundColor: _subtitleColor),
    );
  }

  Widget _buildField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
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
        onPressed: isLoading ? null : _loginWithGoogle,
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

// ── Forgot Password Dialog ─────────────────────────────────────────────────

class ForgotPasswordDialog extends ConsumerStatefulWidget {
  const ForgotPasswordDialog({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  ConsumerState<ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _sending = false;
  bool _sent = false;
  String? _errorMessage;

  static const _fieldFill = Color(0xFFEAECF4);
  static const _subtitleColor = Color(0xFF888888);
  static const _headingColor = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _errorMessage = null;
    });
    try {
      final authService = ref.read(authServiceProvider);
      await authService.resetPassword(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _sent = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 40.h),
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: _sent ? _buildSuccessState(theme) : _buildInputState(theme),
      ),
    );
  }

  Widget _buildInputState(ThemeData theme) {
    return SizedBox(
      width: 400.w,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_reset_rounded,
                  color: theme.colorScheme.primary, size: 26.w),
            ),
            SizedBox(height: 18.h),
      
            Text(
              'Forgot Password?',
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _headingColor),
            ),
            SizedBox(height: 6.h),
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: TextStyle(fontSize: 13.sp, color: _subtitleColor, height: 1.5),
            ),
            SizedBox(height: 24.h),
      
            // Email field
            Text(
              'Email',
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF555555)),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              autofocus: widget.initialEmail.isEmpty,
              style: TextStyle(fontSize: 14.sp, color: _headingColor),
              decoration: InputDecoration(
                hintText: 'your@email.com',
                hintStyle:
                    TextStyle(fontSize: 13.sp, color: const Color(0xFFAAAAAA)),
                filled: true,
                fillColor: _fieldFill,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15.h, horizontal: 16.w),
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
      
            // Inline error (from service)
            if (_errorMessage != null) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  Icon(Icons.error_outline,
                      size: 14.w, color: theme.colorScheme.error),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                          fontSize: 12.sp, color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ],
      
            SizedBox(height: 24.h),
      
            // Send button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _sending ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: _sending
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Send Reset Link',
                        style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            SizedBox(height: 12.h),
      
            // Cancel
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: _subtitleColor),
                child: Text('Cancel',
                    style: TextStyle(fontSize: 13.sp, color: _subtitleColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(ThemeData theme) {
    final email = _emailController.text.trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.h),

        // Success icon
        Container(
          padding: EdgeInsets.all(18.w),
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mark_email_read_outlined,
              color: const Color(0xFF388E3C), size: 32.w),
        ),
        SizedBox(height: 20.h),

        Text(
          'Check your inbox!',
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: _headingColor),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10.h),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
                fontSize: 13.sp, color: _subtitleColor, height: 1.6),
            children: [
              const TextSpan(text: 'We sent a password reset link to\n'),
              TextSpan(
                text: email,
                style: const TextStyle(
                    color: _headingColor, fontWeight: FontWeight.w600),
              ),
              const TextSpan(
                  text:
                      '.\n\nCheck your spam folder if you don\'t see it within a few minutes.'),
            ],
          ),
        ),
        SizedBox(height: 28.h),

        // Done button
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text('Done',
                style:
                    TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
          ),
        ),
        SizedBox(height: 12.h),

        // Try different email
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _sent = false;
              _errorMessage = null;
            }),
            style: TextButton.styleFrom(foregroundColor: _subtitleColor),
            child: Text(
              'Try a different email',
              style: TextStyle(fontSize: 13.sp, color: _subtitleColor),
            ),
          ),
        ),
      ],
    );
  }
}
