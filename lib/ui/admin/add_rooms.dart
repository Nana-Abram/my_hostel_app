import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/backend/provider/room_provider.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';
import '../../backend/model/room_model.dart';

class AdminAddRoomPage extends ConsumerStatefulWidget {
  const AdminAddRoomPage({super.key});

  @override
  ConsumerState<AdminAddRoomPage> createState() => _AdminAddRoomPageState();
}

class _AdminAddRoomPageState extends ConsumerState<AdminAddRoomPage> {
  String? selectedHostel;
  String? selectedType;
  String? selectedGender;
  String? selectedAvailability;
  int capacity = 1;
  int availableRooms = 0;
  double price = 3000;

  Uint8List? imageBytes;
  String? uploadedImageUrl;

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

  /// Pick room image from computer (Web supported)
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.image,
    );

    if (result != null) {
      setState(() => imageBytes = result.files.single.bytes);
    }
  }

  /// Upload image to Firebase Storage
  Future<String> uploadImage() async {
    if (imageBytes == null) return "";

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref("room_images/$id.jpg");

    await ref.putData(imageBytes!, SettableMetadata(contentType: "image/jpeg"));
    return await ref.getDownloadURL();
  }

  /// Save room to Firestore through service
  Future<void> saveRoom() async {
    if (selectedHostel == null || selectedType == null || imageBytes == null || selectedGender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    uploadedImageUrl = await uploadImage();

    final room = RoomModel(
      id: FirebaseFirestore.instance.collection("rooms").doc().id,
      hostelId: selectedHostel!,
      type: selectedType!,
      image: uploadedImageUrl!,
      gender:selectedGender!,
      capacity: capacity,
      availableRooms: availableRooms,
      price: price,
      available: selectedAvailability == "True" ? true : false,
      features: selectedFeatures,
    );

    final service = ref.read(roomServiceProvider);
    await service.addRoom(room);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Room added successfully")));

    setState(() {
      selectedHostel = null;
      selectedType = null;
      selectedGender = null;
      imageBytes = null;
      uploadedImageUrl = null;
      selectedFeatures.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hostelsAsync = ref.watch(hostelsStreamProvider);

    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(20.w),
          width: 0.4.sw,
          padding: EdgeInsets.all(30.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmallText(
                        text: "Add New Room",
                        size: 20.sp,
                        color: Colors.black,
                      ),
                      SizedBox(height: 20.h),
              hostelsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text("Error loading hostels"),
                data: (hostels) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///  Hostel selector
                        DropdownButtonFormField(
      
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
                      
                        ///  Room Type selector
                        DropdownButtonFormField(
                          hint: const Text("Room Type"),
                          value: selectedType,
                          items: types
                              .map(
                                (t) => DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedType = v),
                        ),
                        DropdownButtonFormField(
                          hint: const Text("Gender"),
                          value: selectedGender,
                          items: gender
                              .map(
                                (t) => DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedGender = v),
                        ),
                        DropdownButtonFormField(
                          hint: const Text("AVailability"),
                          value: selectedAvailability,
                          items: availability
                              .map(
                                (t) => DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedAvailability= v),
                        ),
                        
                        SizedBox(height: 20.h),
                      
                        /// Capacity
                        Row(
                          children: [
                            const Text("Capacity: "),
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
                      
                        ///  Price
                        Row(
                          children: [
                            const Text("Price (GHS): "),
                            SizedBox(width: 20.w),
                            SizedBox(
                              width: 100.w,
                              child: TextFormField(
                                initialValue: price.toStringAsFixed(2),
                                keyboardType: TextInputType.number,
                                onChanged: (v) =>
                                    setState(() => price = double.tryParse(v) ?? price),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        ///  Available Rooms
                        Row(
                          children: [
                            const Text("Available Rooms: "),
                            SizedBox(width: 20.w),
                            SizedBox(
                              width: 100.w,
                              child: TextFormField(
                                initialValue: availableRooms.toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (v) =>
                                    setState(() => availableRooms = int.tryParse(v) ?? availableRooms),
                              ),
                            ),
                          ],
                        ),
                      
                        /// Features
                        const Text("Features:"),
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
                      
                        /// Image Picker
                        TextButton.icon(
                          onPressed: pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text("Choose Image"),
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
                      
                        SizedBox(height: 30.h),
                      
                        /// Submit
                        ElevatedButton(
                          onPressed: saveRoom,
                          child: const Text("Save Room"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
    );
    
  }
}
