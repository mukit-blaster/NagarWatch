import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationHandler {
  NotificationHandler._();
  static final instance = NotificationHandler._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'geofence_channel';
  static const _channelName = 'Geofence Alerts';
  static const _channelDesc =
      'Notifications when you enter/exit selected ward geofence';

  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      ),
    );

    await requestPermissionIfNeeded();
  }

  Future<void> requestPermissionIfNeeded() async {
    // Android 13+ needs POST_NOTIFICATIONS runtime permission
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> showGeofenceNotification({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details);
  }
}
