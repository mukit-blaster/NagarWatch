import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../features/authentication/screens/welcome_screen.dart';
import '../features/authentication/screens/login_screen.dart';
import '../features/authentication/screens/admin_login_screen.dart';
import '../features/authentication/screens/register_screen.dart';
import '../features/authentication/screens/ward_selection_screen.dart';
import '../features/home/home_screen.dart';
import '../features/project_management/screens/project_list_screen.dart';
import '../features/project_management/screens/project_detail_screen.dart';
import '../features/project_management/screens/project_create_screen.dart';
import '../features/project_management/screens/project_update_screen.dart';
import '../features/evidence_issue_reporting/screens/report_issue_screen.dart';
import '../features/evidence_issue_reporting/screens/issue_list_screen.dart';
import '../features/evidence_issue_reporting/screens/evidence_upload_screen.dart';
import '../features/authority_response_sync/screens/authority_dashboard.dart';
import '../features/authority_response_sync/screens/authority_approval_pending_screen.dart';
import '../features/authority_response_sync/screens/authority_requests_management_screen.dart';
import '../features/authority_response_sync/screens/complaint_monitor_screen.dart';
import '../features/authority_response_sync/screens/evidence_review_screen.dart';
import '../features/geofencing_notifications/screens/area_detection_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return _slide(const WelcomeScreen());
      case AppRoutes.login:
        return _slide(const LoginScreen());
      case AppRoutes.adminLogin:
        return _slide(const AdminLoginScreen());
      case AppRoutes.register:
        return _slide(const RegisterScreen());
      case AppRoutes.wardSelection:
        return _slide(const WardSelectionScreen());
      case AppRoutes.home:
        return _slide(const HomeScreen());
      case AppRoutes.projectList:
        return _slide(const ProjectListScreen());
      case AppRoutes.projectDetail:
        final id = settings.arguments as String? ?? '';
        return _slide(ProjectDetailScreen(projectId: id));
      case AppRoutes.projectCreate:
        return _slide(const ProjectCreateScreen());
      case AppRoutes.projectUpdate:
        final id = settings.arguments as String? ?? '';
        return _slide(ProjectUpdateScreen(projectId: id));
      case AppRoutes.reportIssue:
        return _slide(ReportIssueScreen(onSubmitted: () {}));
      case AppRoutes.issueList:
        return _slide(const IssueListScreen());
      case AppRoutes.evidenceUpload:
        final args = settings.arguments as Map<String, String>? ?? {};
        return _slide(EvidenceUploadScreen(projectId: args['projectId'] ?? '', projectName: args['projectName'] ?? ''));
      case AppRoutes.authorityDashboard:
        return _slide(const AuthorityDashboard());
      case AppRoutes.authorityApprovalPending:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _slide(AuthorityApprovalPendingScreen(
          userName: args['name'] ?? '',
          userEmail: args['email'] ?? '',
        ));
      case AppRoutes.authorityRequestsManagement:
        return _slide(const AuthorityRequestsManagementScreen());
      case AppRoutes.complaintMonitor:
        return _slide(const ComplaintMonitorScreen());
      case AppRoutes.evidenceReview:
        return _slide(const EvidenceReviewScreen());
      case AppRoutes.geofenceArea:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _slide(
          AreaDetectionScreen(
            onboardingFlow: args['onboardingFlow'] == true,
          ),
        );
      default:
        return _slide(const WelcomeScreen());
    }
  }

  static PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, a, __, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: a, curve: Curves.easeInOutCubic)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 350),
  );
}
