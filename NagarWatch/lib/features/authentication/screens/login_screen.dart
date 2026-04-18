import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _useEmail = true;

  @override void dispose() { _emailCtrl.dispose(); _phoneCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      emailOrPhone: _useEmail ? _emailCtrl.text : _phoneCtrl.text,
      password: _passCtrl.text, isEmail: _useEmail,
    );
    if (!mounted) return;
    if (ok) {
      if (auth.needsWardSelection) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.geofenceArea,
          arguments: {'onboardingFlow': true},
        );
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Login failed'), backgroundColor: AppColors.danger));
    }
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
            const Text(AppStrings.welcomeBack, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text(AppStrings.signInSubtitle, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            _AuthToggle(useEmail: _useEmail, onToggle: (v) => setState(() => _useEmail = v)),
            const SizedBox(height: 16),
            if (_useEmail) CustomTextField(label: AppStrings.emailAddress, hint: 'you@example.com', controller: _emailCtrl, prefixIcon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress, validator: (v) => (v?.isEmpty ?? true) ? 'Enter email' : null)
            else CustomTextField(label: AppStrings.phoneNumber, hint: '+880 XXXXX XXXXX', controller: _phoneCtrl, prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => (v?.isEmpty ?? true) ? 'Enter phone' : null),
            const SizedBox(height: 18),
            CustomTextField(label: AppStrings.password, hint: 'Enter your password', controller: _passCtrl, prefixIcon: Icons.lock_outline_rounded, obscureText: true, validator: (v) => (v?.isEmpty ?? true) ? 'Enter password' : null),
            const SizedBox(height: 24),
            CustomButton(label: AppStrings.signIn, icon: Icons.arrow_forward_rounded, onPressed: _handleLogin, isLoading: auth.isLoading),
            const SizedBox(height: 20),
            Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text(AppStrings.noAccount, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              TextButton(onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.register), style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 4), minimumSize: Size.zero),
                child: const Text(AppStrings.register, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryLight))),
            ])),
          ])),
        )),
      ]),
    );
  }

  Widget _appBar(BuildContext context) => Container(
    color: Colors.white,
    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
    child: Row(children: [
      const SizedBox(width: 12),
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(width: 40, height: 40, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary)),
      ),
      const SizedBox(width: 14),
      const Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    ]),
  );
}

class _AuthToggle extends StatelessWidget {
  final bool useEmail; final void Function(bool) onToggle;
  const _AuthToggle({required this.useEmail, required this.onToggle});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: AppColors.primary50, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [_Btn('📧 Email', useEmail, () => onToggle(true)), _Btn('📱 Phone', !useEmail, () => onToggle(false))]),
  );
}

class _Btn extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const _Btn(this.label, this.active, this.onTap);
  @override Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: active ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textTertiary)))));
}
