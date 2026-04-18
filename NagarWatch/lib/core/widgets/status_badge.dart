import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/project_model.dart';

class StatusBadge extends StatelessWidget {
  final ProjectStatus status;
  final bool onDark; // true = show on dark gradient background

  const StatusBadge({super.key, required this.status, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final (label, textColor, bg) = _style(status, onDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: textColor,
          )),
    );
  }

  static (String, Color, Color) _style(ProjectStatus status, bool onDark) {
    if (onDark) {
      // On dark hero backgrounds use semi-transparent white
      return switch (status) {
        ProjectStatus.ongoing   => ('🔨 Ongoing',   Colors.white, Colors.white.withOpacity(0.2)),
        ProjectStatus.planned   => ('📋 Planned',   Colors.white, Colors.white.withOpacity(0.2)),
        ProjectStatus.completed => ('✅ Completed', Colors.white, Colors.white.withOpacity(0.2)),
        ProjectStatus.delayed   => ('⚠️ Delayed',   Colors.white, Colors.white.withOpacity(0.2)),
      };
    }
    return switch (status) {
      ProjectStatus.ongoing   => ('Ongoing',   const Color(0xFF92400E), AppColors.warning50),
      ProjectStatus.planned   => ('Planned',   AppColors.primary,       AppColors.primary50),
      ProjectStatus.completed => ('Completed', AppColors.accentDark,    AppColors.accent50),
      ProjectStatus.delayed   => ('Delayed',   AppColors.danger,        AppColors.danger50),
    };
  }
}
