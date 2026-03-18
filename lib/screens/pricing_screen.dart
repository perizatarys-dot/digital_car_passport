import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_surfaces.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_feedback.dart';
import '../utils/app_preferences.dart';
import '../widgets/common/payment_checkout_sheet.dart';

class _Plan {
  final String title;
  final String price;
  final String description;
  final List<String> bullets;
  final bool featured;
  final String cta;

  const _Plan({
    required this.title,
    required this.price,
    required this.description,
    required this.bullets,
    required this.cta,
    this.featured = false,
  });
}

const _plans = [
  _Plan(
    title: 'Personal Subscription',
    price: '2,000 KZT / month',
    description: 'For private buyers after the one free report is used.',
    bullets: [
      'First report stays free',
      'Open reports after your free limit finishes',
      'Continue checking cars without interruption',
      'Best fit for active buyers',
    ],
    cta: 'Start subscription',
    featured: true,
  ),
  _Plan(
    title: 'Dealership Basic',
    price: '20,000 KZT / month',
    description: 'For used-car dealerships that need daily deal screening.',
    bullets: [
      'Up to 30 full reports',
      'Saved team history',
      'Marketing banner placement',
      'Support for listing platform integrations',
    ],
    cta: 'Start Basic',
  ),
  _Plan(
    title: 'Dealership Pro',
    price: '50,000 KZT / month',
    description: 'For high-volume sellers, banks, insurers, and service networks.',
    bullets: [
      'Unlimited reports',
      'B2B API option',
      'Priority onboarding',
      'Business dashboard and partner support',
    ],
    cta: 'Contact sales',
  ),
];

class PricingScreen extends ConsumerWidget {
  const PricingScreen({super.key});

  void _handlePlan(BuildContext context, WidgetRef ref, String title) {
    if (title == 'Personal Subscription') {
      showPaymentCheckoutSheet(
        context,
        title: 'Start subscription',
        amountLabel: '2,000 ₸ / month',
        description:
            'Choose a payment method to continue opening reports after your first free report.',
        ctaLabel: 'Start for 2,000 ₸',
        onSuccess: () {
          ref.read(reportAccessProvider.notifier).activateSubscription();
          AppFeedback.showMessage(
            context,
            'Subscription activated. Reports are now unlocked.',
          );
        },
      );
      return;
    }

    if (title == 'Dealership Basic') {
      showPaymentCheckoutSheet(
        context,
        title: 'Start Dealership Basic',
        amountLabel: '20,000 ₸ / month',
        description:
            'Select a bank and enter your card details to activate the monthly dealership subscription.',
        ctaLabel: 'Start for 20,000 ₸',
        onSuccess: () {
          AppFeedback.showMessage(
            context,
            'Dealership Basic activated in the MVP mock.',
          );
        },
      );
      return;
    }

    context.push('/b2b');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAccess = ref.watch(reportAccessProvider);

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
                  Text('Pricing & payments', style: AppTextStyles.h1White),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Clean pricing for individual buyers, dealerships, banks, insurers, and partner platforms.',
                    style: AppTextStyles.body.copyWith(color: AppColors.white60),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      reportAccess.hasSubscription
                          ? 'Subscription status: active'
                          : 'Reports: first one free, then subscription required',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
              40,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ..._plans.map(
                  (plan) => Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: context.appCardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: plan.featured
                            ? AppColors.blueAccent
                            : context.appBorderColor,
                        width: plan.featured ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (plan.featured)
                          Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.blueAccent.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'MOST POPULAR',
                              style: TextStyle(
                                color: AppColors.blueAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        Text(
                          plan.title,
                          style: AppTextStyles.h4.copyWith(
                            color: context.appPrimaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          plan.price,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          plan.description,
                          style: TextStyle(
                            color: context.appSecondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...plan.bullets.map(
                          (bullet) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 18,
                                  color: AppColors.tealMuted,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    bullet,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.appPrimaryTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton(
                          onPressed: () => _handlePlan(context, ref, plan.title),
                          child: Text(plan.cta),
                        ),
                      ],
                    ),
                  ),
                ),
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
                        'B2B API for banks and insurance',
                        style: AppTextStyles.h4.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Use Digital Car Passport inside credit scoring, underwriting, claims, and car listing workflows.',
                        style: TextStyle(
                          color: AppColors.white60,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton(
                        onPressed: () => context.push('/b2b'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.white15),
                        ),
                        child: const Text('Request B2B demo'),
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
