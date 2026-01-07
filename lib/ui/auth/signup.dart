import 'dart:ui';

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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().split(' ').length < 2) {
      return 'Please enter your full name (first and last name)';
    }
    return null;
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
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _signUpWithEmail() async {
    if (_formKey.currentState!.validate()) {
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
        );

        // Success - show verification message
        GoRouter.of(context).goNamed('login');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Account created successfully!'),
                SizedBox(height: 4.h),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50), // green
            duration: Duration(seconds: 5),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: ${e.toString()}'),
            backgroundColor: const Color(0xFFF44336), // red
          ),
        );
      } finally {
        ref.read(authLoadingProvider.notifier).state = false;
      }
    }
  }

  // Future<void> _signUpWithGoogle() async {
  //   try {
  //     ref.read(authLoadingProvider.notifier).state = true;

  //     // final authService = ref.read(authServiceProvider);
  //     // await authService.signInWithGoogle();

  //     Navigator.pop(context);
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Google sign up failed: ${e.toString()}'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } finally {
  //     ref.read(authLoadingProvider.notifier).state = false;
  //   }
  // }

  void _navigateToLogin() {
    GoRouter.of(context).goNamed('login');
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
          onPressed:() {
            GoRouter.of(context).goNamed('home');
          },
        ),
      ),
      body: Stack(
        children: [
         Stack(
  children: [
    SizedBox(
      width: double.infinity,
      child: Image.asset(
        "assets/images/h1.jpg",
        fit: BoxFit.cover,
      ),
    ),

    // Blur effect
    Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: const Color(0xFF000000).withOpacity(0.2), // light dim
        ),
      ),
    ),
  ],
),

          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Center(
              child: Container(
                margin: EdgeInsets.all(20.w),
                width: 500.w,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.1), blurRadius: 6)],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    SizedBox(height: 20.h),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Join thousands of students finding their perfect hostel',
                      style: TextStyle(fontSize: 16.sp, color: theme.colorScheme.onSurfaceVariant),
                    ),
                    SizedBox(height: 40.h),

                    // SIGNUP FORM
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // ROLE SELECTION
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'I am a:',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Wrap(
                                  spacing: 12.w,
                                  runSpacing: 12.h,
                                  children: UserRole.values.map((role) {
                                    final isSelected = _selectedRole == role;
                                    return ChoiceChip(
                                      label: Text(
                                        role.displayName,
                                        style: TextStyle(
                                          color: isSelected
                                              ? theme.colorScheme.onPrimary
                                              : theme.colorScheme.onSurface,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedRole = role;
                                        });
                                      },
                                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                      selectedColor: theme.colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),

                          TextFormField(
                            controller: _fullNameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name *',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            validator: _validateFullName,
                          ),
                          SizedBox(height: 20.h),

                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address *',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          SizedBox(height: 20.h),

                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number (Optional)',
                              prefixIcon: Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 20.h),

                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password *',
                              prefixIcon: Icon(Icons.lock_outline),
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
                          SizedBox(height: 20.h),

                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password *',
                              prefixIcon: Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            obscureText: _obscureConfirmPassword,
                            validator: _validateConfirmPassword,
                          ),
                          SizedBox(height: 30.h),

                          // TERMS AGREEMENT
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16.w,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            'By signing up, you agree to our ',
                                      ),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30.h),

                          // SIGNUP BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _signUpWithEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
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
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    )
                                  : Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // DIVIDER
                          Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Text(
                                  'Or sign up with',
                                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          // GOOGLE SIGN UP
                          // SizedBox(
                          //   width: double.infinity,
                          //   height: 56.h,
                          //   child: OutlinedButton(
                          //     onPressed: isLoading ? null : _signUpWithGoogle,
                          //     style: OutlinedButton.styleFrom(
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(12.r),
                          //       ),
                          //       side: BorderSide(color: Colors.grey.shade300),
                          //     ),
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         Image.asset(
                          //           'assets/images/contact1',
                          //           width: 24.w,
                          //           height: 24.w,
                          //           errorBuilder: (context, error, stackTrace) {
                          //             return Icon(
                          //               Icons.account_circle,
                          //               size: 24.w,
                          //             );
                          //           },
                          //         ),
                          //         SizedBox(width: 12.w),
                          //         Text(
                          //           'Continue with Google',
                          //           style: TextStyle(
                          //             fontSize: 16.sp,
                          //             color: Colors.black87,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(height: 30.h),

                          // LOGIN LINK
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                              ),
                              TextButton(
                                onPressed: _navigateToLogin,
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
