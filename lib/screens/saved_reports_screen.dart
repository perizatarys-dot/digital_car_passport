import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_surfaces.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_feedback.dart';
import '../utils/app_preferences.dart';
import '../widgets/common/score_pill.dart';

class SavedReportsScreen extends ConsumerWidget {
  const SavedReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedReports = ref.watch(accountGarageProvider).savedReports;

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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: context.isDarkMode
                      ? const [
                          Color(0xFF08111F),
                          Color(0xFF10203A),
                          Color(0xFF16345B),
                        ]
                      : const [AppColors.blueDark, AppColors.blueMid],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saved reports', style: AppTextStyles.h1White),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${savedReports.length} reports saved for this account',
                    style:
                        AppTextStyles.body.copyWith(color: AppColors.white60),
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
            sliver: savedReports.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bookmark_outline_rounded,
                            size: 58,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text('No saved reports yet', style: AppTextStyles.h4),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Search a VIN and save the report to reopen it later.',
                            style: AppTextStyles.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: () => context.push('/vin-search'),
                            child: const Text('Search a VIN'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList.builder(
                    itemCount: savedReports.length,
                    itemBuilder: (_, index) {
                      final report = savedReports[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: context.appCardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: context.appBorderColor),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () =>
                                  context.push('/report/${report.vin}'),
                              borderRadius: BorderRadius.circular(18),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: context.appCardAltColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.directions_car_filled_outlined,
                                      color: AppColors.blueAccent,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${report.brand} ${report.model} ${report.year}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: context.appPrimaryTextColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          report.vin,
                                          style: TextStyle(
                                            fontFamily: 'Courier',
                                            fontSize: 11,
                                            color: context.appHintTextColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Saved ${report.savedAt}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color:
                                                context.appSecondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ScorePill(status: report.status),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${report.trustScore}/100',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: context.appPrimaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      await ref
                                          .read(accountGarageProvider.notifier)
                                          .removeSavedReport(report.vin);
                                      if (!context.mounted) {
                                        return;
                                      }
                                      AppFeedback.showMessage(
                                        context,
                                        '${report.brand} ${report.model} removed from saved reports.',
                                      );
                                    },
                                    child: const Text('Remove'),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        context.push('/report/${report.vin}'),
                                    child: const Text('Open report'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
