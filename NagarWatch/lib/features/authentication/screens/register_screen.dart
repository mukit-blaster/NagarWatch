import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _agreed = false;

  @override void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _passCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreed) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please agree to Terms & Conditions'))); return; }
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(name: _nameCtrl.text, email: _emailCtrl.text, password: _passCtrl.text, phone: _phoneCtrl.text.isEmpty ? null : _phoneCtrl.text);
    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Registration failed'), backgroundColor: AppColors.danger));
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.geofenceArea,
      arguments: {'onboardingFlow': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        _appBar(context),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(AppStrings.joinNagarWatch, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text(AppStrings.registerSubtitle, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            CustomTextField(label: AppStrings.fullName, hint: 'Your full name', controller: _nameCtrl, prefixIcon: Icons.person_outline_rounded, validator: (v) => (v?.isEmpty ?? true) ? 'Enter name' : null),
            const SizedBox(height: 16),
            CustomTextField(label: AppStrings.emailAddress, hint: 'you@example.com', controller: _emailCtrl, prefixIcon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress, validator: (v) => (v?.isEmpty ?? true) ? 'Enter email' : null),
            const SizedBox(height: 16),
            CustomTextField(label: AppStrings.phoneNumber, hint: '+880 XXXXX XXXXX (optional)', controller: _phoneCtrl, prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            CustomTextField(label: AppStrings.createPassword, hint: 'Min 6 characters', controller: _passCtrl, prefixIcon: Icons.lock_outline_rounded, isPassword: true, validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 chars' : null),
            const SizedBox(height: 16),
            CustomTextField(label: AppStrings.confirmPassword, hint: 'Re-enter password', controller: _confirmCtrl, prefixIcon: Icons.lock_outline_rounded, isPassword: true, validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => setState(() => _agreed = !_agreed),
              child: Row(children: [
                SizedBox(width: 18, height: 18, child: Checkbox(value: _agreed, onChanged: (v) => setState(() => _agreed = v ?? false), activeColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
                const SizedBox(width: 10),
                const Text(AppStrings.agreeTerms, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ]),
            ),
            const SizedBox(height: 24),
            CustomButton(label: 'Create Account', icon: Icons.person_add_outlined, onPressed: _handleRegister, isLoading: auth.isLoading),
            const SizedBox(height: 20),
            Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text(AppStrings.alreadyHaveAccount, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              TextButton(onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login), style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 4), minimumSize: Size.zero),
                child: const Text(AppStrings.signIn, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryLight))),
            ])),
          ])),
        )),
      ]),
    );
  }

  Widget _appBar(BuildContext context) => Container(color: Colors.white, padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
    child: Row(children: [
      const SizedBox(width: 12),
      GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 40, height: 40, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary))),
      const SizedBox(width: 14),
      const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    ]));
}
