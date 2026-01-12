import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/widgets/modern/modern_widgets.dart';

/// Demo screen showcasing all modern UI components
class ModernComponentsDemo extends StatefulWidget {
  const ModernComponentsDemo({super.key});

  @override
  State<ModernComponentsDemo> createState() => _ModernComponentsDemoState();
}

class _ModernComponentsDemoState extends State<ModernComponentsDemo> {
  bool _showSkeletons = false;
  bool _showLoading = false;
  bool _showEmpty = false;
  bool _showError = false;
  bool _isButtonLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modern UI Components Demo'),
        elevation: 0,
      ),
      body: PullToRefreshWrapper(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Refreshed!')),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Control Buttons
              _buildSectionTitle('Demo Controls'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildToggleButton(
                    'Skeletons',
                    _showSkeletons,
                    () => setState(() => _showSkeletons = !_showSkeletons),
                  ),
                  _buildToggleButton(
                    'Loading',
                    _showLoading,
                    () => setState(() => _showLoading = !_showLoading),
                  ),
                  _buildToggleButton(
                    'Empty',
                    _showEmpty,
                    () => setState(() => _showEmpty = !_showEmpty),
                  ),
                  _buildToggleButton(
                    'Error',
                    _showError,
                    () => setState(() => _showError = !_showError),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Section: Skeleton Loaders
              _buildSectionTitle('Skeleton Loaders'),
              SizedBox(height: 16.h),
              if (_showSkeletons) ...[
                const SkeletonCard(height: 200),
                SizedBox(height: 16.h),
                const SkeletonListItem(),
                const SkeletonListItem(),
                const SkeletonListItem(),
              ] else
                Text(
                  'Toggle "Skeletons" to see skeleton loaders',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              SizedBox(height: 32.h),

              // Section: Loading Indicators
              _buildSectionTitle('Loading Indicators'),
              SizedBox(height: 16.h),
              if (_showLoading)
                const LoadingCard(
                  height: 200,
                  message: 'Loading your data...',
                )
              else
                Text(
                  'Toggle "Loading" to see loading indicators',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              SizedBox(height: 32.h),

              // Section: Empty States
              _buildSectionTitle('Empty States'),
              SizedBox(height: 16.h),
              if (_showEmpty)
                SizedBox(
                  height: 300.h,
                  child: EmptyHostelsState(
                    onExplore: () {
                      HapticUtils.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Explore tapped!')),
                      );
                    },
                  ),
                )
              else
                Text(
                  'Toggle "Empty" to see empty states',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              SizedBox(height: 32.h),

              // Section: Error States
              _buildSectionTitle('Error States'),
              SizedBox(height: 16.h),
              if (_showError)
                SizedBox(
                  height: 300.h,
                  child: NetworkErrorState(
                    onRetry: () {
                      HapticUtils.mediumImpact();
                      setState(() => _showError = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Retrying...')),
                      );
                    },
                  ),
                )
              else
                Text(
                  'Toggle "Error" to see error states',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              SizedBox(height: 32.h),

              // Section: Haptic Buttons
              _buildSectionTitle('Haptic Feedback Buttons'),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  HapticButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Light haptic!')),
                      );
                    },
                    feedbackType: HapticFeedbackType.light,
                    child: const Text('Light'),
                  ),
                  HapticButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Medium haptic!')),
                      );
                    },
                    feedbackType: HapticFeedbackType.medium,
                    child: const Text('Medium'),
                  ),
                  HapticButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Heavy haptic!')),
                      );
                    },
                    feedbackType: HapticFeedbackType.heavy,
                    child: const Text('Heavy'),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Section: Loading Button
              _buildSectionTitle('Loading Button'),
              SizedBox(height: 16.h),
              LoadingButton(
                text: 'Submit',
                isLoading: _isButtonLoading,
                icon: Icons.check,
                onPressed: () async {
                  setState(() => _isButtonLoading = true);
                  await Future.delayed(const Duration(seconds: 2));
                  if (mounted) {
                    setState(() => _isButtonLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Submitted!')),
                    );
                  }
                },
              ),
              SizedBox(height: 32.h),

              // Section: Bottom Sheets
              _buildSectionTitle('Bottom Sheets'),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: () => _showOptionsBottomSheet(context),
                    child: const Text('Show Options'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showConfirmationBottomSheet(context),
                    child: const Text('Show Confirmation'),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Section: Animated Cards
              _buildSectionTitle('Animated Cards (Staggered)'),
              SizedBox(height: 16.h),
              ...List.generate(
                3,
                (index) => StaggeredAnimationWrapper(
                  position: index,
                  animationType: AnimationType.slideAndFade,
                  child: HapticCard(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Card ${index + 1} tapped!')),
                      );
                    },
                    margin: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: theme.primaryColor,
                          size: 32.sp,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Animated Card ${index + 1}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Tap me to feel the haptic feedback',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16.sp,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Info Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.primaryColor,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Info',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Pull down to refresh this screen. All components support dark mode automatically.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildToggleButton(String text, bool isActive, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.surface,
        foregroundColor: isActive
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface,
      ),
      child: Text(text),
    );
  }

  Future<void> _showOptionsBottomSheet(BuildContext context) async {
    final result = await ModernBottomSheet.showOptions<String>(
      context: context,
      title: 'Select an Action',
      options: [
        const BottomSheetOption(
          title: 'Edit',
          subtitle: 'Make changes to your selection',
          icon: Icons.edit,
          value: 'edit',
        ),
        const BottomSheetOption(
          title: 'Share',
          subtitle: 'Share with others',
          icon: Icons.share,
          value: 'share',
        ),
        BottomSheetOption(
          title: 'Delete',
          subtitle: 'Remove permanently',
          icon: Icons.delete,
          iconColor: Theme.of(context).colorScheme.error,
          titleColor: Theme.of(context).colorScheme.error,
          value: 'delete',
        ),
      ],
    );

    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected: $result')),
      );
    }
  }

  Future<void> _showConfirmationBottomSheet(BuildContext context) async {
    final confirmed = await ModernBottomSheet.showConfirmation(
      context: context,
      title: 'Delete Item',
      message: 'Are you sure you want to delete this item? This action cannot be undone.',
      icon: Icons.warning_amber_rounded,
      isDangerous: true,
    );

    if (confirmed == true && context.mounted) {
      HapticUtils.success();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted!')),
      );
    }
  }
}
