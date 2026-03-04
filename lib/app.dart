import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_app_nagar_watch/features/evidence_issue_reporting/providers/issue_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IssueProvider()),
        // Add other providers here as your app grows (e.g., AuthProvider, UserProvider)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NagarWatch',

        // --- Theming ---
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.system,

        // --- Navigation ---
        initialRoute: AppRouter.welcome,
        routes: AppRouter.routes,

        // --- Localization (Recommended for Bangladesh) ---
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('bn', 'BD'), // Adding Bengali support
        ],
        localizationsDelegates: const [
          // Add your localization delegates here when ready
        ],
      ),
    );
  }
}
