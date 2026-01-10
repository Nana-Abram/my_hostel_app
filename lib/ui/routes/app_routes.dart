import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/ui/app_bar/app_bar_screen.dart';
import 'package:my_hostel_app/ui/auth/login.dart';
import 'package:my_hostel_app/ui/auth/signup.dart';
import 'package:my_hostel_app/ui/booking/booking_screen.dart';
import 'package:my_hostel_app/ui/dashboard/dashboard.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/profile_page.dart';
import 'package:my_hostel_app/ui/dashboard/student_dashboard/my_booking_screen.dart';
import 'package:my_hostel_app/ui/dashboard/student_dashboard/student_dashboard.dart';
import 'package:my_hostel_app/ui/hostels/hostel_details_page.dart';
import 'package:my_hostel_app/ui/hostels/room_details_page.dart';


class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const AppBarScreen(initialIndex: 0),
      ),
      
      GoRoute(
        path: '/tabs/:tabIndex',
        name: 'tabs',
        builder: (context, state) {
          final tabIndex = state.pathParameters['tabIndex']!;
          final initialIndex = int.tryParse(tabIndex) ?? 0;
          return AppBarScreen(initialIndex: initialIndex);
        },
      ),

      GoRoute(
        path: '/login',
        name: 'login',  // Add name
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/hostel-details/:hostelId',
        name:'hostels' ,
        builder: (context, state) {
          final hostelId = state.pathParameters['hostelId']!;
          return HostelDetailsPage(hostelId: hostelId);
        },
      ),
      // Student dashboard route
GoRoute(
  path: '/student-dashboard',
  name: 'student-dashboard',
  builder: (context, state) => const StudentDashboard(),
),

// My bookings route
GoRoute(
  path: '/room-details/:hostelId/:roomId',
  name: 'room-details',
  builder: (context, state){
    final hostelId = state.pathParameters['hostelId']!;
    final roomId = state.pathParameters['roomId']!;
    final room = state.extra as Map<String, dynamic>?;
    return RoomDetailsPage(
      room: room?['room'],
      hostel: room?['hostel'],
    );
  },
),
GoRoute(
  path: '/my-bookings',
  name: 'my-bookings',
  builder: (context, state) => const MyBookingsScreen(),
),
GoRoute(
  path: '/booking/:hostelId/:roomId',
  name: 'booking',
  builder: (context, state) {
    final hostelId = state.pathParameters['hostelId']!;
    final roomId = state.pathParameters['roomId']!;
    return BookingScreen(
      hostelId: hostelId,
      roomId: roomId,
    );
  },
),
    ],
     errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
}

// Then navigate using names (safer):
// GoRouter.of(context).goNamed('login');