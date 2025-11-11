import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/firebase_options.dart';
import 'package:my_hostel_app/ui/app_bar/app_bar_screen.dart';
import 'package:my_hostel_app/ui/booking/booking_screen.dart';
import 'package:my_hostel_app/ui/hostels/hostel_details_page.dart';
import 'package:my_hostel_app/ui/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final hostels = ref.watch(hostelsStreamProvider);
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
              final hostel =
                  ModalRoute.of(context)!.settings.arguments as HostelModel;
              return HostelDetailsPage(hostel: hostel);
            },

            AppRoutes.bookingPage: (context) => BookingScreen(
              roomType: "2 in a room",
              price: 400.8,
              imagePath: "assets/images/h1.jpg",
            ),
          },
        );
      },
      child: const AppBarScreen(),
    );
  }
}
