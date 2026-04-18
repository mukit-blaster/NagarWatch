# Real-Time Notifications & Geofencing Setup Checklist

Complete this checklist to ensure all real-time features are properly configured.

## ✅ Dependencies Setup

- [x] Updated `pubspec.yaml` with `firebase_messaging: ^15.0.0`
- [x] Installed packages (run `flutter pub get`)
- [x] Verified `firebase_core` and `cloud_firestore` are installed
- [x] Verified `geolocator` and `flutter_local_notifications` are installed

## ✅ Backend Firebase Configuration

- [ ] Created Firebase project (if not already done)
- [ ] Enabled Firebase Cloud Messaging
- [ ] Downloaded Firebase configuration files:
  - [ ] `google-services.json` (for Android)
  - [ ] `GoogleService-Info.plist` (for iOS)
- [ ] Placed files in correct directories:
  - [ ] `android/app/google-services.json`
  - [ ] `ios/Runner/GoogleService-Info.plist`

## ✅ Android Configuration

In `android/app/build.gradle`, verify:
```gradle
defaultConfig {
    // ... other config
    minSdkVersion 20  // Or higher
}
```

In `android/app/src/main/AndroidManifest.xml`, verify these permissions:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

- [ ] Added location permissions
- [ ] Added notification permission
- [ ] Updated minSdkVersion if needed

## ✅ iOS Configuration

In `ios/Runner/Info.plist`, add:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>NagarWatch needs your location to show nearby issues</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>NagarWatch needs your location in the background</string>

<key>UIBackgroundModes</key>
<array>
  <string>location</string>
</array>
```

- [ ] Added location permission descriptions
- [ ] Added background mode for location
- [ ] Updated iOS deployment target to 12.0 or higher

## ✅ Code Changes

- [x] Created `lib/core/services/fcm_service.dart`
- [x] Created `lib/core/services/geofencing_notification_service.dart`
- [x] Updated `lib/core/services/notification_service.dart`
- [x] Updated `lib/features/evidence_issue_reporting/screens/issue_list_screen.dart` to use StreamBuilder
- [x] Added `getIssuesStream()` method to `IssueProvider`
- [x] Updated `lib/main.dart` to initialize FCM

## ✅ Testing on Devices

### Android Testing
- [ ] Build and run on Android device
- [ ] Grant location permission when prompted
- [ ] Test local notifications appear
- [ ] Test FCM token is generated
- [ ] Test real-time issue updates

### iOS Testing
- [ ] Build and run on iOS device
- [ ] Grant location permission when prompted
- [ ] Test local notifications appear
- [ ] Test FCM token is generated
- [ ] Test real-time issue updates

## ✅ Backend Integration

- [ ] Created FCM token storage in user profile
- [ ] Set up backend API to send push notifications
- [ ] Implemented topic subscription endpoint
- [ ] Tested sending messages via Firebase console
- [ ] Tested automated notifications for issue updates

## ✅ Monitoring & Debugging

- [ ] Enable logging in debug builds
- [ ] Set up Firebase Analytics (optional)
- [ ] Configure Firestore rules for real-time queries
- [ ] Test with network throttling for offline scenarios

## 🚀 Deployment Checklist

- [ ] Release builds tested on real devices
- [ ] FCM certificate uploaded to Firebase
- [ ] Notification permissions requested appropriately
- [ ] Location permissions configured for continuous monitoring
- [ ] Error handling tested for permission denials
- [ ] Cooldown periods verified to prevent spam
- [ ] Battery optimization verified on long-running tests

## 📱 Feature Verification

### Real-Time Issue Updates
- [ ] New issues appear instantly in list
- [ ] Issue status changes appear instantly
- [ ] Filtering by status works with real-time data
- [ ] Offline mode fallback works

### Geofencing
- [ ] Location monitoring starts on app launch
- [ ] Location monitoring stops when app closes
- [ ] Notifications appear when entering geofence area
- [ ] Cooldown prevents duplicate notifications
- [ ] Distance calculations are accurate

### Push Notifications
- [ ] App receives FCM tokens
- [ ] Foreground messages show notifications
- [ ] Background messages are handled
- [ ] Tapping notification opens correct screen
- [ ] Multiple notification types work

## 🔧 Troubleshooting Steps

If features aren't working:

1. **Check FCM Token Generation**
   ```dart
   final token = await FCMService.instance.getToken();
   print('Token: $token');
   ```

2. **Check Location Permission**
   ```dart
   final permission = await GeofencingNotificationService.requestLocationPermission();
   print('Permission: $permission');
   ```

3. **Check Firestore Connection**
   - Verify Firestore rules allow read access
   - Check internet connection
   - Verify Firebase is initialized

4. **Check Notifications**
   - Verify notification channel is created
   - Check notification permissions are granted
   - Test with local notification first

5. **Check Logs**
   - Search for "[FCMService]" in logs
   - Search for "[GeofencingNotificationService]" in logs
   - Search for "[NotificationService]" in logs

## 📚 Documentation

- [REAL_TIME_INTEGRATION_GUIDE.md](./REAL_TIME_INTEGRATION_GUIDE.md) - Comprehensive integration guide
- [lib/examples/geofencing_integration_examples.dart](./lib/examples/geofencing_integration_examples.dart) - Code examples

## ✨ Next Steps

After setup is complete:

1. Monitor real-world usage
2. Gather user feedback on notification frequency
3. Adjust geofence radius based on real-world data
4. Optimize notification cooldown periods
5. Add analytics for notification engagement
