
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/backend/service/image_upload_service.dart';
import 'package:my_hostel_app/ui/admin/add_rooms.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class AdminAddHostelPage extends ConsumerStatefulWidget {
  const AdminAddHostelPage({super.key});

  @override
  ConsumerState<AdminAddHostelPage> createState() => _AdminAddHostelPageState();
}

class _AdminAddHostelPageState extends ConsumerState<AdminAddHostelPage> {
  final _formKey = GlobalKey<FormState>();

  // --- INPUT CONTROLLERS ---
  final nameCtrl = TextEditingController();
  final campusCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final startPriceCtrl = TextEditingController();
  final reviewCountCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final ratingCtrl = TextEditingController();

  // --- DATA HOLDERS ---
  List<String> amenities = [];
  List<String> images = []; // Firebase Storage URLs (final saved)
  bool isUploading = false;

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
  //  Submit Hostel
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one image")),
      );
      return;
    }

    final hostel = HostelModel(
      id: "",
      name: nameCtrl.text.trim(),
      campus: campusCtrl.text.trim(),
      description: descriptionCtrl.text.trim(),
      amenities: amenities,
      images: images,
      startPrice: double.parse(startPriceCtrl.text),
      rating: ratingCtrl.text.isEmpty ? 4.0 : double.parse(ratingCtrl.text),
      reviewsCount: reviewCountCtrl.text.isEmpty ? 4.0 : double.parse(reviewCountCtrl.text),
      location: locationCtrl.text.trim(),

    );

    final service = ref.read(hostelServiceProvider);
    await service.addHostel(hostel);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Hostel added successfully")),
    );

    _formKey.currentState!.reset();
    amenities.clear();
    images.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        _input("Description", descriptionCtrl, maxLines: 3),
                            
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
                            
                        Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: images
                              .map((img) => Container(
                                    width: 140.w,
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Column(
                                      children: [
                                        Image.network(
                                          img,
                                          height: 90.h,
                                          width: 120.w,
                                          fit: BoxFit.cover,
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            images.remove(img);
                                            setState(() {});
                                          },
                                          child: const Text("Remove"),
                                        )
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                            
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
}
