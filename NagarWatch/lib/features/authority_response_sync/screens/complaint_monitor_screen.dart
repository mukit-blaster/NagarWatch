import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/models/issue_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../evidence_issue_reporting/providers/issue_provider.dart';

class ComplaintMonitorScreen extends StatefulWidget {
  const ComplaintMonitorScreen({super.key});

  @override
  State<ComplaintMonitorScreen> createState() => _ComplaintMonitorScreenState();
}

class _ComplaintMonitorScreenState extends State<ComplaintMonitorScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _statusFilter = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final issueProvider = context.watch<IssueProvider>();
    final wardId = context.watch<AuthProvider>().user?.wardId;

    final scopedIssues = issueProvider.issues.where((issue) {
      return wardId == null || wardId.isEmpty || issue.wardId == wardId;
    }).toList();

    final filtered = scopedIssues.where((issue) {
      final q = _search.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          issue.title.toLowerCase().contains(q) ||
          issue.areaName.toLowerCase().contains(q) ||
          issue.roadNumber.toLowerCase().contains(q) ||
          (issue.reportedBy ?? '').toLowerCase().contains(q);
      final matchesStatus = _statusFilter == 'All' || issue.status.name == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: C.bg,
        body: Column(
          children: [
            ScreenHeader(
              title: 'Complaint Monitor',
              actions: [
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.authorityRequestsManagement),
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  color: C.textPrimary,
                  tooltip: 'Authority requests',
                ),
              ],
            ),
            _searchBar(),
            _filterRow(),
            _summaryStrip(scopedIssues),
            Expanded(
              child: issueProvider.isLoading && scopedIssues.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final issue = filtered[index];
                            return _IssueCard(issue: issue);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Container(
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: R.md,
            border: Border.all(color: C.border, width: 1.5),
            boxShadow: S.xs,
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Icon(Icons.search_rounded, color: C.textTertiary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (value) => setState(() => _search = value),
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: C.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Search by title, area, road…',
                    hintStyle: TextStyle(color: C.textTertiary, fontSize: 14, fontFamily: 'Inter'),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (_search.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _search = '');
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.close_rounded, color: C.textTertiary, size: 18),
                  ),
                ),
            ],
          ),
        ),
      );

  Widget _filterRow() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 0, 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            children: const [
              _FilterChip(label: 'All', status: 'All'),
              _FilterChip(label: 'Submitted', status: 'submitted'),
              _FilterChip(label: 'In Progress', status: 'inProgress'),
              _FilterChip(label: 'Resolved', status: 'resolved'),
            ],
          ),
        ),
      );

  Widget _summaryStrip(List<IssueModel> issues) {
    final submitted = issues.where((i) => i.status == IssueStatus.submitted).length;
    final inProgress = issues.where((i) => i.status == IssueStatus.inProgress).length;
    final resolved = issues.where((i) => i.status == IssueStatus.resolved).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          _Strip('$submitted', 'Submitted', C.primaryLight, C.primary50),
          const SizedBox(width: 8),
          _Strip('$inProgress', 'In Progress', C.warning, C.warning50),
          const SizedBox(width: 8),
          _Strip('$resolved', 'Resolved', C.accentDark, C.accent50),
          const SizedBox(width: 8),
          _Strip('${issues.length}', 'Total', C.textSecondary, C.borderLight),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle_outline_rounded, size: 64, color: C.accentDark),
          SizedBox(height: 14),
          Text('No complaints match.', style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800, color: C.textPrimary)),
          SizedBox(height: 6),
          Text('Citizen reports will appear here automatically.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: C.textSecondary)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String status;

  const _FilterChip({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_ComplaintMonitorScreenState>();
    final active = state?._statusFilter == status;
    final color = status == 'submitted'
        ? C.primaryLight
        : status == 'inProgress'
            ? C.warning
            : status == 'resolved'
                ? C.accentDark
                : C.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => state?.setState(() => state._statusFilter = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? (status == 'All' ? C.textPrimary : color.withOpacity(.12)) : C.card,
            borderRadius: R.full,
            border: Border.all(color: active ? (status == 'All' ? C.textPrimary : color) : C.border, width: 1.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? (status == 'All' ? Colors.white : color) : C.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final IssueModel issue;

  const _IssueCard({required this.issue});

  Color get _pc {
    switch (issue.status) {
      case IssueStatus.submitted:
        return C.primaryLight;
      case IssueStatus.inProgress:
        return C.warning;
      case IssueStatus.resolved:
        return C.accentDark;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: R.md,
          boxShadow: S.sm,
          border: Border.all(color: const Color(0x06000000)),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, decoration: BoxDecoration(color: _pc, borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)))),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(issue.title, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: C.textPrimary)),
                      const SizedBox(height: 3),
                      Text(issue.areaName, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.textSecondary)),
                      const SizedBox(height: 3),
                      Text('Road ${issue.roadNumber}${issue.reportedBy != null ? ' • ${issue.reportedBy}' : ''}', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.textTertiary)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _StatusDrop(
                  value: issue.status,
                  onChanged: (status) => context.read<IssueProvider>().updateStatus(issue.id, status),
                ),
              ),
            ],
          ),
        ),
      );
}

class _StatusDrop extends StatelessWidget {
  final IssueStatus value;
  final ValueChanged<IssueStatus> onChanged;

  const _StatusDrop({required this.value, required this.onChanged});

  Color get _c {
    switch (value) {
      case IssueStatus.submitted:
        return C.primaryLight;
      case IssueStatus.inProgress:
        return C.warning;
      case IssueStatus.resolved:
        return C.accentDark;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: _c.withOpacity(.1), borderRadius: R.full, border: Border.all(color: _c.withOpacity(.3))),
        child: DropdownButton<IssueStatus>(
          value: value,
          isDense: true,
          underline: const SizedBox(),
          icon: Icon(Icons.expand_more_rounded, size: 14, color: _c),
          style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: _c),
          dropdownColor: C.card,
          borderRadius: R.md,
          items: const [
            DropdownMenuItem(value: IssueStatus.submitted, child: Text('Submitted')),
            DropdownMenuItem(value: IssueStatus.inProgress, child: Text('In Progress')),
            DropdownMenuItem(value: IssueStatus.resolved, child: Text('Resolved')),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      );
}

class _Strip extends StatelessWidget {
  final String val;
  final String label;
  final Color color;
  final Color bg;

  const _Strip(this.val, this.label, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: bg, borderRadius: R.sm),
          child: Column(
            children: [
              Text(val, style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w500, color: C.textSecondary)),
            ],
          ),
        ),
      );
}
