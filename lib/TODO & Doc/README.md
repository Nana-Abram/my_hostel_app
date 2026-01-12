# Modern UI Components - Usage Guide

This guide demonstrates how to use the new modern UI components in the My Hostel App.

## Table of Contents
1. [Skeleton Loaders](#skeleton-loaders)
2. [Loading Indicators](#loading-indicators)
3. [Empty States](#empty-states)
4. [Error States](#error-states)
5. [Pull to Refresh](#pull-to-refresh)
6. [Animated Lists](#animated-lists)
7. [Page Transitions](#page-transitions)
8. [Bottom Sheets](#bottom-sheets)
9. [Haptic Feedback](#haptic-feedback)

## Skeleton Loaders

Use skeleton loaders to show loading states instead of circular progress indicators:

```dart
import 'package:my_hostel_app/ui/widgets/modern/modern_widgets.dart';

// Basic skeleton
SkeletonLoader(width: 200, height: 20)

// Skeleton card
SkeletonCard(width: 300, height: 200)

// Skeleton list item
SkeletonListItem(hasLeading: true, hasTrailing: false)

// Skeleton hostel card (pre-built for hostel grid)
SkeletonHostelCard()

// Skeleton stat card (for dashboard)
SkeletonStatCard()
```

## Loading Indicators

Modern loading indicators with various styles:

```dart
// Basic loading indicator
LoadingIndicator(
  color: Colors.blue,
  size: 50,
  style: LoadingStyle.fadingCircle,
)

// Full screen loading overlay
LoadingOverlay(
  isLoading: true,
  message: 'Loading hostels...',
  child: YourWidget(),
)

// Loading card
LoadingCard(
  height: 200,
  message: 'Fetching data...',
)

// Button with loading state
LoadingButton(
  text: 'Book Now',
  isLoading: _isLoading,
  onPressed: () => bookHostel(),
  icon: Icons.check,
)
```

## Empty States

Pre-built empty states for common scenarios:

```dart
// Empty hostels
EmptyHostelsState(
  onExplore: () => navigateToHostels(),
)

// Empty bookings
EmptyBookingsState(
  onBrowse: () => navigateToBrowse(),
)

// Empty search results
EmptySearchState(
  searchQuery: 'campus',
  onClearSearch: () => clearSearch(),
)

// Custom empty state
EmptyStateWidget(
  icon: Icons.favorite_border,
  title: 'No Favorites',
  message: 'You haven\'t added any favorites yet.',
  actionText: 'Browse Hostels',
  onActionPressed: () => browse(),
)
```

## Error States

Pre-built error states with retry functionality:

```dart
// Network error
NetworkErrorState(
  onRetry: () => retryFetch(),
)

// Server error
ServerErrorState(
  onRetry: () => retryFetch(),
)

// Not found error
NotFoundErrorState(
  resourceName: 'Hostel',
  onGoBack: () => Navigator.pop(context),
)

// Custom error state
ErrorStateWidget(
  title: 'Failed to load',
  message: 'Something went wrong',
  errorType: ErrorType.generic,
  onRetry: () => retry(),
)
```

## Pull to Refresh

Add pull-to-refresh to any scrollable content:

```dart
PullToRefreshWrapper(
  onRefresh: () async {
    await fetchData();
  },
  child: ListView(...),
)

// With custom styling
CustomRefreshIndicator(
  onRefresh: () async {
    await fetchData();
  },
  backgroundColor: Colors.white,
  color: Colors.blue,
  child: ListView(...),
)
```

## Animated Lists

Use animated lists for smooth staggered animations:

```dart
// Animated list view
AnimatedListView(
  children: [
    Item1(),
    Item2(),
    Item3(),
  ],
  duration: Duration(milliseconds: 375),
  verticalOffset: 50.0,
)

// Animated grid view
AnimatedGridView(
  children: hostelCards,
  crossAxisCount: 3,
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
)

// Wrap individual widgets
StaggeredAnimationWrapper(
  position: index,
  animationType: AnimationType.slideAndFade,
  child: HostelCard(),
)
```

## Page Transitions

Custom page transitions for navigation:

```dart
// Using the helper function
navigateWithAnimation(
  context,
  HostelDetailPage(),
  transitionType: PageTransitionType.fadeAndSlide,
)

// Manual route creation
Navigator.push(
  context,
  CustomPageRoute(
    builder: (context) => HostelDetailPage(),
    transitionType: PageTransitionType.slideUp,
  ),
)

// Available transition types:
// - fade
// - slide
// - scale
// - rotation
// - slideUp
// - fadeAndSlide
```

## Bottom Sheets

Modern bottom sheets for various use cases:

```dart
// Basic bottom sheet
ModernBottomSheet.show(
  context: context,
  child: YourContent(),
)

// Options bottom sheet
final result = await ModernBottomSheet.showOptions<String>(
  context: context,
  title: 'Select Action',
  options: [
    BottomSheetOption(
      title: 'Edit',
      icon: Icons.edit,
      value: 'edit',
    ),
    BottomSheetOption(
      title: 'Delete',
      icon: Icons.delete,
      iconColor: Colors.red,
      value: 'delete',
    ),
  ],
);

// Confirmation bottom sheet
final confirmed = await ModernBottomSheet.showConfirmation(
  context: context,
  title: 'Delete Booking',
  message: 'Are you sure you want to delete this booking?',
  icon: Icons.warning,
  isDangerous: true,
);

// Filter bottom sheet
final filters = await ModernBottomSheet.showFilters(
  context: context,
  title: 'Filter Hostels',
  currentFilters: _currentFilters,
  filterBuilder: (context, filters, updateFilters) {
    return Column(
      children: [
        // Your filter widgets
      ],
    );
  },
);
```

## Haptic Feedback

Add haptic feedback to interactions:

```dart
// Utility functions
HapticUtils.lightImpact();    // Light tap
HapticUtils.mediumImpact();   // Standard tap
HapticUtils.heavyImpact();    // Important action
HapticUtils.selectionClick(); // Selection change

// Haptic button
HapticButton(
  onPressed: () => doSomething(),
  feedbackType: HapticFeedbackType.medium,
  child: Text('Book Now'),
)

// Haptic icon button
HapticIconButton(
  icon: Icons.favorite,
  onPressed: () => toggleFavorite(),
  feedbackType: HapticFeedbackType.light,
)

// Haptic gesture detector
HapticGestureDetector(
  onTap: () => handleTap(),
  onLongPress: () => handleLongPress(),
  feedbackType: HapticFeedbackType.light,
  child: YourWidget(),
)

// Haptic card
HapticCard(
  onTap: () => openDetails(),
  feedbackType: HapticFeedbackType.light,
  child: CardContent(),
)

// Haptic list tile
HapticListTile(
  title: Text('Hostel Name'),
  onTap: () => openHostel(),
  feedbackType: HapticFeedbackType.light,
)
```

## Complete Example: Hostel List Screen

```dart
import 'package:my_hostel_app/ui/widgets/modern/modern_widgets.dart';

class HostelListScreen extends StatefulWidget {
  @override
  _HostelListScreenState createState() => _HostelListScreenState();
}

class _HostelListScreenState extends State<HostelListScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Hostel> _hostels = [];

  @override
  void initState() {
    super.initState();
    _loadHostels();
  }

  Future<void> _loadHostels() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final hostels = await fetchHostels();
      setState(() {
        _hostels = hostels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => SkeletonHostelCard(),
      );
    }

    if (_hasError) {
      return NetworkErrorState(
        onRetry: _loadHostels,
      );
    }

    if (_hostels.isEmpty) {
      return EmptyHostelsState(
        onExplore: () => Navigator.pushNamed(context, '/explore'),
      );
    }

    return PullToRefreshWrapper(
      onRefresh: _loadHostels,
      child: AnimatedGridView(
        children: _hostels.map((hostel) {
          return HapticCard(
            onTap: () {
              navigateWithAnimation(
                context,
                HostelDetailPage(hostel: hostel),
                transitionType: PageTransitionType.fadeAndSlide,
              );
            },
            feedbackType: HapticFeedbackType.light,
            child: HostelCardContent(hostel: hostel),
          );
        }).toList(),
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
    );
  }
}
```

## Best Practices

1. **Use skeleton loaders** instead of circular progress indicators for better UX
2. **Provide empty states** with actionable CTAs to guide users
3. **Add haptic feedback** to important interactions for better engagement
4. **Implement pull-to-refresh** on all list screens
5. **Use error states with retry** functionality for better error handling
6. **Add page transitions** for smooth navigation experience
7. **Use bottom sheets** for quick actions instead of full-page dialogs
8. **Implement staggered animations** for lists and grids to create visual interest

## Performance Tips

- Use `const` constructors where possible
- Avoid rebuilding entire lists; use `AnimationLimiter` wisely
- Keep skeleton loaders simple to reduce rendering overhead
- Use `cached_network_image` for remote images (already configured)
