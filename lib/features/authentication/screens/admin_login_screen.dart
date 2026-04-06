import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'officer.singh@nagar.gov.in');
  final _passwordController = TextEditingController(text: 'admin@secure');
  final _wardCodeController = TextEditingController(text: 'WD-12-2025');

  bool _isWardOfficer = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _wardCodeController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pushNamed(context, AppRoutes.authorityDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPortalCard(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _RoleToggle(
                            isWardOfficer: _isWardOfficer,
                            onToggle: (v) => setState(() => _isWardOfficer = v),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: AppStrings.officialEmail,
                            hint: 'officer@nagar.gov.in',
                            controller: _emailController,
                            prefixIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => (v?.isEmpty ?? true) ? 'Enter official email' : null,
                          ),
                          const SizedBox(height: 18),
                          CustomTextField(
                            label: AppStrings.password,
                            hint: 'Enter admin password',
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline_rounded,
                            isPassword: true,
                            validator: (v) => (v?.isEmpty ?? true) ? 'Enter password' : null,
                          ),
                          const SizedBox(height: 18),
                          CustomTextField(
                            label: AppStrings.wardCode,
                            hint: 'e.g., WD-12-2025',
                            controller: _wardCodeController,
                            prefixIcon: Icons.key_outlined,
                            validator: (v) => (v?.isEmpty ?? true) ? 'Enter ward code' : null,
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            label: AppStrings.accessPanel,
                            icon: Icons.login_rounded,
                            variant: ButtonVariant.accent,
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            AppStrings.securedWith2FA,
                            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.8),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Row(
        children: [
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          const Text(AppStrings.adminAccess, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildPortalCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.authHeaderStart, AppColors.authHeaderMid, AppColors.accentDark],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Icons.shield_outlined, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 14),
          const Text(AppStrings.authorityPortal, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            AppStrings.authorityPortalSub,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

class _RoleToggle extends StatelessWidget {
  const _RoleToggle({required this.isWardOfficer, required this.onToggle});
  final bool isWardOfficer;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _RoleBtn(
            label: AppStrings.wardOfficer,
            icon: Icons.badge_outlined,
            active: isWardOfficer,
            onTap: () => onToggle(true),
          ),
          _RoleBtn(
            label: AppStrings.superAdmin,
            icon: Icons.workspace_premium_outlined,
            active: !isWardOfficer,
            onTap: () => onToggle(false),
          ),
        ],
      ),
    );
  }
}

class _RoleBtn extends StatelessWidget {
  const _RoleBtn({required this.label, required this.icon, required this.active, required this.onTap});
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.card : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? AppColors.primary : AppColors.textTertiary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
