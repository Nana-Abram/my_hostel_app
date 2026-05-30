# My Hostel App

My Hostel App is a Flutter + Firebase hostel discovery, booking, and management platform.

## Core Features

- Student flow: browse hostels, inspect room details, submit bookings, and view booking history.
- Owner flow: manage hostels/rooms and monitor bookings, revenue, and activity.
- Admin flow: monitor platform stats and manage users/hostels.
- Firebase integrations: Auth, Firestore, Storage, Cloud Messaging.
- Modern UI stack: adaptive theming, responsive layout, loading/error/empty states, and animations.

## Tech Stack

- Flutter (Dart)
- Riverpod for state management
- GoRouter for navigation
- Firebase (Auth, Firestore, Storage, Messaging)

## Run Locally

1. Install Flutter SDK and verify with:
   flutter doctor
2. Install dependencies:
   flutter pub get
3. Ensure Firebase config files are in place:
   - Android: android/app/google-services.json
   - iOS: ios/Runner/GoogleService-Info.plist
   - Web/Desktop: lib/firebase_options.dart
4. Run app:
   flutter run

## Deployment Readiness Checklist

Before release, complete all items in DEPLOYMENT_CHECKLIST.md.

High-priority items:

- Replace default package identifiers (example values are still present in Android files).
- Configure production Firebase project and security rules.
- Configure Android release signing (keystore.properties).
- Validate push notifications on each target platform.
- Build and test release artifacts for Android/iOS/Web.

## Build Commands

- Android APK: flutter build apk --release
- Android App Bundle: flutter build appbundle --release
- iOS: flutter build ios --release
- Web: flutter build web --release

## Notes

- Payment screenshot uploads are now platform-safe and work with XFile across mobile/web.
- Camera and photo library permissions are configured for iOS and Android manifests.
