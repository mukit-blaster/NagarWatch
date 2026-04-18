import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../providers/auth_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _wardCtrl = TextEditingController();
  String _role = 'requestAuthority';

  @override void dispose() { _emailCtrl.dispose(); _wardCtrl.dispose(); super.dispose(); }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginAuthority(email: _emailCtrl.text, wardCode: _wardCtrl.text);
    if (!mounted) return;
    if (ok) {
      // Check if user is pending approval
      if (auth.authorizationStatus == 'pending_approval') {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.authorityApprovalPending,
          arguments: {
            'name': auth.user?.name ?? '',
            'email': auth.user?.email ?? '',
          },
        );
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.authorityDashboard);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isSuperAdmin = _role == 'admin';
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.authHeaderStart, AppColors.authHeaderMid])),
          child: SafeArea(bottom: false, child: Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withOpacity(.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18))),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(20)), child: const Text('🛡️ Authority Portal', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
            const SizedBox(height: 8),
            const Text(AppStrings.adminAccess, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text(AppStrings.authorityPortalSub, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(.7))),
          ]))),
        ),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Role', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Row(children: [
            _roleBtn('Request Authority Panel', 'requestAuthority'),
            const SizedBox(width: 10),
            _roleBtn(AppStrings.superAdmin, 'admin'),
          ]),
          const SizedBox(height: 20),
          CustomTextField(label: AppStrings.officialEmail, hint: 'officer@city.gov.bd', controller: _emailCtrl, prefixIcon: Icons.badge_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => (v?.isEmpty ?? true) ? 'Enter email' : null),
          const SizedBox(height: 16),
          CustomTextField(label: AppStrings.password, hint: 'Enter your password', controller: _wardCtrl, prefixIcon: Icons.lock_outline_rounded, isPassword: true, validator: (v) => (v?.isEmpty ?? true) ? 'Enter password' : null),
          const SizedBox(height: 28),
          CustomButton(
            label: isSuperAdmin ? AppStrings.accessPanel : 'Request Authority Panel',
            icon: isSuperAdmin ? Icons.shield_outlined : Icons.send_outlined,
            onPressed: _handleLogin,
            isLoading: auth.isLoading,
          ),
          const SizedBox(height: 16),
          const Center(child: Text(AppStrings.securedWith2FA, style: TextStyle(fontSize: 12, color: AppColors.textTertiary))),
        ])))),
      ]),
    );
  }

  Widget _roleBtn(String label, String val) {
    final active = _role == val;
    return Expanded(child: GestureDetector(onTap: () => setState(() => _role = val),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: active ? AppColors.authHeaderStart : AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: active ? AppColors.authHeaderStart : AppColors.border, width: active ? 2 : 1.5)),
        child: Center(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary))))));
  }
}
