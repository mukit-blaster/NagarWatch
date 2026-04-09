import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/authority_response_sync/screens/authority_dashboard.dart';
import 'routes/app_router.dart';

class NagarWatchApp extends StatelessWidget {
  const NagarWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NagarWatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        useMaterial3: true,
        scaffoldBackgroundColor: C.bg,
        colorScheme: const ColorScheme.light(
          primary: C.primary,
          secondary: C.accent,
        ),
      ),
      home: const AuthorityDashboard(),
      onGenerateRoute: AppRouter.generate,
    );
  }
}
