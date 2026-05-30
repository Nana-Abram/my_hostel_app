import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/backend/service/notification_service.dart';
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

// ─────────────────────────────────────────────────────────────────────────────
// Routes that require the user to be authenticated
// ─────────────────────────────────────────────────────────────────────────────
const _protectedRoutes = [
  '/dashboard',
  '/profile',
  '/my-bookings',
  '/student-dashboard',
];

bool _isProtected(String location) =>
    _protectedRoutes.any((r) => location.startsWith(r));

// ─────────────────────────────────────────────────────────────────────────────
// AppRouter
// ─────────────────────────────────────────────────────────────────────────────
class AppRouter {
  // The router must be built with a ProviderContainer / Ref so the redirect
  // callback can read Riverpod providers.  Call AppRouter.createRouter(ref)
  // inside your ConsumerWidget build (or pass a container from main).
  static GoRouter createRouter(WidgetRef ref) {
    // Keep a listenable that GoRouter can refresh whenever auth state changes.
    final authNotifier = _AuthChangeNotifier(ref);

    final router = GoRouter(
      refreshListenable: authNotifier,
      redirect: (context, state) {
        final authAsync = ref.read(authStateProvider);
        final isLoading = authAsync.isLoading;

        // While Firebase is still resolving the auth state, don't redirect.
        if (isLoading) return null;

        final user = authAsync.value;
        final isLoggedIn = user != null;
        final location = state.matchedLocation;

        final goingToLogin = location == '/login';
        final goingToSignup = location == '/signup';
        final goingToAuth = goingToLogin || goingToSignup;


        // ── Not logged in ──────────────────────────────────────────────────
        if (!isLoggedIn && _isProtected(location)) {
          // Preserve destination so user lands there after login
          final redirect = Uri.encodeComponent(location);
          return '/login?redirect=$redirect';
        }

        // ── Already logged in ──────────────────────────────────────────────
        if (isLoggedIn && goingToAuth) {

          // Don't send them to login/signup if they're already in
          return '/dashboard';
        }

        return null; // No redirect needed
      },
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
          name: 'login',
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
          name: 'hostels',
          builder: (context, state) {
            final hostelId = state.pathParameters['hostelId']!;
            return HostelDetailsPage(hostelId: hostelId);
          },
        ),

        GoRoute(
          path: '/student-dashboard',
          name: 'student-dashboard',
          builder: (context, state) => const StudentDashboard(),
        ),

        GoRoute(
          path: '/room-details/:hostelId/:roomId',
          name: 'room-details',
          builder: (context, state) {
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
            return BookingScreen(hostelId: hostelId, roomId: roomId);
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.uri}')),
      ),
    );

    // ── Wire up FCM notification taps → router navigation ──────────────────
    NotificationService().notificationTapStream.listen((data) {
      final type = data['type'] as String?;
      final id = data['id'] as String?;

      switch (type) {
        case 'booking':
          if (id != null) {
            router.go('/my-bookings');
          } else {
            router.go('/my-bookings');
          }
          break;
        case 'payment':
          router.go('/my-bookings');
          break;
        case 'hostel':
          if (id != null) {
            router.go('/hostel-details/$id');
          }
          break;
        case 'message':
          router.go('/dashboard');
          break;
        default:
          router.go('/dashboard');
      }
    });

    return router;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Listenable that fires whenever the Riverpod auth stream emits a new value.
// GoRouter uses this to re-run its redirect logic automatically.
// ─────────────────────────────────────────────────────────────────────────────
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(WidgetRef ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}
