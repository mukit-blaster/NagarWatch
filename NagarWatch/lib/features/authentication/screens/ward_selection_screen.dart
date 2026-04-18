import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/models/ward_model.dart';
import '../providers/auth_provider.dart';

class WardSelectionScreen extends StatefulWidget {
  const WardSelectionScreen({super.key});

  @override
  State<WardSelectionScreen> createState() => _WardSelectionScreenState();
}

class _WardSelectionScreenState extends State<WardSelectionScreen> {
  String _search = '';
  WardModel? _selected;
  final _searchCtrl = TextEditingController();

  List<WardModel> get _filtered {
    if (_search.isEmpty) return WardModel.sampleWards;
    final q = _search.toLowerCase();
    return WardModel.sampleWards.where((w) =>
      w.name.toLowerCase().contains(q) ||
      w.district.toLowerCase().contains(q) ||
      w.upazila.toLowerCase().contains(q)
    ).toList();
  }

  Future<void> _confirm() async {
    if (_selected == null) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.selectWard(_selected!.id, _selected!.name);
    if (!mounted) return;
    if (ok) Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        _header(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _searchBar(),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            itemCount: _filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final ward = _filtered[i];
              final isSelected = _selected?.id == ward.id;
              return GestureDetector(
                onTap: () => setState(() => _selected = ward),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary50 : AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(.1), blurRadius: 8)] : [],
                  ),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.location_on_rounded, color: isSelected ? Colors.white : AppColors.textTertiary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(ward.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                      Text('${ward.upazila}, ${ward.district}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ])),
                    if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                  ]),
                ),
              );
            },
          ),
        ),
        _bottomBar(auth),
      ]),
    );
  }

  Widget _header() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [AppColors.welcomeStart, AppColors.welcomeMid1, AppColors.welcomeMid2]),
    ),
    child: SafeArea(bottom: false, child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withOpacity(.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18)),
          ),
        ]),
        const SizedBox(height: 16),
        const Text('Select Your Ward', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -.5)),
        const SizedBox(height: 6),
        Text('Choose your area to see nearby projects & report issues', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(.7))),
      ]),
    )),
  );

  Widget _searchBar() => Container(
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border, width: 1.5)),
    child: Row(children: [
      const Padding(padding: EdgeInsets.only(left: 14), child: Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20)),
      const SizedBox(width: 10),
      Expanded(child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _search = v),
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'Search ward, area, district…',
          border: InputBorder.none, fillColor: Colors.transparent, filled: false,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
        ),
      )),
      if (_search.isNotEmpty) GestureDetector(
        onTap: () { _searchCtrl.clear(); setState(() => _search = ''); },
        child: const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 18)),
      ),
    ]),
  );

  Widget _bottomBar(AuthProvider auth) => Container(
    padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
    decoration: const BoxDecoration(color: AppColors.card, boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -4))]),
    child: Column(children: [
      if (_selected != null) Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text('Selected: ${_selected!.name}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
        ]),
      ),
      SizedBox(
        width: double.infinity, height: 52,
        child: ElevatedButton(
          onPressed: _selected == null || auth.isLoading ? null : _confirm,
          child: auth.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Confirm Selection'),
        ),
      ),
    ]),
  );
}
