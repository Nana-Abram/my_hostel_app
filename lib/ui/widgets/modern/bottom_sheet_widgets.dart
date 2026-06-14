import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Custom bottom sheet with modern design
class ModernBottomSheet {
  /// Show a custom bottom sheet with rounded corners and drag handle
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? maxHeight,
    bool isScrollControlled = true,
  }) {
    final theme = Theme.of(context);
    
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }

  /// Show a list of options in a bottom sheet
  static Future<T?> showOptions<T>({
    required BuildContext context,
    required String title,
    required List<BottomSheetOption<T>> options,
    bool showCancelButton = true,
    String? cancelText,
  }) {
    return show<T>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Divider
          Divider(height: 1.h),
          
          // Options
          ...options.map((option) => InkWell(
            onTap: () => Navigator.pop(context, option.value),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 16.h,
              ),
              child: Row(
                children: [
                  if (option.icon != null) ...[
                    Icon(
                      option.icon,
                      color: option.iconColor ?? 
                        Theme.of(context).iconTheme.color,
                      size: 24.sp,
                    ),
                    SizedBox(width: 16.w),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: option.titleColor,
                          ),
                        ),
                        if (option.subtitle != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            option.subtitle!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (option.trailing != null) option.trailing!,
                ],
              ),
            ),
          )),
          
          // Cancel button
          if (showCancelButton) ...[
            Divider(height: 1.h),
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 16.h,
                ),
                child: Center(
                  child: Text(
                    cancelText ?? 'Cancel',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
          
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  /// Show a confirmation bottom sheet
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    IconData? icon,
    bool isDangerous = false,
  }) {
    final theme = Theme.of(context);
    
    return show<bool>(
      context: context,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (icon != null)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: (confirmColor ?? 
                    (isDangerous ? theme.colorScheme.error : theme.primaryColor))
                    .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48.sp,
                  color: confirmColor ?? 
                    (isDangerous ? theme.colorScheme.error : theme.primaryColor),
                ),
              ),
            
            SizedBox(height: 24.h),
            
            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 12.h),
            
            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32.h),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(cancelText ?? 'Cancel'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      backgroundColor: confirmColor ?? 
                        (isDangerous ? theme.colorScheme.error : theme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(confirmText ?? 'Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show a filter bottom sheet
  static Future<Map<String, dynamic>?> showFilters({
    required BuildContext context,
    required String title,
    required Map<String, dynamic> currentFilters,
    required Widget Function(
      BuildContext context,
      Map<String, dynamic> filters,
      void Function(Map<String, dynamic>) updateFilters,
    ) filterBuilder,
  }) {
    Map<String, dynamic> tempFilters = Map.from(currentFilters);
    
    return show<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          tempFilters.clear();
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),
              
              Divider(height: 1.h),
              
              // Filters
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: filterBuilder(
                    context,
                    tempFilters,
                    (newFilters) {
                      setState(() {
                        tempFilters = newFilters;
                      });
                    },
                  ),
                ),
              ),
              
              // Apply button
              Padding(
                padding: EdgeInsets.all(24.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, tempFilters),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Model for bottom sheet options
class BottomSheetOption<T> {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? titleColor;
  final Widget? trailing;
  final T value;

  const BottomSheetOption({
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.titleColor,
    this.trailing,
    required this.value,
  });
}
