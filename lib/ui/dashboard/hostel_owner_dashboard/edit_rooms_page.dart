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

  Uint8List? imageBytes;
  String? uploadedImageUrl;
  bool useExistingImage = true;

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
    uploadedImageUrl = widget.room.image;
  }

  /// Pick room image from computer (Web supported)
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        imageBytes = result.files.single.bytes;
        useExistingImage = false;
      });
    }
  }

  /// Upload image to Firebase Storage
  Future<String> uploadImage() async {
    if (imageBytes == null) return uploadedImageUrl ?? "";
    
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref("room_images/$id.jpg");

    await ref.putData(imageBytes!, SettableMetadata(contentType: "image/jpeg"));
    return await ref.getDownloadURL();
  }

  /// Update room in Firestore
  Future<void> updateRoom() async {
    if (selectedHostel == null || selectedType == null || selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields"))
      );
      return;
    }

    // Upload new image if selected, otherwise use existing
    final imageUrl = useExistingImage ? uploadedImageUrl : await uploadImage();

    if (imageUrl == null || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image"))
      );
      return;
    }

    final updatedRoom = RoomModel(
      id: widget.room.id, // Keep the same ID
      hostelId: selectedHostel!,
      type: selectedType!,
      image: imageUrl,
      gender: selectedGender!,
      capacity: capacity,
      availableRooms: availableRooms,
      price: price,
      available: selectedAvailability == "True",
      features: selectedFeatures,
    );

    try {
      final service = ref.read(roomServiceProvider);
      await service.updateRoom(widget.room.id, updatedRoom);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Room updated successfully"))
      );

      Navigator.pop(context); // Go back to previous page
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update room: $e"))
      );
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
                        Text("Room Image:", style: TextStyle(fontSize: 14.sp)),
                        SizedBox(height: 10.h),
                        
                        // Current Image
                        if (useExistingImage && uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty)
                          Column(
                            children: [
                              Text("Current Image:", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                              SizedBox(height: 10.h),
                              
                              ImageNetwork(
                                image: uploadedImageUrl!,
                                 height: 200.h, width: 300.w,
                                fitAndroidIos: BoxFit.cover,
                                fitWeb: BoxFitWeb.cover,
                                borderRadius: BorderRadius.circular(12.r)
                                ),


                              SizedBox(height: 10.h),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    useExistingImage = false;
                                    uploadedImageUrl = null;
                                  });
                                },
                                child: Text("Change Image", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        
                        // New Image Picker
                        if (!useExistingImage || uploadedImageUrl == null)
                          Column(
                            children: [
                              TextButton.icon(
                                onPressed: pickImage,
                                icon: const Icon(Icons.image),
                                label: const Text("Choose New Image"),
                              ),
                              if (imageBytes != null)
                                Container(
                                  margin: EdgeInsets.only(top: 20.h),
                                  height: 200.h,
                                  width: 300.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    image: DecorationImage(
                                      image: MemoryImage(imageBytes!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      
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
}