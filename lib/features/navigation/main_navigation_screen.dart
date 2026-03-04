import 'package:flutter/material.dart';
import 'package:flutter_app_nagar_watch/features/evidence_issue_reporting/screens/report_issue_screen.dart';
import 'package:flutter_app_nagar_watch/features/evidence_issue_reporting/screens/issue_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Smooth Animation Wrapper ---
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: IndexedStack(
          key: ValueKey(_currentIndex), // Crucial: Triggers the animation
          index: _currentIndex,
          children: [
            const Center(child: Text("Home Dashboard")),
            const Center(child: Text("Projects")),
            ReportIssueScreen(
              onSubmitted: () => setState(() => _currentIndex = 3),
            ),
            const IssueListScreen(),
            const Center(child: Text("Profile")),
          ],
        ),
      ),

      // --- Styled NavigationBar ---
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          // Colors and Styling
          indicatorColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundColor: Theme.of(context).colorScheme.surface,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              );
            }
            return TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            );
          }),
        ),
        child: NavigationBar(
          elevation: 0,
          selectedIndex: _currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: "Home",
            ),
            NavigationDestination(
              icon: Icon(Icons.business_outlined),
              selectedIcon: Icon(Icons.business),
              label: "Projects",
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: "Report",
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: "Issues",
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
