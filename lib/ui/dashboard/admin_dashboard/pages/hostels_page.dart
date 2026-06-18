import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/provider/admin_hostel_provider.dart';

class HostelsManagementPage extends ConsumerStatefulWidget {
  const HostelsManagementPage({super.key});

  @override
  ConsumerState<HostelsManagementPage> createState() =>
      _HostelsManagementPageState();
}

class _HostelsManagementPageState
    extends ConsumerState<HostelsManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  List<HostelModel> _applyFilters(List<HostelModel> hostels) {
    var result = hostels;

    if (_selectedFilter != 'All') {
      result = result
          .where((h) =>
              h.status.toLowerCase() == _selectedFilter.toLowerCase())
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((h) =>
              h.name.toLowerCase().contains(q) ||
              h.location.toLowerCase().contains(q) ||
              h.ownerName.toLowerCase().contains(q))
          .toList();
    }

    return result;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          _buildHeader(theme),
          SizedBox(height: 20.h),

          Consumer(
            builder: (context, ref, child) {
              final statsAsync = ref.watch(hostelsStatsProvider);
              return statsAsync.when(
                data: (stats) => _buildHostelsStats(stats, theme, isMobile),
                loading: () => _buildStatsLoading(theme),
                error: (error, stack) => _buildStatsError(error, theme),
              );
            },
          ),
          SizedBox(height: 24.h),

          _buildSearchAndFilters(theme),
          SizedBox(height: 16.h),

          _buildHostelsList(theme, isMobile),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hostels Management',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Manage all hostel listings and verifications',
          style: TextStyle(
            fontSize: 12.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  Widget _buildHostelsStats(Map<String, dynamic> stats, ThemeData theme, bool isMobile) {
    final cards = [
      _buildStatCard(theme: theme, title: 'Total Hostels', value: '${stats['totalHostels'] ?? 0}', icon: Icons.business, color: theme.colorScheme.primary),
      _buildStatCard(theme: theme, title: 'Verified', value: '${stats['verifiedHostels'] ?? 0}', icon: Icons.verified, color: theme.colorScheme.secondary),
      _buildStatCard(theme: theme, title: 'Pending', value: '${stats['pendingHostels'] ?? 0}', icon: Icons.pending, color: theme.colorScheme.tertiary),
      _buildStatCard(theme: theme, title: 'Suspended', value: '${stats['suspendedHostels'] ?? 0}', icon: Icons.pause_circle_outline, color: theme.colorScheme.error),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(children: [
            Expanded(child: cards[0]),
            SizedBox(width: 12.w),
            Expanded(child: cards[1]),
          ]),
          SizedBox(height: 12.h),
          Row(children: [
            Expanded(child: cards[2]),
            SizedBox(width: 12.w),
            Expanded(child: cards[3]),
          ]),
        ],
      );
    }

    return Row(children: [
      Expanded(child: cards[0]),
      SizedBox(width: 12.w),
      Expanded(child: cards[1]),
      SizedBox(width: 12.w),
      Expanded(child: cards[2]),
      SizedBox(width: 12.w),
      Expanded(child: cards[3]),
    ]);
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.w, color: color),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsLoading(ThemeData theme) {
    return Row(
      children: [
        for (int i = 0; i < 4; i++) ...[
          Expanded(
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: CircularProgressIndicator(
                    color: theme.colorScheme.primary),
              ),
            ),
          ),
          if (i < 3) SizedBox(width: 12.w),
        ],
      ],
    );
  }

  Widget _buildStatsError(Object error, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.colorScheme.error),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline,
              color: theme.colorScheme.onErrorContainer, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Failed to load stats: $error',
              style: TextStyle(
                  color: theme.colorScheme.onErrorContainer, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search + filter bar ───────────────────────────────────────────────────

  Widget _buildSearchAndFilters(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18.w,
                      color: theme.colorScheme.onSurfaceVariant),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search hostels...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 13.sp,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: theme.colorScheme.onSurface,
                      ),
                      onChanged: (q) => setState(() => _searchQuery = q),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: Icon(Icons.close, size: 16.w,
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),

          Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.4)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilter,
                dropdownColor: theme.colorScheme.surface,
                items: ['All', 'Verified', 'Pending', 'Suspended']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: theme.colorScheme.onSurface,
                              )),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedFilter = value);
                },
                style: TextStyle(
                    fontSize: 13.sp, color: theme.colorScheme.onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hostels list ──────────────────────────────────────────────────────────

  Widget _buildHostelsList(ThemeData theme, bool isMobile) {
    return Consumer(
      builder: (context, ref, child) {
        final hostelsAsync = ref.watch(hostelsProvider);

        return hostelsAsync.when(
          data: (hostels) {
            final filtered = _applyFilters(hostels);
            if (filtered.isEmpty) return _buildEmptyState(theme);

            return Column(
              children: [
                // Table header (desktop only)
                if (!isMobile)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12.r)),
                      border: Border(
                        bottom: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 60.w),
                        Expanded(
                          flex: 2,
                          child: Text('Hostel Info',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ),
                        Expanded(
                          child: Text('Rooms',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ),
                        Expanded(
                          child: Text('Status',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ),
                        SizedBox(width: 80.w),
                      ],
                    ),
                  ),

                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: isMobile
                        ? BorderRadius.circular(12.r)
                        : const BorderRadius.vertical(bottom: Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: filtered
                        .map((h) => _buildHostelListItem(h, theme, isMobile))
                        .toList(),
                  ),
                ),
              ],
            );
          },
          loading: () => _buildLoadingState(theme),
          error: (error, stack) => _buildErrorState(error, theme),
        );
      },
    );
  }

  Widget _buildHostelListItem(HostelModel hostel, ThemeData theme, bool isMobile) {
    final imageUrl = hostel.images.isNotEmpty ? hostel.images.first : null;
    final statusColor = _statusColor(hostel.status, theme);

    final imgSize = isMobile ? 100.w : 60.w;
    final imgHeight = isMobile ? 100.h : 60.h;

    final thumbnail = ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: SizedBox(
        height: imgHeight,
        width: imgSize,
        child: imageUrl != null
            ? ImageNetwork(
                key: ValueKey(imageUrl),
                image: imageUrl,
                height: imgHeight,
                width: imgSize,
                fitWeb: BoxFitWeb.cover,
                fitAndroidIos: BoxFit.cover,
                onLoading: Container(
                  color: theme.colorScheme.surfaceVariant,
                  child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: theme.colorScheme.primary),
                  ),
                ),
                onError: Container(
                  color: theme.colorScheme.surfaceVariant,
                  child: Icon(Icons.broken_image_outlined,
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              )
            : Container(
                color: theme.colorScheme.surfaceVariant,
                child: Icon(Icons.business_outlined,
                    color: theme.colorScheme.onSurfaceVariant),
              ),
      ),
    );

    final actionMenu = PopupMenuButton<String>(
      onSelected: (value) => _handleHostelAction(value, hostel),
      color: theme.colorScheme.surface,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'view',
          child: Row(children: [
            Icon(Icons.visibility, size: 16.w,
                color: theme.colorScheme.onSurfaceVariant),
            SizedBox(width: 8.w),
            Text('View Details',
                style: TextStyle(color: theme.colorScheme.onSurface)),
          ]),
        ),
        if (hostel.status.toLowerCase() == 'pending')
          PopupMenuItem(
            value: 'verify',
            child: Row(children: [
              Icon(Icons.verified, size: 16.w,
                  color: theme.colorScheme.secondary),
              SizedBox(width: 8.w),
              Text('Verify',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
            ]),
          ),
        PopupMenuItem(
          value: 'suspend',
          child: Row(children: [
            Icon(Icons.pause_circle, size: 16.w,
                color: theme.colorScheme.tertiary),
            SizedBox(width: 8.w),
            Text('Suspend',
                style: TextStyle(color: theme.colorScheme.onSurface)),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete, size: 16.w, color: theme.colorScheme.error),
            SizedBox(width: 8.w),
            Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
          ]),
        ),
      ],
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(Icons.more_vert, size: 16.w,
            color: theme.colorScheme.onSurfaceVariant),
      ),
    );

    final statusBadge = Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        _statusLabel(hostel.status),
        style: TextStyle(
            fontSize: 10.sp, color: statusColor, fontWeight: FontWeight.w600),
      ),
    );

    final border = BoxDecoration(
      border: Border(
          bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.15))),
    );

    if (isMobile) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: border,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            thumbnail,
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hostel.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      statusBadge,
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(hostel.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.colorScheme.onSurfaceVariant)),
                  Text('Owner: ${hostel.ownerName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Color(0xFFFFC107)),
                      SizedBox(width: 2.w),
                      Text(hostel.rating.toStringAsFixed(1),
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFFFFC107),
                              fontWeight: FontWeight.w600)),
                      SizedBox(width: 8.w),
                      Text('${hostel.totalRooms.toInt()} rooms',
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: theme.colorScheme.onSurfaceVariant)),
                      const Spacer(),
                      actionMenu,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Desktop: table row layout
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: border,
      child: Row(
        children: [
          thumbnail,
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hostel.name,
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface)),
                SizedBox(height: 2.h),
                Text(hostel.location,
                    style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.colorScheme.onSurfaceVariant)),
                SizedBox(height: 2.h),
                Text('Owner: ${hostel.ownerName}',
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                SizedBox(height: 4.h),
                Row(children: [
                  const Icon(Icons.star, size: 12, color: Color(0xFFFFC107)),
                  SizedBox(width: 2.w),
                  Text(hostel.rating.toStringAsFixed(1),
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFFFFC107),
                          fontWeight: FontWeight.w600)),
                ]),
              ],
            ),
          ),
          Expanded(
            child: Text('${hostel.totalRooms.toInt()}',
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface)),
          ),
          Expanded(child: statusBadge),
          SizedBox(width: 80.w, child: actionMenu),
        ],
      ),
    );
  }

  // ── Loading / Error / Empty ───────────────────────────────────────────────

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            SizedBox(height: 16.h),
            Text('Loading hostels...',
                style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 56.w, color: theme.colorScheme.error),
          SizedBox(height: 16.h),
          Text('Failed to load hostels',
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface)),
          SizedBox(height: 8.h),
          Text(error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.sp,
                  color: theme.colorScheme.onSurfaceVariant)),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () => ref.invalidate(hostelsProvider),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final isFiltered = _selectedFilter != 'All' || _searchQuery.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(Icons.business_outlined, size: 56.w,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          SizedBox(height: 16.h),
          Text(
            isFiltered ? 'No hostels match your filter' : 'No Hostels Found',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface),
          ),
          SizedBox(height: 8.h),
          Text(
            isFiltered
                ? 'Try adjusting your search or filter.'
                : 'There are no hostels yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.sp,
                color: theme.colorScheme.onSurfaceVariant),
          ),
          if (isFiltered) ...[
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => setState(() {
                _selectedFilter = 'All';
                _searchQuery = '';
                _searchController.clear();
              }),
              child: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color _statusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'verified':
        return theme.colorScheme.secondary;
      case 'pending':
        return theme.colorScheme.tertiary;
      case 'suspended':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'Verified';
      case 'pending':
        return 'Pending';
      case 'suspended':
        return 'Suspended';
      default:
        return 'Unknown';
    }
  }

  // ── Action handlers ───────────────────────────────────────────────────────

  void _handleHostelAction(String action, HostelModel hostel) {
    switch (action) {
      case 'view':
        _viewHostelDetails(hostel);
      case 'verify':
        _verifyHostel(hostel);
      case 'suspend':
        _suspendHostel(hostel);
      case 'delete':
        _deleteHostel(hostel);
    }
  }

  void _viewHostelDetails(HostelModel hostel) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(hostel.name,
            style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: ${hostel.location}'),
            Text('Owner: ${hostel.ownerName}'),
            Text('Total Rooms: ${hostel.totalRooms.toInt()}'),
            Text('Rating: ${hostel.rating.toStringAsFixed(1)}'),
            Text('Status: ${_statusLabel(hostel.status)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyHostel(HostelModel hostel) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Verify Hostel',
            style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Text(
          'Verify "${hostel.name}"? It will be listed as available to students.',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await HostelsService().verifyHostel(hostel.id);
      if (!mounted) return;
      ref.invalidate(hostelsStatsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${hostel.name} verified')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify: $e')),
      );
    }
  }

  Future<void> _suspendHostel(HostelModel hostel) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Suspend Hostel',
            style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Text(
          'Suspend "${hostel.name}"? It will be hidden from students.',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.tertiary,
              foregroundColor: theme.colorScheme.onTertiary,
            ),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await HostelsService().suspendHostel(hostel.id);
      if (!mounted) return;
      ref.invalidate(hostelsStatsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${hostel.name} suspended')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to suspend: $e')),
      );
    }
  }

  void _deleteHostel(HostelModel hostel) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Delete Hostel',
            style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Text('Are you sure you want to delete ${hostel.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await HostelsService().deleteHostel(hostel.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${hostel.name} deleted')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
