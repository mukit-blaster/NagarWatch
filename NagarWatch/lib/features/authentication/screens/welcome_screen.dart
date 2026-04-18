import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto-redirect if already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn) {
        if (auth.needsWardSelection) {
          Navigator.pushReplacementNamed(context, AppRoutes.wardSelection);
        } else if (auth.isAuthority) Navigator.pushReplacementNamed(context, AppRoutes.authorityDashboard);
        else Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          stops: [0.0, 0.35, 0.65, 1.0],
          colors: [AppColors.welcomeStart, AppColors.welcomeMid1, AppColors.welcomeMid2, AppColors.welcomeEnd])),
        child: SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Column(children: [
          const Spacer(),
          Container(width: 120, height: 120,
            decoration: BoxDecoration(color: Colors.white.withOpacity(.1), borderRadius: BorderRadius.circular(38), border: Border.all(color: Colors.white.withOpacity(.15), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.25), blurRadius: 48, offset: const Offset(0, 16))]),
            child: const Icon(Icons.domain, size: 52, color: Colors.white)),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withOpacity(.15))),
            child: Text(AppStrings.madeFor, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(.9)))),
          const SizedBox(height: 16),
          const Text(AppStrings.appName, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
          const SizedBox(height: 8),
          Text(AppStrings.appTagline, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(.65), height: 1.6)),
          const Spacer(),
          _WhiteButton(label: AppStrings.citizenLogin, icon: Icons.login_rounded, onTap: () => Navigator.pushNamed(context, AppRoutes.login)),
          const SizedBox(height: 12),
          CustomButton(label: AppStrings.authorityLogin, icon: Icons.shield_outlined, variant: ButtonVariant.outlineWhite, onPressed: () => Navigator.pushNamed(context, AppRoutes.adminLogin)),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: Divider(color: Colors.white.withOpacity(.15))), Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('NEW HERE?', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.4), fontWeight: FontWeight.w500))), Expanded(child: Divider(color: Colors.white.withOpacity(.15)))]),
          const SizedBox(height: 8),
          CustomButton(label: AppStrings.createAccount, icon: Icons.person_add_outlined, variant: ButtonVariant.ghostWhite, onPressed: () => Navigator.pushNamed(context, AppRoutes.register)),
          const SizedBox(height: 20),
          Text(AppStrings.termsText, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.35))),
          const SizedBox(height: 16),
        ]))),
      ),
    );
  }
}

class _WhiteButton extends StatelessWidget {
  const _WhiteButton({required this.label, required this.icon, required this.onTap});
  final String label; final IconData icon; final VoidCallback onTap;
  @override Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 52,
    child: DecoratedBox(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 24, offset: const Offset(0, 8))]),
      child: Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: AppColors.primary, size: 20), const SizedBox(width: 10), Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600))])))));
}
