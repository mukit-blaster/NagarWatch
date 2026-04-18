import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ButtonVariant { filled, outlineWhite, ghostWhite }

class CustomButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = ButtonVariant.filled,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case ButtonVariant.outlineWhite:
        return _outline();
      case ButtonVariant.ghostWhite:
        return _ghost();
      case ButtonVariant.filled:
        return _filled();
    }
  }

  Widget _filled() => SizedBox(
    width: double.infinity, height: 52,
    child: DecoratedBox(
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]), borderRadius: BorderRadius.circular(16)),
      child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(16),
        child: InkWell(onTap: isLoading ? null : onPressed, borderRadius: BorderRadius.circular(16),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            else ...[
              if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 10)],
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ]),
        ),
      ),
    ),
  );

  Widget _outline() => SizedBox(
    width: double.infinity, height: 52,
    child: OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: icon != null ? Icon(icon, color: Colors.white, size: 20) : const SizedBox.shrink(),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.white.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );

  Widget _ghost() => SizedBox(
    width: double.infinity, height: 48,
    child: TextButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: icon != null ? Icon(icon, color: Colors.white.withOpacity(0.7), size: 18) : const SizedBox.shrink(),
      label: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500)),
    ),
  );
}

// Gradient button (Mukit design)
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final List<Color> colors;
  final List<BoxShadow> shadows;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.colors = const [C.primary, C.primaryLight],
    this.shadows = const [],
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: R.md, boxShadow: shadows),
    child: Material(color: Colors.transparent, borderRadius: R.md,
      child: InkWell(onTap: onTap, borderRadius: R.md,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 10)],
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -.2)),
          ]),
        ),
      ),
    ),
  );
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String value, label;
  const StatCard({super.key, required this.icon, required this.iconColor, required this.iconBg, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    decoration: BoxDecoration(color: C.card, borderRadius: R.md, boxShadow: S.lg, border: Border.all(color: const Color(0x08000000))),
    child: Column(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 18)),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: C.textPrimary)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: C.textSecondary)),
    ]),
  );
}

class ScreenHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final List<Widget> actions;
  const ScreenHeader({super.key, required this.title, this.showBack = true, this.actions = const []});

  @override
  Widget build(BuildContext context) => Container(
    color: C.card,
    child: SafeArea(bottom: false, child: Container(
      height: 56, padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0A000000)))),
      child: Row(children: [
        if (showBack) GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(width: 38, height: 38, decoration: BoxDecoration(color: C.bg, borderRadius: R.sm, border: Border.all(color: C.border)), child: const Icon(Icons.arrow_back_rounded, size: 18, color: C.textPrimary)),
        ),
        if (showBack) const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.textPrimary, letterSpacing: -.3))),
        ...actions,
      ]),
    )),
  );
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: C.textPrimary, letterSpacing: -.3)),
      if (actionLabel != null) GestureDetector(onTap: onAction, child: Text(actionLabel!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.primaryLight))),
    ],
  );
}
