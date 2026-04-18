import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/project_model.dart';

class ProjectTypeIcon extends StatelessWidget {
  final ProjectType type;
  final double size;

  const ProjectTypeIcon({super.key, required this.type, this.size = 42});

  @override
  Widget build(BuildContext context) {
    final (icon, color, bg) = _style(type);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.33),
      ),
      child: Icon(icon, color: color, size: size * 0.48),
    );
  }

  static (IconData, Color, Color) _style(ProjectType type) {
    switch (type) {
      case ProjectType.road:
        return (Icons.construction, const Color(0xFF92400E), AppColors.warning50);
      case ProjectType.drainage:
        return (Icons.water_drop_outlined, AppColors.primary, AppColors.primary50);
      case ProjectType.lighting:
        return (Icons.lightbulb_outline, AppColors.accentDark, AppColors.accent50);
      case ProjectType.waste:
        return (Icons.delete_outline, AppColors.danger, AppColors.danger50);
      case ProjectType.park:
        return (Icons.park_outlined, const Color(0xFF7C3AED), const Color(0xFFF5F3FF));
      case ProjectType.building:
        return (Icons.apartment_outlined, const Color(0xFF0891B2), const Color(0xFFECFEFF));
      case ProjectType.other:
        return (Icons.build_outlined, AppColors.textSecondary, AppColors.borderLight);
    }
  }
}
