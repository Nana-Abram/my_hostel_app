// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/core/app_logger.dart';
import 'package:my_hostel_app/ui/widgets/modern/modern_widgets.dart';

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

  // Store the redirect URL from query parameters
  String? _redirectUrl;

  @override
  void initState() {
    super.initState();
    
    // Extract redirect URL from query parameters after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouterState.of(context).uri;
      final redirect = uri.queryParameters['redirect'];
      
      if (redirect != null && redirect.isNotEmpty) {
        setState(() {
          _redirectUrl = redirect;
        });
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
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _loginWithEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        ref.read(authLoadingProvider.notifier).state = true;

        final authService = ref.read(authServiceProvider);
        await authService.loginWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // SUCCESS: Handle redirect or go to dashboard
        _handleLoginSuccess();

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      } finally {
        ref.read(authLoadingProvider.notifier).state = false;
      }
    }
  }

  void _handleLoginSuccess() {
    if (_redirectUrl != null && _redirectUrl!.isNotEmpty) {
      // Redirect back to the original booking page
      context.go(_redirectUrl!);
    } else {
      //  No redirect, go to dashboard
      GoRouter.of(context).goNamed('dashboard');
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      ref.read(authLoadingProvider.notifier).state = true;

      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();

      // Handle success
      _handleLoginSuccess();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign in failed: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(context: context, builder: (context) => ForgotPasswordDialog());
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            // Use pop to go back, or go home if no back stack
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.secondary.withOpacity(0.6),
              theme.colorScheme.tertiary.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
              child: Container(
                constraints: BoxConstraints(maxWidth: 500.w),
                padding: EdgeInsets.all(40.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // HEADER
                    Icon(
                      Icons.lock_person_rounded,
                      size: 60.sp,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sign in to continue your hostel search',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    // Show redirect info if applicable
                    if (_redirectUrl != null) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'You will be redirected after login',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    SizedBox(height: 40.h),

                    // LOGIN FORM
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'Enter your email',
                              prefixIcon: Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          SizedBox(height: 20.h),

                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: Icon(Icons.lock_outline),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: _validatePassword,
                          ),
                          SizedBox(height: 16.h),

                          // FORGOT PASSWORD
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPasswordDialog,
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(color: AppColors.blueColor),
                              ),
                            ),
                          ),
                          SizedBox(height: 30.h),

                          // LOGIN BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _loginWithEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blueColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 2,
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 30.h),

                          // DIVIDER
                          Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Text(
                                  'Or continue with',
                                  style: TextStyle(color: Colors.blueGrey),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          SizedBox(height: 30.h),

                          // SOCIAL LOGIN
                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: OutlinedButton(
                              onPressed: isLoading ? null : _loginWithGoogle,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                                backgroundColor: theme.colorScheme.surface,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  EnhancedCachedImage(
                                    imageUrl: 'https://www.google.com/favicon.ico',
                                    width: 20.w,
                                    height: 20.h,
                                    showShimmer: false,
                                    errorWidget: Icon(
                                      Icons.login,
                                      size: 20.sp,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 40.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.blueGrey),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Pass redirect URL to signup if exists
                                  final redirectParam = _redirectUrl != null 
                                    ? '?redirect=${Uri.encodeComponent(_redirectUrl!)}'
                                    : '';
                                  context.go('/signup$redirectParam');
                                },
                                child: Text(
                                  'SignUp',
                                  style: TextStyle(
                                    color: AppColors.blueColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Forgot Password Dialog (keep this the same)
class ForgotPasswordDialog extends ConsumerWidget {
  final _emailController = TextEditingController();

  ForgotPasswordDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('Reset Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter your email address and we\'ll send you a password reset link.',
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final email = _emailController.text.trim();
            if (email.isEmpty) return;

            try {
              final authService = ref.read(authServiceProvider);
              await authService.resetPassword(email);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset link sent to $email')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}'))
              );
            }
          },
          child: Text('Send Link'),
        ),
      ],
    );
  }
}