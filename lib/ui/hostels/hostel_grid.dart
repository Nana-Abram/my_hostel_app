import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/ui/hostels/hostels_card.dart';
import 'package:provider/provider.dart';
// import your dynamic card

class HostelGrid extends StatelessWidget {
  const HostelGrid({super.key});

  @override
  Widget build(BuildContext context) {

    final hostels = context.watch<HostelProvider>().filteredHostels;
 
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive: show 1 per row on small screens, 2 on wider screens
          int crossAxisCount = constraints.maxWidth < 700 ? 1 : 2;

          return GridView.builder(
            itemCount: hostels.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 20.h,
              crossAxisSpacing: 20.w,
              childAspectRatio:MediaQuery.of(context).size.width<600? 0.8:1.1, // adjust to control card height
            ),
            itemBuilder: (context, index) {
              final hostel = hostels[index];
              return HostelCard(
                imageUrl:hostel.image,
                name: hostel.name,
                location: hostel.campus,
                reviewsCount: hostel.reviewsCount,
                price: hostel.price,
                rating: hostel.rating,
                description: hostel.description,
                amenities: List<String>.from(hostel.amenities),
                onPressed: () {
                  // e.g. Navigate to details page
                  debugPrint("Clicked on ${hostel.name}");
                },
              );
            },
          );
        },
      ),
    );
  }
}
