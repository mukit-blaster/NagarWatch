// lib/features/geofencing_notifications/main.dart
//
// Standalone demo runner for the geofencing feature.
// Provides a polished, production-style ward/area selection screen.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'features/geofencing_notifications/models/geofence_model.dart';
import 'features/geofencing_notifications/providers/geofence_provider.dart';
import 'features/authority_response_sync/screens/authority_dashboard.dart';
// ═══════════════════════════════════════════════════════════════════════════
// APP ENTRY
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const NagarWatchGeofenceDemo());
}

class NagarWatchGeofenceDemo extends StatelessWidget {
  const NagarWatchGeofenceDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GeofenceProvider()..initialize(),
      child: MaterialApp(
        title: 'NagarWatch — Area Selection',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A2E50),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const AreaSelectionScreen(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COLOR PALETTE
// ═══════════════════════════════════════════════════════════════════════════

class _C {
  _C._();
  static const navy = Color(0xFF1A2E50);
  static const navyLight = Color(0xFF253D66);
  static const accent = Color(0xFF2E86DE);
  static const accentLight = Color(0xFFD6EAFF);
  static const success = Color(0xFF27AE60);
  static const successBg = Color(0xFFEAFAF1);
  static const warning = Color(0xFFF39C12);
  static const warningBg = Color(0xFFFFF8E7);
  static const danger = Color(0xFFE74C3C);
  static const dangerBg = Color(0xFFFDEDED);
  static const bg = Color(0xFFF0F4F8);
  static const card = Colors.white;
  static const textPrimary = Color(0xFF1A2E50);
  static const textSecondary = Color(0xFF5A6B85);
  static const textMuted = Color(0xFF8FA0B8);
  static const border = Color(0xFFE1E8F0);
  static const divider = Color(0xFFF0F4F8);
  static const goldButton = Color(0xFFE8A317);
  static const goldButtonDark = Color(0xFFCC8E10);
}

// ═══════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class AreaSelectionScreen extends StatefulWidget {
  const AreaSelectionScreen({super.key});

  @override
  State<AreaSelectionScreen> createState() => _AreaSelectionScreenState();
}

class _AreaSelectionScreenState extends State<AreaSelectionScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<GeofenceArea> _filteredAreas(List<GeofenceArea> areas) {
    if (_searchQuery.isEmpty) return areas;
    final q = _searchQuery.toLowerCase();
    return areas
        .where(
          (a) =>
              a.name.toLowerCase().contains(q) ||
              a.upazila.toLowerCase().contains(q) ||
              a.district.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GeofenceProvider>();
    final filtered = _filteredAreas(provider.availableAreas);

    return Scaffold(
      backgroundColor: _C.bg,
      body: Column(
        children: [
          // ── Header ──
          _buildHeader(context),

          // ── Scrollable body ──
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _C.dangerBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: _C.danger,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose Your Area',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _C.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Based on your location or search manually',
                              style: TextStyle(
                                fontSize: 13,
                                color: _C.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Detection card ──
                  _buildDetectionCard(provider),

                  const SizedBox(height: 16),

                  // ── Error card ──
                  if (provider.errorMessage != null)
                    _buildErrorCard(provider.errorMessage!),

                  // ── Fallback notice ──
                  if (provider.hasResult && !provider.isInsideRadius)
                    _buildFallbackNotice(),

                  const SizedBox(height: 8),

                  // ── Search ──
                  _buildSearchBar(),

                  const SizedBox(height: 16),

                  // ── Area list ──
                  ...filtered.map((area) => _buildAreaTile(provider, area)),

                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: _C.textMuted.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No areas match "$_searchQuery"',
                              style: const TextStyle(
                                color: _C.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ── Info notice ──
                  _buildInfoNotice(),

                  const SizedBox(height: 16),

                  // ── Continue button ──
                  _buildContinueButton(provider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // HEADER
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 14, 20, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_C.navy, _C.navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Area',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'NagarWatch · Civic Monitoring',
                  style: TextStyle(
                    color: Color(0xAAFFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _C.success.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: _C.success, size: 8),
                SizedBox(width: 6),
                Text(
                  'Online',
                  style: TextStyle(
                    color: Color(0xFF6FE09B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // DETECTION CARD
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildDetectionCard(GeofenceProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingCard();
    }

    if (provider.hasResult) {
      return _buildResultCard(provider);
    }

    return _buildEmptyCard(provider);
  }

  Widget _buildEmptyCard(GeofenceProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _C.accentLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.gps_fixed_rounded,
              color: _C.accent,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Detect Your Location',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap the button below to automatically find your nearest service area using GPS.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _C.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetectButton(provider, isRedetect: false),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, child) {
              final scale = 1.0 + (_pulseController.value * 0.15);
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _C.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: _C.accent,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Detecting your location...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Please wait while we find your GPS position\nand match the nearest service area.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _C.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(
            width: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              child: LinearProgressIndicator(
                minHeight: 4,
                backgroundColor: Color(0xFFE8EEF5),
                valueColor: AlwaysStoppedAnimation<Color>(_C.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(GeofenceProvider provider) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // Top success banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: const BoxDecoration(
              color: _C.successBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _C.success,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Location detected',
                  style: TextStyle(
                    color: _C.success,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (provider.isInsideRadius)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _C.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Inside radius',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _C.success,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Area name
                Text(
                  provider.selectedArea!.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _C.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.selectedArea!.upazila}, ${provider.selectedArea!.district}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: _C.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),

                // Address
                _ResultInfoRow(
                  icon: Icons.place_outlined,
                  label: provider.detectedAddress,
                ),
                const SizedBox(height: 8),

                // Coordinates
                _ResultInfoRow(
                  icon: Icons.explore_outlined,
                  label:
                      '${provider.latitude!.toStringAsFixed(4)}° N,  ${provider.longitude!.toStringAsFixed(4)}° E',
                ),
                const SizedBox(height: 8),

                // Distance
                if (provider.distanceKm != null)
                  _ResultInfoRow(
                    icon: Icons.straighten_rounded,
                    label:
                        '${provider.distanceKm!.toStringAsFixed(2)} km from area center',
                  ),

                const SizedBox(height: 18),
                _buildDetectButton(provider, isRedetect: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // DETECT BUTTON
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildDetectButton(
    GeofenceProvider provider, {
    required bool isRedetect,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: provider.isLoading
            ? null
            : () => context.read<GeofenceProvider>().detectCurrentArea(),
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.navy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _C.navy.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: Icon(
          isRedetect ? Icons.refresh_rounded : Icons.navigation_rounded,
          size: 18,
        ),
        label: Text(
          isRedetect ? 'Re-detect Location' : 'Detect My Area',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // ERROR / NOTICE CARDS
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildErrorCard(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.dangerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _C.danger.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: _C.danger,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detection Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _C.danger,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: _C.danger.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackNotice() {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.warningBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: _C.warning, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You are outside all configured service radii. '
              'The nearest area has been selected as a fallback.',
              style: TextStyle(
                fontSize: 12.5,
                color: _C.warning.withValues(alpha: 0.9),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // SEARCH BAR
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(fontSize: 14, color: _C.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search areas...',
          hintStyle: const TextStyle(color: _C.textMuted, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _C.textMuted,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: _C.textMuted,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // AREA LIST TILES
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildAreaTile(GeofenceProvider provider, GeofenceArea area) {
    final isSelected = provider.selectedArea?.id == area.id;
    final hasDistance = provider.hasDetected && provider.latitude != null;

    // Calculate distance for display even for non-selected areas
    double? distKm;
    if (hasDistance) {
      final meters = _haversineDistance(
        provider.latitude!,
        provider.longitude!,
        area.centerLat,
        area.centerLng,
      );
      distKm = meters / 1000.0;
    }

    return GestureDetector(
      onTap: () => context.read<GeofenceProvider>().selectAreaManually(area),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _C.accentLight : _C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _C.accent : _C.border,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: _C.accent.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 3),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? _C.accent.withValues(alpha: 0.15) : _C.bg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                isSelected
                    ? Icons.location_on_rounded
                    : Icons.location_on_outlined,
                color: isSelected ? _C.accent : _C.textMuted,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    area.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: isSelected ? _C.accent : _C.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${area.upazila}, ${area.district}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isSelected
                          ? _C.accent.withValues(alpha: 0.7)
                          : _C.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Distance + Checkmark
            if (distKm != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '${distKm.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? _C.accent : _C.success,
                  ),
                ),
              ),

            // Checkmark
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isSelected ? _C.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? _C.accent : _C.border,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // BOTTOM ELEMENTS
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildInfoNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFD4920A)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your access to projects & issue reporting will be '
              'restricted to the selected area (FR-1.4).',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF8B6914),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(GeofenceProvider provider) {
    final enabled = provider.selectedArea != null;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: enabled
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AuthorityDashboard(),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.goldButton,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _C.border,
          disabledForegroundColor: _C.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: enabled ? 4 : 0,
          shadowColor: _C.goldButton.withValues(alpha: 0.4),
        ),
        icon: Icon(
          enabled ? Icons.check_circle_outline_rounded : Icons.block_rounded,
          size: 20,
        ),
        label: Text(
          enabled ? 'Continue to Dashboard' : 'Select an Area First',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═════════════════════════════════════════════════════════════════════════

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: _C.card,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: _C.border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// Quick Haversine for display-only distance on list tiles.
  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0; // Earth radius in metres
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _degToRad(double deg) => deg * (pi / 180.0);
}

// ═══════════════════════════════════════════════════════════════════════════
// SMALL REUSABLE WIDGETS (kept private to this file)
// ═══════════════════════════════════════════════════════════════════════════

class _ResultInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ResultInfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _C.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: _C.textSecondary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
