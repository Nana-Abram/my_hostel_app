import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
      child: Column(
        children: [
          _buildHeaderSection(theme),
          SizedBox(height: 60.h),
          _buildContactMethods(context),
          SizedBox(height: 60.h),
          _buildContactForm(context),
          SizedBox(height: 40.h),
          _buildFAQSection(theme),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get In Touch',
          style: TextStyle(
            fontSize: 25.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'We\'re here to help you find your perfect student accommodation',
          style: TextStyle(
            fontSize: 14.sp,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30.h),
        Container(
          width: double.infinity,
          height: 500.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            image: const DecorationImage(
              image: AssetImage('assets/images/contact2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactMethods(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Choose your preferred method to reach out to us. Our team is always ready to assist you with any questions about hostels, bookings, or partnerships.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.6,
                ),
              ),
              SizedBox(height: 40.h),
              
              _buildContactCard(
                icon: Icons.phone,
                title: 'Call Us',
                subtitle: 'Available 24/7 for urgent inquiries',
                contact: '+233 12 345 6789', // Ghana number format
                onTap: () => _showPhoneDialog(context),
                context: context,
              ),
              SizedBox(height: 20.h),
              
              _buildContactCard(
                icon: Icons.email,
                title: 'Email Us',
                subtitle: 'We respond within 2 hours',
                contact: 'support@hostelhub.com',
                onTap: () => _showEmailDialog(context),
                context: context,
              ),
              SizedBox(height: 20.h),
              
              _buildContactCard(
                icon: Icons.chat,
                title: 'Live Chat',
                subtitle: 'Instant help from our team',
                contact: 'Start Chat',
                onTap: () => _showChatDialog(context),
                context: context,
              ),
              SizedBox(height: 20.h),
              
              _buildContactCard(
                icon: Icons.location_on,
                title: 'Visit Us',
                subtitle: 'Come say hello at our office',
                contact: 'University of Energy and Natural Resource, Sunyani',
                onTap: () => _showLocationDialog(context),
                context: context,
              ),
            ],
          ),
        ),
        SizedBox(width: 60.w),
        
        Expanded(
          child: Container(
            padding: EdgeInsets.all(30.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(isDark ? 0.08 : 0.05),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Office Hours',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 20.h),
                _buildOfficeHour('Monday - Friday', '9:00 AM - 6:00 PM'),
                _buildOfficeHour('Saturday', '10:00 AM - 4:00 PM'),
                _buildOfficeHour('Sunday', 'Emergency Support Only'),
                SizedBox(height: 30.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(isDark ? 0.14 : 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: theme.colorScheme.tertiary, size: 20.w),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'For urgent hostel emergencies outside office hours, call our 24/7 support line.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String contact,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 24.w, color: theme.colorScheme.primary),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    contact,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.w, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeHour(String day, String time) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

Widget _buildContactForm(BuildContext context) {
  final theme = Theme.of(context);
  return Container(
    padding: EdgeInsets.all(30.w),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: theme.shadowColor.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send us a Message',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Have a question? We\'ll get back to you quickly.',
          style: TextStyle(
            fontSize: 12.sp,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 25.h),
        
        // FORM FIELDS WITH VALIDATION
        _ContactForm(),
      ],
    ),
  );
}

  Widget _buildFAQSection(ThemeData theme) {
    final faqs = [
      {
        'question': 'How do I book a hostel through HostelHub?',
        'answer': 'Simply browse available hostels, select your preferred room, and complete the booking process through our secure platform.'
      },
      {
        'question': 'Are all hostels verified?',
        'answer': 'Yes! Every hostel on our platform undergoes a thorough verification process to ensure safety and quality standards.'
      },
      {
        'question': 'What payment methods do you accept?',
        'answer': 'We accept mobile money, credit/debit cards, and bank transfers for your convenience.'
      },
      {
        'question': 'Can I cancel my booking?',
        'answer': 'Cancellation policies vary by hostel. Check the specific hostel\'s cancellation policy before booking.'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 20.h),
        ...faqs.map((faq) => _buildFAQItem(
          question: faq['question']!,
          answer: faq['answer']!,
          theme: theme,
        )),
      ],
    );
  }

  Widget _buildFAQItem({required String question, required String answer, required ThemeData theme}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Web-compatible contact methods
  void _showPhoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call Us'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: +233 12 345 6789'),
            SizedBox(height: 10.h),
            Text('Copy the number to call us directly.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              // Copy to clipboard
              // You can add clipboard functionality here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Phone number copied to clipboard!')),
              );
            },
            child: Text('Copy Number'),
          ),
        ],
      ),
    );
  }

  void _showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Email Us'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: support@hostelhub.com'),
            SizedBox(height: 10.h),
            Text('Copy the email address to contact us.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Email copied to clipboard!')),
              );
            },
            child: Text('Copy Email'),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Our Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('University of Energy and Natural Resources'),
            Text('Sunyani, Ghana'),
            SizedBox(height: 10.h),
            Text('Visit us at our campus office.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Live Chat'),
        content: Text('Our live chat feature is coming soon! In the meantime, please use email or phone support.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // void _showSuccessDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Message Sent!'),
  //       content: Text('Thank you for reaching out! We\'ll get back to you within 2 hours.'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}



// Separate stateful widget for form validation
class _ContactForm extends StatefulWidget {
  const _ContactForm();

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  // Validation states
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Validation methods
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message is required';
    }
    if (value.trim().length < 10) {
      return 'Message must be at least 10 characters long';
    }
    return null;
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Form is valid - process the data
      setState(() {
        _isLoading = true;
      });

      // Simulate API call delay
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        
        // Show success dialog
        if (context.mounted) {
          _showSuccessDialog(context);
        }
        
        // Clear form
        _formKey.currentState!.reset();
        _firstNameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
      });
    }
  }

  void _showSuccessDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: theme.colorScheme.secondary, size: 24.w),
            SizedBox(width: 8.w),
            Text('Message Sent!'),
          ],
        ),
        content: Text('Thank you for your message! We\'ll get back to you within 2 hours.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // NAME ROW
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  validator: (value) => _validateRequired(value, 'First name'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  validator: (value) => _validateRequired(value, 'Last name'),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // EMAIL
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          SizedBox(height: 16.h),
          
          // SUBJECT
          TextFormField(
            controller: _subjectController,
            decoration: InputDecoration(
              labelText: 'Subject *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            validator: (value) => _validateRequired(value, 'Subject'),
          ),
          SizedBox(height: 16.h),
          
          // MESSAGE
          TextFormField(
            controller: _messageController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Your Message *',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
            validator: _validateMessage,
          ),
          SizedBox(height: 25.h),
          
          // SUBMIT BUTTON
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _submitForm(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Sending...',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Send Message',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            },
          ),
          
          // REQUIRED FIELD NOTE
          SizedBox(height: 12.h),
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return Text(
                '* Required fields',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}