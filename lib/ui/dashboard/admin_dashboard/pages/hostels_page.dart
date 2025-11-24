import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/provider/admin_hostel_provider.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';

class HostelsManagementPage extends ConsumerStatefulWidget {
  const HostelsManagementPage({super.key});

  @override
  ConsumerState<HostelsManagementPage> createState() =>
      _HostelsManagementPageState();
}

class _HostelsManagementPageState extends ConsumerState<HostelsManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  // ignore: unused_field
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          _buildHeader(),
          SizedBox(height: 20.h),

          // QUICK STATS

          // USERS STATS
          Consumer(
            builder: (context, ref, child) {
              final statsAsync = ref.watch(hostelsStatsProvider);
              return statsAsync.when(
                data: (stats) => _buildHostelsStats(stats),
                loading: () => _buildStatsLoading(),
                error: (error, stack) => _buildStatsError(error),
              );
            },
          ),
          SizedBox(height: 24.h),

          // SEARCH AND FILTERS
          _buildSearchAndFilters(),
          SizedBox(height: 16.h),

          // HOSTELS LIST
          _buildHostelsList(),
        ],
      ),
    );
  }

  Widget _buildStatsLoading() {
    return Row(
      children: [
        for (int i = 0; i < 4; i++) ...[
          Expanded(
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
          if (i < 3) SizedBox(width: 12.w),
        ],
      ],
    );
  }

  Widget _buildStatsError(Object error) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Failed to load stats: $error',
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hostels Management',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Manage all hostel listings and verifications',
              style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHostelsStats(stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Hostels',
            value: '${stats['totalHostels'] ?? 0}',
            change: '+12%',
            isPositive: true,
            icon: Icons.business,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            title: 'Verified',
            value: '${stats['verifiedHostels'] ?? 0}',
            change: '+8%',
            isPositive: true,
            icon: Icons.verified,
            color: Colors.green,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            title: 'Pending',
            value: '${stats['pendingHostels'] ?? 0}',
            change: '-2%',
            isPositive: false,
            icon: Icons.pending,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 20.w, color: color),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // SEARCH BAR
          Expanded(
            child: Container(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18.w, color: Colors.blueGrey),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search hostels...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      style: TextStyle(fontSize: 14.sp),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // FILTER DROPDOWN
          Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilter,
                items: ['All', 'Verified', 'Pending', 'Suspended']
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: TextStyle(fontSize: 14.sp)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                },
                style: TextStyle(fontSize: 14.sp, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostelsList() {
    return Consumer(
      builder: (context, ref, child) {
        final hostelsAsync = ref.watch(hostelsStreamProvider);

        return hostelsAsync.when(
          data: (hostels) {
            if (hostels.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                // TABLE HEADER
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 60.w), // Image space
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Hostel Info',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Rooms',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      // Expanded(
                      //   child: Text(
                      //     'Occupancy',
                      //     style: TextStyle(
                      //       fontSize: 12.sp,
                      //       fontWeight: FontWeight.w600,
                      //       color: Colors.blueGrey,
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      SizedBox(width: 80.w), // Actions space
                    ],
                  ),
                ),

                // HOSTELS LIST
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: hostels
                        .map((hostel) => _buildHostelListItem(hostel))
                        .toList(),
                  ),
                ),
              ],
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error),
        );
      },
    );
  }

  Widget _buildHostelListItem(HostelModel hostel) {
    // Calculate occupancy percentage from occupancyRate
    // final occupancyPercent = (hostel.occupancyRate * 100).toInt();
    // final occupancyText = '$occupancyPercent%';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          // HOSTEL IMAGE
          SizedBox(
                  height: 100.h,
                  width: 100.w,
                  child: ImageNetwork(
                    image: hostel.images.first,

                    height: 100.h,
                    width: 100.w,

                    duration: 1500,
                    curve: Curves.easeIn,
                    onPointer: true,
                    debugPrint: false,
                    backgroundColor: Colors.blue,

                    fitWeb: BoxFitWeb.cover,
                    fitAndroidIos: BoxFit.cover,

                    borderRadius: BorderRadius.circular(8.r),
                    onLoading: const CircularProgressIndicator(
                      color: Colors.indigoAccent,
                    ),
                    onError: const Icon(Icons.error, color: Colors.red),

                  ),
          ),
          SizedBox(width: 12.w),

          // HOSTEL INFO
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hostel.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  hostel.location,
                  style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Owner: ${hostel.ownerName}',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.star, size: 14.w, color: Colors.orange),
                    SizedBox(width: 4.w),
                    Text(
                      hostel.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ROOMS
          Expanded(
            child: Text(
              '${hostel.totalRooms.toInt()} rooms',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          // STATUS
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _getStatusColor(hostel.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _getStatusColor(hostel.status).withOpacity(0.3),
                ),
              ),
              child: Text(
                _getStatusText(hostel.status),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: _getStatusColor(hostel.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // ACTIONS
          SizedBox(
            width: 80.w,
            child: PopupMenuButton<String>(
              onSelected: (value) => _handleHostelAction(value, hostel),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 16.w,
                        color: Colors.blueGrey,
                      ),
                      SizedBox(width: 8.w),
                      const Text('View Details'),
                    ],
                  ),
                ),
       
                if (hostel.status.toLowerCase() == 'pending')
                  PopupMenuItem(
                    value: 'verify',
                    child: Row(
                      children: [
                        Icon(Icons.verified, size: 16.w, color: Colors.green),
                        SizedBox(width: 8.w),
                        const Text('Verify'),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'suspend',
                  child: Row(
                    children: [
                      Icon(
                        Icons.pause_circle,
                        size: 16.w,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 8.w),
                      const Text('Suspend'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16.w, color: Colors.red),
                      SizedBox(width: 8.w),
                      const Text('Delete'),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  Icons.more_vert,
                  size: 16.w,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.blueColor),
            SizedBox(height: 16.h),
            Text(
              'Loading hostels...',
              style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64.w, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'Failed to load hostels',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () {
              final ref = ProviderScope.containerOf(context);
              ref.refresh(hostelsProvider);
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(Icons.business_outlined, size: 64.w, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            'No Hostels Found',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            'There are no hostels matching your criteria.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: _addNewHostel,
            child: const Text('Add First Hostel'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
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


  // Action handlers
  void _onSearchChanged(String query) {
    // Implement search functionality
  }

  void _addNewHostel() {
    // Navigate to add hostel screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add hostel functionality coming soon')),
    );
  }

  void _handleHostelAction(String action, HostelModel hostel) {
    switch (action) {
      case 'view':
        _viewHostelDetails(hostel);
        break;
      case 'verify':
        _verifyHostel(hostel);
        break;
      case 'suspend':
        _suspendHostel(hostel);
        break;
      case 'delete':
        _deleteHostel(hostel);
        break;
    }
  }

  void _viewHostelDetails(HostelModel hostel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hostel.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: ${hostel.location}'),
            Text('Owner: ${hostel.ownerName}'),
            Text('Total Rooms: ${hostel.totalRooms.toInt()}'),
            // Text('Occupancy: ${(hostel.occupancyRate * 100).toInt()}%'),
            Text('Rating: ${hostel.rating.toStringAsFixed(1)}'),
            Text('Status: ${_getStatusText(hostel.status)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }


  void _verifyHostel(HostelModel hostel) {
    final hostelsService = HostelsService();
    try {
      hostelsService.verifyHostel(hostel.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Verified ${hostel.name}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to verify: $e')));
    }
  }

  void _suspendHostel(HostelModel hostel) {
    final hostelsService = HostelsService();
    try {
      hostelsService.suspendHostel(hostel.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Suspended ${hostel.name}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to suspend: $e')));
    }
  }

  void _deleteHostel(HostelModel hostel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hostel'),
        content: Text('Are you sure you want to delete ${hostel.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final hostelsService = HostelsService();
              try {
                hostelsService.deleteHostel(hostel.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted ${hostel.name}')),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
