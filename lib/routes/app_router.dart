import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../features/authority_response_sync/screens/authority_dashboard.dart';
import '../features/authority_response_sync/screens/complaint_monitor_screen.dart';
import '../features/authority_response_sync/screens/evidence_review_screen.dart';
// import '../features/project_management/screens/project_create_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generate(RouteSettings s) {
    switch (s.name) {
      case AppRoutes.complaintMonitor: return _go(const ComplaintMonitorScreen());
      case AppRoutes.evidenceReview:   return _go(const EvidenceReviewScreen());
      // case AppRoutes.addProject:       return _go(const ProjectCreateScreen());
      default:                         return _go(const AuthorityDashboard());
    }
  }

  static PageRouteBuilder<T> _go<T>(Widget page) => PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, a, __, child) => SlideTransition(
      position: Tween(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.fastOutSlowIn))
          .animate(a),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 320),
  );
}
