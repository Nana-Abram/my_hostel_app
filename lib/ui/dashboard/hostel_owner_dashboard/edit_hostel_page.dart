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
  late final videoTourUrlCtrl = TextEditingController(
    text: widget.hostel.videoTourUrl ?? '',
  );

  final status = ["Verified", "Pending", "Suspended"];
  late String selectedStatus = status.contains(widget.hostel.status)
      ? widget.hostel.status
      : status.first;

  // --- DATA HOLDERS ---
  late List<String> images = List.from(widget.hostel.images);
  bool isUploading = false;
  bool isUploadingVideo = false;
  
  // Track images/videos to delete from Firebase Storage
  final List<String> imagesToDelete = [];
  String? videoToDelete;

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
    videoTourUrlCtrl.dispose();
    super.dispose();
  }

  // Pick Video → Upload → Save URL into controller
  Future<void> pickAndUploadVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'webm'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      if (file.bytes == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not read video file")),
          );
        }
        return;
      }

      setState(() => isUploadingVideo = true);

      final imageService = ImageUploadService();

      // Delete old video from Storage if replacing
      final oldUrl = videoTourUrlCtrl.text.trim();
      if (oldUrl.isNotEmpty && oldUrl.contains('firebasestorage')) {
        videoToDelete = oldUrl; // Mark old video for deletion
      }

      final url = await imageService.uploadVideo(file.bytes!, file.name);

      setState(() {
        videoTourUrlCtrl.text = url;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video uploaded successfully!")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Video upload failed: ${e.toString()}")),
        );
        print("Video upload error: $e");
      }
    } finally {
      if (mounted) {
        setState(() => isUploadingVideo = false);
      }
    }
  }

  void _removeVideo() {
    final oldUrl = videoTourUrlCtrl.text.trim();
    if (oldUrl.isNotEmpty && oldUrl.contains('firebasestorage')) {
      videoToDelete = oldUrl; // Mark for deletion on update
    }
    setState(() {
      videoTourUrlCtrl.clear();
    });
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not read image file")),
          );
        }
        return;
      }

      setState(() => isUploading = true);

      final imageService = ImageUploadService();
      final url = await imageService.uploadImage(file.bytes!, file.name);

      setState(() {
        images.add(url);
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image uploaded successfully!")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Upload failed: ${e.toString()}")));
      }
    } finally {
      if (mounted) {
        setState(() => isUploading = false);
      }
    }
  }

  // Delete files from Firebase Storage
  Future<void> _deleteUnusedFiles() async {
    final imageService = ImageUploadService();
    
    // Delete marked video
    if (videoToDelete != null && videoToDelete!.contains('firebasestorage')) {
      try {
        await imageService.deleteImage(videoToDelete!);
        print("Deleted video from storage: $videoToDelete");
      } catch (e) {
        print("Error deleting video from storage: $e");
        // Continue with update even if deletion fails
      }
    }
    
    // Delete marked images
    for (final imageUrl in imagesToDelete) {
      if (imageUrl.contains('firebasestorage')) {
        try {
          await imageService.deleteImage(imageUrl);
          print("Deleted image from storage: $imageUrl");
        } catch (e) {
          print("Error deleting image from storage: $e");
          // Continue with update even if deletion fails
        }
      }
    }
  }

  // Update Hostel
  Future<void> _updateHostel() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // First delete unused files from storage
      await _deleteUnusedFiles();
      
      // Then update the hostel data
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
        videoTourUrl: videoTourUrlCtrl.text.trim().isEmpty ? null : videoTourUrlCtrl.text.trim(),
      );

      final service = ref.read(hostelServiceProvider);
      await service.updateHostel(widget.hostel.id, updatedHostel);

      // Clear deletion lists after successful update
      imagesToDelete.clear();
      videoToDelete = null;

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hostel updated successfully")),
        );

        // Use addPostFrameCallback to pop page after the current frame completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pop(context); // Go back to previous page
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update hostel: $e")),
        );
      }
    }
  }

  void _removeImage(String imageUrl) {
    // Check if it's a Firebase Storage URL before marking for deletion
    if (imageUrl.contains('firebasestorage')) {
      imagesToDelete.add(imageUrl);
    }
    
    setState(() {
      images.remove(imageUrl);
    });
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image marked for removal. It will be deleted when you save changes.")),
      );
    }
  }

  // Helper to get amenities list
  late List<String> amenities = List.from(widget.hostel.amenities);

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
          // Show indicator if there are files to delete
          if (imagesToDelete.isNotEmpty || videoToDelete != null)
            Tooltip(
              message: '${imagesToDelete.length} image(s) and ${videoToDelete != null ? '1 video' : '0 videos'} will be deleted',
              child: Badge(
                label: Text('${imagesToDelete.length + (videoToDelete != null ? 1 : 0)}'),
                child: IconButton(
                  icon: Icon(Icons.save),
                  onPressed: _updateHostel,
                ),
              ),
            )
          else
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

            // --- Video Tour Section ---
            _buildVideoTourSection(),

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

            // Show warning if images will be deleted
            if (imagesToDelete.isNotEmpty)
              Container(
                padding: EdgeInsets.all(8.w),
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "${imagesToDelete.length} image(s) will be deleted from storage when you save",
                        style: TextStyle(fontSize: 11.sp, color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),

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
    final isMarkedForDeletion = imagesToDelete.contains(imageUrl);
    
    return Container(
      width: 140.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: isMarkedForDeletion ? Colors.red.shade300 : Colors.grey.shade300,
          width: isMarkedForDeletion ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ImageNetwork(
                image: imageUrl,
                height: 90.h,
                width: 120.w,
                fitWeb: BoxFitWeb.cover,
                fitAndroidIos: BoxFit.cover,
                borderRadius: BorderRadius.circular(10.r),
              ),
              if (isMarkedForDeletion)
                Container(
                  height: 90.h,
                  width: 120.w,
                  color: Colors.red.withOpacity(0.3),
                  child: Center(
                    child: Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                  ),
                ),
            ],
          ),
          TextButton(
            onPressed: () => _removeImage(imageUrl),
            child: Text(
              isMarkedForDeletion ? "Will be deleted" : "Remove",
              style: TextStyle(
                color: isMarkedForDeletion ? Colors.red : Colors.red,
                fontWeight: isMarkedForDeletion ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Video Tour section: pick from gallery OR paste a URL
  Widget _buildVideoTourSection() {
    final hasVideo = videoTourUrlCtrl.text.trim().isNotEmpty;
    final isVideoMarkedForDeletion = videoToDelete != null && videoTourUrlCtrl.text.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Video Tour (Optional)",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10.h),

        // Current video preview / status
        if (hasVideo || isVideoMarkedForDeletion) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isVideoMarkedForDeletion 
                ? Colors.red.shade50 
                : Colors.green.shade50,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isVideoMarkedForDeletion 
                  ? Colors.red.shade300 
                  : Colors.green.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isVideoMarkedForDeletion ? Icons.delete_forever : Icons.videocam,
                  color: isVideoMarkedForDeletion ? Colors.red[700] : Colors.green[700],
                  size: 28.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isVideoMarkedForDeletion 
                          ? "Video will be deleted"
                          : "Video attached",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                          color: isVideoMarkedForDeletion 
                            ? Colors.red[700]
                            : Colors.green[700],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      if (hasVideo)
                        Text(
                          videoTourUrlCtrl.text.trim(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: isVideoMarkedForDeletion 
                              ? Colors.red[600]
                              : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isVideoMarkedForDeletion ? Colors.red : Colors.red,
                    size: 20.sp,
                  ),
                  tooltip: isVideoMarkedForDeletion 
                    ? 'Video marked for deletion' 
                    : 'Remove video',
                  onPressed: isVideoMarkedForDeletion ? null : _removeVideo,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
        ],

        // Upload & URL buttons
        if (isUploadingVideo)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              children: [
                SizedBox(
                  width: 22.w,
                  height: 22.h,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12.w),
                Text("Uploading video...", style: TextStyle(fontSize: 12.sp)),
              ],
            ),
          )
        else
          Row(
            children: [
              // Pick from device
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: pickAndUploadVideo,
                  icon: Icon(Icons.video_library, size: 18.sp),
                  label: Text("Pick Video", style: TextStyle(fontSize: 12.sp)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(color: Colors.blue.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // Paste URL
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showVideoUrlDialog,
                  icon: Icon(Icons.link, size: 18.sp),
                  label: Text("Paste URL", style: TextStyle(fontSize: 12.sp)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(color: Colors.orange.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
            ],
          ),

        SizedBox(height: 10.h),
      ],
    );
  }

  void _showVideoUrlDialog() {
    final urlCtrl = TextEditingController(text: videoTourUrlCtrl.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Enter Video URL"),
        content: TextField(
          controller: urlCtrl,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: "https://...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: Icon(Icons.link),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newUrl = urlCtrl.text.trim();
              // If replacing an existing Firebase Storage video, mark it for deletion
              final oldUrl = videoTourUrlCtrl.text.trim();
              if (oldUrl.isNotEmpty && 
                  oldUrl.contains('firebasestorage') &&
                  oldUrl != newUrl) {
                videoToDelete = oldUrl;
              }
              
              setState(() {
                videoTourUrlCtrl.text = newUrl;
              });
              Navigator.pop(ctx);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}