import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/car_report.dart';
import '../services/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';

class PriceEstimateScreen extends StatelessWidget {
  final String vin;

  const PriceEstimateScreen({super.key, required this.vin});

  @override
  Widget build(BuildContext context) {
    final report = MockData.reportForVin(vin);
    final market = report.marketPrice;
    final label = _priceLabel(market.label);
    final widthFactor = (market.estimated - market.rangeMin) /
        (market.rangeMax - market.rangeMin);

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
                  Text('Fair market value', style: AppTextStyles.h1White),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${report.vehicle.brand} ${report.vehicle.model} ${report.vehicle.year}',
                    style: AppTextStyles.body.copyWith(color: AppColors.white60),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Formatters.kzt(market.estimated),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Estimated sale price today',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: label.$2.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            label.$1,
                            style: TextStyle(
                              color: label.$2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
                _PriceCard(
                  title: 'Price range',
                  subtitle: 'This car compared with similar Kazakhstan listings',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.surface2,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: widthFactor.clamp(0.0, 1.0),
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.teal, AppColors.blueAccent],
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _RangeStat('Range low', Formatters.kzt(market.rangeMin)),
                          _RangeStat('This car', Formatters.kzt(market.estimated)),
                          _RangeStat('Range high', Formatters.kzt(market.rangeMax)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _PriceCard(
                  title: 'Market comparison',
                  subtitle: 'Use this before negotiating with the seller',
                  child: Column(
                    children: [
                      _PriceMeter(
                        label: 'This car',
                        value: market.estimated,
                        max: market.rangeMax,
                        color: AppColors.blueAccent,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _PriceMeter(
                        label: 'Market average',
                        value: market.marketAverage,
                        max: market.rangeMax,
                        color: AppColors.tealMuted,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          'This listing is ${Formatters.kzt(market.savingAmount)} below the market average. Keep the discount only if the seller resolves fines and explains the accident history.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _PriceCard(
                  title: 'Value factors',
                  subtitle: 'What pushes the valuation up or down',
                  child: Column(
                    children: market.factors
                        .map(
                          (factor) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    factor.label,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Text(
                                  factor.impact,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: factor.positive
                                        ? AppColors.tealMuted
                                        : AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
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

class _PriceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _PriceCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

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
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _RangeStat extends StatelessWidget {
  final String label;
  final String value;

  const _RangeStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _PriceMeter extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;

  const _PriceMeter({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: value / max,
              backgroundColor: AppColors.surface2,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          Formatters.kztMillions(value),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

(String, Color) _priceLabel(PriceLabel label) {
  switch (label) {
    case PriceLabel.belowMarket:
      return ('Below market', AppColors.tealMuted);
    case PriceLabel.fair:
      return ('Fair price', AppColors.blueAccent);
    case PriceLabel.overpriced:
      return ('Overpriced', AppColors.danger);
  }
}
