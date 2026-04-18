import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../core/models/issue_model.dart';
import '../../../core/services/geofencing_notification_service.dart';
import '../../authentication/providers/auth_provider.dart';
import '../providers/issue_provider.dart';
import 'issue_detail_screen.dart';
import 'report_issue_screen.dart';

class IssueListScreen extends StatefulWidget {
  const IssueListScreen({super.key});

  @override
  State<IssueListScreen> createState() => _IssueListScreenState();
}

class _IssueListScreenState extends State<IssueListScreen> {
  IssueStatus? selectedFilter;
  late Stream<List<IssueModel>> _issueStream;
  String? _lastWardId;

  @override
  void initState() {
    super.initState();
    _initializeGeofencing();
    _initializeIssueStream();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wardId = context.read<AuthProvider>().user?.wardId;
    if (_lastWardId != wardId) {
      _initializeIssueStream();
    }
  }

  /// Initialize geofencing notification service
  Future<void> _initializeGeofencing() async {
    try {
      // Request location permission if not already granted
      final permission =
          await GeofencingNotificationService.requestLocationPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission is required for geofencing'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Start monitoring location
      await GeofencingNotificationService.instance.startMonitoring();
    } catch (e) {
      debugPrint('Error initializing geofencing: $e');
    }
  }

  /// Initialize the issue stream based on current context
  void _initializeIssueStream() {
    // Use logged-in user's ward if available; otherwise stream all issues.
    final issueProvider = context.read<IssueProvider>();
    final wardId = context.read<AuthProvider>().user?.wardId;
    _lastWardId = wardId;

    _issueStream = (wardId != null && wardId.isNotEmpty)
        ? issueProvider.getIssuesStream(wardId)
        : issueProvider.getAllIssuesStream();
  }

  @override
  void dispose() {
    // Stop geofencing when screen is disposed
    GeofencingNotificationService.instance.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<IssueModel>>(
      stream: _issueStream,
      builder: (context, snapshot) {
        final issues = snapshot.data ?? [];

        final filtered = selectedFilter == null
            ? issues
            : issues.where((i) => i.status == selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF3F6FA),

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Issues",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E293B),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportIssueScreen(
                              onSubmitted: () => Navigator.pop(context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            /// FILTER BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _filterButton("All", null),
                  _filterButton("Submitted", IssueStatus.submitted),
                  _filterButton("In Progress", IssueStatus.inProgress),
                  _filterButton("Resolved", IssueStatus.resolved),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// LIST - StreamBuilder
            Expanded(
              child: snapshot.connectionState == ConnectionState.waiting &&
                      issues.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : snapshot.hasError
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.cloud_off, size: 42),
                                const SizedBox(height: 12),
                                Text(
                                  'Error loading issues: ${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xff475569),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _initializeIssueStream();
                                    });
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No reports yet.',
                                style: TextStyle(color: Color(0xff64748B)),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                setState(() {
                                  _initializeIssueStream();
                                });
                                // Wait a bit for the stream to update
                                await Future.delayed(
                                    const Duration(milliseconds: 500));
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final issue = filtered[index];
                                  return _issueCard(issue);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  /// FILTER BUTTON
  Widget _filterButton(String text, IssueStatus? status) {
    final selected = selectedFilter == status;

    return Padding(
      padding: const EdgeInsets.only(right: 8),

      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = status;
          });
        },

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

          decoration: BoxDecoration(
            color: selected ? const Color(0xff2B4EFF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),

          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xff475569),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// ISSUE CARD
  Widget _issueCard(IssueModel issue) {
    Color cardColor;
    Color badgeColor;

    switch (issue.status) {
      case IssueStatus.resolved:
        cardColor = const Color(0xffECFDF5);
        badgeColor = const Color(0xff22C55E);
        break;

      case IssueStatus.inProgress:
        cardColor = const Color(0xffFFF7ED);
        badgeColor = const Color(0xffF59E0B);
        break;

      default:
        cardColor = const Color(0xffEEF2FF);
        badgeColor = const Color(0xff3B82F6);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => IssueDetailScreen(issue: issue)),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),

              child: _issueImage(issue.imageUrl),
            ),

            const SizedBox(width: 14),

            /// RIGHT CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TOP ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),

                        child: Text(
                          "#ISS-${issue.id.substring(0, 4)}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff64748B),
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),

                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(.15),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Text(
                          issue.status.name,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// TITLE
                  Text(
                    issue.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E293B),
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// LOCATION
                  Text(
                    issue.areaName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xff64748B),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// BOTTOM ROW
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Color(0xff94A3B8),
                      ),

                      const SizedBox(width: 4),

                      Text(
                        "${issue.createdAt.day}/${issue.createdAt.month}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff94A3B8),
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Icon(
                        Icons.label_outline,
                        size: 14,
                        color: Color(0xff94A3B8),
                      ),

                      const SizedBox(width: 4),

                      Text(
                        issue.title,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff94A3B8),
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xff94A3B8),
                      ),

                      const SizedBox(width: 4),

                      Text(
                        "Road ${issue.roadNumber}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _issueImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 70,
        height: 70,
        color: Colors.grey.shade300,
        child: const Icon(Icons.image),
      );
    }

    final uri = Uri.tryParse(imageUrl);
    final isNetworkImage =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    if (isNetworkImage) {
      return Image.network(
        imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 70,
            height: 70,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image),
          );
        },
      );
    }
    if (kIsWeb) {
      return Container(
        width: 70,
        height: 70,
        color: Colors.grey.shade300,
        child: const Icon(Icons.image),
      );
    }

    final file = File(imageUrl);
    if (file.existsSync()) {
      return Image.file(file, width: 70, height: 70, fit: BoxFit.cover);
    }

    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image),
    );
  }
}
