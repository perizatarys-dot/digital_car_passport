import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/car_report.dart';
import '../services/car_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_surfaces.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_feedback.dart';
import '../utils/app_preferences.dart';
import '../utils/formatters.dart';
import '../widgets/common/payment_checkout_sheet.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final String vin;

  const ReportScreen({super.key, required this.vin});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  CarReport? _report;
  var _loading = true;
  var _checkingAccess = true;
  var _hasAccess = false;
  var _usedFreeAccess = false;

  static const _labels = [
    'Overview',
    'Accidents',
    'Mileage',
    'Owners',
    'Fines',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _labels.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeReportAccess();
    });
  }

  Future<void> _initializeReportAccess() async {
    final accessState = ref.read(reportAccessProvider);
    final usedFreeAccess = accessState.hasFreeReportRemaining;
    final hasAccess = ref.read(reportAccessProvider.notifier).unlockReport();

    if (!mounted) return;

    setState(() {
      _usedFreeAccess = usedFreeAccess;
      _hasAccess = hasAccess;
      _checkingAccess = false;
      _loading = hasAccess;
    });

    if (hasAccess) {
      await _load();
    }
  }

  Future<void> _load() async {
    final report = await CarService.getReport(widget.vin);
    await ref.read(accountGarageProvider.notifier).addSearchHistory(widget.vin);
    if (!mounted) return;
    setState(() {
      _report = report;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _toggleSave(CarReport report, bool isSaved) async {
    await ref.read(accountGarageProvider.notifier).toggleSavedReport(report);
    if (!mounted) return;
    AppFeedback.showMessage(
      context,
      isSaved ? 'Report removed from saved.' : 'Report saved for later.',
    );
  }

  void _share() {
    AppFeedback.showMessage(
      context,
      'Secure share link generated for this report.',
    );
  }

  void _showPaymentMock() {
    showPaymentCheckoutSheet(
      context,
      title: 'Secure payment mockup',
      amountLabel: '2,000 ₸',
      description:
          'Choose a Kazakhstan bank or manual card entry before paying for a premium report PDF.',
      ctaLabel: 'Pay 2,000 ₸',
      onSuccess: () {
        AppFeedback.showMessage(
          context,
          'Payment confirmed in the MVP mock.',
        );
      },
    );
  }

  void _payForReportAccess() {
    context.push('/pricing');
  }

  @override
  Widget build(BuildContext context) {
    final accessState = ref.watch(reportAccessProvider);

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
                      Text('Your limit is finished', style: AppTextStyles.h3),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'You can open one report for free. From the second report, you need a subscription to continue.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        accessState.hasSubscription
                            ? 'Subscription is active.'
                            : 'Free reports left: ${accessState.remainingFreeReports}',
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
                          onPressed: _payForReportAccess,
                          child: const Text('Go to subscription'),
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

    if (_loading || _report == null) {
      return Scaffold(
        backgroundColor: AppColors.blueDark,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 74,
                height: 74,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.blueLight.withValues(alpha: 0.3),
                      strokeWidth: 6,
                      value: 1,
                    ),
                    const CircularProgressIndicator(
                      color: AppColors.teal,
                      strokeWidth: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Generating report', style: AppTextStyles.h3White),
              const SizedBox(height: 6),
              Text(
                'Checking claims, fines, mileage, registration, and market sources...',
                style: AppTextStyles.body.copyWith(color: AppColors.white60),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final report = _report!;
    final isSaved =
        ref.watch(accountGarageProvider).isSaved(report.vehicle.vin);
    final vehicle = report.vehicle;
    final recommendation = _recommendationConfig(report.recommendation);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                MediaQuery.of(context).padding.top + AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
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
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _share,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                        ),
                        icon: const Icon(Icons.share_outlined,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _toggleSave(report, isSaved),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                        ),
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_usedFreeAccess) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'First report unlocked for free',
                        style: TextStyle(
                          color: AppColors.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  Text(
                    '${vehicle.brand} ${vehicle.model}',
                    style: AppTextStyles.h1White.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicle.year} • ${vehicle.bodyType} • ${vehicle.engineVolume} ${vehicle.engineType}',
                    style:
                        const TextStyle(color: AppColors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.vin,
                    style: const TextStyle(
                      color: AppColors.white40,
                      fontSize: 11,
                      fontFamily: 'Courier',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _HeaderStat(
                          label: 'Trust score',
                          value: '${report.trustScore}',
                          caption: Formatters.trustLabel(report.trustScore),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _HeaderStat(
                          label: 'Market value',
                          value: Formatters.kztMillions(
                              report.marketPrice.estimated),
                          caption: 'Estimated today',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _HeaderStat(
                          label: 'Unpaid fines',
                          value: '${report.unpaidFines.length}',
                          caption: 'Resolve before purchase',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ActionChip(
                          text: 'Price estimate',
                          icon: Icons.sell_outlined,
                          onTap: () => context.push('/price/${widget.vin}'),
                        ),
                        _ActionChip(
                          text: 'Fines check',
                          icon: Icons.receipt_long_outlined,
                          onTap: () => context.push('/fines/${widget.vin}'),
                        ),
                        _ActionChip(
                          text: 'Timeline',
                          icon: Icons.timeline_outlined,
                          onTap: () => context.push('/history/${widget.vin}'),
                        ),
                        _ActionChip(
                          text: 'Pay for PDF',
                          icon: Icons.lock_open_outlined,
                          onTap: _showPaymentMock,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SummarySignal(
                        label: 'Accidents',
                        value: '${report.accidents.length}',
                        tone: report.accidents.isEmpty
                            ? AppColors.tealMuted
                            : AppColors.amber,
                      ),
                      const _SummarySignal(
                        label: 'Mileage',
                        value: 'Consistent',
                        tone: AppColors.tealMuted,
                      ),
                      _SummarySignal(
                        label: 'Fines',
                        value: report.unpaidFines.isEmpty
                            ? 'Clear'
                            : '${report.unpaidFines.length} open',
                        tone: report.unpaidFines.isEmpty
                            ? AppColors.tealMuted
                            : AppColors.danger,
                      ),
                      _SummarySignal(
                        label: 'Transit',
                        value: report.transitPlateWarning ? 'Check' : 'Clear',
                        tone: report.transitPlateWarning
                            ? AppColors.amber
                            : AppColors.tealMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: recommendation.$2.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: recommendation.$2.withValues(alpha: 0.26),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(recommendation.$3,
                            color: recommendation.$2, size: 22),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recommendation.$1,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: recommendation.$2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                report.recommendationText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ColoredBox(
              color: AppColors.blueMid,
              child: TabBar(
                controller: _tabs,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.white50,
                indicatorColor: AppColors.teal,
                tabs: _labels.map((label) => Tab(text: label)).toList(),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _OverviewTab(report),
            _AccidentsTab(report),
            _MileageTab(report),
            _OwnersTab(report),
            _FinesTab(report),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final CarReport report;

  const _OverviewTab(this.report);

  @override
  Widget build(BuildContext context) {
    final vehicle = report.vehicle;
    final specs = [
      ('Brand', vehicle.brand),
      ('Model', vehicle.model),
      ('Year', '${vehicle.year}'),
      ('Body', vehicle.bodyType),
      ('Engine', '${vehicle.engineVolume} ${vehicle.engineType}'),
      ('Transmission', vehicle.transmission),
      ('Drive', vehicle.drivetrain),
      ('Region', vehicle.registrationRegion),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        120,
      ),
      children: [
        _SurfaceCard(
          title: 'Vehicle details',
          subtitle:
              'Privacy-first report with visible history and hidden identities',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: specs
                .map(
                  (item) => SizedBox(
                    width: (MediaQuery.of(context).size.width - 58) / 2,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.appCardAltColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.$2,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SurfaceCard(
          title: 'Warnings and signals',
          subtitle: 'Fast risk summary before you review the full timeline',
          child: Column(
            children: [
              _SignalRow(
                icon: Icons.error_outline_rounded,
                title: 'Transit plate warning',
                body: report.transitPlateNote,
                color: report.transitPlateWarning
                    ? AppColors.amber
                    : AppColors.tealMuted,
              ),
              const SizedBox(height: AppSpacing.sm),
              _SignalRow(
                icon: Icons.gpp_good_outlined,
                title: 'Theft and wanted vehicle check',
                body: report.stolenCheckClear
                    ? 'No stolen or wanted vehicle match found in the mock registry.'
                    : 'Potential wanted vehicle match found.',
                color: report.stolenCheckClear
                    ? AppColors.tealMuted
                    : AppColors.danger,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SurfaceCard(
          title: 'Recommendation',
          subtitle: 'What we would tell a buyer before making an offer',
          child: Text(
            report.recommendationText,
            style: AppTextStyles.body
                .copyWith(color: context.appSecondaryTextColor),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SurfaceCard(
          title: 'Source confidence',
          subtitle: 'How this report was assembled',
          child: Text(
            report.sourceSummary,
            style: AppTextStyles.body
                .copyWith(color: context.appSecondaryTextColor),
          ),
        ),
      ],
    );
  }
}

class _AccidentsTab extends StatelessWidget {
  final CarReport report;

  const _AccidentsTab(this.report);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _SurfaceCard(
          title: 'Accident history',
          subtitle: '${report.accidents.length} records found',
          child: Column(
            children: report.accidents
                .map(
                  (accident) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _TimelineCard(
                      color: accident.severity == AccidentSeverity.minor
                          ? AppColors.amber
                          : AppColors.danger,
                      date: Formatters.date(accident.date),
                      title: accident.description,
                      subtitle:
                          '${accident.city} • Airbags ${accident.airbagsDeployed ? "deployed" : "not deployed"} • ${accident.repaired ? "repaired" : "pending repair"}',
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _MileageTab extends StatelessWidget {
  final CarReport report;

  const _MileageTab(this.report);

  @override
  Widget build(BuildContext context) {
    final maxMileage = report.mileageHistory
        .map((record) => record.mileage)
        .reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _SurfaceCard(
          title: 'Mileage timeline',
          subtitle: 'Consistent growth helps reduce odometer fraud risk',
          child: Column(
            children: report.mileageHistory
                .map(
                  (record) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 44,
                              child: Text(
                                '${record.year}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: context.appSecondaryTextColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  minHeight: 10,
                                  value: record.mileage / maxMileage,
                                  backgroundColor: context.appCardAltColor,
                                  valueColor: const AlwaysStoppedAnimation(
                                    AppColors.blueAccent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              Formatters.km(record.mileage),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 44),
                            child: Text(
                              record.source,
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SurfaceCard(
          title: 'Service history',
          subtitle: 'Maintenance records strengthen report confidence',
          child: Column(
            children: report.serviceHistory
                .map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _TimelineCard(
                      color: AppColors.tealMuted,
                      date: Formatters.date(event.date),
                      title: event.title,
                      subtitle:
                          '${event.provider} • ${Formatters.km(event.mileage)}',
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _OwnersTab extends StatelessWidget {
  final CarReport report;

  const _OwnersTab(this.report);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _SurfaceCard(
          title: 'Owner history',
          subtitle:
              'Ownership periods are visible while identities stay private',
          child: Column(
            children: report.owners
                .map(
                  (owner) => Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.appCardAltColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.blueAccent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              '#${owner.order}',
                              style: const TextStyle(
                                color: AppColors.blueAccent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                owner.ownershipType,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${owner.periodFrom} → ${owner.periodTo} • ${owner.durationYears} years',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.appSecondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blueAccent.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Identity hidden',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blueAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _FinesTab extends StatelessWidget {
  final CarReport report;

  const _FinesTab(this.report);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _SurfaceCard(
          title: 'Fines and unpaid penalties',
          subtitle: 'Resolve unpaid records before purchase or transfer',
          child: Column(
            children: report.fines
                .map(
                  (fine) => Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: fine.status == FineStatus.unpaid
                          ? AppColors.danger.withValues(alpha: 0.06)
                          : context.appCardAltColor,
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
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.appSecondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formatters.kzt(fine.amount),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: fine.status == FineStatus.unpaid
                                    ? AppColors.danger
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              fine.status == FineStatus.unpaid
                                  ? 'Unpaid'
                                  : 'Paid',
                              style: TextStyle(
                                fontSize: 11,
                                color: fine.status == FineStatus.unpaid
                                    ? AppColors.danger
                                    : AppColors.tealMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SurfaceCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appCardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.appBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style:
                TextStyle(fontSize: 12, color: context.appSecondaryTextColor),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Color color;
  final String date;
  final String title;
  final String subtitle;

  const _TimelineCard({
    required this.color,
    required this.date,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.appCardAltColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appSecondaryTextColor,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SignalRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _SignalRow({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appSecondaryTextColor,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final String caption;

  const _HeaderStat({
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
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.white60)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(caption,
              style: const TextStyle(fontSize: 11, color: AppColors.white40)),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionChip({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        context.isDarkMode ? Colors.white : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        onPressed: onTap,
        backgroundColor: context.isDarkMode
            ? context.appCardAltColor
            : context.appOverlayStrongColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(
            color:
                context.isDarkMode ? context.appBorderColor : AppColors.white15,
          ),
        ),
        avatar: Icon(icon, size: 16, color: foregroundColor),
        label: Text(
          text,
          style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SummarySignal extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;

  const _SummarySignal({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.appOverlayColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: tone,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

(String, Color, IconData) _recommendationConfig(RecommendationLevel level) {
  switch (level) {
    case RecommendationLevel.safe:
      return ('Safe to consider', AppColors.tealMuted, Icons.verified_outlined);
    case RecommendationLevel.caution:
      return ('Check carefully', AppColors.amber, Icons.fact_check_outlined);
    case RecommendationLevel.risk:
      return (
        'High risk',
        AppColors.danger,
        Icons.report_gmailerrorred_rounded
      );
  }
}
