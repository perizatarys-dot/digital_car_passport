import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../services/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_surfaces.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_language.dart';
import '../utils/app_preferences.dart';
import '../widgets/common/app_user_avatar.dart';
import '../widgets/common/score_pill.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authStateChangesProvider).valueOrNull;
    final accountGarage = ref.watch(accountGarageProvider);
    final report = accountGarage.searchHistory.isNotEmpty
        ? MockData.reportForVin(accountGarage.searchHistory.first)
        : MockData.sampleReport;
    final language = ref.watch(appLanguageProvider);
    final reportAccess = ref.watch(reportAccessProvider);

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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.appTitle(language),
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.white60,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.dashboardHeadline(language),
                              style: AppTextStyles.h2White,
                            ),
                          ],
                        ),
                      ),
                      AppUserAvatar(
                        radius: 24,
                        user: authUser,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? AppColors.teal.withValues(alpha: 0.14)
                          : AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.isDarkMode
                            ? AppColors.teal.withValues(alpha: 0.30)
                            : AppColors.teal.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Best next step',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Start with a full VIN report before opening deeper checks. The first report is free.',
                                style: TextStyle(
                                  color: AppColors.white60,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GestureDetector(
                    onTap: () => context.push('/vin-search'),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.appOverlayStrongColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: context.isDarkMode
                              ? Colors.white.withValues(alpha: 0.08)
                              : AppColors.white15,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enter or upload VIN',
                                  style: AppTextStyles.bodySemibold.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Scan documents or paste the 17-character VIN',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _HeroStat(
                          label: 'Last report',
                          value: '${report.trustScore}/100',
                          caption: 'Trust score',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _HeroStat(
                          label: 'Report access',
                          value: reportAccess.hasSubscription
                              ? 'Subscribed'
                              : '${reportAccess.remainingFreeReports} free',
                          caption: reportAccess.hasSubscription
                              ? 'Reports unlocked'
                              : 'Then subscription',
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
                _SectionTitle(
                  title: AppStrings.quickActions(language),
                  subtitle: 'Secondary tools after the main VIN report',
                ),
                const SizedBox(height: AppSpacing.md),
                _QuickActionGrid(),
                const SizedBox(height: AppSpacing.lg),
                _PremiumBanner(),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(
                  title: AppStrings.recentSearches(language),
                  subtitle: 'Jump back into the cars you checked recently',
                ),
                const SizedBox(height: AppSpacing.md),
                ...MockData.recentSearches
                    .map((item) => _RecentSearchCard(item)),
                const SizedBox(height: AppSpacing.lg),
                const _SectionTitle(
                  title: 'Growth & Partnerships',
                  subtitle:
                      'Referral rewards, partner plans, and automotive media',
                ),
                const SizedBox(height: AppSpacing.md),
                _MarketingStrip(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final String caption;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.caption,
  });

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
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.white60),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            caption,
            style: const TextStyle(fontSize: 11, color: AppColors.white40),
          ),
        ],
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Accident Check',
        'Crash and claims history',
        Icons.car_crash_outlined,
        AppColors.danger,
        '/report/${MockData.sampleVin}'
      ),
      (
        'Mileage Check',
        'Timeline and consistency',
        Icons.speed_outlined,
        AppColors.blueAccent,
        '/history/${MockData.sampleVin}'
      ),
      (
        'Fines Check',
        'Unpaid penalties before purchase',
        Icons.receipt_long_outlined,
        AppColors.amber,
        '/fines/${MockData.sampleVin}'
      ),
      (
        'Price Estimate',
        'Market value and price range',
        Icons.sell_outlined,
        AppColors.tealMuted,
        '/price/${MockData.sampleVin}'
      ),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        return InkWell(
          onTap: () => context.push(item.$5),
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.appCardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.appBorderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: item.$4.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.$3, color: item.$4),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  item.$1,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.appPrimaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.$2,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.appSecondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/pricing'),
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.blueMid, AppColors.blueAccent],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Premium reports and dealership plans',
                    style: AppTextStyles.h4.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Per-report fee from 2,000 KZT. Monthly plans for dealerships, banks, and insurers.',
                    style: TextStyle(
                      color: AppColors.white60,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: context.appCardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'View Plans',
                style: TextStyle(
                  color: AppColors.blueAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSearchCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _RecentSearchCard(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => context.push('/report/${item['vin']}'),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.appCardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.appBorderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: context.appCardAltColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.directions_car_filled_outlined,
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
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.appPrimaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['vin'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.appHintTextColor,
                        fontFamily: 'Courier',
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

class _MarketingStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        'Invite friends',
        'Get free checks when your referral joins.',
        Icons.people_alt_outlined,
        AppColors.tealMuted,
      ),
      (
        'Car blogger banner',
        'Feature your review with a trusted report badge.',
        Icons.campaign_outlined,
        AppColors.amber,
      ),
      (
        'Listing platform API',
        'Bring trust scores into car marketplace listings.',
        Icons.api_rounded,
        AppColors.blueAccent,
      ),
    ];

    return SizedBox(
      height: 156,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, index) {
          final card = cards[index];
          return Container(
            width: 220,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.appCardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.appBorderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: card.$4.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(card.$3, color: card.$4),
                ),
                const Spacer(),
                Text(
                  card.$1,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.appPrimaryTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  card.$2,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.appSecondaryTextColor,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h4),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: context.appSecondaryTextColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
