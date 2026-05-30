# Deployment Checklist

Use this checklist before publishing My Hostel App.

## 1. App Identity

- [ ] Replace Android applicationId in android/app/build.gradle.kts.
- [ ] Replace Android namespace in android/app/build.gradle.kts.
- [ ] Set iOS bundle identifier in Xcode project settings.
- [ ] Set production app display name if needed.

## 2. Signing And Secrets

- [ ] Create android/keystore.properties with release signing values.
- [ ] Ensure keystore file path in keystore.properties is valid.
- [ ] Verify no secrets are committed to source control.
- [ ] Add local secrets files to .gitignore if missing.

Example keystore.properties:

keyAlias=your_key_alias
keyPassword=your_key_password
storeFile=../upload-keystore.jks
storePassword=your_store_password

## 3. Firebase Production Setup

- [ ] Use production Firebase project for release builds.
- [ ] Verify Firebase Auth providers and domain settings.
- [ ] Verify Cloud Firestore indexes required by booking queries.
- [ ] Validate Firestore security rules for users, owners, and admin.
- [ ] Validate Firebase Storage security rules for uploads/deletes.
- [ ] Confirm FCM tokens are saved and refreshed correctly.

## 4. Platform Permissions

- [ ] Android INTERNET and CAMERA permissions are present.
- [ ] iOS NSCameraUsageDescription is present.
- [ ] iOS NSPhotoLibraryUsageDescription is present.
- [ ] Test camera/gallery flow on real devices.

## 5. Quality Gates

- [ ] Run flutter pub get.
- [ ] Run flutter analyze and resolve warnings/errors.
- [ ] Run flutter test.
- [ ] Validate sign-in, booking, owner dashboard, and admin dashboard flows.
- [ ] Test push notifications in foreground/background/terminated states.

## 6. Build Artifacts

- [ ] Build Android APK: flutter build apk --release
- [ ] Build Android App Bundle: flutter build appbundle --release
- [ ] Build iOS release: flutter build ios --release
- [ ] Build Web release: flutter build web --release

## 7. Store Readiness

- [ ] Prepare app icon and screenshots for each platform.
- [ ] Prepare privacy policy and terms URL.
- [ ] Complete App Store and Play Store metadata.
- [ ] Verify crash reporting and analytics configuration.
