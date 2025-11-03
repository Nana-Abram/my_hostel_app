import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/ui/app_bar/app_bar_screen.dart';
import 'package:my_hostel_app/ui/hostels/hostel_details_page.dart';
import 'package:my_hostel_app/ui/routes/app_routes.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HostelProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
             AppRoutes.hostelDetails:(context) => HostelDetailsPage(),
          },
        );
      },
      child: const AppBarScreen(),
      
    );
  }
}
