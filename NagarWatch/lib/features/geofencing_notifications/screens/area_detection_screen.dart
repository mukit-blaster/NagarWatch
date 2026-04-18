import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../authentication/providers/auth_provider.dart';
import '../providers/geofence_provider.dart';

class AreaDetectionScreen extends StatefulWidget {
  final bool onboardingFlow;

  const AreaDetectionScreen({
    super.key,
    this.onboardingFlow = false,
  });

  @override
  State<AreaDetectionScreen> createState() => _AreaDetectionScreenState();
}

class _AreaDetectionScreenState extends State<AreaDetectionScreen> {
  bool _autoDetectTriggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.onboardingFlow && !_autoDetectTriggered) {
      _autoDetectTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<GeofenceProvider>().detectCurrentArea();
      });
    }
  }

  Future<void> _continueToDashboard() async {
    final prov = context.read<GeofenceProvider>();
    final selected = prov.selectedArea;
    if (selected == null) return;

    final auth = context.read<AuthProvider>();
    await auth.selectWard(selected.id, selected.name);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<GeofenceProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Area Detection', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white, foregroundColor: AppColors.textPrimary, elevation: 0,
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        // Status card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppColors.welcomeStart, AppColors.welcomeMid1]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('GPS Area Detection', style: TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 4),
            Text(
              prov.hasResult ? (prov.selectedArea?.name ?? 'Detected') : 'Not yet detected',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            if (prov.hasResult) ...[
              const SizedBox(height: 8),
              Text(prov.selectedArea?.fullDisplayName ?? '', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(.7))),
              const SizedBox(height: 4),
              Text('Distance: ${prov.distanceKm?.toStringAsFixed(2) ?? '?'} km', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.6))),
            ],
            if (prov.detectedAddress.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('📍 ${prov.detectedAddress}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.6))),
            ],
          ]),
        ),
        const SizedBox(height: 16),

        // Detect button
        ElevatedButton.icon(
          onPressed: prov.isLoading ? null : () => prov.detectCurrentArea(),
          icon: prov.isLoading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
          label: Text(prov.isLoading ? 'Detecting…' : 'Detect My Location', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        ),

        if (widget.onboardingFlow) ...[
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: prov.selectedArea == null || prov.isLoading
                ? null
                : _continueToDashboard,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Continue to Dashboard',
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],

        if (prov.errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.danger50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.dangerLight)),
            child: Text(prov.errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 13))),
        ],

        const SizedBox(height: 24),
        const Text('Select Area Manually', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...prov.availableAreas.take(8).map((area) {
          final isSelected = prov.selectedArea?.id == area.id;
          return Padding(padding: const EdgeInsets.only(bottom: 8), child: GestureDetector(
            onTap: () => prov.selectAreaManually(area),
            child: AnimatedContainer(duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary50 : AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1.5),
              ),
              child: Row(children: [
                Icon(Icons.location_on_rounded, color: isSelected ? AppColors.primary : AppColors.textTertiary, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(area.fullDisplayName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? AppColors.primary : AppColors.textPrimary))),
                if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
              ]),
            ),
          ));
        }),
      ]),
    );
  }
}
