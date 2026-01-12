import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Empty state widget with customizable icon, message, and action button
class EmptyStateWidget extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Widget? illustration;

  const EmptyStateWidget({
    super.key,
    this.icon,
    required this.title,
    this.message,
    this.actionText,
    this.onActionPressed,
    this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration or Icon
            if (illustration != null)
              illustration!
            else if (icon != null)
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 80.sp,
                  color: theme.primaryColor.withOpacity(0.7),
                ),
              ),
            
            SizedBox(height: 24.h),
            
            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Message
            if (message != null) ...[
              SizedBox(height: 12.h),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Action Button
            if (actionText != null && onActionPressed != null) ...[
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-built empty states for common scenarios
class EmptyHostelsState extends StatelessWidget {
  final VoidCallback? onExplore;

  const EmptyHostelsState({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.home_outlined,
      title: 'No Hostels Found',
      message: 'We couldn\'t find any hostels matching your criteria. Try adjusting your filters or explore all available hostels.',
      actionText: 'Explore Hostels',
      onActionPressed: onExplore,
    );
  }
}

class EmptyBookingsState extends StatelessWidget {
  final VoidCallback? onBrowse;

  const EmptyBookingsState({super.key, this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.calendar_today_outlined,
      title: 'No Bookings Yet',
      message: 'You haven\'t made any bookings yet. Browse available hostels and make your first booking.',
      actionText: 'Browse Hostels',
      onActionPressed: onBrowse,
    );
  }
}

class EmptySearchState extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback? onClearSearch;

  const EmptySearchState({
    super.key,
    this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off_outlined,
      title: 'No Results Found',
      message: searchQuery != null
          ? 'No results found for "$searchQuery". Try different keywords or clear your search.'
          : 'No results found. Try different keywords.',
      actionText: onClearSearch != null ? 'Clear Search' : null,
      onActionPressed: onClearSearch,
    );
  }
}

class EmptyNotificationsState extends StatelessWidget {
  const EmptyNotificationsState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.notifications_none_outlined,
      title: 'No Notifications',
      message: 'You\'re all caught up! You\'ll be notified when there\'s something new.',
    );
  }
}

class EmptyFavoritesState extends StatelessWidget {
  final VoidCallback? onBrowse;

  const EmptyFavoritesState({super.key, this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.favorite_border,
      title: 'No Favorites',
      message: 'You haven\'t added any hostels to your favorites yet. Start exploring and save your favorites!',
      actionText: 'Browse Hostels',
      onActionPressed: onBrowse,
    );
  }
}

/// Error state widget with retry functionality
class ErrorStateWidget extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? message;
  final String? actionText;
  final VoidCallback? onRetry;
  final ErrorType errorType;

  const ErrorStateWidget({
    super.key,
    this.icon,
    this.title = 'Something went wrong',
    this.message,
    this.actionText = 'Try Again',
    this.onRetry,
    this.errorType = ErrorType.generic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine icon and colors based on error type
    IconData errorIcon = icon ?? _getIconForErrorType();
    Color iconColor = _getColorForErrorType(theme);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                errorIcon,
                size: 80.sp,
                color: iconColor,
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Message
            if (message != null) ...[
              SizedBox(height: 12.h),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Retry Button
            if (onRetry != null) ...[
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(actionText ?? 'Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                  backgroundColor: iconColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconForErrorType() {
    switch (errorType) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.permission:
        return Icons.lock_outline;
      case ErrorType.generic:
        return Icons.error_outline;
    }
  }

  Color _getColorForErrorType(ThemeData theme) {
    switch (errorType) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.server:
        return Colors.red;
      case ErrorType.notFound:
        return Colors.blue;
      case ErrorType.permission:
        return Colors.amber;
      case ErrorType.generic:
        return theme.colorScheme.error;
    }
  }
}

enum ErrorType {
  network,
  server,
  notFound,
  permission,
  generic,
}

/// Pre-built error states for common scenarios
class NetworkErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.',
      errorType: ErrorType.network,
      onRetry: onRetry,
    );
  }
}

class ServerErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'Server Error',
      message: 'We\'re having trouble connecting to our servers. Please try again later.',
      errorType: ErrorType.server,
      onRetry: onRetry,
    );
  }
}

class NotFoundErrorState extends StatelessWidget {
  final String? resourceName;
  final VoidCallback? onGoBack;

  const NotFoundErrorState({
    super.key,
    this.resourceName,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: resourceName != null ? '$resourceName Not Found' : 'Not Found',
      message: 'The content you\'re looking for doesn\'t exist or has been removed.',
      errorType: ErrorType.notFound,
      actionText: 'Go Back',
      onRetry: onGoBack,
    );
  }
}

class PermissionErrorState extends StatelessWidget {
  final VoidCallback? onRequestPermission;

  const PermissionErrorState({super.key, this.onRequestPermission});

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'Permission Required',
      message: 'This feature requires additional permissions. Please grant the necessary permissions to continue.',
      errorType: ErrorType.permission,
      actionText: 'Grant Permission',
      onRetry: onRequestPermission,
    );
  }
}
