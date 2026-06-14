import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/backend/service/booking_service.dart';
import 'package:my_hostel_app/ui/core/app_logger.dart';

class EarningsPage extends ConsumerStatefulWidget {
  const EarningsPage({super.key});

  @override
  ConsumerState<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends ConsumerState<EarningsPage> {
  String _selectedView = 'overview';
  bool _isLoading = true;
  List<BookingModel> _confirmedBookings = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEarningsData());
  }

  Future<void> _loadEarningsData() async {
    setState(() => _isLoading = true);

    final user = ref.read(authProvider).value;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final bookingService = BookingService();
      _confirmedBookings = await bookingService.getConfirmedBookingsByOwnerOnce(user.id);
      _calculateStats();
    } catch (e) {
      AppLogger.error('Error loading earnings data', e);

      // Fallback when Firestore composite index is missing
      if (e.toString().contains('index') || e.toString().contains('failed-precondition')) {
        try {
          final querySnapshot = await FirebaseFirestore.instance
              .collection('bookings')
              .where('ownerId', isEqualTo: user.id)
              .where('status', whereIn: ['confirmed', 'checked-in'])
              .get();

          _confirmedBookings = querySnapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          _calculateStats();
        } catch (e2) {
          AppLogger.error('Earnings fallback query failed', e2);
        }
      }
    }

    setState(() => _isLoading = false);
  }

  void _calculateStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Normalise to midnight so Monday bookings at any time of day are included
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    final yearStart = DateTime(now.year, 1, 1);

    double totalEarnings = 0;
    double monthlyEarnings = 0;
    double weeklyEarnings = 0;
    double yearlyEarnings = 0;
    int totalBookings = 0;
    int monthlyBookings = 0;
    int weeklyBookings = 0;
    int yearlyBookings = 0;

    for (final booking in _confirmedBookings) {
      final amount = booking.totalPrice;
      final bookingDate = booking.createdAt;

      totalEarnings += amount;
      totalBookings++;

      if (!bookingDate.isBefore(weekStart)) {
        weeklyEarnings += amount;
        weeklyBookings++;
      }
      if (!bookingDate.isBefore(monthStart)) {
        monthlyEarnings += amount;
        monthlyBookings++;
      }
      if (!bookingDate.isBefore(yearStart)) {
        yearlyEarnings += amount;
        yearlyBookings++;
      }
    }

    _stats = {
      'totalEarnings': totalEarnings,
      'monthlyEarnings': monthlyEarnings,
      'weeklyEarnings': weeklyEarnings,
      'yearlyEarnings': yearlyEarnings,
      'totalBookings': totalBookings,
      'monthlyBookings': monthlyBookings,
      'weeklyBookings': weeklyBookings,
      'yearlyBookings': yearlyBookings,
      'averageBookingValue': totalBookings > 0 ? totalEarnings / totalBookings : 0.0,
    };
  }

  Future<void> _refreshData() => _loadEarningsData();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(theme),
          if (_isLoading)
            Expanded(child: _buildLoading(theme))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                color: theme.colorScheme.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20.w),
                  child: _confirmedBookings.isEmpty
                      ? _buildEmptyNotice(theme)
                      : Column(
                          children: [
                            _buildQuickStats(theme),
                            SizedBox(height: 24.h),
                            _buildViewToggle(theme),
                            SizedBox(height: 24.h),
                            _selectedView == 'details'
                                ? _buildEarningsDetails(theme)
                                : _buildSummary(theme),
                          ],
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      color: theme.colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Earnings',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Track your booking earnings',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh, size: 24.w),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            onPressed: _refreshData,
          ),
        ],
      ),
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  Widget _buildLoading(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          SizedBox(height: 16.h),
          Text(
            'Loading earnings...',
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty notice ──────────────────────────────────────────────────────────

  Widget _buildEmptyNotice(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'No confirmed bookings yet. Earnings will appear here.',
              style: TextStyle(
                fontSize: 14.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick stats card ──────────────────────────────────────────────────────

  Widget _buildQuickStats(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Earnings',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'GHS ${_stats['totalEarnings']?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.bookmark_outline, size: 14.w, color: Colors.green),
                    SizedBox(width: 4.w),
                    Text(
                      '${_stats['totalBookings'] ?? 0} bookings',
                      style: TextStyle(fontSize: 12.sp, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 60.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avg Booking',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'GHS ${_stats['averageBookingValue']?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.trending_up_outlined, size: 14.w, color: theme.colorScheme.primary),
                    SizedBox(width: 4.w),
                    Text(
                      'Per booking',
                      style: TextStyle(fontSize: 12.sp, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── View toggle ───────────────────────────────────────────────────────────

  Widget _buildViewToggle(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleTab('overview', 'Overview', theme)),
          SizedBox(width: 8.w),
          Expanded(child: _buildToggleTab('details', 'Details', theme)),
        ],
      ),
    );
  }

  Widget _buildToggleTab(String value, String label, ThemeData theme) {
    final isActive = _selectedView == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedView = value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: isActive
              ? [BoxShadow(color: theme.shadowColor.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 1))]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }

  // ── Summary (overview tab) ────────────────────────────────────────────────

  Widget _buildSummary(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Summary',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          _buildStatRow('This Week', 'GHS ${_stats['weeklyEarnings']?.toStringAsFixed(2) ?? '0.00'}',
              '${_stats['weeklyBookings'] ?? 0} bookings', Icons.calendar_today_outlined, Colors.blue, theme),
          SizedBox(height: 12.h),
          _buildStatRow('This Month', 'GHS ${_stats['monthlyEarnings']?.toStringAsFixed(2) ?? '0.00'}',
              '${_stats['monthlyBookings'] ?? 0} bookings', Icons.trending_up_outlined, Colors.green, theme),
          SizedBox(height: 12.h),
          _buildStatRow('This Year', 'GHS ${_stats['yearlyEarnings']?.toStringAsFixed(2) ?? '0.00'}',
              '${_stats['yearlyBookings'] ?? 0} bookings', Icons.attach_money_outlined, Colors.orange, theme),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String title,
    String amount,
    String subtitle,
    IconData icon,
    Color accentColor,
    ThemeData theme,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.w, color: accentColor),
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
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Details tab ───────────────────────────────────────────────────────────

  Widget _buildEarningsDetails(ThemeData theme) {
    final sortedBookings = List<BookingModel>.from(_confirmedBookings)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Earnings',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          if (sortedBookings.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_outlined, size: 64.w,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  SizedBox(height: 16.h),
                  Text(
                    'No earnings yet',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: sortedBookings
                  .take(10)
                  .map((booking) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildEarningItem(booking, theme),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEarningItem(BookingModel booking, ThemeData theme) {
    final isCheckedIn = booking.status == 'checked-in';
    final statusLabel = isCheckedIn ? 'checked-in' : 'confirmed';
    final statusColor = isCheckedIn ? Colors.blue : Colors.green;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.business_outlined, size: 20.w, color: theme.colorScheme.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.hostelName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${booking.userName} • ${_formatDate(booking.createdAt)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'GHS ${booking.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  BoxDecoration _cardDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: theme.shadowColor.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
