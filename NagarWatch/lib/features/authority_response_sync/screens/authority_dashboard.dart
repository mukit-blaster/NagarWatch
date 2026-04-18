import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/models/evidence_model.dart';
import '../../../core/models/issue_model.dart';
import '../../../core/models/project_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../evidence_issue_reporting/providers/evidence_provider.dart';
import '../../evidence_issue_reporting/providers/issue_provider.dart';
import '../../project_management/providers/project_provider.dart';
import '../../project_management/screens/project_create_screen.dart';
import 'complaint_monitor_screen.dart';
import 'evidence_review_screen.dart';

class AuthorityDashboard extends StatefulWidget {
  const AuthorityDashboard({super.key});
  @override State<AuthorityDashboard> createState() => _AuthorityDashboardState();
}

class _AuthorityDashboardState extends State<AuthorityDashboard> {
  int _tab = 0;
  String? _lastWardId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wardId = context.read<AuthProvider>().user?.wardId;
    if (_lastWardId != wardId) {
      _lastWardId = wardId;
      if (wardId != null && wardId.isNotEmpty) {
        context.read<ProjectProvider>().streamProjectsByWard(wardId);
        context.read<EvidenceProvider>().streamEvidence(wardId: wardId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: C.bg,
        body: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _header()),
          SliverToBoxAdapter(child: _statsRow()),
          SliverPersistentHeader(pinned: true, delegate: _Pinned(62, child: _tabBar())),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverToBoxAdapter(child: _tabContent()),
          ),
        ]),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _header() => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [C.authStart, C.authMid, C.authEnd],
    )),
    child: SafeArea(bottom: false, child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _hBtn(Icons.logout_rounded, _handleLogoutOrBack),
          const Spacer(),
          const Text('Authority Panel', style: TextStyle(fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
          const Spacer(),
          _hBtn(Icons.refresh_rounded, () => setState(() {})),
        ]),
        const SizedBox(height: 20),
        const Text('Ward Officer Dashboard', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: Color(0x99FFFFFF), letterSpacing: .3)),
        const SizedBox(height: 4),
        const Text('Officer Blaster', style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -.4)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: const Color(0x1AFFFFFF), borderRadius: R.full, border: Border.all(color: const Color(0x26FFFFFF))),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.verified_rounded, size: 13, color: Color(0xFF34D399)),
            SizedBox(width: 6),
            Text('WD-12-2025', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
          ]),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.authorityRequestsManagement),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0x14FFFFFF),
              borderRadius: R.md,
              border: Border.all(color: const Color(0x2AFFFFFF)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Authority Access Requests', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                      SizedBox(height: 2),
                      Text('Review pending requests and promote approved officers', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xB3FFFFFF))),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ]),
    )),
  );

  Widget _hBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: const Color(0x1FFFFFFF), borderRadius: R.sm, border: Border.all(color: const Color(0x1AFFFFFF))),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );

  // ── Stats row ─────────────────────────────────────────────────────────────
  Widget _statsRow() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Builder(builder: (context) {
      final liveProjects = context.watch<ProjectProvider>().projects;
      final liveIssues = context.watch<IssueProvider>().issues;
      final liveEvidence = context.watch<EvidenceProvider>().items;
      return Row(children: [
        Expanded(child: StatCard(icon: Icons.folder_rounded,        iconColor: C.primary,  iconBg: C.primary50, value: '${liveProjects.length}', label: 'Projects')),
        const SizedBox(width: 10),
        Expanded(child: StatCard(icon: Icons.warning_amber_rounded, iconColor: C.danger,   iconBg: C.danger50,  value: '${liveIssues.length}', label: 'Issues')),
        const SizedBox(width: 10),
        Expanded(child: StatCard(icon: Icons.image_rounded,         iconColor: C.warning,  iconBg: C.warning50, value: '${liveEvidence.length}', label: 'Evidence')),
      ]);
    }),
  );

  // ── Tab bar ───────────────────────────────────────────────────────────────
  Widget _tabBar() => Builder(builder: (context) {
    final liveIssueCount = context.watch<IssueProvider>().issues.length;
    final liveEvidenceCount = context.watch<EvidenceProvider>().items.length;
    return Container(
      color: C.bg,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: C.borderLight, borderRadius: R.md, border: Border.all(color: C.border)),
        child: Row(children: [
          _tabBtn(0, 'Projects'),
          _tabBtn(1, 'Issues', badge: liveIssueCount),
          _tabBtn(2, 'Evidence', badge: liveEvidenceCount),
        ]),
      ),
    );
  });

  Widget _tabBtn(int idx, String label, {int? badge}) {
    final on = _tab == idx;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _tab = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: on ? C.card : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: on ? S.md : [],
        ),
        child: Stack(clipBehavior: Clip.none, children: [
          Center(child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: on ? FontWeight.w600 : FontWeight.w500, color: on ? C.primary : C.textTertiary))),
          if (badge != null) Positioned(top: -4, right: 6, child: Container(
            width: 15, height: 15, decoration: const BoxDecoration(color: C.danger, shape: BoxShape.circle),
            child: Center(child: Text('$badge', style: const TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white))),
          )),
        ]),
      ),
    ));
  }

  // ── Tab content ───────────────────────────────────────────────────────────
  Widget _tabContent() {
    switch (_tab) {
      case 0: return _projectsTab();
      case 1: return _issuesTab();
      case 2: return _evidenceTab();
      default: return const SizedBox();
    }
  }

  Widget _projectsTab() => Builder(builder: (context) {
  final projects = context.watch<ProjectProvider>().projects;
  return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const SizedBox(height: 16),

    GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProjectCreateScreen(),
        ),
      ),

      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: R.md,
          boxShadow: S.xs,
          border: Border.all(
            color: C.accent.withOpacity(.25),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [C.accentDark, C.accent],
                ),
                borderRadius: R.sm,
                boxShadow: S.accent,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Project',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: C.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Create a development project for your ward',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: C.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: C.textTertiary,
            ),
          ],
        ),
      ),
    ),

    const SizedBox(height: 14),
    if (projects.isEmpty)
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: C.card, borderRadius: R.md, boxShadow: S.xs),
        child: const Text('No projects yet.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: C.textSecondary)),
      )
    else
      ...projects.take(6).map(
        (project) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ProjectCard(project: project),
        ),
      ),
  ],
);    
  });
  Widget _issuesTab() => Builder(builder: (context) {
    final liveIssues = context.watch<IssueProvider>().issues;
    final previewIssues = liveIssues.take(4).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 16),
      SectionHeader(title: 'Citizen Reports', actionLabel: 'View All',
        onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintMonitorScreen()))),
      const SizedBox(height: 12),
      if (previewIssues.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: C.card, borderRadius: R.md, boxShadow: S.xs),
          child: const Text('No citizen reports yet.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: C.textSecondary)),
        )
      else
        ...previewIssues.map((issue) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _IssueCard(issue: issue),
        )),
    ]);
  });

  Widget _evidenceTab() => Builder(builder: (context) {
    final evidenceItems = context.watch<EvidenceProvider>().items;
    final preview = evidenceItems.take(4).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 16),
      SectionHeader(title: 'Citizen Evidence', actionLabel: 'View All',
        onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EvidenceReviewScreen()))),
      const SizedBox(height: 12),
      if (preview.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: C.card, borderRadius: R.md, boxShadow: S.xs),
          child: const Text('No evidence yet.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: C.textSecondary)),
        )
      else
        ...preview.map((ev) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _EvidCard(ev: ev, onVerify: () => _toast('Use View All to verify'), onReject: () => _toast('Use View All to reject')),
        )),
    ]);
  });

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500)),
    backgroundColor: C.textPrimary, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: R.md), margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 2),
  ));

  Future<void> _handleLogoutOrBack() async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (_) => false);
  }
}

// ── Project card ─────────────────────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  const _ProjectCard({required this.project});

  String get _statusLabel {
    switch (project.status) {
      case ProjectStatus.ongoing:
        return 'Ongoing';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.delayed:
        return 'Delayed';
      case ProjectStatus.planned:
        return 'Planned';
    }
  }

  Color get _statusColor {
    switch (project.status) {
      case ProjectStatus.ongoing:
        return C.warning;
      case ProjectStatus.completed:
        return C.accentDark;
      case ProjectStatus.delayed:
        return C.danger;
      case ProjectStatus.planned:
        return C.primaryLight;
    }
  }

  IconData get _icon {
    switch (project.type) {
      case ProjectType.road:
        return Icons.construction_rounded;
      case ProjectType.drainage:
        return Icons.water_drop_rounded;
      case ProjectType.lighting:
        return Icons.lightbulb_rounded;
      case ProjectType.waste:
        return Icons.delete_rounded;
      case ProjectType.park:
        return Icons.park_rounded;
      case ProjectType.building:
        return Icons.apartment_rounded;
      case ProjectType.other:
        return Icons.folder_rounded;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: C.card, borderRadius: R.md, boxShadow: S.xs, border: Border.all(color: const Color(0x06000000))),
    child: Row(children: [
      Container(width: 42, height: 42, decoration: BoxDecoration(color: _statusColor.withOpacity(.12), borderRadius: BorderRadius.circular(14)), child: Icon(_icon, color: _statusColor, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(project.name, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: C.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text('৳${project.budgetLakh.toStringAsFixed(0)} লাখ  •  ${project.progressPercent}%', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.textSecondary)),
      ])),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: _statusColor.withOpacity(.1), borderRadius: R.full, border: Border.all(color: _statusColor.withOpacity(.3))),
        child: Text(_statusLabel, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor)),
      ),
    ]),
  );
}

// ── Issue card ───────────────────────────────────────────────────────────────
class _IssueCard extends StatelessWidget {
  final IssueModel issue;

  const _IssueCard({required this.issue});

  Color get _pc {
    switch (issue.status) {
      case IssueStatus.inProgress:
        return C.warning;
      case IssueStatus.resolved:
        return C.accentDark;
      case IssueStatus.submitted:
        return C.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: C.card, borderRadius: R.md, boxShadow: S.xs, border: Border.all(color: const Color(0x06000000))),
    child: IntrinsicHeight(child: Row(children: [
      Container(width: 4, decoration: BoxDecoration(color: _pc, borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)))),
      const SizedBox(width: 12),
      Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(issue.title, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: C.textPrimary)),
        const SizedBox(height: 3),
        Text(issue.areaName, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.textSecondary)),
        const SizedBox(height: 3),
        Text('Road ${issue.roadNumber}${issue.reportedBy != null ? ' • ${issue.reportedBy}' : ''}', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.textTertiary)),
      ]))),
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: _StatusDrop(value: issue.status, onChanged: (status) => context.read<IssueProvider>().updateStatus(issue.id, status)),
      ),
    ])),
  );
}

// ── Evidence card ────────────────────────────────────────────────────────────
class _EvidCard extends StatelessWidget {
  final EvidenceModel ev;
  final VoidCallback onVerify, onReject;

  const _EvidCard({
    required this.ev,
    required this.onVerify,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: R.md,
          boxShadow: S.xs,
          border: Border.all(color: const Color(0x06000000)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [C.primary50, C.borderLight],
                    ),
                  ),
                    child: ev.imageUrl.isNotEmpty
                      ? Image.network(
                        ev.imageUrl,
                          width: double.infinity,
                          height: 110,
                          fit: BoxFit.cover,

                          // loading indicator
                          loadingBuilder:
                              (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },

                          // error fallback
                          errorBuilder:
                              (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40,
                                color: C.textTertiary,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_rounded,
                            size: 40,
                            color: C.textTertiary,
                          ),
                        ),
                ),

                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ev.timestamp.toLocal().toString().split('.')[0],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          ev.projectName?.isNotEmpty == true ? ev.projectName! : 'Project ${ev.projectId}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: C.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'By: ${ev.uploaderName.isNotEmpty ? ev.uploaderName : ev.uploadedBy}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: C.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    label: 'Verify',
                    bg: C.accentDark,
                    onTap: onVerify,
                  ),
                  const SizedBox(width: 6),
                  _ActionBtn(
                    label: 'Reject',
                    bg: C.danger,
                    onTap: onReject,
                    outline: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── Status dropdown ──────────────────────────────────────────────────────────
class _StatusDrop extends StatelessWidget {
  final IssueStatus value;
  final ValueChanged<IssueStatus> onChanged;
  const _StatusDrop({required this.value, required this.onChanged});

  Color get _c {
    switch (value) {
      case IssueStatus.inProgress:
        return C.warning;
      case IssueStatus.resolved:
        return C.accentDark;
      case IssueStatus.submitted:
        return C.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: _c.withOpacity(.1), borderRadius: R.full, border: Border.all(color: _c.withOpacity(.3))),
    child: DropdownButton<IssueStatus>(
      value: value, isDense: true, underline: const SizedBox(),
      icon: Icon(Icons.expand_more_rounded, size: 14, color: _c),
      style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: _c),
      dropdownColor: C.card, borderRadius: R.md,
      items: const [
        DropdownMenuItem(value: IssueStatus.submitted, child: Text('Submitted')),
        DropdownMenuItem(value: IssueStatus.inProgress, child: Text('In Progress')),
        DropdownMenuItem(value: IssueStatus.resolved, child: Text('Resolved')),
      ],
      onChanged: (v) { if (v != null) onChanged(v); },
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final String label; final Color bg; final VoidCallback onTap; final bool outline;
  const _ActionBtn({required this.label, required this.bg, required this.onTap, this.outline = false});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: outline ? bg.withOpacity(.1) : null,
        gradient: outline ? null : LinearGradient(colors: [bg, bg.withOpacity(.8)]),
        borderRadius: R.sm,
        border: outline ? Border.all(color: bg.withOpacity(.4)) : null,
        boxShadow: outline ? [] : [BoxShadow(color: bg.withOpacity(.3), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: outline ? bg : Colors.white)),
    ),
  );
}

// ── Pinned header delegate ────────────────────────────────────────────────────
class _Pinned extends SliverPersistentHeaderDelegate {
  final double h; final Widget child;
  const _Pinned(this.h, {required this.child});
  @override double get minExtent => h;
  @override double get maxExtent => h;
  @override Widget build(BuildContext _, double __, bool ___) => child;
  @override bool shouldRebuild(_Pinned o) => o.child != child;
}
