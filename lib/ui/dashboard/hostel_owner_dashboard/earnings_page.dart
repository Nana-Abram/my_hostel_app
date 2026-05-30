import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/backend/service/booking_service.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/core/app_logger.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';

class EarningsPage extends ConsumerStatefulWidget {
  const EarningsPage({super.key});

  @override
  ConsumerState<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends ConsumerState<EarningsPage> { 
  String _selectedView = 'overview'; // overview, details
  bool _isLoading = true;
  List<BookingModel> _confirmedBookings = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEarningsData();
    });
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
      
      // Fallback without orderBy
      if (e.toString().contains('index') || e.toString().contains('failed-precondition')) {
        try {
          final querySnapshot = await FirebaseFirestore.instance
              .collection('bookings')
              .where('ownerId', isEqualTo: user.id)
              .where('status', whereIn: ['confirmed', 'checked-in'])
              .get();
          
          _confirmedBookings = querySnapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList();
          
          _confirmedBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
    final monthStart = DateTime(now.year, now.month, 1);
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final yearStart = DateTime(now.year, 1, 1);

    double totalEarnings = 0;
    double monthlyEarnings = 0;
    double weeklyEarnings = 0;
    double yearlyEarnings = 0;
    int totalBookings = 0;
    int monthlyBookings = 0;
    int weeklyBookings = 0;
    int yearlyBookings = 0;

    for (var booking in _confirmedBookings) {
      final amount = booking.totalPrice;
      final bookingDate = booking.createdAt;
      
      totalEarnings += amount;
      totalBookings++;
      
      if (bookingDate.isAfter(monthStart)) {
        monthlyEarnings += amount;
        monthlyBookings++;
      }
      
      if (bookingDate.isAfter(weekStart)) {
        weeklyEarnings += amount;
        weeklyBookings++;
      }
      
      if (bookingDate.isAfter(yearStart)) {
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
      'averageBookingValue': totalBookings > 0 ? totalEarnings / totalBookings : 0,
    };
  }


  Future<void> _refreshData() async {
    await _loadEarningsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IconAndTextWidget(
                    icon: Icons.arrow_back_ios,
                    text: 'Back',
                    iconColor: Colors.blueGrey,
                    isBackArrow: true,
                  ),
                  SizedBox(height: 16.h),
                  Row(
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
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Track your booking earnings',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, size: 24.w),
                        onPressed: _refreshData,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.blueColor),
                      SizedBox(height: 16.h),
                      Text(
                        'Loading earnings...',
                        style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      // No bookings message
                      if (_confirmedBookings.isEmpty)
                        Container(
                          padding: EdgeInsets.all(16.w),
                          margin: EdgeInsets.only(bottom: 20.h),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'No confirmed bookings yet. Earnings will appear here.',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: [
                            // Quick Stats
                            _buildQuickStats(),
                            SizedBox(height: 24.h),
                            
                            // View Toggle
                            _buildViewToggle(),
                            SizedBox(height: 24.h),
                            
                            // Content
                            _selectedView == 'details' 
                                ? _buildEarningsDetails() 
                                : _buildSummary(),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.checkColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Earnings', style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey)),
                SizedBox(height: 4.h),
                Text('GHS ${_stats['totalEarnings']?.toStringAsFixed(2) ?? '0.00'}', 
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 8.h),
                Row(children: [
                  Icon(Icons.bookmark_outline, size: 14.w, color: Colors.green),
                  SizedBox(width: 4.w),
                  Text('${_stats['totalBookings'] ?? 0} bookings', 
                    style: TextStyle(fontSize: 12.sp, color: Colors.green)),
                ]),
              ],
            ),
          ),
          Container(width: 1, height: 60.h, color: Colors.grey[200], margin: EdgeInsets.symmetric(horizontal: 16.w)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Avg Booking', style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey)),
                SizedBox(height: 4.h),
                Text('GHS ${_stats['averageBookingValue']?.toStringAsFixed(2) ?? '0.00'}', 
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 8.h),
                Row(children: [
                  Icon(Icons.trending_up_outlined, size: 14.w, color: AppColors.blueColor),
                  SizedBox(width: 4.w),
                  Text('Per booking', style: TextStyle(fontSize: 12.sp, color: AppColors.blueColor)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedView = 'overview'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: _selectedView == 'overview' ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: _selectedView == 'overview' ? [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))] : [],
                ),
                child: Center(child: Text('Overview', style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: _selectedView == 'overview' ? FontWeight.w600 : FontWeight.normal,
                  color: _selectedView == 'overview' ? AppColors.blueColor : Colors.blueGrey,
                ))),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedView = 'details'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: _selectedView == 'details' ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: _selectedView == 'details' ? [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))] : [],
                ),
                child: Center(child: Text('Details', style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: _selectedView == 'details' ? FontWeight.w600 : FontWeight.normal,
                  color: _selectedView == 'details' ? AppColors.blueColor : Colors.blueGrey,
                ))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance Summary', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
          SizedBox(height: 16.h),
          _buildStatRow('This Week', 'GHS ${_stats['weeklyEarnings']?.toStringAsFixed(2) ?? '0.00'}', '${_stats['weeklyBookings'] ?? 0} bookings', Icons.calendar_today_outlined, Colors.blue),
          SizedBox(height: 12.h),
          _buildStatRow('This Month', 'GHS ${_stats['monthlyEarnings']?.toStringAsFixed(2) ?? '0.00'}', '${_stats['monthlyBookings'] ?? 0} bookings', Icons.trending_up_outlined, Colors.green),
          SizedBox(height: 12.h),
          _buildStatRow('This Year', 'GHS ${_stats['yearlyEarnings']?.toStringAsFixed(2) ?? '0.00'}', '${_stats['yearlyBookings'] ?? 0} bookings', Icons.attach_money_outlined, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildEarningsDetails() {
    final sortedBookings = List<BookingModel>.from(_confirmedBookings)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Earnings', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
          SizedBox(height: 16.h),
          if (sortedBookings.isEmpty)
            Center(child: Column(children: [
              Icon(Icons.receipt_outlined, size: 64.w, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              Text('No earnings yet', style: TextStyle(fontSize: 16.sp, color: Colors.grey[600])),
            ]))
          else
            Column(
              children: sortedBookings.take(10).map((booking) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildEarningItem(booking),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String title, String amount, String subtitle, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, size: 20.w, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey)),
              SizedBox(height: 4.h),
              Text(amount, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
            ]),
          ),
          Text(subtitle, style: TextStyle(fontSize: 12.sp, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEarningItem(BookingModel booking) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: AppColors.blueColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
            child: Icon(Icons.business_outlined, size: 20.w, color: AppColors.blueColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(booking.hostelName, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black87)),
              SizedBox(height: 4.h),
              Text('${booking.userName} • ${_formatDate(booking.createdAt)}', style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('GHS ${booking.totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.green)),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4.r)),
              child: Text('confirmed', style: TextStyle(fontSize: 10.sp, color: Colors.green, fontWeight: FontWeight.w600)),
            ),
          ]),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ChartData {
  final String x;
  final double y;
  final Color color;
  
  ChartData(this.x, this.y, this.color);
}