import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class _Slide {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final String footer;

  const _Slide({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.footer,
  });
}

const _slides = [
  _Slide(
    icon: Icons.layers_outlined,
    eyebrow: 'All car data in one place',
    title: 'Check car history in one app',
    description:
        'Combine registration changes, accident records, service notes, mileage updates, and unpaid fines into a single trusted report.',
    footer: 'Built for Kazakhstan buyers, sellers, and dealerships.',
  ),
  _Slide(
    icon: Icons.gpp_good_outlined,
    eyebrow: 'Reduce used-car risk',
    title: 'Find hidden problems before buying',
    description:
        'Spot accident damage, suspicious mileage gaps, transit plate warnings, and unresolved penalties before money changes hands.',
    footer: 'Privacy first: history is visible, owner identities stay hidden.',
  ),
  _Slide(
    icon: Icons.bolt_outlined,
    eyebrow: 'Fast report generation',
    title: 'Get instant VIN-based reports',
    description:
        'Enter or upload a VIN and get a startup-ready report with a trust score, recommendation, price estimate, and timeline view.',
    footer: 'One app. Every data source. Instant trust.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  var _index = 0;

  void _next() {
    if (_index == _slides.length - 1) {
      context.go('/login');
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '0${_index + 1} / 03',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Skip'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (_, index) {
                    final slide = _slides[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.blueDark,
                                  AppColors.blueMid,
                                  AppColors.blueAccent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.08),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 84,
                                        height: 84,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.16),
                                          ),
                                        ),
                                        child: Icon(
                                          slide.icon,
                                          color: Colors.white,
                                          size: 38,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xl),
                                      Text(
                                        slide.eyebrow.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.white60,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Text(
                                        slide.title,
                                        style: AppTextStyles.h1White,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          slide.description,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            slide.footer,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    margin: const EdgeInsets.only(right: 6),
                    width: index == _index ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _index
                          ? AppColors.blueAccent
                          : AppColors.blueAccent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: _next,
                child: Text(
                  _index == _slides.length - 1 ? 'Get Started' : 'Continue',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
