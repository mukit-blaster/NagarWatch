import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/project_model.dart';
import '../providers/project_provider.dart';

class ProjectCreateScreen extends StatefulWidget {
  const ProjectCreateScreen({super.key});
  @override State<ProjectCreateScreen> createState() => _State();
}

class _State extends State<ProjectCreateScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _loc = TextEditingController();
  final _contractor = TextEditingController();
  ProjectType _type = ProjectType.road;
  String _priority = 'Medium';
  double _budget = 50;
  double _geofence = 500;
  bool _loading = false;

  @override void dispose() { _name.dispose(); _desc.dispose(); _loc.dispose(); _contractor.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final project = ProjectModel(
      id: '', name: _name.text, description: _desc.text,
      wardId: 'ward_12', wardName: 'Ward 12',
      location: _loc.text, latitude: 23.7806, longitude: 90.4141,
      geofenceRadius: _geofence, budgetLakh: _budget,
      deadlineLabel: "Dec '26", status: ProjectStatus.planned, type: _type,
      progressPercent: 0, contractorName: _contractor.text,
      startDate: DateTime.now().toIso8601String(), deadlineDate: '2026-12-31',
      priority: _priority,
    );
    await context.read<ProjectProvider>().createProject(project);
    if (mounted) { setState(() => _loading = false); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(title: const Text('Create Project'), backgroundColor: Colors.white, foregroundColor: AppColors.textPrimary, elevation: 0),
    body: Form(key: _form, child: ListView(padding: const EdgeInsets.all(20), children: [
      _field('Project Name', _name, required: true),
      const SizedBox(height: 16),
      _field('Description', _desc, maxLines: 3),
      const SizedBox(height: 16),
      _field('Location', _loc, required: true),
      const SizedBox(height: 16),
      _field('Contractor Name', _contractor),
      const SizedBox(height: 20),
      const Text('Project Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: ProjectType.values.where((t) => t != ProjectType.other).map((t) {
        final active = _type == t;
        return ChoiceChip(selected: active, onSelected: (_) => setState(() => _type = t),
          label: Text(t.name[0].toUpperCase() + t.name.substring(1)),
          selectedColor: AppColors.primary50, checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(color: active ? AppColors.primary : AppColors.textSecondary, fontWeight: active ? FontWeight.w700 : FontWeight.normal));
      }).toList()),
      const SizedBox(height: 20),
      Text('Budget: ৳${_budget.toInt()} লাখ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      Slider(value: _budget, min: 5, max: 500, divisions: 99, activeColor: AppColors.primary, onChanged: (v) => setState(() => _budget = v)),
      const SizedBox(height: 12),
      Text('Geofence Radius: ${_geofence.toInt()}m', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      Slider(value: _geofence, min: 100, max: 2000, divisions: 38, activeColor: AppColors.primary, onChanged: (v) => setState(() => _geofence = v)),
      const SizedBox(height: 20),
      const Text('Priority', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 10),
      Row(children: ['High','Medium','Low'].map((p) {
        final active = _priority == p;
        final c = p == 'High' ? AppColors.danger : p == 'Medium' ? AppColors.warning : AppColors.primaryLight;
        return Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(
          onTap: () => setState(() => _priority = p),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: active ? c.withOpacity(.1) : AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: active ? c : AppColors.border, width: active ? 1.5 : 1)),
            child: Center(child: Text(p, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? c : AppColors.textSecondary)))),
        )));
      }).toList()),
      const SizedBox(height: 32),
      ElevatedButton(
        onPressed: _loading ? null : _submit,
        child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create Project'),
      ),
      const SizedBox(height: 20),
    ])),
  );

  Widget _field(String label, TextEditingController ctrl, {bool required = false, int maxLines = 1}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      TextFormField(controller: ctrl, maxLines: maxLines,
        validator: required ? (v) => (v?.isEmpty ?? true) ? 'Required' : null : null,
        decoration: InputDecoration(hintText: 'Enter $label')),
    ]);
}
