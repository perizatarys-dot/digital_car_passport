import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/car_report.dart';
import '../services/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_surfaces.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_preferences.dart';
import '../widgets/common/score_pill.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountGarage = ref.watch(accountGarageProvider);
    final recentReports =
        accountGarage.searchHistory.map(MockData.reportForVin).toList();
    final report =
        recentReports.isNotEmpty ? recentReports.first : MockData.sampleReport;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                MediaQuery.of(context).padding.top + AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.blueDark, AppColors.blueMid],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reports Hub', style: AppTextStyles.h1White),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Open full reports, review key risk signals, and continue where you left off.',
                    style:
                        AppTextStyles.body.copyWith(color: AppColors.white60),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: context.appOverlayColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: context.isDarkMode
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.white15,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Latest report',
                          style: TextStyle(
                            color: AppColors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${report.vehicle.brand} ${report.vehicle.model} ${report.vehicle.year}',
                          style: AppTextStyles.h3White,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.vehicle.vin,
                          style: const TextStyle(
                            color: AppColors.white40,
                            fontSize: 11,
                            fontFamily: 'Courier',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _HeroBadge(
                                label: 'Trust score',
                                value: '${report.trustScore}/100',
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _HeroBadge(
                                label: 'Open fines',
                                value: '${report.unpaidFines.length}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton(
                          onPressed: () =>
                              context.push('/report/${report.vehicle.vin}'),
                          child: const Text('Open full report'),
                        ),
                      ],
                    ),
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
                Text('Recent reports', style: AppTextStyles.h4),
                const SizedBox(height: AppSpacing.sm),
                if (recentReports.isEmpty)
                  ...MockData.recentSearches
                      .map((item) => _ReportRow(item: item))
                else
                  ...recentReports
                      .map((item) => _ReportRow.fromReport(report: item)),
                const SizedBox(height: AppSpacing.lg),
                Text('Shortcuts', style: AppTextStyles.h4),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _ShortcutCard(
                        title: 'History',
                        icon: Icons.timeline_outlined,
                        onTap: () =>
                            context.push('/history/${report.vehicle.vin}'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _ShortcutCard(
                        title: 'Price',
                        icon: Icons.sell_outlined,
                        onTap: () =>
                            context.push('/price/${report.vehicle.vin}'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _ShortcutCard(
                        title: 'Fines',
                        icon: Icons.receipt_long_outlined,
                        onTap: () =>
                            context.push('/fines/${report.vehicle.vin}'),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ReportRow({required this.item});

  factory _ReportRow.fromReport({required CarReport report}) {
    final subtitle = report.unpaidFines.isEmpty
        ? '${report.accidents.length} accidents'
        : '${report.accidents.length} accidents · ${report.unpaidFines.length} unpaid fines';
    return _ReportRow(
      item: {
        'vin': report.vehicle.vin,
        'brand': report.vehicle.brand,
        'model': report.vehicle.model,
        'year': report.vehicle.year,
        'status': report.recommendation.name,
        'subtitle': subtitle,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => context.push('/report/${item['vin']}'),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.appCardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.appBorderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.blueAccent,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item['brand']} ${item['model']} ${item['year']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.appSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ScorePill(status: item['status'] as String),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.appCardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.appBorderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.blueAccent),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final String label;
  final String value;

  const _HeroBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appOverlayColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.white15,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.white60)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
