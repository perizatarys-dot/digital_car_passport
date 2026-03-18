import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ScorePill extends StatelessWidget {
  final String status; // 'safe' | 'caution' | 'risk'
  const ScorePill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (status) {
      case 'safe':
        bg = AppColors.safeBg; fg = AppColors.safeText; label = 'Safe';
      case 'caution':
        bg = AppColors.cautionBg; fg = AppColors.cautionText; label = 'Caution';
      default:
        bg = AppColors.riskBg; fg = AppColors.riskText; label = 'Risk';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
