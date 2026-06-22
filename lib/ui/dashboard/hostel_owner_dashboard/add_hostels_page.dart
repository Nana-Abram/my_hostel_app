
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
  final latCtrl = TextEditingController();
  final lngCtrl = TextEditingController();

  

  // --- DATA HOLDERS ---
  List<String> amenities = [];
  List<String> images = [];
  bool isUploading = false;
  bool isUploadingVideo = false;
  bool _isLoading = false;

  // Tracks the hostel that was just created and is awaiting its first room.
  String? _pendingHostelId;
  String? _pendingHostelName;

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

Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  if (images.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Add at least one image")),
    );
    return;
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please sign in to add a hostel")),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final hostelName = nameCtrl.text.trim();
    final hostel = HostelModel(
      id: "",
      name: hostelName,
      campus: campusCtrl.text.trim(),
      description: descriptionCtrl.text.trim(),
      ownerName: ownerNameCtrl.text.trim(),
      totalRooms: double.parse(totalRoomsCtrl.text.trim()),
      amenities: amenities,
      images: images,
      startPrice: double.parse(startPriceCtrl.text.trim()),
      rating: ratingCtrl.text.trim().isEmpty ? 0.0 : double.parse(ratingCtrl.text.trim()),
      reviewsCount: reviewCountCtrl.text.trim().isEmpty ? 0.0 : double.parse(reviewCountCtrl.text.trim()),
      location: locationCtrl.text.trim(),
      status: "Pending",
      ownerId: currentUser.uid,
      videoTourUrl: videoTourUrlCtrl.text.trim().isEmpty ? null : videoTourUrlCtrl.text.trim(),
      latitude: latCtrl.text.trim().isEmpty ? null : double.tryParse(latCtrl.text.trim()),
      longitude: lngCtrl.text.trim().isEmpty ? null : double.tryParse(lngCtrl.text.trim()),
    );

    final service = ref.read(hostelServiceProvider);
    final newHostelId = await service.addHostel(hostel);

    if (!mounted) return;

    // Reset hostel form immediately — hostel is saved.
    _formKey.currentState!.reset();
    setState(() {
      amenities.clear();
      images.clear();
      _pendingHostelId = newHostelId;
      _pendingHostelName = hostelName;
    });
    latCtrl.clear();
    lngCtrl.clear();
    videoTourUrlCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hostel "$hostelName" created! Now add at least one room →'),
        duration: const Duration(seconds: 4),
      ),
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add hostel: $e")),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

void _onRoomSaved() {
  if (!mounted) return;
  final hostelName = _pendingHostelName ?? 'your hostel';
  setState(() {
    _pendingHostelId = null;
    _pendingHostelName = null;
  });
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Room added! "$hostelName" is now ready for bookings.'),
      backgroundColor: Colors.green[700],
      duration: const Duration(seconds: 4),
    ),
  );
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
    latCtrl.dispose();
    lngCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    final formContainer = Container(
      margin: EdgeInsets.all(isMobile ? 16.w : 20.w),
      width: isMobile ? null : 0.4.sw,
      padding: EdgeInsets.all(isMobile ? 20.w : 30.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.12),
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
              color: theme.colorScheme.onSurface,
            ),
            SizedBox(height: 20.h),

            _input("Hostel Name", nameCtrl),
            _input("Campus", campusCtrl),
            _input("Location", locationCtrl),
            _coordinatesInput(),
            _input("Starting Price (GHS)", startPriceCtrl, keyboard: TextInputType.number),
            _input("Rating", ratingCtrl, keyboard: TextInputType.number),
            _input("Review Count", reviewCountCtrl, keyboard: TextInputType.number),
            _input("Owner Name", ownerNameCtrl),
            _input("Total Rooms", totalRoomsCtrl, keyboard: TextInputType.number),
            _input("Description", descriptionCtrl, maxLines: 3),

            _buildVideoTourSection(),

            SizedBox(height: 25.h),
            Text(
              "Amenities",
              style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface),
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
            Text("Upload Images", style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface)),
            SizedBox(height: 10.h),
            isUploading
                ? const CircularProgressIndicator()
                : InkWell(
                    onTap: pickAndUploadImage,
                    child: const ElvButtonWidget(text: "Choose Image"),
                  ),

            SizedBox(height: 10.h),
            if (images.isNotEmpty) ...[
              Text(
                "Selected Images (${images.length})",
                style: TextStyle(fontSize: 12.sp, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: images.map((img) => _imagePreview(img)).toList(),
              ),
            ],

            SizedBox(height: 40.h),

            if (_pendingHostelId != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[800], size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        isMobile
                            ? 'Hostel saved! Add at least one room below before guests can book it.'
                            : 'Hostel saved! Add at least one room on the right before guests can book it.',
                        style: TextStyle(fontSize: 12.sp, color: Colors.orange[900]),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ] else ...[
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : InkWell(
                      onTap: _submit,
                      child: const ElvButtonWidget(text: "Submit Hostel", isPrimary: true),
                    ),
            ],
          ],
        ),
      ),
    );

    final roomPanel = AdminAddRoomPage(
      lockedHostelId: _pendingHostelId,
      lockedHostelName: _pendingHostelName,
      onRoomSaved: _onRoomSaved,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Hostel'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _submit),
        ],
      ),
      body: isMobile
          ? SingleChildScrollView(
              child: Column(children: [formContainer, roomPanel]),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SingleChildScrollView(child: formContainer),
                roomPanel,
              ],
            ),
    );
  }

  Widget _imagePreview(String imageUrl) {
    final theme = Theme.of(context);
    return Container(
      width: 140.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
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

  Widget _coordinatesInput() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "GPS Coordinates (Optional — for map view)",
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: latCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: InputDecoration(
                  labelText: "Latitude",
                  hintText: "e.g. 5.6037",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (double.tryParse(v) == null) return "Invalid number";
                  return null;
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextFormField(
                controller: lngCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: InputDecoration(
                  labelText: "Longitude",
                  hintText: "e.g. -0.1870",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (double.tryParse(v) == null) return "Invalid number";
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          "Find coordinates at maps.google.com — right-click the location and copy the numbers shown.",
          style: TextStyle(fontSize: 10.sp, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  // Reusable input field
  Widget _input(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: theme.colorScheme.onSurface)),
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
    final theme = Theme.of(context);
    final selected = amenities.contains(title);

    return GestureDetector(
      onTap: () => setState(() => selected ? amenities.remove(title) : amenities.add(title)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  /// Video Tour section: pick from gallery OR paste a URL
  Widget _buildVideoTourSection() {
    final theme = Theme.of(context);
    final hasVideo = videoTourUrlCtrl.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Video Tour (Optional)",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
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
                        style: TextStyle(fontSize: 10.sp, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
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
                  child: const CircularProgressIndicator(strokeWidth: 2),
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
        title: const Text("Enter Video URL"),
        content: TextField(
          controller: urlCtrl,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: "https://...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.link),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                videoTourUrlCtrl.text = urlCtrl.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

}
