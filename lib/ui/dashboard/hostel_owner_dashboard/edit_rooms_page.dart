import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/backend/provider/room_provider.dart';
import 'package:my_hostel_app/backend/service/image_upload_service.dart';

class EditRoomPage extends ConsumerStatefulWidget {
  final RoomModel room;

  const EditRoomPage({super.key, required this.room});

  @override
  ConsumerState<EditRoomPage> createState() => _EditRoomPageState();
}

class _EditRoomPageState extends ConsumerState<EditRoomPage> {
  String? selectedHostel;
  String? selectedType;
  String? selectedGender;
  String? selectedAvailability;
  late int capacity;
  late int availableRooms;
  late double price;

  List<Uint8List> imageBytesList = [];
  List<String> existingImageUrls = [];
  bool useExistingImages = true;
  String? videoUrl;
  bool isUploadingVideo = false;

  List<String> selectedFeatures = [];

  final gender = ["Male", "Female"];
  final availability = ["True", "False"];
  final types = [
    "Single Room with washroom",
    "Single Room self contain",
    "Single Room with shared washroom",
    "double Room self contain",
    "Double Room with shared washroom",
  ];
  final featuresList = [
    "Bed",
    "Desk",
    "Fan",
    "Wardrobe",
    "Kitchen",
    "Study Area",
    "Free mattress",
  ];

  @override
  void initState() {
    super.initState();
    selectedHostel = widget.room.hostelId;
    selectedType = widget.room.type;
    selectedGender = widget.room.gender;
    selectedAvailability = widget.room.available ? "True" : "False";
    capacity = widget.room.capacity;
    availableRooms = widget.room.availableRooms;
    price = widget.room.price;
    selectedFeatures = List.from(widget.room.features);
    existingImageUrls = List.from(widget.room.images);
    videoUrl = widget.room.videoUrl;
  }

  // ── Video helpers ──────────────────────────────────────────────────────────

  String _videoDisplayName(String url) {
    try {
      return Uri.decodeComponent(Uri.parse(url).pathSegments.last);
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

      if (videoUrl != null && videoUrl!.contains('firebasestorage')) {
        ImageUploadService().deleteImage(videoUrl!).catchError((_) {});
      }

      final url =
          await ImageUploadService().uploadRoomVideo(file.bytes!, file.name);
      setState(() => videoUrl = url);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video uploaded successfully!")),
        );
      }
    } catch (e) {
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
    final oldUrl = videoUrl;
    if (oldUrl != null && oldUrl.contains('firebasestorage')) {
      ImageUploadService().deleteImage(oldUrl).catchError((_) {});
    }
    setState(() => videoUrl = null);
  }

  void _showVideoUrlDialog(ThemeData theme) {
    final urlCtrl = TextEditingController(text: videoUrl ?? '');
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
              setState(() {
                final v = urlCtrl.text.trim();
                videoUrl = v.isEmpty ? null : v;
              });
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ── Image helpers ──────────────────────────────────────────────────────────

  Future<void> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        for (final file in result.files) {
          if (file.bytes != null) imageBytesList.add(file.bytes!);
        }
        useExistingImages = false;
      });
    }
  }

  Future<List<String>> uploadImages() async {
    if (imageBytesList.isEmpty) {
      return useExistingImages ? existingImageUrls : [];
    }
    final urls = <String>[];
    for (int i = 0; i < imageBytesList.length; i++) {
      final id = "${DateTime.now().millisecondsSinceEpoch}_$i";
      final ref =
          FirebaseStorage.instance.ref("room_images/$id.jpg");
      await ref.putData(
          imageBytesList[i], SettableMetadata(contentType: "image/jpeg"));
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> updateRoom() async {
    if (selectedHostel == null ||
        selectedType == null ||
        selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final imageUrls =
        useExistingImages ? existingImageUrls : await uploadImages();

    if (imageUrls.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please select at least one image")),
        );
      }
      return;
    }

    final updatedRoom = RoomModel(
      id: widget.room.id,
      hostelId: selectedHostel!,
      type: selectedType!,
      image: imageUrls.first,
      images: imageUrls,
      gender: selectedGender!,
      capacity: capacity,
      availableRooms: availableRooms,
      price: price,
      available: selectedAvailability == "True",
      features: selectedFeatures,
      videoUrl: videoUrl,
    );

    try {
      await ref.read(roomServiceProvider).updateRoom(widget.room.id, updatedRoom);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Room updated successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update room: $e")),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hostelsAsync = ref.watch(hostelsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Room'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          Tooltip(
            message: "Save Changes",
            child: IconButton(
              icon: const Icon(Icons.save),
              onPressed: updateRoom,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 0.8.sw,
            margin: EdgeInsets.all(20.w),
            padding: EdgeInsets.all(30.w),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edit Room",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 20.h),
                hostelsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Text(
                    "Error loading hostels",
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  data: (hostels) => _buildForm(theme, hostels),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme, List<dynamic> hostels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdown(
          theme,
          hint: "Select Hostel",
          value: selectedHostel,
          items: hostels.map((h) => DropdownMenuItem(
                value: h.id as String,
                child: Text(h.name as String),
              )).toList(),
          onChanged: (v) => setState(() => selectedHostel = v),
        ),

        _dropdown(
          theme,
          hint: "Room Type",
          value: selectedType,
          items: types
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => selectedType = v),
        ),

        _dropdown(
          theme,
          hint: "Gender",
          value: selectedGender,
          items: gender
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => selectedGender = v),
        ),

        _dropdown(
          theme,
          hint: "Availability",
          value: selectedAvailability,
          items: availability
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => selectedAvailability = v),
        ),

        // Capacity
        _labelRow(
          theme,
          label: "Capacity",
          child: DropdownButton<int>(
            value: capacity,
            items: [1, 2, 3, 4]
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text("$c students"),
                    ))
                .toList(),
            onChanged: (v) => setState(() => capacity = v!),
          ),
        ),
        SizedBox(height: 20.h),

        // Price
        _labelRow(
          theme,
          label: "Price (GHS)",
          child: SizedBox(
            width: 120.w,
            child: TextFormField(
              initialValue: price.toStringAsFixed(2),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              onChanged: (v) =>
                  setState(() => price = double.tryParse(v) ?? price),
            ),
          ),
        ),
        SizedBox(height: 20.h),

        // Available Rooms
        _labelRow(
          theme,
          label: "Available Rooms",
          child: SizedBox(
            width: 120.w,
            child: TextFormField(
              initialValue: availableRooms.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              onChanged: (v) => setState(
                  () => availableRooms = int.tryParse(v) ?? availableRooms),
            ),
          ),
        ),
        SizedBox(height: 20.h),

        // Features
        Text("Features:",
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface)),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: featuresList.map((f) {
            final selected = selectedFeatures.contains(f);
            return FilterChip(
              label: Text(f),
              selected: selected,
              onSelected: (v) => setState(() =>
                  v ? selectedFeatures.add(f) : selectedFeatures.remove(f)),
            );
          }).toList(),
        ),
        SizedBox(height: 20.h),

        // Images
        Text("Room Images:",
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface)),
        SizedBox(height: 10.h),

        if (useExistingImages && existingImageUrls.isNotEmpty)
          _existingImagesSection(theme)
        else
          _newImagesSection(theme),

        SizedBox(height: 30.h),

        // Video
        _buildVideoSection(theme),

        SizedBox(height: 30.h),

        ElevatedButton(
          onPressed: updateRoom,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            minimumSize: Size(double.infinity, 50.h),
          ),
          child: Text("Update Room", style: TextStyle(fontSize: 16.sp)),
        ),
      ],
    );
  }

  // ── Image sections ─────────────────────────────────────────────────────────

  Widget _existingImagesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Current Images:",
                style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurfaceVariant)),
            SizedBox(width: 10.w),
            Text("${existingImageUrls.length} image(s)",
                style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: existingImageUrls.length,
            itemBuilder: (context, index) => Container(
              margin: EdgeInsets.only(right: 10.w),
              width: 200.w,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: ImageNetwork(
                      image: existingImageUrls[index],
                      height: 200.h,
                      width: 200.w,
                      fitAndroidIos: BoxFit.cover,
                      fitWeb: BoxFitWeb.cover,
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.black54),
                      onPressed: () => setState(
                          () => existingImageUrls.removeAt(index)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            TextButton.icon(
              onPressed: pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text("Add More Images"),
            ),
            SizedBox(width: 10.w),
            TextButton(
              onPressed: () => setState(() {
                useExistingImages = false;
                existingImageUrls.clear();
              }),
              child: Text("Replace All Images",
                  style: TextStyle(color: theme.colorScheme.error)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _newImagesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text("Choose New Images"),
            ),
            SizedBox(width: 10.w),
            Text("${imageBytesList.length} image(s) selected",
                style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        if (imageBytesList.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 20.h),
            height: 200.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageBytesList.length,
              itemBuilder: (context, index) => Container(
                margin: EdgeInsets.only(right: 10.w),
                width: 200.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  image: DecorationImage(
                    image: MemoryImage(imageBytesList[index]),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 5,
                      right: 5,
                      child: IconButton(
                        icon:
                            const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.black54),
                        onPressed: () =>
                            setState(() => imageBytesList.removeAt(index)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Video section ──────────────────────────────────────────────────────────

  Widget _buildVideoSection(ThemeData theme) {
    final hasVideo = videoUrl != null && videoUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer
                  .withValues(alpha: 0.25),
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
                        _videoDisplayName(videoUrl!),
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
                Tooltip(
                  message: 'Replace video',
                  child: IconButton(
                    icon: Icon(Icons.swap_horiz_rounded,
                        size: 20.sp, color: theme.colorScheme.primary),
                    onPressed: pickAndUploadVideo,
                  ),
                ),
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
            onPressed: () => _showVideoUrlDialog(theme),
            icon: Icon(Icons.link, size: 15.sp),
            label: Text("Replace with URL",
                style: TextStyle(fontSize: 11.sp)),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: pickAndUploadVideo,
                  icon: Icon(Icons.video_library_outlined, size: 18.sp),
                  label: Text("Pick Video",
                      style: TextStyle(fontSize: 12.sp)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showVideoUrlDialog(theme),
                  icon: Icon(Icons.link, size: 18.sp),
                  label: Text("Paste URL",
                      style: TextStyle(fontSize: 12.sp)),
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

        SizedBox(height: 10.h),
      ],
    );
  }

  // ── Shared widgets ─────────────────────────────────────────────────────────

  Widget _dropdown<T>(
    ThemeData theme, {
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      children: [
        DropdownButtonFormField<T>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r)),
          ),
          hint: Text(hint),
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _labelRow(
    ThemeData theme, {
    required String label,
    required Widget child,
  }) {
    return Row(
      children: [
        Text("$label: ",
            style: TextStyle(
                fontSize: 14.sp, color: theme.colorScheme.onSurface)),
        SizedBox(width: 10.w),
        child,
      ],
    );
  }
}
