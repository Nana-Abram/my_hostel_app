import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/provider/admin_booking_provider.dart';

class BookingsManagementPage extends ConsumerStatefulWidget {
  const BookingsManagementPage({super.key});

  @override
  ConsumerState<BookingsManagementPage> createState() =>
      _BookingsManagementPageState();
}

class _BookingsManagementPageState
    extends ConsumerState<BookingsManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BookingModel> _applyFilters(List<BookingModel> bookings) {
    var result = bookings;

    if (_selectedFilter != 'All') {
      result = result
          .where((b) =>
              b.status.toLowerCase() == _selectedFilter.toLowerCase())
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((b) =>
              b.hostelName.toLowerCase().contains(q) ||
              b.userName.toLowerCase().contains(q) ||
              b.userEmail.toLowerCase().contains(q) ||
              b.roomType.toLowerCase().contains(q))
          .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          _buildHeader(theme),
          SizedBox(height: 20.h),

          // Stats row
          Consumer(
            builder: (context, ref, child) {
              final statsAsync = ref.watch(bookingStatsProvider);
              return statsAsync.when(
                data: (stats) => _buildStats(stats, theme),
                loading: () => _buildStatsLoading(theme),
                error: (error, _) => _buildStatsError(error, theme),
              );
            },
          ),
          SizedBox(height: 24.h),

          _buildSearchAndFilter(theme),
          SizedBox(height: 16.h),

          _buildBookingsList(theme),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bookings Management',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Monitor all booking activity across the platform',
          style: TextStyle(
            fontSize: 12.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  // ── Stats ──────────────────────────────────────────────────────────────────

  Widget _buildStats(Map<String, dynamic> stats, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme: theme,
                title: 'Total',
                value: '${stats['total'] ?? 0}',
                icon: Icons.receipt_long_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                theme: theme,
                title: 'Confirmed',
                value: '${stats['confirmed'] ?? 0}',
                icon: Icons.check_circle_outline,
                color: theme.colorScheme.secondary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                theme: theme,
                title: 'Pending',
                value: '${stats['pending'] ?? 0}',
                icon: Icons.hourglass_empty_outlined,
                color: theme.colorScheme.tertiary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                theme: theme,
                title: 'Cancelled',
                value: '${stats['cancelled'] ?? 0}',
                icon: Icons.cancel_outlined,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildRevenueCard(stats, theme),
      ],
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
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
            child: Icon(icon, size: 18.w, color: color),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(Map<String, dynamic> stats, ThemeData theme) {
    final revenue = (stats['totalRevenue'] as double?) ?? 0.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.payments_outlined,
                size: 24.w, color: theme.colorScheme.onPrimary),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Revenue (Confirmed)',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'GHS ${revenue.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsLoading(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < 4; i++) ...[
              Expanded(
                child: Container(
                  height: 90.h,
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
        ),
        SizedBox(height: 12.h),
        Container(
          height: 72.h,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
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

  // ── Search + Filter ────────────────────────────────────────────────────────

  Widget _buildSearchAndFilter(ThemeData theme) {
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
                  Icon(Icons.search,
                      size: 18.w,
                      color: theme.colorScheme.onSurfaceVariant),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by hostel, student, email...',
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
                      child: Icon(Icons.close,
                          size: 16.w,
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
                items: ['All', 'Confirmed', 'Pending', 'Cancelled']
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

  // ── Bookings list ──────────────────────────────────────────────────────────

  Widget _buildBookingsList(ThemeData theme) {
    return Consumer(
      builder: (context, ref, child) {
        final bookingsAsync = ref.watch(allBookingsProvider);

        return bookingsAsync.when(
          data: (bookings) {
            final filtered = _applyFilters(bookings);
            if (filtered.isEmpty) return _buildEmptyState(theme);

            return Column(
              children: [
                _buildTableHeader(theme),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12)),
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
                        .map((b) => _buildBookingRow(b, theme))
                        .toList(),
                  ),
                ),
              ],
            );
          },
          loading: () => _buildLoadingState(theme),
          error: (error, _) => _buildErrorState(error, theme),
        );
      },
    );
  }

  Widget _buildTableHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
        border: Border(
          bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Student / Hostel',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            flex: 2,
            child: Text('Room Type',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text('Amount',
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
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  Widget _buildBookingRow(BookingModel booking, ThemeData theme) {
    final statusColor = _statusColor(booking.status, theme);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.12)),
        ),
      ),
      child: Row(
        children: [
          // Student / Hostel info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14.w,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        booking.userName.isNotEmpty
                            ? booking.userName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.userName,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            booking.hostelName,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Room type
          Expanded(
            flex: 2,
            child: Text(
              booking.roomType,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurface),
            ),
          ),

          // Amount
          Expanded(
            child: Text(
              'GHS ${booking.totalPrice.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Status badge
          Expanded(
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
                border:
                    Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                _statusLabel(booking.status),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: 48.w,
            child: PopupMenuButton<String>(
              onSelected: (action) => _handleAction(action, booking),
              color: theme.colorScheme.surface,
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(children: [
                    Icon(Icons.visibility_outlined,
                        size: 16.w,
                        color: theme.colorScheme.onSurfaceVariant),
                    SizedBox(width: 8.w),
                    Text('View Details',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface)),
                  ]),
                ),
                if (booking.status == 'pending')
                  PopupMenuItem(
                    value: 'confirm',
                    child: Row(children: [
                      Icon(Icons.check_circle_outline,
                          size: 16.w,
                          color: theme.colorScheme.secondary),
                      SizedBox(width: 8.w),
                      Text('Confirm',
                          style: TextStyle(
                              color: theme.colorScheme.onSurface)),
                    ]),
                  ),
                if (booking.status != 'cancelled')
                  PopupMenuItem(
                    value: 'cancel',
                    child: Row(children: [
                      Icon(Icons.cancel_outlined,
                          size: 16.w,
                          color: theme.colorScheme.error),
                      SizedBox(width: 8.w),
                      Text('Cancel',
                          style:
                              TextStyle(color: theme.colorScheme.error)),
                    ]),
                  ),
              ],
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(Icons.more_vert,
                    size: 16.w,
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty / Loading / Error ────────────────────────────────────────────────

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
          Icon(Icons.receipt_long_outlined,
              size: 56.w,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          SizedBox(height: 16.h),
          Text(
            isFiltered ? 'No bookings match your filter' : 'No Bookings Yet',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface),
          ),
          SizedBox(height: 8.h),
          Text(
            isFiltered
                ? 'Try adjusting your search or filter.'
                : 'Bookings will appear here once students start booking.',
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
            Text('Loading bookings...',
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
          Icon(Icons.error_outline,
              size: 56.w, color: theme.colorScheme.error),
          SizedBox(height: 16.h),
          Text('Failed to load bookings',
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
            onPressed: () => ref.invalidate(allBookingsProvider),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color _statusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return theme.colorScheme.secondary;
      case 'pending':
        return theme.colorScheme.tertiary;
      case 'cancelled':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _handleAction(String action, BookingModel booking) {
    switch (action) {
      case 'view':
        _showBookingDetails(booking);
      case 'confirm':
        _confirmBooking(booking);
      case 'cancel':
        _cancelBooking(booking);
    }
  }

  void _showBookingDetails(BookingModel booking) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Row(
          children: [
            Icon(Icons.receipt_long_outlined,
                color: theme.colorScheme.primary, size: 22.w),
            SizedBox(width: 8.w),
            Expanded(
              child: Text('Booking Details',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: SizedBox(
          width: 400.w,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow(theme, 'Booking ID', booking.id, isMonospace: true),
                _detailRow(theme, 'Student', booking.userName),
                _detailRow(theme, 'Email', booking.userEmail),
                _detailRow(theme, 'Phone', booking.userPhone),
                _detailDivider(theme),
                _detailRow(theme, 'Hostel', booking.hostelName),
                _detailRow(theme, 'Room Type', booking.roomType),
                _detailRow(theme, 'Check-in Date',
                    _formatDate(booking.checkInDate)),
                _detailDivider(theme),
                _detailRow(theme, 'Amount',
                    'GHS ${booking.totalPrice.toStringAsFixed(2)}'),
                _detailRow(theme, 'Payment Ref',
                    booking.paymentReference ?? 'Not paid'),
                _detailRow(theme, 'Booked On',
                    _formatDate(booking.createdAt)),
                _detailDivider(theme),
                Row(
                  children: [
                    Text('Status: ',
                        style: TextStyle(
                            fontSize: 13.sp,
                            color: theme.colorScheme.onSurfaceVariant)),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: _statusColor(booking.status, theme)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                            color: _statusColor(booking.status, theme)
                                .withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _statusLabel(booking.status),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(booking.status, theme),
                        ),
                      ),
                    ),
                  ],
                ),
                if (booking.specialRequests != null &&
                    booking.specialRequests!.isNotEmpty) ...[
                  _detailDivider(theme),
                  _detailRow(
                      theme, 'Special Requests', booking.specialRequests!),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(ThemeData theme, String label, String value,
      {bool isMonospace = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              '$label:',
              style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailDivider(ThemeData theme) {
    return Divider(
        color: theme.colorScheme.outline.withValues(alpha: 0.2),
        height: 20.h);
  }

  Future<void> _confirmBooking(BookingModel booking) async {
    try {
      await AdminBookingService().confirmBooking(booking.id);
      if (!mounted) return;
      ref.invalidate(bookingStatsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking for ${booking.userName} confirmed'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm: $e')),
      );
    }
  }

  void _cancelBooking(BookingModel booking) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Cancel Booking',
            style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Text(
          'Cancel the booking for ${booking.userName} at ${booking.hostelName}?',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await AdminBookingService().cancelBooking(booking.id);
                if (!mounted) return;
                ref.invalidate(bookingStatsProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking cancelled')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to cancel: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
