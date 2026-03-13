import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../project_management/screens/project_create_screen.dart';
import 'complaint_monitor_screen.dart';
import 'evidence_review_screen.dart';

class AuthorityDashboard extends StatefulWidget {
  const AuthorityDashboard({super.key});
  @override State<AuthorityDashboard> createState() => _AuthorityDashboardState();
}

class _AuthorityDashboardState extends State<AuthorityDashboard> {
  int _tab = 0;

  // ── Mock data ─────────────────────────────────────────────────────────────
  final _projects = const [
    _Proj('Road Widening – NH 30',   '৳3.2 কোটি', 65,  'Ongoing',   Icons.construction_rounded, C.warning,      C.warning50),
    _Proj('Drainage System Ward 12', '৳85 লাখ',   10,  'Planned',   Icons.water_drop_rounded,   C.primaryLight, C.primary50),
    _Proj('LED Street Lights',       '৳42 লাখ',   100, 'Completed', Icons.lightbulb_rounded,    C.accentDark,   C.accent50),
  ];
  final _issues = const [
    _Issue('Pothole on MG Road',         'High',   '3 days ago', C.danger,       C.danger50),
    _Issue('Blocked Drain – Sector 4',   'Medium', '1 day ago',  C.warning,      C.warning50),
    _Issue('Street Light Out – Lane 7',  'Low',    '5 days ago', C.primaryLight, C.primary50),
    _Issue('Garbage Overflow – Market',  'Medium', '12 hrs ago', C.warning,      C.warning50),
  ];
  final _evidence = const [
    _Evid('Road work progress',    'Blaster',  'Oct 30, 2:15 PM', "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRRnKoydG-DPtKSNAUYNVphNQTn7phdovY12g&s"),
    _Evid('Pothole evidence',      'Ashik',  'Oct 28, 9:30 AM', "https://media.istockphoto.com/id/1366054009/photo/pothole-on-the-road.webp?a=1&b=1&s=612x612&w=0&k=20&c=pxxaAfahYVAKJdOahBTzQO2MD4pZXnqTv3Tz8xdeO2M="),
    _Evid('Drain blockage photo',  'Shafia',   'Oct 27, 11:00 AM', "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT58d4I-RhlAWA-7XI0FLXaQf9ykSHQUnU3jA&s"),
  ];

  late final _projStatus  = ['Ongoing', 'Planned', 'Completed'];
  late final _issueStatus = ['In Progress', 'Submitted', 'Resolved', 'Submitted'];

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
          _hBtn(Icons.logout_rounded, () {}),
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
    child: Row(children: [
      Expanded(child: StatCard(icon: Icons.folder_rounded,        iconColor: C.primary,  iconBg: C.primary50, value: '${_projects.length}', label: 'Projects')),
      const SizedBox(width: 10),
      Expanded(child: StatCard(icon: Icons.warning_amber_rounded, iconColor: C.danger,   iconBg: C.danger50,  value: '${_issues.length}',   label: 'Issues')),
      const SizedBox(width: 10),
      Expanded(child: StatCard(icon: Icons.image_rounded,         iconColor: C.warning,  iconBg: C.warning50, value: '${_evidence.length}', label: 'Evidence')),
    ]),
  );

  // ── Tab bar ───────────────────────────────────────────────────────────────
  Widget _tabBar() => Container(
    color: C.bg,
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: C.borderLight, borderRadius: R.md, border: Border.all(color: C.border)),
      child: Row(children: [
        _tabBtn(0, 'Projects'),
        _tabBtn(1, 'Issues', badge: _issues.length),
        _tabBtn(2, 'Evidence', badge: _evidence.length),
      ]),
    ),
  );

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

  Widget _projectsTab() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const SizedBox(height: 16),

    GestureDetector(
      // TODO: Enable after ProjectCreateScreen is implemented
      // onTap: () => Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => const ProjectCreateScreen(),
      //   ),
      // ),

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

    ..._projects.asMap().entries.map(
      (e) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ProjectCard(
          proj: e.value,
          status: _projStatus[e.key],
          onStatus: (s) => setState(() => _projStatus[e.key] = s),
        ),
      ),
    ),
  ],
);    
  Widget _issuesTab() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 16),
    SectionHeader(title: 'Pending Complaints', actionLabel: 'View All',
      onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintMonitorScreen()))),
    const SizedBox(height: 12),
    ..._issues.asMap().entries.map((e) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _IssueCard(issue: e.value, status: _issueStatus[e.key], onStatus: (s) => setState(() => _issueStatus[e.key] = s)),
    )),
  ]);

  Widget _evidenceTab() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 16),
    SectionHeader(title: 'Citizen Evidence', actionLabel: 'View All',
      onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EvidenceReviewScreen()))),
    const SizedBox(height: 12),
    ..._evidence.map((ev) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _EvidCard(ev: ev, onVerify: () => _toast('✅ Verified'), onReject: () => _toast('❌ Rejected')),
    )),
  ]);

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500)),
    backgroundColor: C.textPrimary, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: R.md), margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 2),
  ));
}

// ── Project card ─────────────────────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  final _Proj proj; final String status; final ValueChanged<String> onStatus;
  const _ProjectCard({required this.proj, required this.status, required this.onStatus});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: C.card, borderRadius: R.md, boxShadow: S.xs, border: Border.all(color: const Color(0x06000000))),
    child: Row(children: [
      Container(width: 42, height: 42, decoration: BoxDecoration(color: proj.iconBg, borderRadius: BorderRadius.circular(14)), child: Icon(proj.icon, color: proj.iconColor, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(proj.name, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: C.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text('${proj.budget}  •  ${proj.pct}%', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.textSecondary)),
      ])),
      const SizedBox(width: 8),
      _StatusDrop(value: status, options: const ['Planned','Ongoing','Completed','Delayed'], onChanged: onStatus),
    ]),
  );
}

// ── Issue card ───────────────────────────────────────────────────────────────
class _IssueCard extends StatelessWidget {
  final _Issue issue; final String status; final ValueChanged<String> onStatus;
  const _IssueCard({required this.issue, required this.status, required this.onStatus});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: C.card, borderRadius: R.md, boxShadow: S.xs, border: Border.all(color: const Color(0x06000000))),
    child: IntrinsicHeight(child: Row(children: [
      Container(width: 4, decoration: BoxDecoration(color: issue.pColor, borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)))),
      const SizedBox(width: 12),
      Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(issue.title, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: C.textPrimary)),
        const SizedBox(height: 3),
        Text('${issue.priority}  •  ${issue.timeAgo}', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.textSecondary)),
      ]))),
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: _StatusDrop(value: status, options: const ['Submitted','In Progress','Resolved'], onChanged: onStatus),
      ),
    ])),
  );
}

// ── Evidence card ────────────────────────────────────────────────────────────
class _EvidCard extends StatelessWidget {
  final _Evid ev;
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
                  child: ev.image != null
                      ? Image.network(
                          ev.image!,
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
                      ev.time,
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
                          ev.title,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: C.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'By: ${ev.by}',
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
  final String value; final List<String> options; final ValueChanged<String> onChanged;
  const _StatusDrop({required this.value, required this.options, required this.onChanged});

  Color get _c {
    switch (value) {
      case 'Ongoing': case 'In Progress': return C.warning;
      case 'Completed': case 'Resolved':  return C.accentDark;
      case 'Delayed':                     return C.danger;
      default:                            return C.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: _c.withOpacity(.1), borderRadius: R.full, border: Border.all(color: _c.withOpacity(.3))),
    child: DropdownButton<String>(
      value: value, isDense: true, underline: const SizedBox(),
      icon: Icon(Icons.expand_more_rounded, size: 14, color: _c),
      style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: _c),
      dropdownColor: C.card, borderRadius: R.md,
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: _c)))).toList(),
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

// ── Data models ───────────────────────────────────────────────────────────────
class _Proj {
  final String name, budget, status; final int pct; final IconData icon; final Color iconColor, iconBg;
  const _Proj(this.name, this.budget, this.pct, this.status, this.icon, this.iconColor, this.iconBg);
}
class _Issue {
  final String title, priority, timeAgo; final Color pColor, pBg;
  const _Issue(this.title, this.priority, this.timeAgo, this.pColor, this.pBg);
}
class _Evid {
  final String title, by, time;
  final String? image; 

  const _Evid(this.title, this.by, this.time, [this.image]);
}