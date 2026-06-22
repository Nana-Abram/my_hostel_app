import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/filter_model.dart';
import 'package:my_hostel_app/backend/provider/filter_provider.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/backend/provider/search_history_provider.dart';
import 'package:my_hostel_app/backend/provider/saved_searches_provider.dart';
import 'package:my_hostel_app/ui/core/responsive.dart';
import 'package:my_hostel_app/ui/hostels/filter_section.dart';
import 'package:my_hostel_app/ui/hostels/hostel_grid.dart';
import 'package:my_hostel_app/ui/hostels/hostels_map_view.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/modern/modern_widgets.dart';

class HostelsScreen extends ConsumerStatefulWidget {
  const HostelsScreen({super.key});

  @override
  ConsumerState<HostelsScreen> createState() => _HostelsScreenState();
}

class _HostelsScreenState extends ConsumerState<HostelsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchSuggestions = false;
  bool _isMapView = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _showSearchSuggestions = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Only the count is displayed on this screen (HostelGrid renders the
    // actual cards via its own watch), so select just the length instead of
    // rebuilding this whole screen whenever the list's contents/order change.
    final filteredCount = ref.watch(filteredHostelsProvider.select((list) => list.length));
    final filter = ref.watch(filterProvider);
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: r.isMobile ? _buildFilterFAB(filter, theme) : null,
      body: Padding(
        padding: r.isMobile
            ? const EdgeInsets.fromLTRB(16, 16, 16, 0)
            : EdgeInsets.only(top: 40.h, left: 80.w, right: 40.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: r.isMobile ? 8 : 10.h),
            BigText(
              text: "Available Hostels",
              size: r.h3,
              color: theme.colorScheme.onSurface,
            ),
            SizedBox(height: r.isMobile ? 12 : 10.h),

            // ── Search & controls ─────────────────────────────────────────
            if (r.isMobile)
              _buildMobileSearchRow(theme, filteredCount, filter)
            else ...[
              /// SEARCH BAR & SORT OPTIONS
              Row(
                children: [
                  /// SEARCH BAR WITH SUGGESTIONS
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Container(
                          height: 50.h,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: theme.dividerColor),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 24.w,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  decoration: InputDecoration(
                                    hintText: "Search hostels by name, location, campus...",
                                    hintStyle: TextStyle(
                                      fontSize: 14.sp,
                                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                    ref.read(filterProvider.notifier).setSearchQuery(
                                      value.isEmpty ? null : value,
                                    );
                                  },
                                  onSubmitted: (value) {
                                    if (value.isNotEmpty) {
                                      ref.read(searchHistoryProvider.notifier).addSearch(value);
                                    }
                                    setState(() {
                                      _showSearchSuggestions = false;
                                    });
                                  },
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 20.w,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(filterProvider.notifier).setSearchQuery(null);
                                    _searchFocusNode.unfocus();
                                    setState(() {
                                      _showSearchSuggestions = false;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),

                        /// SEARCH SUGGESTIONS DROPDOWN
                        if (_showSearchSuggestions) _buildSearchSuggestions(theme),
                      ],
                    ),
                  ),

                  SizedBox(width: 16.w),

                  /// SAVED SEARCHES BUTTON
                  IconButton(
                    icon: Icon(
                      Icons.bookmark_outline,
                      color: theme.colorScheme.primary,
                      size: 24.w,
                    ),
                    onPressed: () => _showSavedSearchesDialog(theme),
                    tooltip: "Saved Searches",
                  ),

                  SizedBox(width: 8.w),

                  /// MAP / LIST TOGGLE
                  Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _viewToggleButton(theme, Icons.grid_view, !_isMapView,
                            () => setState(() => _isMapView = false), 'List'),
                        _viewToggleButton(theme, Icons.map_outlined, _isMapView,
                            () => setState(() => _isMapView = true), 'Map'),
                      ],
                    ),
                  ),

                  SizedBox(width: 8.w),

                  /// SORT DROPDOWN
                  Container(
                    height: 50.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SortBy>(
                        value: filter.sortBy,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: theme.colorScheme.onSurface,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: SortBy.popularity,
                            child: Row(children: [
                              Icon(Icons.trending_up, size: 18),
                              SizedBox(width: 8),
                              Text("Most Popular"),
                            ]),
                          ),
                          DropdownMenuItem(
                            value: SortBy.rating,
                            child: Row(children: [
                              Icon(Icons.star, size: 18),
                              SizedBox(width: 8),
                              Text("Highest Rated"),
                            ]),
                          ),
                          DropdownMenuItem(
                            value: SortBy.priceAsc,
                            child: Row(children: [
                              Icon(Icons.arrow_upward, size: 18),
                              SizedBox(width: 8),
                              Text("Price: Low to High"),
                            ]),
                          ),
                          DropdownMenuItem(
                            value: SortBy.priceDesc,
                            child: Row(children: [
                              Icon(Icons.arrow_downward, size: 18),
                              SizedBox(width: 8),
                              Text("Price: High to Low"),
                            ]),
                          ),
                          DropdownMenuItem(
                            value: SortBy.newest,
                            child: Row(children: [
                              Icon(Icons.new_releases, size: 18),
                              SizedBox(width: 8),
                              Text("Newest First"),
                            ]),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(filterProvider.notifier).setSortBy(value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              /// RESULTS COUNT & FILTER SUMMARY
              Row(
                children: [
                  SmallText(
                    text: "Found $filteredCount ${filteredCount == 1 ? 'hostel' : 'hostels'}",
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 14.sp,
                  ),
                  if (filter.hasActiveFilters) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_alt,
                            size: 14.w,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "${filter.activeFilterCount} active ${filter.activeFilterCount == 1 ? 'filter' : 'filters'}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 20.h),
            ],

            // ── Main content ──────────────────────────────────────────────
            Expanded(
              child: _isMapView
                  ? const HostelsMapView()
                  : r.isMobile
                      ? PullToRefreshWrapper(
                          onRefresh: () async {
                            ref.invalidate(hostelsStreamProvider);
                            await Future.delayed(const Duration(milliseconds: 500));
                          },
                          child: const HostelGrid(),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// FILTER SIDEBAR (LEFT)
                            const FilterSection(),

                            SizedBox(width: 40.w),

                            /// HOSTEL GRID WITH PULL-TO-REFRESH
                            Expanded(
                              child: PullToRefreshWrapper(
                                onRefresh: () async {
                                  ref.invalidate(hostelsStreamProvider);
                                  await Future.delayed(const Duration(milliseconds: 500));
                                },
                                child: const HostelGrid(),
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mobile search row ─────────────────────────────────────────────────────

  Widget _buildMobileSearchRow(
      ThemeData theme, int filteredCount, HostelFilter filter) {
    return Column(
      children: [
        // Full-width search bar
        Stack(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: "Search hostels...",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {});
                        ref.read(filterProvider.notifier).setSearchQuery(
                          value.isEmpty ? null : value,
                        );
                      },
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          ref.read(searchHistoryProvider.notifier).addSearch(value);
                        }
                        setState(() => _showSearchSuggestions = false);
                      },
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        ref.read(filterProvider.notifier).setSearchQuery(null);
                        _searchFocusNode.unfocus();
                        setState(() => _showSearchSuggestions = false);
                      },
                      child: Icon(Icons.clear, size: 18,
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            if (_showSearchSuggestions) _buildSearchSuggestions(theme),
          ],
        ),
        const SizedBox(height: 8),
        // Controls row: count + toggles + sort
        Row(
          children: [
            SmallText(
              text: "$filteredCount ${filteredCount == 1 ? 'hostel' : 'hostels'}",
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              size: 13,
            ),
            if (filter.hasActiveFilters)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "${filter.activeFilterCount} filter${filter.activeFilterCount == 1 ? '' : 's'}",
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const Spacer(),
            _viewToggleButton(theme, Icons.grid_view, !_isMapView,
                () => setState(() => _isMapView = false), 'List'),
            _viewToggleButton(theme, Icons.map_outlined, _isMapView,
                () => setState(() => _isMapView = true), 'Map'),
            PopupMenuButton<SortBy>(
              initialValue: filter.sortBy,
              icon: Icon(Icons.sort, color: theme.colorScheme.onSurface, size: 22),
              tooltip: 'Sort',
              onSelected: (value) => ref.read(filterProvider.notifier).setSortBy(value),
              itemBuilder: (_) => const [
                PopupMenuItem(value: SortBy.popularity, child: Text("Most Popular")),
                PopupMenuItem(value: SortBy.rating, child: Text("Highest Rated")),
                PopupMenuItem(value: SortBy.priceAsc, child: Text("Price: Low to High")),
                PopupMenuItem(value: SortBy.priceDesc, child: Text("Price: High to Low")),
                PopupMenuItem(value: SortBy.newest, child: Text("Newest First")),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Filter FAB (mobile only) ──────────────────────────────────────────────

  Widget _buildFilterFAB(HostelFilter filter, ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => _showFilterBottomSheet(context, theme),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.filter_list),
          if (filter.hasActiveFilters)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      label: Text(filter.hasActiveFilters
          ? 'Filter (${filter.activeFilterCount})'
          : 'Filter'),
    );
  }

  void _showFilterBottomSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Filter Hostels',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref.read(filterProvider.notifier).clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Apply',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 32),
                child: FilterSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _viewToggleButton(
    ThemeData theme,
    IconData icon,
    bool selected,
    VoidCallback onTap,
    String tooltip,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 22.w,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  /// Build search suggestions dropdown
  Widget _buildSearchSuggestions(ThemeData theme) {
    final searchHistory = ref.watch(searchHistoryProvider);
    final suggestions = _searchController.text.isEmpty
        ? searchHistory.take(5).toList()
        : searchHistory
            .where((item) =>
                item.toLowerCase().contains(_searchController.text.toLowerCase()))
            .take(5)
            .toList();

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 55.h,
      left: 0,
      right: 0,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          constraints: BoxConstraints(maxHeight: 250.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: theme.dividerColor),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.all(8.w),
            itemCount: suggestions.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: theme.dividerColor),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return ListTile(
                dense: true,
                leading: Icon(
                  Icons.history,
                  size: 18.w,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  suggestion,
                  style: TextStyle(fontSize: 14.sp),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 16.w,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    ref
                        .read(searchHistoryProvider.notifier)
                        .removeSearch(suggestion);
                  },
                ),
                onTap: () {
                  _searchController.text = suggestion;
                  ref.read(filterProvider.notifier).setSearchQuery(suggestion);
                  setState(() {
                    _showSearchSuggestions = false;
                  });
                  _searchFocusNode.unfocus();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Show saved searches dialog
  void _showSavedSearchesDialog(ThemeData theme) {
    final savedSearches = ref.read(savedSearchesProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.bookmark, color: theme.colorScheme.primary),
            SizedBox(width: 8.w),
            const Text("Saved Searches"),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 350),
          child: savedSearches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.3),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "No saved searches yet",
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Apply filters and save them for quick access",
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: savedSearches.length,
                  itemBuilder: (context, index) {
                    final savedSearch = savedSearches[index];
                    return Card(
                      child: ListTile(
                        leading:
                            Icon(Icons.search, color: theme.colorScheme.primary),
                        title: Text(savedSearch.name),
                        subtitle: Text(
                          "Saved ${_formatDate(savedSearch.savedAt)}",
                          style: TextStyle(fontSize: 11.sp),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                ref
                                    .read(savedSearchesProvider.notifier)
                                    .deleteSearch(savedSearch.id);
                                Navigator.pop(context);
                                _showSavedSearchesDialog(theme);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          final filter = savedSearch.filter;
                          ref
                              .read(filterProvider.notifier)
                              .setCampus(filter.campus);
                          ref
                              .read(filterProvider.notifier)
                              .setRoomType(filter.roomType);
                          ref
                              .read(filterProvider.notifier)
                              .setGender(filter.gender);
                          if (filter.minPrice != null ||
                              filter.maxPrice != null) {
                            ref.read(filterProvider.notifier).setPriceRange(
                                  filter.minPrice ?? 0,
                                  filter.maxPrice ?? 20000,
                                );
                          }
                          ref
                              .read(filterProvider.notifier)
                              .setSortBy(filter.sortBy);
                          ref
                              .read(filterProvider.notifier)
                              .setSearchQuery(filter.searchQuery);
                          _searchController.text = filter.searchQuery ?? '';
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Applied "${savedSearch.name}" search'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          if (savedSearches.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(savedSearchesProvider.notifier).clearAllSearches();
                Navigator.pop(context);
              },
              child: const Text("Clear All"),
            ),
          if (ref.read(filterProvider).hasActiveFilters)
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Save Current Search"),
              onPressed: () => _showSaveSearchDialog(theme),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  /// Show save search dialog
  void _showSaveSearchDialog(ThemeData theme) {
    Navigator.pop(context);
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Save Search"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "Search Name",
            hintText: "e.g., Near Campus Male Hostels",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final success = await ref
                    .read(savedSearchesProvider.notifier)
                    .saveSearch(nameController.text, ref.read(filterProvider));

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Search saved successfully!'
                            : 'A search with this name already exists',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
