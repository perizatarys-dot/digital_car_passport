import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/car_report.dart';
import '../services/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';

class FinesCheckScreen extends StatelessWidget {
  final String vin;

  const FinesCheckScreen({super.key, required this.vin});

  @override
  Widget build(BuildContext context) {
    final report = MockData.reportForVin(vin);
    final unpaid = report.unpaidFines;
    final paid = report.fines.where((fine) => fine.status == FineStatus.paid).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                MediaQuery.of(context).padding.top + AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.blueDark, AppColors.blueMid],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Fines & penalties', style: AppTextStyles.h1White),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Check unpaid fines before buying or transferring a vehicle.',
                    style: AppTextStyles.body.copyWith(color: AppColors.white60),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _FineHeaderStat(
                          label: 'Unpaid',
                          value: '${unpaid.length}',
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _FineHeaderStat(
                          label: 'Paid',
                          value: '${paid.length}',
                          color: AppColors.tealMuted,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _FineHeaderStat(
                          label: 'Outstanding',
                          value: Formatters.kzt(report.totalOwed),
                          color: AppColors.amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              110,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (unpaid.isNotEmpty)
                  _FineSection(title: 'Unpaid fines', fines: unpaid),
                if (paid.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _FineSection(title: 'Paid fines', fines: paid),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _FineSection extends StatelessWidget {
  final String title;
  final List<FineRecord> fines;

  const _FineSection({required this.title, required this.fines});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.md),
          ...fines.map(
            (fine) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: fine.status == FineStatus.unpaid
                    ? AppColors.danger.withValues(alpha: 0.06)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(
                    fine.status == FineStatus.unpaid
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline_rounded,
                    color: fine.status == FineStatus.unpaid
                        ? AppColors.danger
                        : AppColors.tealMuted,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fine.type,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${Formatters.date(fine.date)} • ${fine.location}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    Formatters.kzt(fine.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: fine.status == FineStatus.unpaid
                          ? AppColors.danger
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FineHeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FineHeaderStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.white60)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
