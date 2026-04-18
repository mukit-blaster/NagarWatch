import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/project_model.dart';
import '../../authentication/providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../../../core/widgets/project_type_icon.dart';
import '../../../core/widgets/status_badge.dart';
import 'project_create_screen.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProjectProvider>();
    final canAddProject = context.watch<AuthProvider>().isAuthority;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        _appBar(context),
        _searchBar(prov),
        _filterTabs(prov),
        Expanded(child: prov.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : prov.filtered.isEmpty ? _empty() : _list(prov.filtered)),
      ])),
      floatingActionButton: canAddProject
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectCreateScreen())),
              backgroundColor: AppColors.accent,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Project', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }

  Widget _appBar(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      const Text('All Projects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -.3)),
      const Spacer(),
      Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: const Icon(Icons.map_outlined, color: AppColors.textSecondary, size: 18)),
    ]),
  );

  Widget _searchBar(ProjectProvider prov) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
    child: Container(
      decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const SizedBox(width: 14),
        const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
        const SizedBox(width: 10),
        Expanded(child: TextField(
          controller: _searchCtrl,
          onChanged: prov.setSearch,
          decoration: const InputDecoration(hintText: 'Search projects…', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 14), fillColor: Colors.transparent, filled: false, hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14)),
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        )),
        if (_searchCtrl.text.isNotEmpty) GestureDetector(
          onTap: () { _searchCtrl.clear(); prov.setSearch(''); },
          child: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.close, size: 18, color: AppColors.textTertiary)),
        ),
      ]),
    ),
  );

  Widget _filterTabs(ProjectProvider prov) => SizedBox(height: 50, child: ListView(
    scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    children: [
      _tab(prov, ProjectFilter.all, 'All'),
      _tab(prov, ProjectFilter.ongoing, 'Ongoing'),
      _tab(prov, ProjectFilter.planned, 'Planned'),
      _tab(prov, ProjectFilter.completed, 'Completed'),
    ],
  ));

  Widget _tab(ProjectProvider prov, ProjectFilter f, String label) {
    final active = prov.filter == f;
    return GestureDetector(
      onTap: () => prov.setFilter(f),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(color: active ? AppColors.primary : AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.5)),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }

  Widget _list(List<ProjectModel> projects) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), itemCount: projects.length,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (_, i) => _ProjectCard(
      project: projects[i],
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: projects[i].id))),
    ),
  );

  Widget _empty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.folder_open_outlined, size: 72, color: AppColors.textTertiary.withOpacity(.4)),
    const SizedBox(height: 16),
    const Text('No projects found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
  ]));
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;
  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(.03)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(children: [
        Row(children: [
          ProjectTypeIcon(type: project.type, size: 42),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(project.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text('৳${project.budgetLakh.toStringAsFixed(0)} লাখ • ${project.deadlineLabel}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          const SizedBox(width: 8),
          StatusBadge(status: project.status),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
          value: project.progressPercent / 100, minHeight: 6,
          backgroundColor: AppColors.borderLight,
          valueColor: AlwaysStoppedAnimation(_progressColor(project)),
        )),
      ]),
    ),
  );

  Color _progressColor(ProjectModel p) {
    if (p.status == ProjectStatus.completed) return AppColors.accentDark;
    if (p.progressPercent >= 60) return AppColors.warning;
    return AppColors.primary;
  }
}
