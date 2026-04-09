import 'package:flutter/material.dart';

/// Short alias class for colors used everywhere in the app.
class C {
  C._();
  static const primary       = Color(0xFF1E3A8A);
  static const primaryLight  = Color(0xFF3B82F6);
  static const primary50     = Color(0xFFEFF6FF);
  static const primary200    = Color(0xFFBFDBFE);

  static const accent        = Color(0xFF10B981);
  static const accentDark    = Color(0xFF059669);
  static const accentLight   = Color(0xFF34D399);
  static const accent50      = Color(0xFFECFDF5);

  static const bg            = Color(0xFFF1F5F9);
  static const card          = Color(0xFFFFFFFF);
  static const border        = Color(0xFFE2E8F0);
  static const borderLight   = Color(0xFFF1F5F9);

  static const danger        = Color(0xFFEF4444);
  static const danger50      = Color(0xFFFEF2F2);
  static const dangerLight   = Color(0xFFFCA5A5);

  static const warning       = Color(0xFFF59E0B);
  static const warning50     = Color(0xFFFFFBEB);

  static const textPrimary   = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary  = Color(0xFF94A3B8);

  static const purple        = Color(0xFF7C3AED);
  static const purple50      = Color(0xFFF5F3FF);
  static const cyan          = Color(0xFF0891B2);
  static const cyan50        = Color(0xFFECFEFF);

  // Authority header gradient
  static const authStart     = Color(0xFF064E3B);
  static const authMid       = Color(0xFF065F46);
  static const authEnd       = Color(0xFF059669);
}

/// Border-radius shorthands.
class R {
  static BorderRadius get sm   => BorderRadius.circular(12);
  static BorderRadius get md   => BorderRadius.circular(16);
  static BorderRadius get lg   => BorderRadius.circular(24);
  static BorderRadius get full => BorderRadius.circular(999);
}

/// Shadow shorthands.
class S {
  static List<BoxShadow> get xs => [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 2,  offset: const Offset(0, 1))];
  static List<BoxShadow> get sm => [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 4,  offset: const Offset(0, 2))];
  static List<BoxShadow> get md => [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 8,  offset: const Offset(0, 4))];
  static List<BoxShadow> get lg => [BoxShadow(color: Colors.black.withOpacity(.10), blurRadius: 16, offset: const Offset(0, 8))];
  static List<BoxShadow> get accent  => [BoxShadow(color: C.accent.withOpacity(.35),  blurRadius: 12, offset: const Offset(0, 4))];
  static List<BoxShadow> get primary => [BoxShadow(color: C.primary.withOpacity(.35), blurRadius: 12, offset: const Offset(0, 4))];
}
