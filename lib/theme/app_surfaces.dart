import 'package:flutter/material.dart';

import 'app_colors.dart';

extension AppSurfaces on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get appCardColor => isDarkMode ? AppColors.darkCard : Colors.white;

  Color get appCardAltColor =>
      isDarkMode ? AppColors.darkCardAlt : AppColors.surface;

  Color get appBorderColor =>
      isDarkMode ? AppColors.darkBorder : AppColors.border;

  Color get appPrimaryTextColor =>
      isDarkMode ? Colors.white : AppColors.textPrimary;

  Color get appSecondaryTextColor =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;

  Color get appHintTextColor =>
      isDarkMode ? AppColors.darkTextHint : AppColors.textHint;

  Color get appOverlayColor => isDarkMode
      ? const Color(0xFF18253A).withValues(alpha: 0.82)
      : Colors.white.withValues(alpha: 0.08);

  Color get appOverlayStrongColor => isDarkMode
      ? const Color(0xFF213350).withValues(alpha: 0.94)
      : Colors.white.withValues(alpha: 0.14);
}
