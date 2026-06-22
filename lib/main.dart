import 'dart:async';

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

  // Register the background handler before any other Firebase call, but
  // don't block first frame on permission prompts / network token fetch —
  // notifications aren't needed for the app to be usable, so let this run
  // in the background while the UI is already showing.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  unawaited(NotificationService().initialize());

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

    // Pick design size based on actual screen width so ScreenUtil's .w/.h/.sp
    // scale correctly on both mobile and desktop.
    final screenWidth = MediaQuery.sizeOf(context).width;
    final designSize = screenWidth < 600
        ? const Size(390, 844)   // mobile — 1:1 with standard phone screen
        : const Size(1440, 1024); // desktop — keeps existing desktop layouts

    return AdaptiveTheme(
      light: AppTheme.lightTheme(),
      dark: AppTheme.darkTheme(),
      // Follow the device theme automatically; user can override in settings.
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => ScreenUtilInit(
        designSize: designSize,
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'HostelHub',
            theme: theme,
            darkTheme: darkTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
