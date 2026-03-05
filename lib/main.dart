import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';

import 'features/geofencing_notifications/providers/geofence_provider.dart';
import 'features/geofencing_notifications/services/notification_handler.dart';
import 'features/geofencing_notifications/models/geofence_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHandler.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const primary = Color(0xFF1E3A8A);
  static const primaryLight = Color(0xFF3B82F6);
  static const bg = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: bg,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(seedColor: primary).copyWith(
        primary: primary,
        secondary: const Color(0xFF10B981),
      ),
      textTheme: GoogleFonts.interTextTheme(),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GeofenceProvider()..initialize(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: base,
        home: const WardSelectionScreen(),
      ),
    );
  }
}

class WardSelectionScreen extends StatefulWidget {
  const WardSelectionScreen({super.key});

  @override
  State<WardSelectionScreen> createState() => _WardSelectionScreenState();
}

class _WardSelectionScreenState extends State<WardSelectionScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GeofenceProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopHeader(
              title: 'Select Ward',
              onBack: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                children: [
                  const Text(
                    '📍 Choose Your Ward',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Based on your location or search manually',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _LocationCard(
                    statusText: p.locationStatusText,
                    addressText: p.addressText ?? '—',
                    coordsText: p.coordsText ?? '—',
                    isDetecting: p.isDetectingLocation,
                    onRedetect: () => p.detectLocation(force: true),
                  ),
                  _WardMapCard(
                    wards: p.visibleWards.take(12).toList(),
                    selectedWardId: p.selectedWard?.id,
                    userLat: p.userLat,
                    userLng: p.userLng,
                    onTapWard: (w) => p.selectWard(w),
                  ),
                  _SearchBar(
                    controller: _searchCtrl,
                    onChanged: (v) => p.filterWards(v),
                  ),
                  _WardList(
                    wards: p.visibleWards,
                    selectedWardId: p.selectedWard?.id,
                    getDistanceText: (w) => p.distanceTextForWard(w),
                    onTap: (w) => p.selectWard(w),
                  ),
                  const SizedBox(height: 12),
                  _InfoBanner(),
                  const SizedBox(height: 14),
                  _PrimaryCTA(
                    text: 'Continue to Dashboard',
                    onTap: p.selectedWard == null
                        ? null
                        : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DashboardStub(ward: p.selectedWard!),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardStub extends StatelessWidget {
  final WardModel ward;
  const DashboardStub({super.key, required this.ward});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Text(
          'Selected: ${ward.title}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _TopHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.86),
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.04)),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String statusText;
  final String addressText;
  final String coordsText;
  final bool isDetecting;
  final VoidCallback onRedetect;

  const _LocationCard({
    required this.statusText,
    required this.addressText,
    required this.coordsText,
    required this.isDetecting,
    required this.onRedetect,
  });

  @override
  Widget build(BuildContext context) {
    const primary50 = Color(0xFFEFF6FF);
    const primary200 = Color(0xFFBFDBFE);
    const accentDark = Color(0xFF059669);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary50, Color(0xFFEFF6FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PulseDot(isDetecting: isDetecting),
              const SizedBox(width: 10),
              Text(
                statusText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accentDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            addressText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            coordsText,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ElevatedButton.icon(
              onPressed: isDetecting ? null : onRedetect,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                disabledBackgroundColor:
                const Color(0xFF1E3A8A).withOpacity(0.65),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              icon: const Icon(Icons.navigation, size: 16, color: Colors.white),
              label: Text(
                isDetecting ? 'Detecting…' : 'Re-detect Location',
                style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PulseDot extends StatefulWidget {
  final bool isDetecting;
  const PulseDot({super.key, required this.isDetecting});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _t = CurvedAnimation(parent: _c, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isDetecting
        ? const Color(0xFFF59E0B)
        : const Color(0xFF10B981);

    return SizedBox(
      width: 14,
      height: 14,
      child: AnimatedBuilder(
        animation: _t,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - _t.value) * 0.65,
                child: Transform.scale(
                  scale: 1 + _t.value * 1.2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: baseColor, width: 2),
                    ),
                  ),
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration:
                BoxDecoration(shape: BoxShape.circle, color: baseColor),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WardMapCard extends StatelessWidget {
  final List<WardModel> wards;
  final String? selectedWardId;
  final double? userLat;
  final double? userLng;
  final ValueChanged<WardModel> onTapWard;

  const _WardMapCard({
    required this.wards,
    required this.selectedWardId,
    required this.userLat,
    required this.userLng,
    required this.onTapWard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: _OsmMap(
              wards: wards,
              selectedWardId: selectedWardId,
              userLat: userLat,
              userLng: userLng,
              onTapWard: onTapWard,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3A8A).withOpacity(0.06)
      ..strokeWidth = 1;

    const step = 24.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OsmMap extends StatelessWidget {
  final List<WardModel> wards;
  final String? selectedWardId;
  final double? userLat;
  final double? userLng;
  final ValueChanged<WardModel> onTapWard;

  const _OsmMap({
    required this.wards,
    required this.selectedWardId,
    required this.userLat,
    required this.userLng,
    required this.onTapWard,
  });

  @override
  Widget build(BuildContext context) {
    final center = (userLat != null && userLng != null)
        ? LatLng(userLat!, userLng!)
        : (wards.isNotEmpty
        ? wards.first.center
        : const LatLng(23.8103, 90.4125)); // Dhaka fallback

    final markers = <Marker>[
      if (userLat != null && userLng != null)
        Marker(
          point: LatLng(userLat!, userLng!),
          width: 40,
          height: 40,
          child: const _MyLocationDot(),
        ),
      ...wards.map((w) {
        final selected = w.id == selectedWardId;
        return Marker(
          point: LatLng(w.center.latitude, w.center.longitude),
          width: 44,
          height: 44,
          child: GestureDetector(
            onTap: () => onTapWard(w),
            child: WardPin(
              number: w.number.toString(),
              color: w.pinColor,
              selected: selected,
            ),
          ),
        );
      }),
    ];

    // ✅ flutter_map v8 FIX: initialCenter / initialZoom / interactionOptions
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 15,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.nagarwatch', // change to your package name
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}

class _MyLocationDot extends StatelessWidget {
  const _MyLocationDot();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.30),
              blurRadius: 0,
              spreadRadius: 3,
            ),
            const BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }
}

class WardPin extends StatelessWidget {
  final String number;
  final Color color;
  final bool selected;

  const WardPin({
    super.key,
    required this.number,
    required this.color,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final scale = selected ? 1.25 : 1.0;

    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      scale: scale,
      child: Transform.rotate(
        angle: -math.pi / 4,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(999),
              topRight: Radius.circular(999),
              bottomRight: Radius.circular(999),
              bottomLeft: Radius.circular(0),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Search wards...',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _WardList extends StatelessWidget {
  final List<WardModel> wards;
  final String? selectedWardId;
  final String Function(WardModel) getDistanceText;
  final ValueChanged<WardModel> onTap;

  const _WardList({
    required this.wards,
    required this.selectedWardId,
    required this.getDistanceText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        itemCount: wards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final w = wards[i];
          final selected = w.id == selectedWardId;

          return InkWell(
            onTap: () => onTap(w),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFEFF6FF) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                  selected ? const Color(0xFF3B82F6) : Colors.transparent,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: w.iconBgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child:
                    Icon(Icons.location_on, color: w.iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${w.zone} • ${w.projects} projects',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      getDistanceText(w),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? const Color(0xFF1E3A8A)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF1E3A8A)
                            : const Color(0xFFE2E8F0),
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Color(0xFFF59E0B)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your access to projects & issue reporting will be restricted to the selected ward (FR-1.4).',
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryCTA extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _PrimaryCTA({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.55,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x331E3A8A),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 20, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}