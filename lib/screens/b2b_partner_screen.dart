import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_feedback.dart';

class B2BPartnerScreen extends StatelessWidget {
  const B2BPartnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final segments = [
      (
        'Car dealerships',
        'Screen trade-ins faster and attach trust summaries to listings.',
        Icons.directions_car_outlined,
        AppColors.blueAccent,
      ),
      (
        'Banks and lenders',
        'Use vehicle history to support safer loan and collateral decisions.',
        Icons.account_balance_outlined,
        AppColors.tealMuted,
      ),
      (
        'Insurance companies',
        'Review claims, damage patterns, and risk factors in one place.',
        Icons.shield_outlined,
        AppColors.amber,
      ),
      (
        'Service centers',
        'Add inspection and maintenance proof to future resale histories.',
        Icons.build_circle_outlined,
        AppColors.blueGlow,
      ),
    ];

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
                  Text('B2B & partner program', style: AppTextStyles.h1White),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Make the Kazakhstan used-car market safer with trust data inside finance, listings, insurance, and service workflows.',
                    style: AppTextStyles.body.copyWith(color: AppColors.white60),
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
              40,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Who we serve', style: AppTextStyles.h4),
                      const SizedBox(height: AppSpacing.md),
                      ...segments.map(
                        (segment) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: segment.$4.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(segment.$3, color: segment.$4),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      segment.$1,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      segment.$2,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.blueMid,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API and demo access',
                        style: AppTextStyles.h4.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Production-style mock features: REST API, listing platform integration, dashboard onboarding, and business analytics.',
                        style: TextStyle(
                          color: AppColors.white60,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () => AppFeedback.showMessage(
                          context,
                          'Partner demo request submitted in the MVP mock.',
                        ),
                        child: const Text('Request API demo'),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
