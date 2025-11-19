import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/routes/app_routes.dart';

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
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
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
        
        // Success - authStateProvider will handle the state change
        // Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
        Navigator.pushNamed(context,AppRoutes.dashboardScreen);
        
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        ref.read(authLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      ref.read(authLoadingProvider.notifier).state = true;
      
      // final authService = ref.read(authServiceProvider);
      // await authService.signInWithGoogle();
      
      Navigator.pop(context);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign in failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => ForgotPasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
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
          color: Colors.black.withOpacity(0.2), // light dim
        ),
      ),
    ),
  ],
),
      SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(50.w),
            width: 0.4.sw,
            padding: EdgeInsets.all(20),
             decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                SizedBox(height: 20.h),
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Sign in to continue your hostel search',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.blueGrey,
                  ),
                ),
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
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google.png',
                                width: 24.w,
                                height: 24.w,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.account_circle, size: 24.w);
                                },
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black87,
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
                                  Navigator.pushNamed(context,AppRoutes.signUpScreen);
                                },
                                child: Text(
                                  'Sign In',
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
    
        ],
      )
  
    );
  }
}

// Forgot Password Dialog
class ForgotPasswordDialog extends ConsumerWidget {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('Reset Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Enter your email address and we\'ll send you a password reset link.'),
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
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final email = _emailController.text.trim();
            if (email.isEmpty) return;
            
            try {
              final authService = ref.read(authServiceProvider);
              await authService.resetPassword(email);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset link sent to $email')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
            }
          },
          child: Text('Send Link'),
        ),
      ],
    );
  }
}