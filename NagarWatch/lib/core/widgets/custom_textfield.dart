import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
  });

  @override State<CustomTextField> createState() => _State();
}

class _State extends State<CustomTextField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final hideText = widget.isPassword ? _hidden : widget.obscureText;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      TextFormField(
        controller: widget.controller,
        obscureText: hideText,
        keyboardType: widget.keyboardType,
        maxLines: hideText ? 1 : widget.maxLines,
        validator: widget.validator,
        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, color: AppColors.textTertiary, size: 20) : null,
          suffixIcon: widget.isPassword ? GestureDetector(
            onTap: () => setState(() => _hidden = !_hidden),
            child: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textTertiary, size: 20),
          ) : null,
        ),
      ),
    ]);
  }
}
