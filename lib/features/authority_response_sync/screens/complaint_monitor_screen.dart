import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';

class ComplaintMonitorScreen extends StatefulWidget {
  const ComplaintMonitorScreen({super.key});
  @override State<ComplaintMonitorScreen> createState() => _State();
}

class _State extends State<ComplaintMonitorScreen> {
  String _filter = 'All';
  String _search = '';
  final _ctrl = TextEditingController();

  final _issues = const [
    _Issue('ISS-0847', 'Pothole on MG Road',          'MG Road, Near Junction',    'High',   'In Progress', Icons.construction_rounded,  3),
    _Issue('ISS-0848', 'Blocked Drain – Sector 4',    'Sector 4, Sadar Bazaar',    'Medium', 'Submitted',   Icons.water_drop_rounded,    1),
    _Issue('ISS-0849', 'Street Light Out – Lane 7',   'Lane 7, Civil Lines',       'Low',    'Resolved',    Icons.lightbulb_rounded,     5),
    _Issue('ISS-0850', 'Garbage Overflow – Market',   'Vegetable Market',          'Medium', 'Submitted',   Icons.delete_rounded,        0),
    _Issue('ISS-0851', 'Broken Footpath – Zone 2',    'Zone 2, NH-30',             'High',   'In Progress', Icons.construction_rounded,  2),
    _Issue('ISS-0852', 'Water Leakage – Block A',     'Block A, Rajendra Nagar',   'High',   'Submitted',   Icons.water_rounded,         0),
  ];
  late final _status = List<String>.from(_issues.map((i) => i.defaultStatus));

  List<_Issue> get _filtered {
    var list = _issues.toList();
    if (_filter != 'All') list = list.where((i) => i.priority == _filter).toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((i) => i.title.toLowerCase().contains(q) || i.id.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(backgroundColor: C.bg, body: Column(children: [
        ScreenHeader(title: 'Complaint Monitor'),
        _searchBar(),
        _filterRow(),
        _summaryStrip(),
        Expanded(child: _list()),
      ])),
    );
  }

  Widget _searchBar() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
    child: Container(
      decoration: BoxDecoration(color: C.card, borderRadius: R.md, border: Border.all(color: C.border, width: 1.5), boxShadow: S.xs),
      child: Row(children: [
        const Padding(padding: EdgeInsets.only(left: 14), child: Icon(Icons.search_rounded, color: C.textTertiary, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: TextField(
          controller: _ctrl,
          onChanged: (v) => setState(() => _search = v),
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: C.textPrimary),
          decoration: const InputDecoration(hintText: 'Search by title, ID…', hintStyle: TextStyle(color: C.textTertiary, fontSize: 14, fontFamily: 'Inter'), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 14)),
        )),
        if (_search.isNotEmpty) GestureDetector(
          onTap: () { _ctrl.clear(); setState(() => _search = ''); },
          child: const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.close_rounded, color: C.textTertiary, size: 18)),
        ),
      ]),
    ),
  );

  Widget _filterRow() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 0, 0),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(right: 20),
      child: Row(children: ['All','High','Medium','Low'].map((f) {
        final on = _filter == f;
        final c = f == 'High' ? C.danger : f == 'Medium' ? C.warning : f == 'Low' ? C.primaryLight : C.textPrimary;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: on ? (f == 'All' ? C.textPrimary : c.withOpacity(.12)) : C.card,
                borderRadius: R.full,
                border: Border.all(color: on ? (f == 'All' ? C.textPrimary : c) : C.border, width: 1.5),
              ),
              child: Text(f, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: on ? (f == 'All' ? Colors.white : c) : C.textSecondary)),
            ),
          ),
        );
      }).toList()),
    ),
  );

  Widget _summaryStrip() {
    final pending    = _issues.where((i) => _status[_issues.indexOf(i)] == 'Submitted').length;
    final inProgress = _issues.where((i) => _status[_issues.indexOf(i)] == 'In Progress').length;
    final resolved   = _issues.where((i) => _status[_issues.indexOf(i)] == 'Resolved').length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(children: [
        _Strip('$pending',    'Pending',     C.warning,      C.warning50),   const SizedBox(width: 8),
        _Strip('$inProgress', 'In Progress', C.primaryLight, C.primary50),   const SizedBox(width: 8),
        _Strip('$resolved',   'Resolved',    C.accentDark,   C.accent50),    const SizedBox(width: 8),
        _Strip('${_issues.length}', 'Total', C.textSecondary, C.borderLight),
      ]),
    );
  }

  Widget _list() {
    final list = _filtered;
    if (list.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 72, height: 72, decoration: BoxDecoration(color: C.accent50, borderRadius: R.lg), child: const Icon(Icons.check_circle_outline_rounded, size: 36, color: C.accentDark)),
      const SizedBox(height: 14),
      const Text('All clear!', style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800, color: C.textPrimary)),
      const SizedBox(height: 6),
      const Text('No complaints match.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: C.textSecondary)),
    ]));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final issue = list[i];
        final gi = _issues.indexOf(issue);
        return _IssueCard(issue: issue, status: _status[gi], onStatus: (s) => setState(() => _status[gi] = s));
      },
    );
  }
}

// ── Expandable issue card ─────────────────────────────────────────────────────
class _IssueCard extends StatefulWidget {
  final _Issue issue; final String status; final ValueChanged<String> onStatus;
  const _IssueCard({required this.issue, required this.status, required this.onStatus});
  @override State<_IssueCard> createState() => _IssueCardState();
}
class _IssueCardState extends State<_IssueCard> {
  bool _open = false;
  Color get _pc => widget.issue.priority == 'High' ? C.danger : widget.issue.priority == 'Medium' ? C.warning : C.primaryLight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(color: C.card, borderRadius: R.md, boxShadow: S.sm,
          border: Border.all(color: _open ? _pc.withOpacity(.3) : const Color(0x06000000), width: _open ? 1.5 : 1)),
        child: Column(children: [
          IntrinsicHeight(child: Row(children: [
            Container(width: 4, decoration: BoxDecoration(color: _pc, borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)))),
            const SizedBox(width: 12),
            Padding(padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(width: 38, height: 38, decoration: BoxDecoration(color: _pc.withOpacity(.1), borderRadius: BorderRadius.circular(12)), child: Icon(widget.issue.icon, size: 17, color: _pc))),
            const SizedBox(width: 10),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.issue.title, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: C.textPrimary)),
              const SizedBox(height: 4),
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: _pc.withOpacity(.1), borderRadius: R.full), child: Text(widget.issue.priority, style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, color: _pc))),
                const SizedBox(width: 6),
                Text('• ${widget.issue.daysAgo == 0 ? 'Today' : '${widget.issue.daysAgo}d ago'}', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.textTertiary)),
              ]),
            ]))),
            Padding(padding: const EdgeInsets.only(right: 12), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              _Pill(widget.status),
              const SizedBox(height: 4),
              Icon(_open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 16, color: C.textTertiary),
            ])),
          ])),
          if (_open) Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.borderLight))),
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const Icon(Icons.location_on_rounded, size: 13, color: C.textTertiary), const SizedBox(width: 8), Text(widget.issue.address, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: C.textSecondary))]),
              const SizedBox(height: 14),
              const Text('Update Status', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: C.textSecondary)),
              const SizedBox(height: 8),
              Row(children: ['Submitted','In Progress','Resolved'].map((s) {
                final on = widget.status == s;
                final c = s == 'Submitted' ? C.primaryLight : s == 'In Progress' ? C.warning : C.accentDark;
                return Expanded(child: Padding(padding: const EdgeInsets.only(right: 6), child: GestureDetector(
                  onTap: () => widget.onStatus(s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: on ? c.withOpacity(.1) : C.bg, borderRadius: R.sm,
                      border: Border.all(color: on ? c.withOpacity(.4) : C.border, width: on ? 1.5 : 1),
                    ),
                    child: Text(s, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: on ? c : C.textSecondary)),
                  ),
                )));
              }).toList()),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String status;
  const _Pill(this.status);
  Color get _c => status == 'In Progress' ? C.warning : status == 'Resolved' ? C.accentDark : C.primaryLight;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: _c.withOpacity(.1), borderRadius: R.full),
    child: Text(status, style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, color: _c)),
  );
}

class _Strip extends StatelessWidget {
  final String val, label; final Color color, bg;
  const _Strip(this.val, this.label, this.color, this.bg);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(color: bg, borderRadius: R.sm),
    child: Column(children: [
      Text(val, style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w500, color: C.textSecondary)),
    ]),
  ));
}

class _Issue {
  final String id, title, address, priority, defaultStatus; final IconData icon; final int daysAgo;
  const _Issue(this.id, this.title, this.address, this.priority, this.defaultStatus, this.icon, this.daysAgo);
}
