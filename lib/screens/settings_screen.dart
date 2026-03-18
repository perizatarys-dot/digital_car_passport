import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_surfaces.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_language.dart';
import '../utils/app_feedback.dart';
import '../utils/app_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;
  bool _privacy = true;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final themeMode = ref.watch(appThemeModeProvider);
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
                  Text(AppStrings.settings(language), style: AppTextStyles.h1White),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppStrings.settingsSubtitle(language),
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
                _SettingsCard(
                  title: AppStrings.language(language),
                  child: Column(
                    children: AppLanguage.values
                        .map(
                          (item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            onTap: () => ref.read(appLanguageProvider.notifier).state = item,
                            title: Text(item.label),
                            trailing: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: language == item
                                    ? AppColors.blueAccent
                                    : Colors.transparent,
                                border: Border.all(
                                  color: language == item
                                      ? AppColors.blueAccent
                                      : AppColors.borderMid,
                                ),
                              ),
                              child: language == item
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsCard(
                  title: AppStrings.preferences(language),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _notifications,
                        onChanged: (value) => setState(() => _notifications = value),
                        title: Text(AppStrings.pushNotifications(language)),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _privacy,
                        onChanged: (value) => setState(() => _privacy = value),
                        title: Text(AppStrings.privacyFirstMasking(language)),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: themeMode == ThemeMode.dark,
                        onChanged: (value) {
                          ref.read(appThemeModeProvider.notifier).state =
                              value ? ThemeMode.dark : ThemeMode.light;
                          AppFeedback.showMessage(
                            context,
                            value
                                ? 'Dark mode enabled.'
                                : 'Light mode enabled.',
                          );
                        },
                        title: Text(AppStrings.darkMode(language)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsCard(
                  title: AppStrings.supportAndLegal(language),
                  child: Column(
                    children: [
                      _SettingsLink(
                        label: AppStrings.helpCenter(language),
                        onTap: () => AppFeedback.showMessage(
                          context,
                          'Help center opened in the MVP mock.',
                        ),
                      ),
                      _SettingsLink(
                        label: AppStrings.faq(language),
                        onTap: () => AppFeedback.showMessage(
                          context,
                          'FAQ opened in the MVP mock.',
                        ),
                      ),
                      _SettingsLink(
                        label: AppStrings.terms(language),
                        onTap: () => AppFeedback.showMessage(
                          context,
                          'Terms and conditions opened in the MVP mock.',
                        ),
                      ),
                      _SettingsLink(
                        label: AppStrings.privacyPolicy(language),
                        onTap: () => AppFeedback.showMessage(
                          context,
                          'Privacy policy opened in the MVP mock.',
                        ),
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

class _SettingsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsCard({required this.title, required this.child});

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
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _SettingsLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SettingsLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
