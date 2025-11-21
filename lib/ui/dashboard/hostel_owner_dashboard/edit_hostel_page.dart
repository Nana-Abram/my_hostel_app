import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/backend/provider/room_provider.dart';
import 'package:my_hostel_app/backend/service/image_upload_service.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/edit_rooms_page.dart';

class EditHostelPage extends ConsumerStatefulWidget {
  final HostelModel hostel;

  const EditHostelPage({super.key, required this.hostel});

  @override
  ConsumerState<EditHostelPage> createState() => _EditHostelPageState();
}

class _EditHostelPageState extends ConsumerState<EditHostelPage> {
  final _formKey = GlobalKey<FormState>();

  // --- INPUT CONTROLLERS ---
  late final nameCtrl = TextEditingController(text: widget.hostel.name);
  late final campusCtrl = TextEditingController(text: widget.hostel.campus);
  late final descriptionCtrl = TextEditingController(
    text: widget.hostel.description,
  );
  late final startPriceCtrl = TextEditingController(
    text: widget.hostel.startPrice.toString(),
  );
  late final reviewCountCtrl = TextEditingController(
    text: widget.hostel.reviewsCount.toString(),
  );
  late final locationCtrl = TextEditingController(text: widget.hostel.location);
  late final ratingCtrl = TextEditingController(
    text: widget.hostel.rating.toString(),
  );
  late final ownerNameCtrl = TextEditingController(
    text: widget.hostel.ownerName,
  );
  late final totalRoomsCtrl = TextEditingController(
    text: widget.hostel.totalRooms.toString(),
  );

  late String selectedStatus = widget.hostel.status;

  // --- DATA HOLDERS ---
  late List<String> amenities = List.from(widget.hostel.amenities);
  late List<String> images = List.from(widget.hostel.images);
  bool isUploading = false;

  final status = ["Verified", "Pending", "Suspended"];

  @override
  void dispose() {
    nameCtrl.dispose();
    campusCtrl.dispose();
    descriptionCtrl.dispose();
    startPriceCtrl.dispose();
    reviewCountCtrl.dispose();
    locationCtrl.dispose();
    ratingCtrl.dispose();
    ownerNameCtrl.dispose();
    totalRoomsCtrl.dispose();
    super.dispose();
  }

  // Pick Image → Upload → Save URL (same as AddHostelPage)
  Future<void> pickAndUploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      if (file.bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not read image file")),
        );
        return;
      }

      setState(() => isUploading = true);

      final imageService = ImageUploadService();
      final url = await imageService.uploadImage(file.bytes!, file.name);

      setState(() {
        images.add(url);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: ${e.toString()}")));
    } finally {
      if (mounted) {
        setState(() => isUploading = false);
      }
    }
  }

  // Update Hostel
  Future<void> _updateHostel() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedHostel = HostelModel(
      id: widget.hostel.id, // Keep the same ID
      name: nameCtrl.text.trim(),
      campus: campusCtrl.text.trim(),
      description: descriptionCtrl.text.trim(),
      ownerName: ownerNameCtrl.text.trim(),
      totalRooms: double.parse(totalRoomsCtrl.text),
      amenities: amenities,
      images: images,
      startPrice: double.parse(startPriceCtrl.text),
      rating: ratingCtrl.text.isEmpty
          ? widget.hostel.rating
          : double.parse(ratingCtrl.text),
      reviewsCount: reviewCountCtrl.text.isEmpty
          ? widget.hostel.reviewsCount
          : double.parse(reviewCountCtrl.text),
      location: locationCtrl.text.trim(),
      status: selectedStatus,
      ownerId: widget.hostel.ownerId, // Keep the same ownerId
    );

    try {
      final service = ref.read(hostelServiceProvider);
      await service.updateHostel(widget.hostel.id, updatedHostel);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hostel updated successfully")),
      );

      Navigator.pop(context); // Go back to previous page
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update hostel: $e")));
    }
  }

  void _removeImage(String imageUrl) {
    setState(() {
      images.remove(imageUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get rooms for this specific hostel
    final roomsAsync = ref.watch(roomsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Hostel'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          Tooltip(
            message: 'Save Changes',
            child: IconButton(
              icon: Icon(Icons.save),
              onPressed: _updateHostel,
            ),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout - switch to column on small screens
          if (constraints.maxWidth < 1000) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Hostel Edit Form
                  _buildHostelForm(),
                  SizedBox(height: 20.h),
                  // Rooms List
                  _buildRoomsSection(roomsAsync, isSmallScreen: true),
                ],
              ),
            );
          } else {
            // Desktop layout - side by side
            return Row(
              children: [
                // Left side: Hostel Edit Form
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(child: _buildHostelForm()),
                ),
                // Right side: Rooms List
                Expanded(
                  flex: 1,
                  child: _buildRoomsSection(roomsAsync),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildHostelForm() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _input("Hostel Name", nameCtrl),
            _input("Campus", campusCtrl),
            _input("Location", locationCtrl),
            _input(
              "Starting Price (GHS)",
              startPriceCtrl,
              keyboard: TextInputType.number,
            ),
            _input(
              "Rating",
              ratingCtrl,
              keyboard: TextInputType.number,
            ),
            _input(
              "Review Count",
              reviewCountCtrl,
              keyboard: TextInputType.number,
            ),
            _input("Owner Name", ownerNameCtrl),
            _input(
              "Total Rooms",
              totalRoomsCtrl,
              keyboard: TextInputType.number,
            ),
            _input("Description", descriptionCtrl, maxLines: 3),

            SizedBox(height: 25.h),

            DropdownButtonFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              hint: Text("Status"),
              value: selectedStatus,
              items: status
                  .map(
                    (t) => DropdownMenuItem(value: t, child: Text(t)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedStatus = v!),
            ),

            SizedBox(height: 25.h),

            Text("Amenities", style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                _amenityChip("Wi-Fi"),
                _amenityChip("Kitchen"),
                _amenityChip("Study Room"),
                _amenityChip("Security"),
                _amenityChip("Laundry"),
                _amenityChip("Parking"),
                _amenityChip("Gym"),
                _amenityChip("Air Conditioning"),
                _amenityChip("Pool"),
                _amenityChip("DSTV"),
              ],
            ),

            SizedBox(height: 30.h),
            Text(
              "Hostel Images",
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 10.h),

            isUploading
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: pickAndUploadImage,
                    icon: Icon(Icons.add_photo_alternate),
                    label: Text("Add More Images"),
                  ),

            SizedBox(height: 10.h),

            if (images.isNotEmpty) ...[
              Text(
                "Current Images (${images.length})",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: images.map((img) => _imagePreview(img)).toList(),
              ),
            ],

            SizedBox(height: 40.h),

            ElevatedButton(
              onPressed: _updateHostel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50.h),
              ),
              child: Text(
                'Update Hostel',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomsSection(AsyncValue<List<dynamic>> roomsAsync, {bool isSmallScreen = false}) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rooms in this Hostel",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 16.h),

          // Rooms List
          roomsAsync.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error loading rooms: $error'),
            data: (allRooms) {
              // Filter rooms for this specific hostel
              final hostelRooms = allRooms
                  .where((room) => room.hostelId == widget.hostel.id)
                  .toList();

              if (hostelRooms.isEmpty) {
                return Column(
                  children: [
                    Icon(
                      Icons.meeting_room,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No Rooms Added',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to add room page for this hostel
                      },
                      child: Text('Add First Room'),
                    ),
                  ],
                );
              }

              return isSmallScreen
                  ? Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      children: hostelRooms.map((room) => _buildRoomCard(room)).toList(),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: hostelRooms.map((room) => _buildRoomCard(room)).toList(),
                        ),
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(room) {
    return Container(
      width: _calculateCardWidth(), // Responsive width
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// IMAGE SECTION
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: room.image.isNotEmpty
                ? ImageNetwork(
                    image: room.image,
                    height: 80.h,
                    width: 80.w,
                    fitWeb: BoxFitWeb.cover,
                  )
                : Container(
                    height: 80.h,
                    width: 80.w,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.meeting_room,
                      size: 35.sp,
                    ),
                  ),
          ),

          SizedBox(width: 12.w),

          /// TEXT SECTION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.type,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 4.h),

                Text(
                  "GHS ${room.price}",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  "${room.capacity} students",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),

          /// EDIT BUTTON
          Tooltip(
            message: 'Edit Room',
            child: IconButton(
              icon: Icon(Icons.edit, color: Colors.blue, size: 20.sp),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditRoomPage(room: room),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _calculateCardWidth() {
    // Responsive card width based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return screenWidth - 32.w; // Full width on mobile
    } else if (screenWidth < 1000) {
      return (screenWidth / 2) - 24.w; // 2 cards per row on tablet
    } else {
      return 0.4.sw; // Fixed width on desktop
    }
  }

  Widget _input(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 6.h),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboard,
          validator: (v) =>
              v == null || v.isEmpty ? "This field is required" : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _amenityChip(String title) {
    final selected = amenities.contains(title);
    return GestureDetector(
      onTap: () {
        setState(() {
          selected ? amenities.remove(title) : amenities.add(title);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? Colors.blueAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _imagePreview(String imageUrl) {
    return Container(
      width: 140.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          ImageNetwork(
            image:imageUrl,
            height: 90.h,
            width: 120.w,
            fitWeb: BoxFitWeb.cover,
            fitAndroidIos: BoxFit.cover,
            borderRadius: BorderRadius.circular(10.r),
          ),
          TextButton(
            onPressed: () => _removeImage(imageUrl),
            child: Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}