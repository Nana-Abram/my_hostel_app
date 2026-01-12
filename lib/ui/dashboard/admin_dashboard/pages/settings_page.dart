import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/dashboard/edit_profile_page.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key, this.isAppBarVisible = false});
  final bool isAppBarVisible;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _darkMode = false;
  String _language = 'English';
  String _currency = 'GHS - Ghanaian Cedi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isAppBarVisible
          ? AppBar(
              title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.grey[50],
              foregroundColor: Colors.black,
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const IconAndTextWidget(
              icon: Icons.arrow_back_ios,
              text: 'Back to home',
              iconColor: Colors.blueGrey,
              isBackArrow: true,
            ),
            SizedBox(height: 24.h),
            // HEADER
            _buildHeader(),
            SizedBox(height: 24.h),
      
            // ACCOUNT SETTINGS
            _buildSection(
              title: 'Account Settings',
              icon: Icons.person_outline,
              children: [
                _buildSettingItem(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: _editProfile,
                ),
                _buildSettingItem(
                  icon: Icons.security_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'Manage your privacy settings',
                  onTap: _privacySettings,
                ),
                _buildSettingItem(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: _language,
                  trailing: _buildDropdownButton(_language, _changeLanguage),
                  onTap: () {},
                ),
              ],
            ),
            SizedBox(height: 24.h),
      
            // NOTIFICATION SETTINGS
            _buildSection(
              title: 'Notifications',
              icon: Icons.notifications_outlined,
              children: [
                _buildToggleSettingItem(
                  icon: Icons.notifications_active_outlined,
                  title: 'Enable Notifications',
                  subtitle: 'Receive app notifications',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                if (_notificationsEnabled) ...[
                  SizedBox(height: 12.h),
                  _buildToggleSettingItem(
                    icon: Icons.email_outlined,
                    title: 'Email Notifications',
                    subtitle: 'Receive notifications via email',
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildToggleSettingItem(
                    icon: Icons.phone_android_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Receive push notifications',
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                    },
                  ),
                ],
              ],
            ),
            SizedBox(height: 24.h),
      
            // APPEARANCE SETTINGS
            _buildSection(
              title: 'Appearance',
              icon: Icons.palette_outlined,
              children: [
                _buildToggleSettingItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Switch to dark theme',
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 24.h),
      
            // PAYMENT & CURRENCY
            _buildSection(
              title: 'Payment & Currency',
              icon: Icons.payments_outlined,
              children: [
                _buildSettingItem(
                  icon: Icons.currency_exchange_outlined,
                  title: 'Default Currency',
                  subtitle: _currency,
                  trailing: _buildDropdownButton(_currency, _changeCurrency),
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.credit_card_outlined,
                  title: 'Payment Methods',
                  subtitle: 'Manage your payment options',
                  onTap: _paymentMethods,
                ),
              ],
            ),
            SizedBox(height: 24.h),
      
            // SUPPORT & ABOUT
            _buildSection(
              title: 'Support & About',
              icon: Icons.help_outline,
              children: [
                _buildSettingItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: _helpSupport,
                ),
                _buildSettingItem(
                  icon: Icons.info_outline,
                  title: 'About App',
                  subtitle: 'Version 1.0.0',
                  onTap: _aboutApp,
                ),
                _buildSettingItem(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  subtitle: 'App terms and conditions',
                  onTap: _termsConditions,
                ),
                _buildSettingItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  onTap: _privacyPolicy,
                ),
              ],
            ),
            SizedBox(height: 32.h),
      
            // LOGOUT BUTTON
            _buildLogoutButton(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Manage your app preferences and account settings',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.blueGrey,
          ),
        ),
      ],
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
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    size: 20.w,
                    color: AppColors.blueColor,
                  ),
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

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 20.w, color: Colors.blueGrey),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.blueGrey,
        ),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, size: 20.w, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildToggleSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 20.w, color: Colors.blueGrey),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.blueColor,
        ),
      ],
    );
  }

Widget _buildDropdownButton(
  String currentValue,
  Function(String) onChanged,
) {
  final bool isCurrency = currentValue.contains(' - ');  
  // This is more reliable because all currency values contain “ - ”
  // and no language contains it.

  final List<String> items = isCurrency
      ? _currencyItems
      : _languageItems;

  return DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      value: currentValue,
      items: items
          .map((value) => DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(fontSize: 12.sp),
                ),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
      style: TextStyle(fontSize: 12.sp, color: Colors.black87),
      icon: Icon(Icons.arrow_drop_down, size: 20.w, color: Colors.grey),
    ),
  );
}

final List<String> _languageItems = [
  'English',
  'French',
  'Spanish',
  'Arabic',
];

final List<String> _currencyItems = [
  'GHS - Ghanaian Cedi',
  'USD - US Dollar',
  'EUR - Euro',
  'GBP - British Pound',
];

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _confirmLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.1),
          foregroundColor: Colors.red,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: Colors.red.withOpacity(0.3)),
          ),
        ),
        child: Text(
          'Log Out',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Action methods
  void _changeLanguage(String language) {
    setState(() {
      _language = language;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Language changed to $language')),
    );
  }

  void _changeCurrency(String currency) {
    setState(() {
      _currency = currency;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Currency changed to $currency')),
    );
  }

void _editProfile() {
  final authState = ref.read(authProvider);
  final currentUser = authState.value;
  
  if (currentUser != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(currentUser: currentUser),
      ),
    ).then((updatedUser) {
      if (updatedUser != null && context.mounted) {
        // The auth provider is already updated, so UI will refresh automatically
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        
        // No need to call setState() - Riverpod will handle the rebuild
      }
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to load user data')),
    );
  }
}

  void _privacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy & Security settings coming soon')),
    );
  }

  void _paymentMethods() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment Methods management coming soon')),
    );
  }

  void _helpSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support section coming soon')),
    );
  }

  void _aboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About HostelHub'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0', style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 8.h),
            Text('HostelHub - Your trusted hostel booking platform', 
                style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _termsConditions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms & Conditions coming soon')),
    );
  }

  void _privacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy coming soon')),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    // Implement logout logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
  }
}