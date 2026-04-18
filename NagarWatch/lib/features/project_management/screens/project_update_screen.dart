import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/project_model.dart';
import '../providers/project_provider.dart';

class ProjectUpdateScreen extends StatefulWidget {
  final String projectId;
  const ProjectUpdateScreen({super.key, required this.projectId});
  @override State<ProjectUpdateScreen> createState() => _State();
}

class _State extends State<ProjectUpdateScreen> {
  late ProjectModel _project;
  late ProjectStatus _status;
  late int _progress;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final prov = context.read<ProjectProvider>();
    _project = prov.projects.firstWhere((p) => p.id == widget.projectId, orElse: () => kSampleProjects.first);
    _status = _project.status;
    _progress = _project.progressPercent;
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    await context.read<ProjectProvider>().updateProject(widget.projectId, {
      'status': _status.name, 'progressPercent': _progress,
    });
    if (mounted) { setState(() => _loading = false); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(title: const Text('Update Project'), backgroundColor: Colors.white, foregroundColor: AppColors.textPrimary, elevation: 0),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text(_project.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text(_project.location, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(height: 28),
      const Text('Update Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      ...ProjectStatus.values.map((s) {
        final (label, color) = switch (s) {
          ProjectStatus.planned => ('📋 Planned', AppColors.primary),
          ProjectStatus.ongoing => ('🔨 Ongoing', AppColors.warning),
          ProjectStatus.completed => ('✅ Completed', AppColors.accentDark),
          ProjectStatus.delayed => ('⚠️ Delayed', AppColors.danger),
        };
        final active = _status == s;
        return Padding(padding: const EdgeInsets.only(bottom: 8), child: GestureDetector(
          onTap: () => setState(() => _status = s),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: active ? color.withOpacity(.08) : AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: active ? color : AppColors.border, width: active ? 2 : 1.5)),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? color : AppColors.textTertiary)),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: active ? color : AppColors.textSecondary)),
              if (active) ...[const Spacer(), Icon(Icons.check_circle_rounded, color: color, size: 20)],
            ]),
          ),
        ));
      }),
      const SizedBox(height: 24),
      Text('Progress: $_progress%', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      Slider(value: _progress.toDouble(), min: 0, max: 100, divisions: 20, activeColor: AppColors.primary, onChanged: (v) => setState(() => _progress = v.toInt())),
      const SizedBox(height: 32),
      ElevatedButton(
        onPressed: _loading ? null : _save,
        child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save Changes'),
      ),
    ]),
  );
}
