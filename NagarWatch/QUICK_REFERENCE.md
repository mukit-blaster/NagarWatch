# Quick Reference Guide

## Common Tasks

### Enable Real-Time Updates in Any Screen

```dart
// In your widget
StreamBuilder<List<IssueModel>>(
  stream: context.read<IssueProvider>().getIssuesStream('ward_id'),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final issues = snapshot.data!;
      // Build UI with issues
    }
  },
)
```

### Check if User is Near an Issue

```dart
final isNear = await GeofencingNotificationService.instance.isUserNearIssue(
  issue,
  radiusKm: 5.0,
);
```

### Send a Push Notification from Backend

```javascript
// Node.js example
const admin = require('firebase-admin');

await admin.messaging().send({
  notification: {
    title: 'Issue Updated',
    body: 'Your reported issue status changed',
  },
  data: {
    type: 'issue_update',
    issue_id: '123',
  },
  token: userFCMToken,
});
```

### Subscribe User to Ward Updates

```dart
await FCMService.instance.subscribeToTopic('ward_${wardId}');
```

### Get Nearby Issues

```dart
final nearbyIssues = await GeofencingNotificationService.instance
    .filterNearbyIssues(allIssues, radiusKm: 5.0);
```

### Stop Geofencing

```dart
await GeofencingNotificationService.instance.stopMonitoring();
```

### Get FCM Token for Backend Registration

```dart
final token = await FCMService.instance.getToken();
// Send to backend API
```

## File Locations

| Feature | File |
|---------|------|
| FCM Service | `lib/core/services/fcm_service.dart` |
| Geofencing Service | `lib/core/services/geofencing_notification_service.dart` |
| Notifications | `lib/core/services/notification_service.dart` |
| Real-Time Issues | `lib/features/evidence_issue_reporting/screens/issue_list_screen.dart` |
| Issue Provider | `lib/features/evidence_issue_reporting/providers/issue_provider.dart` |
| App Init | `lib/main.dart` |

## Environment Setup

### Firebase
1. Go to Firebase Console
2. Create/select NagarWatch project
3. Enable Cloud Messaging
4. Download `google-services.json` → `android/app/`
5. Download `GoogleService-Info.plist` → `ios/Runner/`

### Android Permissions
File: `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### iOS Permissions
File: `ios/Runner/Info.plist`
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location for nearby issues</string>
<key>UIBackgroundModes</key>
<array><string>location</string></array>
```

## Debugging

### Check FCM Token
```dart
final token = await FCMService.instance.getToken();
print('FCM Token: $token');
```

### Test Local Notification
```dart
await NotificationService.instance.show(
  id: 'test',
  title: 'Test',
  body: 'Testing notification',
);
```

### Check Geofencing Status
```dart
print('Monitoring: ${GeofencingNotificationService.instance.isMonitoring}');
print('Position: ${GeofencingNotificationService.instance.lastKnownPosition}');
```

### Enable Detailed Logging
Search logs for:
- `[FCMService]` - FCM operations
- `[GeofencingNotificationService]` - Geofencing operations
- `[NotificationService]` - Notification operations

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No FCM token | Check Firebase config files exist and google-services.json is in android/app/ |
| Notifications not showing | Check notification permissions are granted |
| Geofencing not working | Check location permission and GPS is enabled |
| Real-time updates slow | Check internet connection and Firestore quota |
| Battery drain | Reduce geofencing update frequency (increase intervalMs) |

## Performance Tips

1. **Reduce geofencing overhead**
   ```dart
   await GeofencingNotificationService.instance.startMonitoring(
     intervalMs: 10000,  // Check every 10 seconds instead of 5
     distanceFilter: 500,  // Require 500m movement
   );
   ```

2. **Use filtered streams**
   ```dart
   // Better than loading all issues
   stream: provider.getIssuesStreamByStatus(wardId, IssueStatus.submitted)
   ```

3. **Clear old cooldowns**
   ```dart
   GeofencingNotificationService.instance.clearAllCooldowns();
   ```

## API Endpoints (Backend)

### Register FCM Token
```
POST /api/users/{userId}/fcm-token
Body: { token: "fcm_token_here" }
```

### Send Push Notification
```
POST /api/notifications/send
Body: {
  token: "fcm_token",
  title: "Title",
  body: "Body",
  data: { type: "issue_update" }
}
```

### Send Topic Notification
```
POST /api/notifications/topic
Body: {
  topic: "ward_123",
  title: "Title",
  body: "Body",
  data: { type: "ward_update" }
}
```

## Database Queries

### Firestore - Get issues for geofencing
```javascript
db.collection('issues')
  .where('wardId', '==', currentWard)
  .where('status', '!=', 'resolved')
  .orderBy('status')
  .orderBy('createdAt', 'desc')
```

### Firestore - Real-time listener
```javascript
db.collection('issues')
  .where('wardId', '==', wardId)
  .onSnapshot(snapshot => {
    // Handle changes
  });
```

## Best Practices

✅ DO:
- Request permissions explicitly
- Clear cooldowns when navigating away
- Stop monitoring when app is not in use
- Use topics for broadcast messages
- Implement error handling

❌ DON'T:
- Force continuous geofencing
- Show notification spam
- Store sensitive data in FCM messages
- Use high-accuracy GPS constantly
- Ignore permission denials

## Resources

- [Firebase Cloud Messaging Docs](https://firebase.flutter.dev/docs/messaging/overview/)
- [Geolocator Package Docs](https://pub.dev/packages/geolocator)
- [Flutter Local Notifications Docs](https://pub.dev/packages/flutter_local_notifications)
- [Complete Guide](./REAL_TIME_INTEGRATION_GUIDE.md)
- [Setup Checklist](./SETUP_CHECKLIST.md)
- [Code Examples](./lib/examples/geofencing_integration_examples.dart)
