# Real-Time Notifications & Geofencing Integration Guide

This document explains how to integrate and use the real-time notifications and geofencing features in NagarWatch.

## Features Implemented

### 1. Firebase Cloud Messaging (FCM)
- **Location**: `lib/core/services/fcm_service.dart`
- **Purpose**: Enable push notifications from Firebase backend
- **Features**:
  - Automatic token registration
  - Background message handling
  - Topic subscription for group messaging
  - Integration with local notifications as fallback

### 2. Real-Time Issue Updates (StreamBuilder)
- **Location**: `lib/features/evidence_issue_reporting/screens/issue_list_screen.dart`
- **Purpose**: Display live issue updates without manual refresh
- **Features**:
  - Automatic Firestore stream subscription
  - Error handling and loading states
  - Smooth UI updates with StreamBuilder

### 3. Geofencing Notifications
- **Location**: `lib/core/services/geofencing_notification_service.dart`
- **Purpose**: Monitor user location and notify about nearby issues
- **Features**:
  - Continuous background location monitoring
  - Smart notification cooldowns (prevent spam)
  - Configurable geofence radius (default: 5km)
  - Distance calculation and filtering

### 4. Enhanced Notification Service
- **Location**: `lib/core/services/notification_service.dart`
- **Updates**:
  - Added FCM support
  - Added specific notification types (issue updates, nearby issues, etc.)
  - Improved permission handling
  - Cooldown management

## Usage Guide

### Initialization

The FCM and notification services are automatically initialized in `lib/main.dart`:

```dart
// Already done in main.dart
await NotificationService.instance.initialize();
await FCMService.instance.initialize();
```

### Real-Time Issue Updates in IssueListScreen

The issue list now uses `StreamBuilder` for real-time updates:

```dart
StreamBuilder<List<IssueModel>>(
  stream: issueProvider.getIssuesStream(wardId),
  builder: (context, snapshot) {
    // UI updates automatically when issues change in Firestore
  },
)
```

### Geofencing Notifications

#### Manual Setup in a Screen

```dart
@override
void initState() {
  super.initState();
  _initializeGeofencing();
}

Future<void> _initializeGeofencing() async {
  // Request permission
  final permission = await GeofencingNotificationService.requestLocationPermission();
  
  if (!permission.isDenied && !permission.isDeniedForever) {
    // Start monitoring
    await GeofencingNotificationService.instance.startMonitoring();
  }
}

@override
void dispose() {
  GeofencingNotificationService.instance.stopMonitoring();
  super.dispose();
}
```

#### Notify About Nearby Issues

```dart
// Check if user is near an issue
final isNear = await GeofencingNotificationService.instance.isUserNearIssue(
  issue,
  radiusKm: 5.0, // Optional: change geofence radius
);

// Or notify and check in one call
final notified = await GeofencingNotificationService.instance.notifyNearbyIssue(
  issue,
  radiusKm: 5.0,
);

// Filter multiple issues to get only nearby ones
final nearbyIssues = await GeofencingNotificationService.instance.filterNearbyIssues(
  allIssues,
  radiusKm: 5.0,
);
```

### FCM Topics for Issue Notifications

Subscribe users to receive updates about specific projects or wards:

```dart
// Subscribe to project updates
await FCMService.instance.subscribeToTopic('project_${projectId}');

// Subscribe to ward updates
await FCMService.instance.subscribeToTopic('ward_${wardId}');

// Get FCM token for backend registration
final token = await FCMService.instance.getToken();
```

### Custom Notification Handling

Handle different types of FCM messages:

```dart
await FCMService.instance.initialize(
  onMessage: (RemoteMessage message) {
    // Handle message when app is in foreground
    print('Message: ${message.notification?.title}');
  },
  onMessageOpenedApp: (RemoteMessage message) {
    // Handle message when user taps notification
    // Can navigate to relevant screen
  },
);
```

## Backend Integration

### Sending Push Notifications from Backend

1. **Get User FCM Token**: The app registers and stores the FCM token
2. **Send Messages**: Use Firebase Admin SDK

```javascript
// Example Node.js backend
const admin = require('firebase-admin');

const message = {
  notification: {
    title: 'Issue Status Updated',
    body: 'Your issue has been resolved',
  },
  data: {
    type: 'issue_update',
    issue_id: 'issue_123',
    status: 'resolved',
  },
  token: userFCMToken,
};

admin.messaging().send(message);
```

### Topic-Based Broadcasting

Send messages to all users subscribed to a topic:

```javascript
const message = {
  notification: {
    title: 'New Issue in Your Ward',
    body: 'A new issue has been reported',
  },
  data: {
    type: 'new_issue',
  },
  topic: 'ward_123',
};

admin.messaging().send(message);
```

## Permissions Required

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<!-- Location permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Background location (for continuous geofencing) -->
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- Notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>NagarWatch needs your location to show nearby issues</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>NagarWatch needs your location in the background to monitor nearby areas</string>

<key>UIBackgroundModes</key>
<array>
  <string>location</string>
</array>
```

## Troubleshooting

### Notifications Not Showing

1. Check FCM permissions are granted
2. Verify `firebase_options.dart` has correct Firebase config
3. Check notification channel name (default: 'nagarwatch_ch')

### Geofencing Not Working

1. Ensure location permission is granted
2. Enable location services on device
3. Check device has enough battery (geofencing uses continuous GPS)

### Real-Time Updates Not Showing

1. Verify Firestore rules allow read access
2. Check internet connection
3. Verify stream is properly initialized in provider

## Performance Optimization

### Geofencing Battery Usage

Adjust monitoring intervals to balance accuracy and battery:

```dart
await GeofencingNotificationService.instance.startMonitoring(
  accuracy: LocationAccuracy.high,      // Can use medium/low
  distanceFilter: 100,                  // Increase for less frequent updates
  intervalMs: 5000,                     // Increase for less frequent checks
);
```

### Notification Cooldowns

Prevent notification spam with cooldowns:

```dart
static const Duration _notificationCooldown = Duration(minutes: 15);
```

Adjust in `geofencing_notification_service.dart` if needed.

### Stream Optimization

For large lists, consider filtering streams by status:

```dart
// Instead of streaming all issues
Stream<List<IssueModel>> stream = issueProvider.getIssuesStream(wardId);

// Stream only specific status
Stream<List<IssueModel>> stream = issueProvider.getIssuesStreamByStatus(
  wardId,
  IssueStatus.submitted,
);
```

## Testing

### Test FCM Token Registration

```dart
final token = await FCMService.instance.getToken();
print('FCM Token: $token');
```

### Test Local Notification

```dart
await NotificationService.instance.show(
  id: 'test',
  title: 'Test Notification',
  body: 'This is a test',
);
```

### Test Geofencing

```dart
// Manually check if user is near an issue
final isNear = await GeofencingNotificationService.instance.isUserNearIssue(
  testIssue,
  radiusKm: 50, // Large radius for easy testing
);
print('Is near: $isNear');
```

## Next Steps

1. Register FCM tokens in backend user profile
2. Set up backend API to send push notifications
3. Implement topic subscriptions for ward-specific updates
4. Add notification tap handlers for deep linking
5. Test on real devices with location enabled
