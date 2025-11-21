import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/provider/room_provider.dart';
import 'package:my_hostel_app/ui/hostels/available_rooms.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class ViewRooms extends ConsumerWidget {
  const ViewRooms({super.key, required this.hostel,});
  final HostelModel hostel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsByHostelProvider(hostel.id));
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Rooms'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body:   // Rooms list with proper loading/error states
        roomsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 40.sp),
                SizedBox(height: 10.h),
                SmallText(
                  text: "Failed to load rooms",
                  color: Colors.red,
                  size: 12.sp,
                ),
              ],
            ),
          ),
          data: (rooms) {
            if (rooms.isEmpty) {
              return _buildNoRoomsAvailable();
            }
            return SingleChildScrollView(
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(20.w),
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    children: rooms
                        .map((room) => Padding(
                          padding: EdgeInsets.only(bottom: 15.h),
                          child: AvailableRooms(room: room, hostel: hostel, isHostelOwner: true,),
                        ))
                        .toList(),
                  ),
                ),
              ),
            );
          },
        ), 
    
    );
  }
}
  Widget _buildNoRoomsAvailable() {
    return Container(
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(Icons.hotel, size: 50.sp, color: Colors.grey),
          SizedBox(height: 15.h),
          BigText(
            text: "No rooms available",
            color: Colors.grey,
            size: 16.sp,
          ),
          SizedBox(height: 10.h),
          SmallText(
            text: "Check back later for new room listings",
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }
