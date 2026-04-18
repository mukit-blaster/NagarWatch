import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/project_model.dart';
import '../providers/project_provider.dart';
import '../../../core/widgets/status_badge.dart';
import 'project_update_screen.dart';
import '../../evidence_issue_reporting/screens/evidence_upload_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProjectProvider>();
    final project = prov.projects.firstWhere((p) => p.id == projectId, orElse: () => kSampleProjects.first);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: CustomScrollView(slivers: [
        _appBar(context, project),
        SliverToBoxAdapter(child: _hero(project)),
        SliverToBoxAdapter(child: _stats(project)),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          _card('📝 Description', Text(project.description.isEmpty ? 'No description.' : project.description, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6))),
          const SizedBox(height: 12),
          _card('📍 Location & Geofence', Column(children: [
            _MapPlaceholder(geofenceSize: project.geofenceRadius.clamp(60, 120).toDouble()),
            const SizedBox(height: 8),
            Text('Geofence: ${project.geofenceRadius.toInt()}m • Enter zone for notifications', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary), textAlign: TextAlign.center),
            if (project.contractorName.isNotEmpty) ...[const SizedBox(height: 8),
              Row(children: [const Icon(Icons.person_outline, size: 16, color: AppColors.textTertiary), const SizedBox(width: 6), Text('Contractor: ${project.contractorName}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))]),
            ],
          ])),
          const SizedBox(height: 12),
          _card('📊 Milestones', Column(children: project.milestones.isEmpty
            ? [const Text('No milestones.', style: TextStyle(color: AppColors.textTertiary))]
            : project.milestones.map((m) => _MilestoneRow(m)).toList())),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EvidenceUploadScreen(projectId: project.id, projectName: project.name))),
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
            label: const Text('Upload Evidence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
          ),
          const SizedBox(height: 30),
        ]))),
      ])),
    );
  }

  Widget _appBar(BuildContext context, ProjectModel p) => SliverAppBar(
    pinned: true, backgroundColor: Colors.white, elevation: 0,
    leading: Padding(padding: const EdgeInsets.all(8), child: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)), child: const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary)),
    )),
    title: const Text('Project Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    actions: [
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectUpdateScreen(projectId: p.id))),
        child: Container(margin: const EdgeInsets.only(right: 16), width: 40, height: 40, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)), child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary)),
      ),
    ],
  );

  Widget _hero(ProjectModel p) => Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0), padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F1B3D), AppColors.primary, AppColors.primaryLight]), borderRadius: BorderRadius.circular(24)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      StatusBadge(status: p.status, onDark: true), const SizedBox(height: 12),
      Text(p.name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white)),
      const SizedBox(height: 6),
      Text(p.location, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(.6))),
    ]),
  );

  Widget _stats(ProjectModel p) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Row(children: [
      _StatCard('Budget', '৳${p.budgetLakh.toStringAsFixed(0)}L'),
      const SizedBox(width: 10),
      _StatCard('Deadline', p.deadlineLabel),
      const SizedBox(width: 10),
      _StatCard('Progress', '${p.progressPercent}%', p.progressPercent >= 80 ? AppColors.accentDark : p.progressPercent >= 40 ? AppColors.warning : AppColors.primaryLight),
    ]),
  );

  Widget _card(String title, Widget child) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 4, offset: const Offset(0, 2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 12), child,
    ]),
  );
}

class _StatCard extends StatelessWidget {
  final String label, value; final Color? color;
  const _StatCard(this.label, this.value, [this.color]);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 6, offset: const Offset(0, 2))]),
    child: Column(children: [
      Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textTertiary, letterSpacing: .5)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color ?? AppColors.textPrimary)),
    ]),
  ));
}

class _MilestoneRow extends StatelessWidget {
  final MilestoneModel m;
  const _MilestoneRow(this.m);
  @override
  Widget build(BuildContext context) {
    final isPending = m.state == MilestoneState.pending;
    final (dotC, dotI) = switch (m.state) {
      MilestoneState.completed => (AppColors.accent, Icons.check),
      MilestoneState.current => (AppColors.warning, Icons.sync),
      MilestoneState.pending => (Colors.transparent, null),
    };
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
      Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: isPending ? Colors.transparent : dotC, border: isPending ? Border.all(color: AppColors.border, width: 2) : null),
        child: dotI != null ? Icon(dotI, size: 14, color: Colors.white) : null),
      const SizedBox(width: 10),
      Expanded(child: Text(m.title, style: TextStyle(fontSize: 14, color: isPending ? AppColors.textTertiary : AppColors.textPrimary, fontWeight: m.state == MilestoneState.current ? FontWeight.w600 : FontWeight.w400))),
      Text(m.targetDate, style: TextStyle(fontSize: 12, color: m.state == MilestoneState.current ? AppColors.warning : AppColors.textTertiary, fontWeight: m.state == MilestoneState.current ? FontWeight.w600 : FontWeight.w400)),
    ]));
  }
}

class _MapPlaceholder extends StatelessWidget {
  final double geofenceSize;
  const _MapPlaceholder({required this.geofenceSize});
  @override
  Widget build(BuildContext context) => Container(
    height: 160, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFE0F2FE), Color(0xFFDBEAFE)]), borderRadius: BorderRadius.circular(16)),
    child: Center(child: Container(width: geofenceSize, height: geofenceSize, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight.withOpacity(.08), border: Border.all(color: AppColors.primaryLight.withOpacity(.6), width: 2.5)),
      child: const Center(child: Icon(Icons.location_on, color: AppColors.primary, size: 32)))),
  );
}
