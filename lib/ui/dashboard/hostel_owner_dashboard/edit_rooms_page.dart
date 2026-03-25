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
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';


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
  List<String> uploadedImageUrls = [];
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
    'Free mattress',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize form with existing room data
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

  /// Pick and upload room video
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

      // Delete old video if replacing
      if (videoUrl != null && videoUrl!.contains('firebasestorage')) {
        try {
          await ImageUploadService().deleteImage(videoUrl!);
        } catch (_) {}
      }

      final url = await ImageUploadService().uploadRoomVideo(file.bytes!, file.name);
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

  void _showVideoUrlDialog() {
    final urlCtrl = TextEditingController(text: videoUrl ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enter Video URL"),
        content: TextField(
          controller: urlCtrl,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: "https://...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.link),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() => videoUrl = urlCtrl.text.trim().isEmpty ? null : urlCtrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// Pick room images from computer (Web supported)
  Future<void> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          if (file.bytes != null) {
            imageBytesList.add(file.bytes!);
          }
        }
        useExistingImages = false;
      });
    }
  }

  /// Upload images to Firebase Storage
  Future<List<String>> uploadImages() async {
    if (imageBytesList.isEmpty) return useExistingImages ? existingImageUrls : [];
    
    List<String> urls = [];
    
    for (int i = 0; i < imageBytesList.length; i++) {
      final id = "${DateTime.now().millisecondsSinceEpoch}_$i";
      final ref = FirebaseStorage.instance.ref("room_images/$id.jpg");

      await ref.putData(imageBytesList[i], SettableMetadata(contentType: "image/jpeg"));
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    
    return urls;
  }

  /// Update room in Firestore
  Future<void> updateRoom() async {
    if (selectedHostel == null || selectedType == null || selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields"))
      );
      return;
    }

    // Upload new images if selected, otherwise use existing
    final imageUrls = useExistingImages ? existingImageUrls : await uploadImages();

    if (imageUrls.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select at least one image"))
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
      final service = ref.read(roomServiceProvider);
      await service.updateRoom(widget.room.id, updatedRoom);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Room updated successfully"))
        );

        Navigator.pop(context); // Go back to previous page
      }
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update room: $e"))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hostelsAsync = ref.watch(hostelsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Room'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          Tooltip(
            message: "Save Changes",
            child: IconButton(
              icon: Icon(Icons.save),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmallText(
                  text: "Edit Room",
                  size: 20.sp,
                  color: Colors.black,
                ),
                SizedBox(height: 20.h),
                
                hostelsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text("Error loading hostels"),
                  data: (hostels) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Hostel selector
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          hint: const Text("Select Hostel"),
                          value: selectedHostel,
                          items: hostels
                              .map(
                                (h) => DropdownMenuItem(
                                  value: h.id,
                                  child: Text(h.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedHostel = v),
                        ),
                        SizedBox(height: 20.h),
                      
                        /// Room Type selector
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          hint: const Text("Room Type"),
                          value: selectedType,
                          items: types
                              .map(
                                (t) => DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedType = v),
                        ),
                        SizedBox(height: 20.h),
                      
                        /// Gender selector
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          hint: const Text("Gender"),
                          value: selectedGender,
                          items: gender
                              .map(
                                (t) => DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedGender = v),
                        ),
                        SizedBox(height: 20.h),
                      
                        /// Availability selector
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          hint: const Text("Availability"),
                          value: selectedAvailability,
                          items: availability
                              .map(
                                (t) => DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedAvailability = v),
                        ),
                        SizedBox(height: 20.h),
                      
                        /// Capacity
                        Row(
                          children: [
                            Text("Capacity: ", style: TextStyle(fontSize: 14.sp)),
                            SizedBox(width: 10.w),
                            DropdownButton<int>(
                              value: capacity,
                              items: [1, 2, 3, 4]
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text("$c students"),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => capacity = v!),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                      
                        /// Price
                        Row(
                          children: [
                            Text("Price (GHS): ", style: TextStyle(fontSize: 14.sp)),
                            SizedBox(width: 10.w),
                            SizedBox(
                              width: 120.w,
                              child: TextFormField(
                                initialValue: price.toStringAsFixed(2),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                                onChanged: (v) =>
                                    setState(() => price = double.tryParse(v) ?? price),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                      
                        /// Available Rooms
                        Row(
                          children: [
                            Text("Available Rooms: ", style: TextStyle(fontSize: 14.sp)),
                            SizedBox(width: 10.w),
                            SizedBox(
                              width: 120.w,
                              child: TextFormField(
                                initialValue: availableRooms.toString(),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                                onChanged: (v) =>
                                    setState(() => availableRooms = int.tryParse(v) ?? availableRooms),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                      
                        /// Features
                        Text("Features:", style: TextStyle(fontSize: 14.sp)),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: featuresList.map((f) {
                            final selected = selectedFeatures.contains(f);
                            return FilterChip(
                              label: Text(f),
                              selected: selected,
                              onSelected: (v) {
                                setState(() {
                                  v
                                      ? selectedFeatures.add(f)
                                      : selectedFeatures.remove(f);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20.h),
                      
                        /// Image Section
                        Text("Room Images:", style: TextStyle(fontSize: 14.sp)),
                        SizedBox(height: 10.h),
                        
                        // Current/Existing Images
                        if (useExistingImages && existingImageUrls.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("Current Images:", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                                  SizedBox(width: 10.w),
                                  Text("${existingImageUrls.length} image(s)", 
                                    style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              SizedBox(
                                height: 200.h,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: existingImageUrls.length,
                                  itemBuilder: (context, index) {
                                    return Container(
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
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              ),
                                              style: IconButton.styleFrom(
                                                backgroundColor: Colors.black54,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  existingImageUrls.removeAt(index);
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
                                    onPressed: () {
                                      setState(() {
                                        useExistingImages = false;
                                        existingImageUrls.clear();
                                      });
                                    },
                                    child: Text("Replace All Images", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        
                        // New Image Picker
                        if (!useExistingImages || existingImageUrls.isEmpty)
                          Column(
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
                                  Text("${imageBytesList.length} image(s) selected"),
                                ],
                              ),
                              if (imageBytesList.isNotEmpty)
                                Container(
                                  margin: EdgeInsets.only(top: 20.h),
                                  height: 200.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: imageBytesList.length,
                                    itemBuilder: (context, index) {
                                      return Container(
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
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                                style: IconButton.styleFrom(
                                                  backgroundColor: Colors.black54,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    imageBytesList.removeAt(index);
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                      
                        SizedBox(height: 30.h),

                        /// Video Tour Section
                        _buildVideoSection(),
                      
                        SizedBox(height: 30.h),
                      
                        /// Update Button
                        ElevatedButton(
                          onPressed: updateRoom,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50.h),
                          ),
                          child: Text("Update Room", style: TextStyle(fontSize: 16.sp)),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
    final hasVideo = videoUrl != null && videoUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Video Tour (Optional)",
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 10.h),
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
                      Text("Video attached",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              color: Colors.green[700])),
                      SizedBox(height: 4.h),
                      Text(videoUrl!,
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
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
        if (isUploadingVideo)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              children: [
                SizedBox(
                    width: 22.w,
                    height: 22.h,
                    child: const CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 12.w),
                Text("Uploading video...", style: TextStyle(fontSize: 12.sp)),
              ],
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: pickAndUploadVideo,
                  icon: Icon(Icons.video_library, size: 18.sp),
                  label: Text("Pick Video", style: TextStyle(fontSize: 12.sp)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(color: Colors.blue.shade300),
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
                  label: Text("Paste URL", style: TextStyle(fontSize: 12.sp)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(color: Colors.orange.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ),
            ],
          ),
        SizedBox(height: 10.h),
      ],
    );
  }
}