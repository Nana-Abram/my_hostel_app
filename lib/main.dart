import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/firebase_options.dart';
import 'package:my_hostel_app/ui/app_bar/app_bar_screen.dart';
import 'package:my_hostel_app/ui/booking/booking_screen.dart';
import 'package:my_hostel_app/ui/hostels/hostel_details_page.dart';
import 'package:my_hostel_app/ui/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable local cache persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  if(FirebaseFirestore.instance.settings.persistenceEnabled == true) {
    print("✅ Firestore local cache persistence is ENABLED");
  } else {
    print("❌ Firestore local cache persistence is DISABLED");
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {// Example hostelId
    return ScreenUtilInit(
      designSize: const Size(1440, 1024),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Hostel App',
          theme: ThemeData(fontFamily: 'Poppins'),
          home: child,
          routes: {
            AppRoutes.hostelDetails: (context) {
              final args = ModalRoute.of(context)!.settings.arguments;
              if (args == null || args is! HostelModel) {
                return  Scaffold(
                  appBar: AppBar(
                    title: Text("Hostel Details")),
                  body: Center(child: Text("No hostel data provided")),
                );
              }
              return HostelDetailsPage(hostel: args);
            },

            AppRoutes.bookingPage: (context) {
              final args = ModalRoute.of(context)!.settings.arguments;
              
              // Handle different argument types for the two scenarios
              if (args is BookingArguments) {
                // Scenario 1: From AvailableRooms (with selected room)
                return BookingScreen(
                  selectedRoom: args.selectedRoom,
                  selectedHostel: args.selectedHostel,
                );
              }  else {
                // Fallback for invalid arguments
                return Scaffold(
                  appBar: AppBar(
                    title: Text("Booking")),
                  body: Center(child: Text("Invalid booking data")),
                );
              }
            },
          },
        );
      },
      child: const AppBarScreen(),
    );
  }
}

// Helper class to pass booking arguments
class BookingArguments {
  final HostelModel selectedHostel;
  final RoomModel selectedRoom; // optional if none preselected


  BookingArguments({
    required this.selectedHostel,
    required this.selectedRoom,
  });
}