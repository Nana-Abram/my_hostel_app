
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/backend/service/image_upload_service.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/add_rooms.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/modern/modern_widgets.dart';

class AddHostelPage extends ConsumerStatefulWidget {
  const AddHostelPage({super.key});

  @override
  ConsumerState<AddHostelPage> createState() => _AddHostelPageState();
}

class _AddHostelPageState extends ConsumerState<AddHostelPage> {
  final _formKey = GlobalKey<FormState>();

  // --- INPUT CONTROLLERS ---
  final nameCtrl = TextEditingController();
  final campusCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final startPriceCtrl = TextEditingController();
  final reviewCountCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final ratingCtrl = TextEditingController();
  final ownerNameCtrl = TextEditingController();
  final totalRoomsCtrl = TextEditingController();
  final videoTourUrlCtrl = TextEditingController();

  

  // --- DATA HOLDERS ---
  List<String> amenities = [];
  List<String> images = []; // Firebase Storage URLs (final saved)
  bool isUploading = false;
  bool isUploadingVideo = false;

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
        try {
          await imageService.deleteImage(oldUrl);
        } catch (_) {} // Ignore if old file doesn't exist
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
      ImageUploadService().deleteImage(oldUrl).catchError((_) {});
    }
    setState(() {
      videoTourUrlCtrl.clear();
    });
  }

// Pick Image → Upload → Save URL
Future<void> pickAndUploadImage() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    
    // Null safety check
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Upload failed: ${e.toString()}")),
    );
  } finally {
    // Always set uploading to false, even if error occurs
    if (mounted) {
      setState(() => isUploading = false);
    }
  }
}

  void _removeImage(String imageUrl) {
    setState(() {
      images.remove(imageUrl);
    });
  }

 // Update your _submit method to include ownerId
Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  if (images.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Add at least one image")),
    );
    return;
  }

// In your _submit method:
final currentUser = FirebaseAuth.instance.currentUser;
if (currentUser == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Please sign in to add a hostel")),
  );
  return;
}


  // You'll need to get the current user's ID - this depends on your auth setup
  // For now, I'll use a placeholder. You'll need to replace this with actual user ID
  final currentUserId = currentUser.uid;

  final hostel = HostelModel(
    id: "",
    name: nameCtrl.text.trim(),
    campus: campusCtrl.text.trim(),
    description: descriptionCtrl.text.trim(),
    ownerName: ownerNameCtrl.text.trim(),
    totalRooms: double.parse(totalRoomsCtrl.text),
    amenities: amenities,
    images: images,
    startPrice: double.parse(startPriceCtrl.text),
    rating: ratingCtrl.text.isEmpty ? 0.0 : double.parse(ratingCtrl.text), // Changed from 4.0 to 0.0
    reviewsCount: reviewCountCtrl.text.isEmpty ? 0.0 : double.parse(reviewCountCtrl.text), // Changed from 4.0 to 0.0
    location: locationCtrl.text.trim(),
    status: "Pending",
    ownerId: currentUserId, // ADD THIS LINE
    videoTourUrl: videoTourUrlCtrl.text.trim().isEmpty ? null : videoTourUrlCtrl.text.trim(),
  );

  try {
    final service = ref.read(hostelServiceProvider);
    await service.addHostel(hostel);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hostel added successfully")),
      );
    }

    // Clear form
    _formKey.currentState!.reset();
    amenities.clear();
    images.clear();
    setState(() {
    });
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add hostel: $e")),
      );
    }
  }
}

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text('Edit Hostel'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _submit,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF9FAFB),

      body: 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(20.w),
                  width: 0.4.sw,
                  padding: EdgeInsets.all(30.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SmallText(
                          text: "Create New Hostel",
                          size: 20.sp,
                          color: Colors.black,
                        ),
                        SizedBox(height: 20.h),
                            
                        _input("Hostel Name", nameCtrl),
                        _input("Campus", campusCtrl),
                        _input("Location", locationCtrl),
                        _input("Starting Price (GHS)", startPriceCtrl,
                            keyboard: TextInputType.number),
                        _input("Rating (Optional)", ratingCtrl,
                            keyboard: TextInputType.number),
                        _input("Reviw Count (Optional)", reviewCountCtrl,
                            keyboard: TextInputType.number),
                        _input("Owner Name", ownerNameCtrl),
                        _input("Total Rooms", totalRoomsCtrl,
                            keyboard: TextInputType.number),
                        _input("Description", descriptionCtrl, maxLines: 3),

                        // --- Video Tour Section ---
                        _buildVideoTourSection(),
                            
                        SizedBox(height: 25.h),
                                  
                        Text(
                          "Amenities",
                          style: TextStyle(fontSize: 14.sp),
                        ),
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
                        Text("Upload Images", style: TextStyle(fontSize: 14.sp)),
                        SizedBox(height: 10.h),
                            
                        isUploading
                            ? const CircularProgressIndicator()
                            : InkWell(
                              onTap: pickAndUploadImage,
                              child: ElvButtonWidget(
                                  text: "Choose Image",
                                ),
                            ),
                            
                        SizedBox(height: 10.h),
                        // Image previews
                    if (images.isNotEmpty) ...[
                      Text("Selected Images (${images.length})", 
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                      SizedBox(height: 10.h),
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: images.map((img) => _imagePreview(img)).toList(),
                      ),
                    ],
                            
                        SizedBox(height: 40.h),
                            
                        InkWell(
                          onTap:_submit ,
                          child: ElvButtonWidget(
                            text: "Submit Hostel",
                            isPrimary: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AdminAddRoomPage(),
            ],
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
          EnhancedCachedImage(
            imageUrl: imageUrl,
            height: 90.h,
            width: 120.w,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(8.r),
            showShimmer: false,
          ),
          TextButton(
            onPressed: () => _removeImage(imageUrl),
            child: const Text("Remove"),
          )
        ],
      ),
    );
  }

  // Reusable input field
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

  //  Amenity Chip Widget
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

  /// Video Tour section: pick from gallery OR paste a URL
  Widget _buildVideoTourSection() {
    final hasVideo = videoTourUrlCtrl.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Video Tour (Optional)",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10.h),

        // Current video preview / status
        if (hasVideo) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.videocam, color: Colors.green[700], size: 28.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Video attached",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                          color: Colors.green[700],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        videoTourUrlCtrl.text.trim(),
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red, size: 20.sp),
                  tooltip: 'Remove video',
                  onPressed: _removeVideo,
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
              setState(() {
                videoTourUrlCtrl.text = urlCtrl.text.trim();
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
