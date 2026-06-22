import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/ui/widgets/modern/image_widgets.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/backend/provider/room_provider.dart';
import 'package:my_hostel_app/backend/service/image_upload_service.dart';
import 'package:my_hostel_app/ui/core/app_logger.dart';
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
  late final descriptionCtrl = TextEditingController(text: widget.hostel.description);
  late final startPriceCtrl = TextEditingController(text: widget.hostel.startPrice.toString());
  late final reviewCountCtrl = TextEditingController(text: widget.hostel.reviewsCount.toString());
  late final locationCtrl = TextEditingController(text: widget.hostel.location);
  late final ratingCtrl = TextEditingController(text: widget.hostel.rating.toString());
  late final ownerNameCtrl = TextEditingController(text: widget.hostel.ownerName);
  late final totalRoomsCtrl = TextEditingController(text: widget.hostel.totalRooms.toString());
  late final videoTourUrlCtrl = TextEditingController(text: widget.hostel.videoTourUrl ?? '');
  late final latCtrl = TextEditingController(text: widget.hostel.latitude?.toString() ?? '');
  late final lngCtrl = TextEditingController(text: widget.hostel.longitude?.toString() ?? '');

  final status = ["Verified", "Pending", "Suspended"];
  late String selectedStatus = status.contains(widget.hostel.status)
      ? widget.hostel.status
      : status.first;

  // --- DATA HOLDERS ---
  late List<String> amenities = List.from(widget.hostel.amenities);
  late List<String> images = List.from(widget.hostel.images);
  bool isUploading = false;
  bool isUploadingVideo = false;

  // Track files to delete from Firebase Storage on save
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
    latCtrl.dispose();
    lngCtrl.dispose();
    super.dispose();
  }

  // ── Video helpers ──────────────────────────────────────────────────────────

  String _videoDisplayName(String url) {
    try {
      final pathPart = Uri.parse(url).pathSegments.last;
      return Uri.decodeComponent(pathPart);
    } catch (_) {
      return url;
    }
  }

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

      final oldUrl = videoTourUrlCtrl.text.trim();
      if (oldUrl.isNotEmpty && oldUrl.contains('firebasestorage')) {
        videoToDelete = oldUrl;
      }

      final url = await ImageUploadService().uploadVideo(file.bytes!, file.name);
      setState(() => videoTourUrlCtrl.text = url);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video uploaded successfully!")),
        );
      }
    } catch (e) {
      AppLogger.error('Video upload error', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Video upload failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isUploadingVideo = false);
    }
  }

  void _removeVideo() {
    final oldUrl = videoTourUrlCtrl.text.trim();
    if (oldUrl.isNotEmpty && oldUrl.contains('firebasestorage')) {
      videoToDelete = oldUrl;
    }
    setState(() => videoTourUrlCtrl.clear());
  }

  // ── Image helpers ──────────────────────────────────────────────────────────

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

      final url = await ImageUploadService().uploadImage(file.bytes!, file.name);
      setState(() => images.add(url));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image uploaded successfully!")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  void _removeImage(String imageUrl) {
    if (imageUrl.contains('firebasestorage')) imagesToDelete.add(imageUrl);
    setState(() => images.remove(imageUrl));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Image will be deleted when you save changes."),
        ),
      );
    }
  }

  // ── Storage cleanup ────────────────────────────────────────────────────────

  Future<void> _deleteUnusedFiles() async {
    final svc = ImageUploadService();
    if (videoToDelete != null && videoToDelete!.contains('firebasestorage')) {
      try {
        await svc.deleteImage(videoToDelete!);
      } catch (e) {
        AppLogger.error('Error deleting video from storage', e);
      }
    }
    for (final url in imagesToDelete) {
      if (url.contains('firebasestorage')) {
        try {
          await svc.deleteImage(url);
        } catch (e) {
          AppLogger.error('Error deleting image from storage', e);
        }
      }
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _updateHostel() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _deleteUnusedFiles();

      final updatedHostel = HostelModel(
        id: widget.hostel.id,
        name: nameCtrl.text.trim(),
        campus: campusCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        ownerName: ownerNameCtrl.text.trim(),
        totalRooms: double.parse(totalRoomsCtrl.text.trim()),
        amenities: amenities,
        images: images,
        startPrice: double.parse(startPriceCtrl.text.trim()),
        rating: ratingCtrl.text.trim().isEmpty
            ? widget.hostel.rating
            : double.parse(ratingCtrl.text.trim()),
        reviewsCount: reviewCountCtrl.text.trim().isEmpty
            ? widget.hostel.reviewsCount
            : double.parse(reviewCountCtrl.text.trim()),
        location: locationCtrl.text.trim(),
        status: selectedStatus,
        ownerId: widget.hostel.ownerId,
        videoTourUrl: videoTourUrlCtrl.text.trim().isEmpty
            ? null
            : videoTourUrlCtrl.text.trim(),
        latitude: latCtrl.text.trim().isEmpty
            ? null
            : double.tryParse(latCtrl.text.trim()),
        longitude: lngCtrl.text.trim().isEmpty
            ? null
            : double.tryParse(lngCtrl.text.trim()),
      );

      await ref.read(hostelServiceProvider).updateHostel(widget.hostel.id, updatedHostel);

      imagesToDelete.clear();
      videoToDelete = null;

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hostel updated successfully")),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update hostel: $e")),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roomsAsync = ref.watch(roomsStreamProvider);
    final pendingCount = imagesToDelete.length + (videoToDelete != null ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Hostel'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          Tooltip(
            message: pendingCount > 0
                ? '$pendingCount file(s) will be deleted on save'
                : 'Save Changes',
            child: pendingCount > 0
                ? Badge(
                    label: Text('$pendingCount'),
                    child: IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _updateHostel,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _updateHostel,
                  ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 1000) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHostelForm(theme),
                  SizedBox(height: 20.h),
                  _buildRoomsSection(theme, roomsAsync, isSmallScreen: true),
                ],
              ),
            );
          }
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: SingleChildScrollView(child: _buildHostelForm(theme)),
              ),
              Expanded(
                flex: 1,
                child: _buildRoomsSection(theme, roomsAsync),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Hostel form ────────────────────────────────────────────────────────────

  Widget _buildHostelForm(ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _input(theme, "Hostel Name", nameCtrl),
            _input(theme, "Campus", campusCtrl),
            _input(theme, "Location", locationCtrl),
            _coordinatesInput(theme),
            _input(theme, "Starting Price (GHS)", startPriceCtrl,
                keyboard: TextInputType.number),
            _input(theme, "Rating", ratingCtrl,
                keyboard: TextInputType.number),
            _input(theme, "Review Count", reviewCountCtrl,
                keyboard: TextInputType.number),
            _input(theme, "Owner Name", ownerNameCtrl),
            _input(theme, "Total Rooms", totalRoomsCtrl,
                keyboard: TextInputType.number),
            _input(theme, "Description", descriptionCtrl, maxLines: 3),

            _buildVideoTourSection(theme),

            SizedBox(height: 25.h),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Status",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              value: selectedStatus,
              items: status
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => selectedStatus = v!),
            ),

            SizedBox(height: 25.h),

            Text("Amenities",
                style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500)),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                _amenityChip(theme, "Wi-Fi"),
                _amenityChip(theme, "Kitchen"),
                _amenityChip(theme, "Study Room"),
                _amenityChip(theme, "Security"),
                _amenityChip(theme, "Laundry"),
                _amenityChip(theme, "Parking"),
                _amenityChip(theme, "Gym"),
                _amenityChip(theme, "Air Conditioning"),
                _amenityChip(theme, "Pool"),
                _amenityChip(theme, "DSTV"),
              ],
            ),

            SizedBox(height: 30.h),

            Text("Hostel Images",
                style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500)),
            SizedBox(height: 10.h),

            if (imagesToDelete.isNotEmpty)
              Container(
                padding: EdgeInsets.all(10.w),
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: theme.colorScheme.error, size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "${imagesToDelete.length} image(s) will be deleted when you save",
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),

            isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: pickAndUploadImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text("Add More Images"),
                  ),

            SizedBox(height: 10.h),

            if (images.isNotEmpty) ...[
              Text(
                "Current Images (${images.length})",
                style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurfaceVariant),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children:
                    images.map((img) => _imagePreview(theme, img)).toList(),
              ),
            ],

            SizedBox(height: 40.h),

            ElevatedButton(
              onPressed: _updateHostel,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: Size(double.infinity, 50.h),
              ),
              child: Text('Update Hostel', style: TextStyle(fontSize: 16.sp)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Video tour section ─────────────────────────────────────────────────────

  Widget _buildVideoTourSection(ThemeData theme) {
    final hasVideo = videoTourUrlCtrl.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4.h),
        Text(
          "Video Tour",
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface),
        ),
        SizedBox(height: 10.h),

        if (isUploadingVideo) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 18.w,
                  height: 18.h,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary),
                ),
                SizedBox(width: 12.w),
                Text("Uploading video…",
                    style: TextStyle(
                        fontSize: 13.sp,
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ] else if (hasVideo) ...[
          // Attached video card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(9.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.videocam_rounded,
                      color: theme.colorScheme.primary, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Video tour attached",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                            color: theme.colorScheme.onSurface),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        _videoDisplayName(videoTourUrlCtrl.text.trim()),
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4.w),
                // Replace
                Tooltip(
                  message: 'Replace video',
                  child: IconButton(
                    icon: Icon(Icons.swap_horiz_rounded,
                        size: 20.sp, color: theme.colorScheme.primary),
                    onPressed: pickAndUploadVideo,
                  ),
                ),
                // Remove
                Tooltip(
                  message: 'Remove video',
                  child: IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        size: 20.sp, color: theme.colorScheme.error),
                    onPressed: _removeVideo,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          TextButton.icon(
            onPressed: _showVideoUrlDialog,
            icon: Icon(Icons.link, size: 15.sp),
            label: Text("Replace with URL",
                style: TextStyle(fontSize: 11.sp)),
          ),
        ] else ...[
          // No video — pick or paste
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: pickAndUploadVideo,
                  icon: Icon(Icons.video_library_outlined, size: 18.sp),
                  label:
                      Text("Pick Video", style: TextStyle(fontSize: 12.sp)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showVideoUrlDialog,
                  icon: Icon(Icons.link, size: 18.sp),
                  label:
                      Text("Paste URL", style: TextStyle(fontSize: 12.sp)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(
                        color: theme.colorScheme.secondary
                            .withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ),
            ],
          ),
        ],

        SizedBox(height: 20.h),
      ],
    );
  }

  void _showVideoUrlDialog() {
    final urlCtrl = TextEditingController(text: videoTourUrlCtrl.text);
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enter Video URL"),
        content: TextField(
          controller: urlCtrl,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: "https://…",
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.link),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            onPressed: () {
              final newUrl = urlCtrl.text.trim();
              final oldUrl = videoTourUrlCtrl.text.trim();
              if (oldUrl.isNotEmpty &&
                  oldUrl.contains('firebasestorage') &&
                  oldUrl != newUrl) {
                videoToDelete = oldUrl;
              }
              setState(() => videoTourUrlCtrl.text = newUrl);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ── Rooms section ──────────────────────────────────────────────────────────

  Widget _buildRoomsSection(
    ThemeData theme,
    AsyncValue<List<dynamic>> roomsAsync, {
    bool isSmallScreen = false,
  }) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rooms in this Hostel",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 16.h),
          roomsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(
              'Error loading rooms: $error',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            data: (allRooms) {
              final hostelRooms = allRooms
                  .where((r) => r.hostelId == widget.hostel.id)
                  .toList();

              if (hostelRooms.isEmpty) {
                return Column(
                  children: [
                    Icon(Icons.meeting_room,
                        size: 50, color: theme.colorScheme.onSurfaceVariant),
                    SizedBox(height: 16.h),
                    Text('No Rooms Added',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant)),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Add First Room'),
                    ),
                  ],
                );
              }

              final cards =
                  hostelRooms.map((r) => _buildRoomCard(theme, r)).toList();

              return isSmallScreen
                  ? Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      children: cards,
                    )
                  : SingleChildScrollView(
                      child: Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: cards,
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(ThemeData theme, dynamic room) {
    return Container(
      width: _calculateCardWidth(),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          room.image.isNotEmpty
              ? EnhancedCachedImage(
                  imageUrl: room.image,
                  height: 80.h,
                  width: 80.w,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(10.r),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    height: 80.h,
                    width: 80.w,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.meeting_room,
                        size: 35.sp,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.type,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  "GHS ${room.price}",
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  "${room.capacity} students",
                  style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11.sp),
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Edit Room',
            child: IconButton(
              icon: Icon(Icons.edit_outlined,
                  color: theme.colorScheme.primary, size: 20.sp),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => EditRoomPage(room: room)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateCardWidth() {
    final w = MediaQuery.of(context).size.width;
    if (w < 600) return w - 32.w;
    if (w < 1000) return (w / 2) - 24.w;
    return 0.4.sw;
  }

  // ── Shared form widgets ────────────────────────────────────────────────────

  Widget _coordinatesInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "GPS Coordinates (Optional — for map view)",
          style: TextStyle(
              fontSize: 13.sp, color: theme.colorScheme.onSurface),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: latCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                decoration: InputDecoration(
                  labelText: "Latitude",
                  hintText: "e.g. 5.6037",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r)),
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
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                decoration: InputDecoration(
                  labelText: "Longitude",
                  hintText: "e.g. -0.1870",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r)),
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
          style: TextStyle(
              fontSize: 10.sp, color: theme.colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _input(
    ThemeData theme,
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13.sp, color: theme.colorScheme.onSurface)),
        SizedBox(height: 6.h),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboard,
          validator: (v) =>
              v == null || v.isEmpty ? "This field is required" : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _amenityChip(ThemeData theme, String title) {
    final selected = amenities.contains(title);
    return GestureDetector(
      onTap: () => setState(
          () => selected ? amenities.remove(title) : amenities.add(title)),
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _imagePreview(ThemeData theme, String imageUrl) {
    final isMarkedForDeletion = imagesToDelete.contains(imageUrl);

    return Container(
      width: 140.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(
          color: isMarkedForDeletion
              ? theme.colorScheme.error
              : theme.colorScheme.outlineVariant,
          width: isMarkedForDeletion ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              EnhancedCachedImage(
                imageUrl: imageUrl,
                height: 90.h,
                width: 120.w,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(10.r),
              ),
              if (isMarkedForDeletion)
                Container(
                  height: 90.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Icon(Icons.delete_forever,
                        color: Colors.white, size: 30.sp),
                  ),
                ),
            ],
          ),
          TextButton(
            onPressed: () => _removeImage(imageUrl),
            child: Text(
              isMarkedForDeletion ? "Will be deleted" : "Remove",
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: isMarkedForDeletion
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
