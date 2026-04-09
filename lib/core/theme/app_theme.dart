// TODO – extended theme configuration
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();
  static ThemeData get light => ThemeData(
    fontFamily: 'Inter',
    useMaterial3: true,
    scaffoldBackgroundColor: C.bg,
    colorScheme: const ColorScheme.light(primary: C.primary, secondary: C.accent),
  );
}
