import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/evidence_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../evidence_issue_reporting/providers/evidence_provider.dart';

class EvidenceReviewScreen extends StatefulWidget {
  const EvidenceReviewScreen({super.key});

  @override
  State<EvidenceReviewScreen> createState() => _EvidenceReviewScreenState();
}

class _EvidenceReviewScreenState extends State<EvidenceReviewScreen> {
  String? _filter;
  String? _lastWardId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wardId = context.read<AuthProvider>().user?.wardId;
    if (_lastWardId != wardId) {
      _lastWardId = wardId;
      context.read<EvidenceProvider>().streamEvidence(wardId: wardId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<EvidenceProvider>();
    final items = prov.items;
    final shown = _filter == null ? items : items.where((e) => e.status == _filter).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: C.bg,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ScreenHeader(
                title: 'Evidence Review',
                actions: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: C.accent50, borderRadius: R.full),
                    child: Text(
                      '${_cnt(items, 'pending')} pending',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: C.accentDark),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(child: _statsStrip(items)),
            SliverPersistentHeader(pinned: true, delegate: _PH(46, child: _filterChips())),
            if (prov.isLoading && items.isEmpty)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (shown.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(color: C.primary50, borderRadius: R.lg),
                        child: const Icon(Icons.image_search_rounded, size: 36, color: C.primaryLight),
                      ),
                      const SizedBox(height: 14),
                      const Text('No evidence found', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: C.textPrimary)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final ev = shown[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EvCard(
                          ev: ev,
                          onVerify: () => _updateStatus(ev, 'verified'),
                          onReject: () => _rejectSheet(ev),
                        ),
                      );
                    },
                    childCount: shown.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _cnt(List<EvidenceModel> list, String status) => list.where((e) => e.status == status).length;

  Widget _statsStrip(List<EvidenceModel> items) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
    child: Row(children: [
      _St(Icons.hourglass_bottom_rounded, '${_cnt(items, 'pending')}', 'Pending', C.warning, C.warning50),
      const SizedBox(width: 8),
      _St(Icons.verified_rounded, '${_cnt(items, 'verified')}', 'Verified', C.accentDark, C.accent50),
      const SizedBox(width: 8),
      _St(Icons.cancel_rounded, '${_cnt(items, 'rejected')}', 'Rejected', C.danger, C.danger50),
    ]),
  );

  Widget _filterChips() => Container(
    color: C.bg,
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _chip('All', null, _filter == null),
        const SizedBox(width: 8),
        _chip('Pending', 'pending', _filter == 'pending'),
        const SizedBox(width: 8),
        _chip('Verified', 'verified', _filter == 'verified'),
        const SizedBox(width: 8),
        _chip('Rejected', 'rejected', _filter == 'rejected'),
      ]),
    ),
  );

  Widget _chip(String label, String? val, bool on) {
    final c = val == 'pending'
        ? C.warning
        : val == 'verified'
            ? C.accentDark
            : val == 'rejected'
                ? C.danger
                : C.textPrimary;

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
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: on ? (val == null ? Colors.white : c) : C.textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(EvidenceModel ev, String status, {String? reason}) async {
    await context.read<EvidenceProvider>().updateStatus(ev.id, status, reason: reason);
    if (!mounted) return;
    _toast(status == 'verified' ? 'Evidence verified!' : 'Evidence rejected');
  }

  void _rejectSheet(EvidenceModel ev) {
    final reasonCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(color: C.card, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: C.border, borderRadius: R.full))),
            const SizedBox(height: 20),
            const Text('Reject Evidence', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: C.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: C.textPrimary),
              decoration: InputDecoration(
                hintText: 'Reason (optional)…',
                hintStyle: const TextStyle(color: C.textTertiary, fontFamily: 'Inter', fontSize: 14),
                filled: true,
                fillColor: C.bg,
                border: OutlineInputBorder(borderRadius: R.sm, borderSide: const BorderSide(color: C.border)),
                enabledBorder: OutlineInputBorder(borderRadius: R.sm, borderSide: const BorderSide(color: C.border)),
                focusedBorder: OutlineInputBorder(borderRadius: R.sm, borderSide: const BorderSide(color: C.danger, width: 1.5)),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: C.bg, borderRadius: R.md, border: Border.all(color: C.border, width: 1.5)),
                    child: const Center(child: Text('Cancel', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: C.textSecondary))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(ev, 'rejected', reason: reasonCtrl.text);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: C.danger, borderRadius: R.md),
                    child: const Center(child: Text('Reject', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white))),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500)),
      backgroundColor: C.textPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: R.md),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ),
  );
}

class _EvCard extends StatelessWidget {
  final EvidenceModel ev;
  final VoidCallback onVerify;
  final VoidCallback onReject;

  const _EvCard({required this.ev, required this.onVerify, required this.onReject});

  Color get _sc => ev.status == 'verified' ? C.accentDark : ev.status == 'rejected' ? C.danger : C.warning;
  Color get _sb => ev.status == 'verified' ? C.accent50 : ev.status == 'rejected' ? C.danger50 : C.warning50;
  String get _sl => ev.status == 'verified' ? 'Verified' : ev.status == 'rejected' ? 'Rejected' : 'Pending';

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: R.md,
      boxShadow: S.sm,
      border: Border.all(
        color: ev.status == 'verified'
            ? C.accent.withOpacity(.25)
            : ev.status == 'rejected'
                ? C.danger.withOpacity(.2)
                : const Color(0x06000000),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(children: [
      Stack(children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [C.primary50, C.borderLight],
            ),
          ),
          child: ev.imageUrl.isNotEmpty
              ? Image.network(
                  ev.imageUrl,
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_rounded, size: 42, color: C.textTertiary)),
                )
              : const Center(child: Icon(Icons.image_rounded, size: 48, color: C.textTertiary)),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: _sb, borderRadius: R.full, border: Border.all(color: _sc.withOpacity(.3))),
            child: Text(_sl, style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, color: _sc)),
          ),
        ),
      ]),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ev.projectName ?? 'Project ${ev.projectId}', style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: C.textPrimary)),
          const SizedBox(height: 4),
          Text(
            ev.description?.isNotEmpty == true ? ev.description! : 'No description',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: C.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text('By ${ev.uploaderName} • ${ev.timestamp.toLocal().toString().split('.')[0]}', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.textTertiary)),
          if (ev.rejectionReason != null && ev.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Reason: ${ev.rejectionReason}', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: C.danger)),
          ],
          const SizedBox(height: 12),
          if (ev.status == 'pending')
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: onVerify,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: C.accentDark, borderRadius: R.sm),
                    child: const Center(child: Text('Verify', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: onReject,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: C.danger.withOpacity(.1), borderRadius: R.sm, border: Border.all(color: C.danger.withOpacity(.3))),
                    child: const Center(child: Text('Reject', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: C.danger))),
                  ),
                ),
              ),
            ]),
        ]),
      ),
    ]),
  );
}

class _St extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color bg;

  const _St(this.icon, this.value, this.label, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: R.sm),
      child: Column(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w500, color: C.textSecondary)),
      ]),
    ),
  );
}

class _PH extends SliverPersistentHeaderDelegate {
  final double h;
  final Widget child;

  const _PH(this.h, {required this.child});

  @override
  double get minExtent => h;

  @override
  double get maxExtent => h;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _PH oldDelegate) => oldDelegate.child != child;
}
