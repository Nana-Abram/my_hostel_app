import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/service/notification_service.dart';
import 'package:my_hostel_app/firebase_options.dart';
import 'package:my_hostel_app/ui/core/app_theme.dart';
import 'package:my_hostel_app/ui/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notifications (background handler must be registered before
  // any other Firebase call, so it stays here at the top level)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService().initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── IMPORTANT: The router is created here, inside the ConsumerWidget, ──
    // so its redirect callback has access to Riverpod via `ref`.             
    // Creating it as a static field (as before) meant the redirect ran       
    // before any provider was ready → auth state appeared null → double-login.
    final router = AppRouter.createRouter(ref);

    return AdaptiveTheme(
      light: AppTheme.lightTheme(),
      dark: AppTheme.darkTheme(),
      // Follow the device theme automatically; user can override in settings.
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => ScreenUtilInit(
        designSize: const Size(1440, 1024),
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'My Hostel App',
            theme: theme,
            darkTheme: darkTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
