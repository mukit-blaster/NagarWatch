import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/authority_approval_provider.dart';
import 'package:provider/provider.dart';

class AuthorityRequestsManagementScreen extends StatefulWidget {
  const AuthorityRequestsManagementScreen({super.key});

  @override
  State<AuthorityRequestsManagementScreen> createState() => _AuthorityRequestsManagementScreenState();
}

class _AuthorityRequestsManagementScreenState extends State<AuthorityRequestsManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthorityApprovalProvider>().fetchPendingRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AuthorityApprovalProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Authority Approval Requests', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
          : prov.pendingRequests.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 64, color: AppColors.accent50),
                      SizedBox(height: 16),
                      Text('All Approved', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      SizedBox(height: 8),
                      Text('No pending approval requests', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: prov.pendingRequests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final req = prov.pendingRequests[i];
                    return _RequestCard(request: req, onApprove: () => _showApproveDialog(context, prov, req['id']), onReject: () => _showRejectDialog(context, prov, req['id']));
                  },
                ),
    );
  }

  void _showApproveDialog(BuildContext context, AuthorityApprovalProvider prov, String requestId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Authority?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('This authority member will be promoted to admin and gain full dashboard access.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              prov.approveRequest(requestId);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, AuthorityApprovalProvider prov, String requestId) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Request?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Provide a reason (optional):', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason for rejection...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              prov.rejectRequest(requestId, reasonCtrl.text);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RequestCard({required this.request, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: AppColors.primary50, shape: BoxShape.circle),
                child: const Icon(Icons.person_rounded, size: 24, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request['name'] ?? 'Unknown', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text(request['email'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.warning50, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.warningLight)),
            child: const Text('Pending Review', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning)),
          ),
          const SizedBox(height: 12),
          if (request['requestedAt'] != null)
            Text(
              'Requested: ${DateTime.parse(request['requestedAt']).toLocal().toString().split('.')[0]}',
              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Reject', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
