import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';

class EvidenceReviewScreen extends StatefulWidget {
  const EvidenceReviewScreen({super.key});
  @override State<EvidenceReviewScreen> createState() => _State();
}

class _State extends State<EvidenceReviewScreen> {
  String? _filter;

  final _items = <_Ev>[
    _Ev('ev-1', 'Road work progress',    'Blaster',  'Oct 30, 2:15 PM',  'ISS-0847', 'pending', "https://images.unsplash.com/photo-1762247019055-f0170f1c7245?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fFJvYWQlMjB3b3JrJTIwcHJvZ3Jlc3N8ZW58MHx8MHx8fDA%3D"),
    _Ev('ev-2', 'Pothole evidence',       'Ashik',  'Oct 28, 9:30 AM',  null,       'pending', "https://media.istockphoto.com/id/1366054009/photo/pothole-on-the-road.webp?a=1&b=1&s=612x612&w=0&k=20&c=pxxaAfahYVAKJdOahBTzQO2MD4pZXnqTv3Tz8xdeO2M="),
    _Ev('ev-3', 'Drain blockage photo',   'Shafia',   'Oct 27, 11:00 AM', 'ISS-0848', 'verified', "https://images.unsplash.com/photo-1702018750845-32aad516678f?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fERyYWluJTIwYmxvY2thZ2UlMjBwaG90b3xlbnwwfHwwfHx8MA%3D%3D"),
    _Ev('ev-4', 'Garbage overflow photo', 'Dipta', 'Today, 10:15 AM',  'ISS-0850', 'pending', "https://images.unsplash.com/photo-1772461288079-5fc92ac66035?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8R2FyYmFnZSUyMG92ZXJmbG93JTIwcGhvdG98ZW58MHx8MHx8fDA%3D"),
    _Ev('ev-5', 'Street light damage',    'Nobel',  'Oct 25, 7:00 PM',  'ISS-0849', 'rejected', "https://media.istockphoto.com/id/2163757100/photo/low-angle-view-of-broken-lamppost.webp?a=1&b=1&s=612x612&w=0&k=20&c=PFGEEq2VMWu-aqqinsoaA5GHNsHKJKfRmK10fFAOmEM="),
  ];

  List<_Ev> get _shown => _filter == null ? _items : _items.where((e) => e.status == _filter).toList();
  int _cnt(String s) => _items.where((e) => e.status == s).length;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(backgroundColor: C.bg, body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: ScreenHeader(
          title: 'Evidence Review',
          actions: [Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: C.accent50, borderRadius: R.full),
            child: Text('${_cnt('pending')} pending', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: C.accentDark)),
          )],
        )),
        SliverToBoxAdapter(child: _statsStrip()),
        SliverPersistentHeader(pinned: true, delegate: _PH(46, child: _filterChips())),
        _shown.isEmpty
          ? SliverFillRemaining(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 72, height: 72, decoration: BoxDecoration(color: C.primary50, borderRadius: R.lg), child: const Icon(Icons.image_search_rounded, size: 36, color: C.primaryLight)),
              const SizedBox(height: 14),
              const Text('No evidence found', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: C.textPrimary)),
            ])))
          : SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList(delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(padding: const EdgeInsets.only(bottom: 12),
                  child: _EvCard(ev: _shown[i], onVerify: () => _act(_shown[i], 'verified'), onReject: () => _rejectSheet(_shown[i]))),
                childCount: _shown.length,
              )),
            ),
      ])),
    );
  }

  Widget _statsStrip() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
    child: Row(children: [
      _St(Icons.hourglass_bottom_rounded, '${_cnt('pending')}',  'Pending',  C.warning,    C.warning50),  const SizedBox(width: 8),
      _St(Icons.verified_rounded,         '${_cnt('verified')}', 'Verified', C.accentDark, C.accent50),   const SizedBox(width: 8),
      _St(Icons.cancel_rounded,           '${_cnt('rejected')}', 'Rejected', C.danger,     C.danger50),
    ]),
  );

  Widget _filterChips() => Container(
    color: C.bg, padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
    child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
      _chip('All',         null,       _filter == null),       const SizedBox(width: 8),
      _chip('⏳ Pending',  'pending',  _filter == 'pending'),  const SizedBox(width: 8),
      _chip('✅ Verified', 'verified', _filter == 'verified'), const SizedBox(width: 8),
      _chip('❌ Rejected', 'rejected', _filter == 'rejected'),
    ])),
  );

  Widget _chip(String label, String? val, bool on) {
    final c = val == 'pending' ? C.warning : val == 'verified' ? C.accentDark : val == 'rejected' ? C.danger : C.textPrimary;
    return GestureDetector(
      onTap: () => setState(() => _filter = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: on ? (val == null ? C.textPrimary : c.withOpacity(.12)) : C.card,
          borderRadius: R.full,
          border: Border.all(color: on ? (val == null ? C.textPrimary : c) : C.border, width: on ? 1.5 : 1),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: on ? (val == null ? Colors.white : c) : C.textSecondary)),
      ),
    );
  }

  void _act(_Ev ev, String s) {
    setState(() { final i = _items.indexWhere((e) => e.id == ev.id); if (i >= 0) _items[i] = ev.copy(s); });
    _toast(s == 'verified' ? '✅ Evidence verified!' : '❌ Evidence rejected');
  }

  void _rejectSheet(_Ev ev) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(color: C.card, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: C.border, borderRadius: R.full))),
            const SizedBox(height: 20),
            const Text('Reject Evidence', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: C.textPrimary)),
            const SizedBox(height: 4),
            Text('"${ev.title}"', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: C.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: C.textPrimary),
              decoration: InputDecoration(
                hintText: 'Reason (optional)…', hintStyle: const TextStyle(color: C.textTertiary, fontFamily: 'Inter', fontSize: 14),
                filled: true, fillColor: C.bg,
                border: OutlineInputBorder(borderRadius: R.sm, borderSide: const BorderSide(color: C.border)),
                enabledBorder: OutlineInputBorder(borderRadius: R.sm, borderSide: const BorderSide(color: C.border)),
                focusedBorder: OutlineInputBorder(borderRadius: R.sm, borderSide: const BorderSide(color: C.danger, width: 1.5)),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: C.bg, borderRadius: R.md, border: Border.all(color: C.border, width: 1.5)),
                  child: const Center(child: Text('Cancel', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: C.textSecondary)))),
              )),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(
                onTap: () { Navigator.pop(context); _act(ev, 'rejected'); },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: C.danger, borderRadius: R.md),
                  child: const Center(child: Text('Reject', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white))),
                ),
              )),
            ]),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500)),
    backgroundColor: C.textPrimary, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: R.md), margin: const EdgeInsets.all(16), duration: const Duration(seconds: 2),
  ));
}

// ── Evidence card ─────────────────────────────────────────────────────────────
class _EvCard extends StatelessWidget {
  final _Ev ev; final VoidCallback onVerify, onReject;
  const _EvCard({required this.ev, required this.onVerify, required this.onReject});

  Color get _sc => ev.status == 'verified' ? C.accentDark : ev.status == 'rejected' ? C.danger : C.warning;
  Color get _sb => ev.status == 'verified' ? C.accent50  : ev.status == 'rejected' ? C.danger50  : C.warning50;
  String get _sl => ev.status == 'verified' ? '✅ Verified' : ev.status == 'rejected' ? '❌ Rejected' : '⏳ Pending';

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: C.card, borderRadius: R.md, boxShadow: S.sm,
      border: Border.all(color: ev.status == 'verified' ? C.accent.withOpacity(.25) : ev.status == 'rejected' ? C.danger.withOpacity(.2) : const Color(0x06000000))),
    clipBehavior: Clip.antiAlias,
    child: Column(children: [
      Stack(children: [
        Container(height: 140, width: double.infinity,
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [C.primary50, C.borderLight])),
          child: ev.image != null
    ? Image.network(
        ev.image!,
        width: double.infinity,
        height: 140,
        fit: BoxFit.cover,
      )
    : const Center(
        child: Icon(Icons.image_rounded, size: 48, color: C.textTertiary),
      ),),
        Positioned(top: 10, left: 10, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: _sb, borderRadius: R.full, border: Border.all(color: _sc.withOpacity(.3))),
          child: Text(_sl, style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, color: _sc)),
        )),
        Positioned(bottom: 10, right: 10, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
          child: Text(ev.time, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
        )),
      ]),
      Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(ev.title, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: C.textPrimary)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 6, children: [
          _chip(Icons.person_rounded, ev.by),
          if (ev.issueId != null) _chip(Icons.warning_amber_rounded, 'Issue: ${ev.issueId}', C.warning),
        ]),
        if (ev.status == 'pending') ...[
          const SizedBox(height: 12),
          const Divider(height: 1, color: C.borderLight),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: GestureDetector(onTap: onReject, child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: C.danger50, borderRadius: R.sm, border: Border.all(color: C.dangerLight.withOpacity(.5))),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.close_rounded, size: 16, color: C.danger), SizedBox(width: 6), Text('Reject', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: C.danger))]),
            ))),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(onTap: onVerify, child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [C.accentDark, C.accent]), borderRadius: R.sm, boxShadow: S.accent),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_rounded, size: 16, color: Colors.white), SizedBox(width: 6), Text('Verify', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))]),
            ))),
          ]),
        ],
      ])),
    ]),
  );

  Widget _chip(IconData icon, String text, [Color? c]) {
    final col = c ?? C.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: col.withOpacity(.08), borderRadius: R.full),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 11, color: col), const SizedBox(width: 4), Text(text, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: col))]),
    );
  }
}

class _St extends StatelessWidget {
  final IconData icon; final String val, label; final Color color, bg;
  const _St(this.icon, this.val, this.label, this.color, this.bg);
  @override Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(color: bg, borderRadius: R.md),
    child: Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(val, style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w500, color: C.textSecondary)),
    ])]),
  ));
}

class _PH extends SliverPersistentHeaderDelegate {
  final double h; final Widget child;
  const _PH(this.h, {required this.child});
  @override double get minExtent => h;
  @override double get maxExtent => h;
  @override Widget build(_, __, ___) => child;
  @override bool shouldRebuild(_PH o) => o.child != child;
}


class _Ev {
  final String id, title, by, time, status;
  final String? issueId;
  final String? image; 

  const _Ev(this.id, this.title, this.by, this.time, this.issueId, this.status, this.image);

  _Ev copy(String s) => _Ev(id, title, by, time, issueId, s, image);
}
