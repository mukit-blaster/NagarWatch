import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../geofencing_notifications/providers/geofence_provider.dart';
import '../../geofencing_notifications/services/notification_handler.dart';

class AuthorityDashboard extends StatelessWidget {
  const AuthorityDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = NotificationHandler.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Authority Dashboard'),
        backgroundColor: const Color(0xFF1A2E50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          AnimatedBuilder(
            animation: notifications,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Center(
                      child: Icon(Icons.notifications_active_rounded),
                    ),
                    if (notifications.unreadCount > 0)
                      Positioned(
                        right: -6,
                        top: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            notifications.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<GeofenceProvider>(
        builder: (context, geofenceProvider, _) {
          return AnimatedBuilder(
            animation: notifications,
            builder: (context, _) {
              final items = notifications.notifications;

              return RefreshIndicator(
                onRefresh: geofenceProvider.detectCurrentArea,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _buildStatusCard(context, geofenceProvider),
                    const SizedBox(height: 16),
                    _buildControlCard(context, notifications),
                    const SizedBox(height: 20),
                    Text(
                      'Notification Feed',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A2E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Every successful area detection is added here for authority review.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5A6B85),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (items.isEmpty)
                      _buildEmptyState(context)
                    else
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildNotificationTile(
                            context,
                            notifications,
                            item,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, GeofenceProvider provider) {
    final area = provider.selectedArea;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE5F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_searching_rounded,
                  color: Color(0xFF1A2E50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Detection Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A2E50),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      area == null
                          ? 'No area detected yet.'
                          : 'Current area: ${area.name}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5A6B85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (provider.isLoading) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(minHeight: 4),
          ],
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'Detected Address',
            value: provider.detectedAddress.isEmpty
                ? 'Not available yet'
                : provider.detectedAddress,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            label: 'Distance',
            value: provider.distanceKm == null
                ? 'Unknown'
                : '${provider.distanceKm!.toStringAsFixed(2)} km',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            label: 'Status',
            value: provider.hasResult
                ? (provider.isInsideRadius
                      ? 'Inside monitored radius'
                      : 'Nearest area assigned as fallback')
                : 'Waiting for detection',
          ),
          if (provider.errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDEDED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF6C4C4)),
              ),
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(
                  color: Color(0xFF9A2A2A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: provider.isLoading
                  ? null
                  : () => context.read<GeofenceProvider>().detectCurrentArea(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A2E50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.my_location_rounded),
              label: Text(
                provider.isLoading ? 'Detecting...' : 'Detect Area Again',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard(
    BuildContext context,
    NotificationHandler notifications,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE5F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Dashboard Handler',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A2E50),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7EE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${notifications.unreadCount} unread',
                  style: const TextStyle(
                    color: Color(0xFF1F7A43),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'This section now handles the in-app notification flow after geofence detection.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5A6B85),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: notifications.unreadCount == 0
                    ? null
                    : notifications.markAllAsRead,
                icon: const Icon(Icons.done_all_rounded),
                label: const Text('Mark all read'),
              ),
              OutlinedButton.icon(
                onPressed: notifications.hasNotifications
                    ? notifications.clearNotifications
                    : null,
                icon: const Icon(Icons.delete_sweep_rounded),
                label: const Text('Clear feed'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationHandler notifications,
    DashboardNotification item,
  ) {
    final cardColor = item.isRead
        ? Colors.white
        : const Color(0xFFF1F7FF);
    final borderColor = item.isRead
        ? const Color(0xFFDDE5F0)
        : const Color(0xFFBCD6FF);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => notifications.markAsRead(item.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.isRead
                    ? const Color(0xFFE9EEF5)
                    : const Color(0xFFDDEBFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.title.contains('Updated')
                    ? Icons.sync_alt_rounded
                    : Icons.location_on_rounded,
                color: const Color(0xFF1A2E50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A2E50),
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.isRead
                              ? const Color(0xFFEFF2F6)
                              : const Color(0xFFE8F7EE),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.isRead ? 'Read' : 'New',
                          style: TextStyle(
                            color: item.isRead
                                ? const Color(0xFF5A6B85)
                                : const Color(0xFF1F7A43),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF344054),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      _buildMetaChip(
                        icon: Icons.map_outlined,
                        label: item.areaName,
                      ),
                      _buildMetaChip(
                        icon: Icons.access_time_rounded,
                        label: _formatTimestamp(item.createdAt),
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

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE5F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 34,
              color: Color(0xFF1A2E50),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No notifications yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A2E50),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Run area detection from this dashboard or from the selection screen. New detection alerts will appear here automatically.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5A6B85),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5A6B85),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A2E50),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF5A6B85)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5A6B85),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';

    return '${time.day} ${months[time.month - 1]}, $hour:$minute $suffix';
  }
}
