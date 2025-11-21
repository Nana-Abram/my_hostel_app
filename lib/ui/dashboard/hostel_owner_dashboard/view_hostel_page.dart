import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/view_rooms.dart';
import 'package:my_hostel_app/ui/hostels/image_slider_h_d.dart';

class ViewHostelPage extends StatelessWidget {
  final HostelModel hostel;
  
  const ViewHostelPage({super.key, required this.hostel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hostel Details'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
         floatingActionButton: SizedBox(
          height: 40.h,
          width: 130.w,
           child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewRooms(hostel: hostel),
                  ),
                );
              },
              backgroundColor: Colors.blue[700],
           
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_outlined, size: 18.sp, color: Colors.white),
                  SizedBox(width: 5.w),
                  Text(
                    'View Rooms',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500,color: Colors.white),
                  ),
                ],
              ),
            ),
         ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hostel Images Carousel
            HostelImageCarousel(images: hostel.images),
            SizedBox(height: 20.h),
            
            // Basic Information
            
            _buildSectionHeader('Basic Information'),
            _buildInfoRow('Hostel Name', hostel.name),
            _buildInfoRow('Campus', hostel.campus),
            _buildInfoRow('Location', hostel.location),
            _buildInfoRow('Owner Name', hostel.ownerName),
            _buildInfoRow('Total Rooms', '${hostel.totalRooms.toInt()}'),
            
            SizedBox(height: 20.h),
            
            // Pricing and Ratings
            _buildSectionHeader('Pricing & Ratings'),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Starting Price',
                    'GHS ${hostel.startPrice.toInt()}/year',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: _buildInfoCard(
                    'Rating',
                    hostel.rating.toStringAsFixed(1),
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: _buildInfoCard(
                    'Reviews',
                    hostel.reviewsCount.toInt().toString(),
                    Icons.reviews,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20.h),
            
            // Status
            _buildSectionHeader('Status'),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _getStatusColor(hostel.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStatusColor(hostel.status)),
              ),
              child: Text(
                hostel.status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(hostel.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Description
            _buildSectionHeader('Description'),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                hostel.description,
                style: TextStyle(fontSize: 14.sp, height: 1.5),
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Amenities
            _buildSectionHeader('Amenities'),
            _buildAmenitiesGrid(),
            
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // Widget _buildImageCarousel() {
  //   if (hostel.images.isEmpty) {
  //     return Container(
  //       height: 200.h,
  //       width: double.infinity,
  //       decoration: BoxDecoration(
  //         color: Colors.grey[200],
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(Icons.photo_library, size: 50, color: Colors.grey[400]),
  //           SizedBox(height: 8.h),
  //           Text('No Images Available', style: TextStyle(color: Colors.grey[500])),
  //         ],
  //       ),
  //     );
  //   }

  //   return Column(
  //     children: [
  //       Container(
  //         height: 250.h,
  //         width: double.infinity,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(12),
  //           image: DecorationImage(
  //             image: NetworkImage(hostel.images.first),
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //       ),
  //       SizedBox(height: 10.h),
  //       if (hostel.images.length > 1)
  //         SizedBox(
  //           height: 80.h,
  //           child: ListView.builder(
  //             scrollDirection: Axis.horizontal,
  //             itemCount: hostel.images.length,
  //             itemBuilder: (context, index) {
  //               return Container(
  //                 width: 80.w,
  //                 height: 80.h,
  //                 margin: EdgeInsets.only(right: 8.w),
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(8),
  //                   image: DecorationImage(
  //                     image: NetworkImage(hostel.images[index]),
  //                     fit: BoxFit.cover,
  //                   ),
  //                   border: Border.all(
  //                     color: index == 0 ? Colors.blue : Colors.grey[300]!,
  //                     width: index == 0 ? 2 : 1,
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //     ],
  //   );
  // }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp),
            ),
          ),
        
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesGrid() {
    if (hostel.amenities.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Text(
            'No amenities listed',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: hostel.amenities.map((amenity) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.blue[700], size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                amenity.toString(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'suspended':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}