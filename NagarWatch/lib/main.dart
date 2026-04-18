import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'features/authentication/providers/auth_provider.dart';
import 'features/evidence_issue_reporting/providers/evidence_provider.dart';
import 'features/evidence_issue_reporting/providers/issue_provider.dart';
import 'features/geofencing_notifications/providers/geofence_provider.dart';
import 'features/project_management/providers/project_provider.dart';
import 'features/authority_response_sync/providers/authority_provider.dart';
import 'features/authority_response_sync/providers/authority_approval_provider.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/local_cache_service.dart';
import 'core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Initialize services
  try {
    await LocalCacheService.instance.initialize();
    print('✓ Local cache initialized');
  } catch (e) {
    print('✗ Local cache initialization failed: $e');
  }

  try {
    await FirestoreService.instance.initialize();
    print('✓ Firestore initialized');
  } catch (e) {
    print('✗ Firestore initialization failed: $e');
  }

  await NotificationService.instance.initialize();
  print('✓ Notification service initialized');

  // Initialize FCM for cloud messaging
  try {
    await FCMService.instance.initialize();
    print('✓ FCM service initialized');
  } catch (e) {
    print('✗ FCM initialization failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()..loadProjects()),
        ChangeNotifierProvider(create: (_) => IssueProvider()..loadIssues()),
        ChangeNotifierProvider(create: (_) => EvidenceProvider()..streamEvidence()),
        ChangeNotifierProvider(create: (_) => GeofenceProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => AuthorityProvider()),
        ChangeNotifierProvider(create: (_) => AuthorityApprovalProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()..init()),
      ],
      child: const NagarWatchApp(),
    ),
  );
}
