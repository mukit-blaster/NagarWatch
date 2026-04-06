import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _useEmail = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to Terms & Conditions')),
      );
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _confirmController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }
      Navigator.pushNamed(context, AppRoutes.wardSelection);
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(AppStrings.joinNagarWatch, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text(AppStrings.registerSubtitle, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    _AuthToggle(
                      useEmail: _useEmail,
                      onToggle: (v) => setState(() => _useEmail = v),
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      label: AppStrings.fullName,
                      hint: 'Enter your full name',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) => (v?.isEmpty ?? true) ? 'Enter full name' : null,
                    ),
                    const SizedBox(height: 18),
                    if (_useEmail)
                      CustomTextField(
                        label: AppStrings.emailAddress,
                        hint: 'you@example.com',
                        controller: _emailController,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v?.isEmpty ?? true) ? 'Enter email' : null,
                      )
                    else
                      CustomTextField(
                        label: AppStrings.phoneNumber,
                        hint: '+880 XXXXX XXXXX',
                        controller: _phoneController,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v?.isEmpty ?? true) ? 'Enter phone' : null,
                      ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      label: AppStrings.createPassword,
                      hint: 'Min 8 characters',
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null,
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      label: AppStrings.confirmPassword,
                      hint: 'Re-enter password',
                      controller: _confirmController,
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: (v) => (v?.isEmpty ?? true) ? 'Confirm your password' : null,
                    ),
                    const SizedBox(height: 20),
                    _TermsCheckbox(
                      value: _agreedToTerms,
                      onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      label: 'Create Account',
                      icon: Icons.person_add_outlined,
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(AppStrings.alreadyHaveAccount, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                            style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 4), minimumSize: Size.zero),
                            child: const Text('Sign In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryLight)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
          const Text('Create Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _AuthToggle extends StatelessWidget {
  const _AuthToggle({required this.useEmail, required this.onToggle});
  final bool useEmail;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ToggleBtn(label: '📧 Email', active: useEmail, onTap: () => onToggle(true)),
          _ToggleBtn(label: '📱 Phone', active: !useEmail, onTap: () => onToggle(false)),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});
  final bool value;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          const Text('I agree to ', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const Text('Terms & Conditions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryLight)),
        ],
      ),
    );
  }
}
