import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';

class AuthorityApprovalPendingScreen extends StatelessWidget {
  final String userName;
  final String userEmail;

  const AuthorityApprovalPendingScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.welcomeStart, AppColors.welcomeMid1, AppColors.welcomeMid2],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Approval Pending',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your authority request is awaiting admin approval',
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(.7)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.warning50,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.hourglass_bottom_rounded, color: AppColors.warning, size: 48),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Request Submitted',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your account has been registered as an authority member. An administrator will review and approve your request soon.',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.warningLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Request Details',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(label: 'Name:', value: userName),
                          const SizedBox(height: 8),
                          _DetailRow(label: 'Email:', value: userEmail),
                          const SizedBox(height: 8),
                          const _DetailRow(label: 'Status:', value: 'Pending Admin Approval', valueColor: AppColors.warning),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'What happens next?',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const _StepCard(number: 1, title: 'Admin Review', description: 'An administrator will verify your credentials'),
                    const SizedBox(height: 12),
                    const _StepCard(number: 2, title: 'Approval Decision', description: 'Your request will be approved or rejected'),
                    const SizedBox(height: 12),
                    const _StepCard(number: 3, title: 'Full Access', description: 'Once approved, you\'ll have admin dashboard access'),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: const BoxDecoration(
                color: AppColors.card,
                boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -4))],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.welcome),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textSecondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Return to Welcome', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 13, color: valueColor ?? AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String title;
  final String description;

  const _StepCard({required this.number, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: AppColors.primary50, borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text(number.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
