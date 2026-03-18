import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/car_report.dart';
import '../services/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_feedback.dart';
import '../widgets/common/payment_checkout_sheet.dart';
import '../utils/formatters.dart';
import '../utils/app_preferences.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final String vin;

  const HistoryScreen({super.key, required this.vin});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  var _checkingAccess = true;
  var _hasAccess = false;
  var _usedFreeAccess = false;
  var _usedPaidAccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tryUnlockAccess();
    });
  }

  void _tryUnlockAccess() {
    final accessState = ref.read(historyAccessProvider);
    final usedFreeAccess = accessState.hasFreeHistoryCheckRemaining;
    final usedPaidAccess =
        !accessState.hasFreeHistoryCheckRemaining &&
        accessState.hasPaidHistoryCheckRemaining;
    final hasAccess =
        ref.read(historyAccessProvider.notifier).unlockHistoryAccess();

    if (!mounted) return;

    setState(() {
      _usedFreeAccess = usedFreeAccess;
      _usedPaidAccess = usedPaidAccess;
      _hasAccess = hasAccess;
      _checkingAccess = false;
    });
  }

  void _payForHistoryAccess() {
    showPaymentCheckoutSheet(
      context,
      title: 'Unlock history check',
      amountLabel: '2,000 ₸',
      description:
          'Your first history check is free. Pay 2,000 ₸ to open this next history timeline.',
      ctaLabel: 'Pay 2,000 ₸',
      onSuccess: () {
        ref.read(historyAccessProvider.notifier).purchaseHistoryAccess();
        if (!mounted) return;
        setState(() {
          _tryUnlockAccess();
        });
        AppFeedback.showMessage(
          context,
          'Payment confirmed. This history check is now unlocked.',
        );
      },
    );
  }

  List<_Event> _events(CarReport report) {
    return [
      ...report.owners.map(
        (owner) => _Event(
          date: owner.periodFrom,
          title: 'Registration changed',
          subtitle: '${owner.ownershipType} • owner #${owner.order}',
          color: AppColors.blueAccent,
        ),
      ),
      ...report.mileageHistory.map(
        (record) => _Event(
          date: '${record.year}-01-01',
          title: 'Mileage update',
          subtitle: '${Formatters.km(record.mileage)} • ${record.source}',
          color: AppColors.tealMuted,
        ),
      ),
      ...report.accidents.map(
        (accident) => _Event(
          date: accident.date,
          title: 'Accident record',
          subtitle: '${accident.city} • ${accident.description}',
          color: AppColors.amber,
        ),
      ),
      ...report.serviceHistory.map(
        (service) => _Event(
          date: service.date,
          title: 'Service event',
          subtitle: '${service.title} • ${service.provider}',
          color: AppColors.blueGlow,
        ),
      ),
    ]..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Widget build(BuildContext context) {
    final accessState = ref.watch(historyAccessProvider);

    if (_checkingAccess) {
      return const Scaffold(
        backgroundColor: AppColors.blueDark,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.teal,
            strokeWidth: 4,
          ),
        ),
      );
    }

    if (!_hasAccess) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surface2,
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.blueAccent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_outlined,
                          color: AppColors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Payment required', style: AppTextStyles.h3),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Your first history timeline check is free. After that, you need to pay 2,000 ₸ each time you open another car history timeline.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        accessState.hasFreeHistoryCheckRemaining
                            ? 'Free history checks left: ${accessState.remainingFreeHistoryChecks}'
                            : 'Paid history checks available: ${accessState.paidHistoryChecks}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _payForHistoryAccess,
                          child: const Text('Pay 2,000 ₸'),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    final report = MockData.reportForVin(widget.vin);
    final events = _events(report);

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
                  Text('History timeline', style: AppTextStyles.h1White),
                  const SizedBox(height: AppSpacing.sm),
                  if (_usedFreeAccess) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'First history check unlocked for free',
                        style: TextStyle(
                          color: AppColors.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  if (_usedPaidAccess) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blueAccent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Paid history check unlocked',
                        style: TextStyle(
                          color: AppColors.blueAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  Text(
                    '${report.vehicle.brand} ${report.vehicle.model} • ${events.length} timeline events',
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
              110,
            ),
            sliver: SliverList.builder(
              itemCount: events.length,
              itemBuilder: (_, index) {
                final event = events[index];
                final isLast = index == events.length - 1;
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 28,
                        child: Column(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: event.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: AppColors.borderMid,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Formatters.date(event.date), style: AppTextStyles.caption),
                              const SizedBox(height: 4),
                              Text(
                                event.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.subtitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
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

class _Event {
  final String date;
  final String title;
  final String subtitle;
  final Color color;

  const _Event({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
