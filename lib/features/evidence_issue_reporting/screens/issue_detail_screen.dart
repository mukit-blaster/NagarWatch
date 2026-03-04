import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/models/issue_model.dart';

class IssueDetailScreen extends StatefulWidget {
  final IssueModel issue;

  const IssueDetailScreen({super.key, required this.issue});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _statusIndex(IssueStatus status) {
    switch (status) {
      case IssueStatus.submitted:
        return 0;
      case IssueStatus.inProgress:
        return 2;
      case IssueStatus.resolved:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;
    final step = _statusIndex(issue.status);
    final percent = ((step + 1) / 4);

    return Scaffold(
      backgroundColor: const Color(0xffF3F6FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffF3F6FA),
        title: const Text(
          "Issue Tracking",
          style: TextStyle(
            color: Color(0xff1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: FadeTransition(
        opacity: _fade,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              /// IMAGE
              if (issue.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(issue.imageUrl!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 16),

              /// HEADER CARD
              _headerCard(issue),

              const SizedBox(height: 16),

              /// RESOLUTION PROGRESS
              _resolutionProgress(percent, step),

              const SizedBox(height: 16),

              /// STATUS TIMELINE
              _statusTimeline(step),
            ],
          ),
        ),
      ),
    );
  }

  /// HEADER CARD
  Widget _headerCard(IssueModel issue) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xffEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Text(
                  "#ISS-${issue.id.substring(0, 4)}",
                  style: const TextStyle(
                    color: Color(0xff4F46E5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              _statusBadge(issue.status),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            issue.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E293B),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            issue.description,
            style: const TextStyle(color: Color(0xff64748B)),
          ),

          const SizedBox(height: 16),

          const Divider(),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Color(0xff64748B),
              ),

              const SizedBox(width: 6),

              Text("${issue.createdAt.day} Oct, ${issue.createdAt.year}"),

              const SizedBox(width: 16),

              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Color(0xff64748B),
              ),

              const SizedBox(width: 6),

              Text("Ward ${issue.roadNumber}"),

              const SizedBox(width: 16),

              const Icon(
                Icons.label_outline,
                size: 16,
                color: Color(0xff64748B),
              ),

              const SizedBox(width: 6),

              Text(issue.title),
            ],
          ),
        ],
      ),
    );
  }

  /// STATUS BADGE
  Widget _statusBadge(IssueStatus status) {
    Color color;

    switch (status) {
      case IssueStatus.resolved:
        color = const Color(0xff22C55E);
        break;
      case IssueStatus.inProgress:
        color = const Color(0xffF59E0B);
        break;
      default:
        color = const Color(0xff3B82F6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),

      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Text(
        status.name,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// RESOLUTION PROGRESS
  Widget _resolutionProgress(double percent, int step) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Resolution Progress",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Overall", style: TextStyle(color: Color(0xff64748B))),
              Text(
                "${(percent * 100).toInt()}%",
                style: const TextStyle(
                  color: Color(0xffF59E0B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: const Color(0xffE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xffF59E0B)),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _progressDot("Submitted", step >= 0),
              _progressDot("Reviewed", step >= 1),
              _progressDot("Working", step >= 2, highlight: step == 2),
              _progressDot("Resolved", step >= 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressDot(String label, bool active, {bool highlight = false}) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: active ? const Color(0xff10B981) : const Color(0xffCBD5E1),
            shape: BoxShape.circle,
            border: highlight
                ? Border.all(color: const Color(0xffF59E0B), width: 4)
                : null,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: highlight
                ? const Color(0xffF59E0B)
                : const Color(0xff94A3B8),
          ),
        ),
      ],
    );
  }

  /// STATUS TIMELINE
  Widget _statusTimeline(int step) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Status Timeline (FR-5.2)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          _timelineItem("Issue Submitted", "Report received and logged", true),

          _timelineItem(
            "Under Review",
            "Assigned to Public Works Dept",
            step >= 1,
          ),

          _timelineItem(
            "Work In Progress",
            "Repair crew dispatched",
            step >= 2,
            working: step == 2,
          ),

          _timelineItem("Resolved", "Awaiting completion", step >= 3),
        ],
      ),
    );
  }

  Widget _timelineItem(
    String title,
    String subtitle,
    bool active, {
    bool working = false,
  }) {
    Color color = working
        ? const Color(0xffF59E0B)
        : active
        ? const Color(0xff10B981)
        : const Color(0xffCBD5E1);

    IconData icon = working ? Icons.star : Icons.check;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color,

            child: active ? Icon(icon, size: 16, color: Colors.white) : null,
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1E293B),
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xff64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
