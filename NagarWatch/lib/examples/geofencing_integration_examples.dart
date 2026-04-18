/// Example: Integrating Geofencing Notifications with Issue Updates
/// 
/// This file demonstrates how to combine real-time issue updates with
/// geofencing notifications for a seamless user experience.
library;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../core/models/issue_model.dart';
import '../core/services/geofencing_notification_service.dart';
import '../core/services/notification_service.dart';
import '../features/evidence_issue_reporting/providers/issue_provider.dart';

/// Example 1: Monitor issues and notify about nearby ones
class IssueMonitoringMixin {
  /// Start monitoring for nearby issues
  /// Should be called in home screen or app level
  static Future<void> startIssueMonitoring(BuildContext context) async {
    final issueProvider = context.read<IssueProvider>();
    final issues = issueProvider.issues;

    // Start geofencing
    await GeofencingNotificationService.instance.startMonitoring();

    // Periodically check for nearby issues (every 30 seconds)
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));

      if (!GeofencingNotificationService.instance.isMonitoring) {
        return false;
      }

      // Filter nearby issues
      final nearbyIssues =
          await GeofencingNotificationService.instance.filterNearbyIssues(
        issues,
        radiusKm: 5.0,
      );

      // Notify about each nearby issue
      for (final issue in nearbyIssues) {
        final distance = _calculateDistance(issue);
        await NotificationService.instance.notifyNearbyIssue(
          issue.id,
          issue.title,
          issue.areaName,
          distance.toStringAsFixed(1),
        );
      }

      return true;
    });
  }

  static double _calculateDistance(IssueModel issue) {
    // Calculate actual distance
    // Implementation details...
    return 0.0;
  }
}

/// Example 2: Display nearby issues in a dedicated widget
class NearbyIssuesWidget extends StatefulWidget {
  final List<IssueModel> allIssues;

  const NearbyIssuesWidget({
    required this.allIssues,
    super.key,
  });

  @override
  State<NearbyIssuesWidget> createState() => _NearbyIssuesWidgetState();
}

class _NearbyIssuesWidgetState extends State<NearbyIssuesWidget> {
  late Stream<List<IssueModel>> _nearbyIssuesStream;

  @override
  void initState() {
    super.initState();
    _nearbyIssuesStream = _getNearbyIssuesStream();
  }

  Stream<List<IssueModel>> _getNearbyIssuesStream() async* {
    while (true) {
      try {
        final nearbyIssues =
            await GeofencingNotificationService.instance.filterNearbyIssues(
          widget.allIssues,
          radiusKm: 5.0,
        );
        yield nearbyIssues;
      } catch (e) {
        print('Error filtering nearby issues: $e');
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<IssueModel>>(
      stream: _nearbyIssuesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final nearbyIssues = snapshot.data ?? [];

        if (nearbyIssues.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No issues nearby',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: nearbyIssues.length,
          itemBuilder: (context, index) {
            final issue = nearbyIssues[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: Text(issue.title),
                subtitle: Text('${issue.areaName} - Nearby'),
              ),
            );
          },
        );
      },
    );
  }
}

/// Example 3: Enhanced Issue Provider with Geofencing Integration
class EnhancedIssueProviderExample extends ChangeNotifier {
  final _geofencingService = GeofencingNotificationService.instance;
  final _notificationService = NotificationService.instance;
  
  final List<IssueModel> _issues = [];
  List<IssueModel> _nearbyIssues = [];
  bool _isMonitoring = false;

  List<IssueModel> get nearbyIssues => _nearbyIssues;
  bool get isMonitoring => _isMonitoring;

  /// Start monitoring for nearby issues
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    _isMonitoring = true;
    await _geofencingService.startMonitoring();
    notifyListeners();

    // Continuous monitoring loop
    _monitorNearbyIssues();
  }

  /// Stop monitoring
  Future<void> stopMonitoring() async {
    _isMonitoring = false;
    await _geofencingService.stopMonitoring();
    notifyListeners();
  }

  /// Internal: Monitor and notify about nearby issues
  Future<void> _monitorNearbyIssues() async {
    while (_isMonitoring) {
      try {
        // Get nearby issues
        final nearby = await _geofencingService.filterNearbyIssues(
          _issues,
          radiusKm: 5.0,
        );

        // Check for new nearby issues
        final newNearby = nearby.where(
          (issue) => !_nearbyIssues.any((old) => old.id == issue.id),
        );

        // Notify about new nearby issues
        for (final issue in newNearby) {
          await _notificationService.notifyNearbyIssue(
            issue.id,
            issue.title,
            issue.areaName,
            '5',
          );
        }

        _nearbyIssues = nearby;
        notifyListeners();
      } catch (e) {
        print('Error monitoring nearby issues: $e');
      }

      // Check every 30 seconds
      await Future.delayed(const Duration(seconds: 30));
    }
  }
}

/// Example 4: Automatic Topic Subscription Based on Location
class SmartTopicSubscriptionExample {
  static Future<void> subscribeToLocalTopics(IssueModel issue) async {
    // Subscribe to ward topic
    if (issue.wardId != null) {
      await NotificationService.instance.subscribeToTopic(
        'ward_${issue.wardId}',
      );
    }

    // Subscribe to area topic
    await NotificationService.instance.subscribeToTopic(
      'area_${issue.areaName}',
    );
  }

  static Future<void> unsubscribeFromTopic(String topicName) async {
    await NotificationService.instance.unsubscribeFromTopic(topicName);
  }
}

/// Example 5: Real-time issue updates with geofencing
class RealTimeIssueScreen extends StatefulWidget {
  const RealTimeIssueScreen({super.key});

  @override
  State<RealTimeIssueScreen> createState() => _RealTimeIssueScreenState();
}

class _RealTimeIssueScreenState extends State<RealTimeIssueScreen> {
  @override
  void initState() {
    super.initState();
    _setupRealtimeFeatures();
  }

  Future<void> _setupRealtimeFeatures() async {
    // Get provider
    final issueProvider = context.read<IssueProvider>();

    // Start geofencing monitoring
    final permission =
        await GeofencingNotificationService.requestLocationPermission();
    if (permission != LocationPermission.denied &&
      permission != LocationPermission.deniedForever) {
      await GeofencingNotificationService.instance.startMonitoring();
    }

    // Subscribe to relevant topics
    for (final issue in issueProvider.issues) {
      await SmartTopicSubscriptionExample.subscribeToLocalTopics(issue);
    }
  }

  @override
  void dispose() {
    GeofencingNotificationService.instance.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real-Time Issues')),
      body: const Center(
        child: Text('See IssueListScreen for implementation'),
      ),
    );
  }
}
