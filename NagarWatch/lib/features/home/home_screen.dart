import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/models/project_model.dart';
import '../authentication/providers/auth_provider.dart';
import '../project_management/providers/project_provider.dart';
import '../project_management/screens/project_list_screen.dart';
import '../evidence_issue_reporting/screens/report_issue_screen.dart';
import '../evidence_issue_reporting/screens/issue_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _index, children: [
      _CitizenDashboard(onTabChange: (i) => setState(() => _index = i)),
      const ProjectListScreen(),
      ReportIssueScreen(onSubmitted: () => setState(() => _index = 3)),
      const IssueListScreen(),
      _ProfileTab(),
    ]),
    bottomNavigationBar: NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: AppColors.primary50,
        backgroundColor: AppColors.card,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
          color: s.contains(WidgetState.selected) ? AppColors.primary : AppColors.textSecondary,
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
      ),
      child: NavigationBar(
        elevation: 0, selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppColors.primary), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business, color: AppColors.primary), label: 'Projects'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline_rounded), selectedIcon: Icon(Icons.add_circle_rounded, color: AppColors.primary), label: 'Report'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt, color: AppColors.primary), label: 'Issues'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppColors.primary), label: 'Profile'),
        ],
      ),
    ),
  );
}

class _CitizenDashboard extends StatelessWidget {
  final ValueChanged<int> onTabChange;
  const _CitizenDashboard({required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prov = context.watch<ProjectProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _header(context, auth)),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _statsRow(prov),
          const SizedBox(height: 24),
          _ActionGrid(context, onTabChange: onTabChange),
          const SizedBox(height: 24),
          const Text('Recent Projects', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          if (prov.isLoading) const Center(child: CircularProgressIndicator(color: AppColors.primary))
          else ...prov.projects.take(3).map((p) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _ProjectMini(p))),
        ]))),
      ]),
    );
  }

  Widget _header(BuildContext context, AuthProvider auth) => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [AppColors.welcomeStart, AppColors.welcomeMid1, AppColors.welcomeMid2])),
    child: SafeArea(bottom: false, child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('NagarWatch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -.3)),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.geofenceArea),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(.2))),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.my_location_rounded, color: Colors.white, size: 13), SizedBox(width: 4), Text('Detect Area', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))])),
        ),
      ]),
      const SizedBox(height: 14),
      Text('Welcome back,', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(.7))),
      Text(auth.user?.name ?? 'Citizen', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
      const SizedBox(height: 4),
      Text(auth.user?.wardName ?? 'Select your ward', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.65))),
    ]))),
  );

  Widget _statsRow(ProjectProvider prov) => Row(children: [
    _Stat(prov.projects.where((p) => p.status == ProjectStatus.ongoing).length.toString(), 'Ongoing', AppColors.warning, AppColors.warning50),
    const SizedBox(width: 10),
    _Stat(prov.projects.where((p) => p.status == ProjectStatus.planned).length.toString(), 'Planned', AppColors.primaryLight, AppColors.primary50),
    const SizedBox(width: 10),
    _Stat(prov.projects.where((p) => p.status == ProjectStatus.completed).length.toString(), 'Done', AppColors.accentDark, AppColors.accent50),
  ]);
}

class _Stat extends StatelessWidget {
  final String val, label; final Color color, bg;
  const _Stat(this.val, this.label, this.color, this.bg);
  @override Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)), child: Column(children: [Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)), Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500))])));
}

class _ProjectMini extends StatelessWidget {
  final ProjectModel p;
  const _ProjectMini(this.p);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 4, offset: const Offset(0, 2))]),
    child: Row(children: [
      Container(width: 6, height: 36, decoration: BoxDecoration(color: p.status == ProjectStatus.completed ? AppColors.accentDark : p.status == ProjectStatus.ongoing ? AppColors.warning : AppColors.primaryLight, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text('${p.progressPercent}% complete • ${p.deadlineLabel}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ])),
      const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
    ]),
  );
}

class _ActionGrid extends StatelessWidget {
  final BuildContext ctx;
  final ValueChanged<int> onTabChange;
  const _ActionGrid(this.ctx, {required this.onTabChange});
  @override Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
    children: [
      _action(Icons.report_problem_outlined, 'Report Issue', AppColors.danger, AppColors.danger50, () => onTabChange(2)),
      _action(Icons.business_outlined, 'All Projects', AppColors.primary, AppColors.primary50, () => onTabChange(1)),
      _action(Icons.list_alt_outlined, 'My Reports', AppColors.accentDark, AppColors.accent50, () => onTabChange(3)),
      _action(Icons.location_searching_rounded, 'Detect Area', AppColors.warning, AppColors.warning50, () => Navigator.pushNamed(ctx, AppRoutes.geofenceArea)),
    ],
  );
  Widget _action(IconData icon, String label, Color color, Color bg, VoidCallback onTap) => GestureDetector(onTap: onTap,
    child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ]),
    ));
}

class _ProfileTab extends StatelessWidget {
  @override Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(backgroundColor: AppColors.bg, appBar: AppBar(title: const Text('Profile'), backgroundColor: Colors.white, foregroundColor: AppColors.textPrimary, elevation: 0, automaticallyImplyLeading: false),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(child: Container(width: 72, height: 72, decoration: const BoxDecoration(color: AppColors.primary50, shape: BoxShape.circle), child: const Icon(Icons.person_rounded, size: 36, color: AppColors.primary))),
        const SizedBox(height: 10),
        Center(child: Text(auth.user?.name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
        Center(child: Text(auth.user?.email ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        Center(child: Text(auth.user?.wardName ?? 'No ward selected', style: const TextStyle(fontSize: 13, color: AppColors.primaryLight, fontWeight: FontWeight.w600))),
        const SizedBox(height: 24),
        _tile(context, Icons.location_on_outlined, 'Change Ward', () => Navigator.pushNamed(context, AppRoutes.wardSelection)),
        const SizedBox(height: 8),
        _tile(context, Icons.list_alt_outlined, 'My Reports', () => Navigator.pushNamed(context, AppRoutes.issueList)),
        const SizedBox(height: 8),
        _tile(context, Icons.location_searching_rounded, 'Area Detection', () => Navigator.pushNamed(context, AppRoutes.geofenceArea)),
        const Divider(height: 32),
        _tile(context, Icons.logout_rounded, 'Logout', () async { await auth.logout(); if (context.mounted) Navigator.pushReplacementNamed(context, AppRoutes.welcome); }, color: AppColors.danger),
      ]));
  }
  Widget _tile(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) => ListTile(
    leading: Icon(icon, color: color ?? AppColors.primary),
    title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary)),
    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
    onTap: onTap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    tileColor: AppColors.card, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
}
