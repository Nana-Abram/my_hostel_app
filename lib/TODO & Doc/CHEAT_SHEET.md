# Modern UI Components - Cheat Sheet

## 🚀 Quick Reference

### Import
```dart
import 'package:my_hostel_app/ui/widgets/modern/modern_widgets.dart';
```

---

## 📋 Common Patterns

### 1. Replace Loading Indicator
```dart
// ❌ Old Way
loading: () => Center(child: CircularProgressIndicator())

// ✅ New Way - Single Item
loading: () => LoadingCard(height: 200, message: 'Loading...')

// ✅ New Way - List
loading: () => ListView.builder(
  itemCount: 4,
  itemBuilder: (_, i) => SkeletonCard(height: 150),
)

// ✅ New Way - Grid
loading: () => GridView.builder(
  itemCount: 6,
  itemBuilder: (_, i) => SkeletonHostelCard(),
)
```

### 2. Replace Error Message
```dart
// ❌ Old Way
error: (e, s) => Center(child: Text('Error: $e'))

// ✅ New Way
error: (e, s) => NetworkErrorState(
  onRetry: () {
    ref.invalidate(dataProvider);
  },
)
```

### 3. Replace Empty Message
```dart
// ❌ Old Way
if (list.isEmpty) {
  return Center(child: Text('No items'));
}

// ✅ New Way
if (list.isEmpty) {
  return EmptyHostelsState(
    onExplore: () => context.go('/hostels'),
  );
}
```

### 4. Add Pull-to-Refresh
```dart
// Wrap any ListView/GridView/SingleChildScrollView
PullToRefreshWrapper(
  onRefresh: () async {
    ref.invalidate(dataProvider);
    await Future.delayed(Duration(milliseconds: 500));
  },
  child: ListView(...),
)
```

### 5. Add Haptic Feedback
```dart
// For Cards
HapticCard(
  onTap: () => navigate(),
  child: CardContent(),
)

// For Buttons (replace ElevatedButton)
HapticButton(
  onPressed: () => doSomething(),
  child: Text('Click Me'),
)

// For Any Gesture
HapticGestureDetector(
  onTap: () => handleTap(),
  feedbackType: HapticFeedbackType.light,
  child: AnyWidget(),
)

// Manual Haptic
HapticUtils.lightImpact();
HapticUtils.selectionClick();
```

### 6. Better Navigation
```dart
// ❌ Old Way
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => DetailPage()),
)

// ✅ New Way
navigateWithAnimation(
  context,
  DetailPage(),
  transitionType: PageTransitionType.fadeAndSlide,
)
```

### 7. Bottom Sheets
```dart
// Options Menu
final action = await ModernBottomSheet.showOptions<String>(
  context: context,
  title: 'Select Action',
  options: [
    BottomSheetOption(
      title: 'Edit',
      icon: Icons.edit,
      value: 'edit',
    ),
  ],
);

// Confirmation
final confirmed = await ModernBottomSheet.showConfirmation(
  context: context,
  title: 'Delete Item',
  message: 'Are you sure?',
  isDangerous: true,
);
```

### 8. Loading Button
```dart
LoadingButton(
  text: 'Submit',
  isLoading: _isLoading,
  icon: Icons.check,
  onPressed: () async {
    setState(() => _isLoading = true);
    await submit();
    setState(() => _isLoading = false);
  },
)
```

---

## 🎨 Complete Screen Pattern

```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dataProvider);
    
    return Scaffold(
      body: dataAsync.when(
        // Loading State
        loading: () => ListView.builder(
          itemCount: 5,
          itemBuilder: (_, i) => SkeletonCard(),
        ),
        
        // Error State
        error: (e, s) => NetworkErrorState(
          onRetry: () => ref.invalidate(dataProvider),
        ),
        
        // Success State
        data: (items) {
          // Empty State
          if (items.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.inbox,
              title: 'No Items',
              message: 'Add some items to get started',
              actionText: 'Add Item',
              onActionPressed: () => addItem(),
            );
          }
          
          // Show Data with Pull-to-Refresh
          return PullToRefreshWrapper(
            onRefresh: () async {
              ref.invalidate(dataProvider);
              await Future.delayed(Duration(milliseconds: 500));
            },
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return HapticCard(
                  onTap: () {
                    navigateWithAnimation(
                      context,
                      DetailPage(item: items[index]),
                    );
                  },
                  child: ItemContent(items[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```

---

## 🔥 Pro Tips

### Skeleton Counts
```dart
// Show expected number of items
itemCount: expectedItemCount  // Better UX
itemCount: 6                  // Good default
```

### Error Context
```dart
// Be specific
NetworkErrorState()           // Network issues
ServerErrorState()            // Server problems
NotFoundErrorState()          // Resource not found
```

### Haptic Types
```dart
HapticFeedbackType.light      // Taps, selections
HapticFeedbackType.medium     // Standard actions
HapticFeedbackType.heavy      // Important actions
HapticFeedbackType.selection  // Selection changes
```

### Transition Types
```dart
PageTransitionType.fadeAndSlide  // Recommended
PageTransitionType.slideUp       // Modal-style
PageTransitionType.fade          // Subtle
```

---

## 📊 Widget Quick Reference

### Skeleton Loaders
- `SkeletonLoader` - Basic skeleton
- `SkeletonCard` - Card layout
- `SkeletonListItem` - List item
- `SkeletonHostelCard` - Hostel grid item
- `SkeletonStatCard` - Dashboard stat

### Loading Widgets
- `LoadingIndicator` - Spinner
- `LoadingOverlay` - Full screen overlay
- `LoadingCard` - Card with loading
- `LoadingButton` - Button with loading state

### State Widgets
- `EmptyStateWidget` - Generic empty
- `EmptyHostelsState` - No hostels
- `EmptyBookingsState` - No bookings
- `EmptySearchState` - No search results
- `ErrorStateWidget` - Generic error
- `NetworkErrorState` - Network error
- `ServerErrorState` - Server error
- `NotFoundErrorState` - 404 error

### Interaction Widgets
- `HapticButton` - Button with haptic
- `HapticIconButton` - Icon button
- `HapticCard` - Card with haptic
- `HapticListTile` - List tile
- `HapticGestureDetector` - Any widget

### Animation Widgets
- `PullToRefreshWrapper` - Pull to refresh
- `AnimatedListView` - Staggered list
- `AnimatedGridView` - Staggered grid
- `StaggeredAnimationWrapper` - Single item
- `CustomPageRoute` - Page transition
- `navigateWithAnimation()` - Helper function

### Bottom Sheets
- `ModernBottomSheet.show()` - Basic
- `ModernBottomSheet.showOptions()` - Options list
- `ModernBottomSheet.showConfirmation()` - Confirm dialog
- `ModernBottomSheet.showFilters()` - Filters

---

## ⚡ One-Liners

```dart
// Haptic on tap
HapticUtils.lightImpact();

// Navigate with animation
navigateWithAnimation(context, Page());

// Show loading
if (isLoading) return LoadingCard();

// Show error
if (hasError) return NetworkErrorState(onRetry: retry);

// Show empty
if (isEmpty) return EmptyStateWidget(...);

// Pull to refresh
PullToRefreshWrapper(onRefresh: refresh, child: list);

// Haptic card
HapticCard(onTap: navigate, child: content);

// Loading button
LoadingButton(text: 'Save', isLoading: loading, onPressed: save);
```

---

## 🎯 Common Mistakes to Avoid

### ❌ Don't
```dart
// Don't use CircularProgressIndicator
loading: () => CircularProgressIndicator()

// Don't use plain Text for errors
error: (e, s) => Text('Error')

// Don't use plain Text for empty
if (isEmpty) return Text('No items')

// Don't use Navigator.push directly
Navigator.push(context, MaterialPageRoute(...))

// Don't forget haptic on important actions
GestureDetector(onTap: delete)
```

### ✅ Do
```dart
// Use skeleton loaders
loading: () => SkeletonCard()

// Use error states
error: (e, s) => NetworkErrorState(...)

// Use empty states
if (isEmpty) return EmptyStateWidget(...)

// Use animated navigation
navigateWithAnimation(context, Page())

// Add haptic for important actions
HapticGestureDetector(onTap: delete)
```

---

## 📱 Screen-Specific Patterns

### List Screen
```dart
- SkeletonCard for loading
- NetworkErrorState for errors
- EmptyStateWidget for empty
- PullToRefreshWrapper for refresh
- HapticCard for items
```

### Detail Screen
```dart
- LoadingCard for loading
- NotFoundErrorState if not found
- navigateWithAnimation for entry
- HapticButton for actions
```

### Form Screen
```dart
- LoadingButton for submit
- HapticButton for secondary actions
- ErrorStateWidget for validation errors
```

---

**Save this file for quick reference while coding!** 🚀
