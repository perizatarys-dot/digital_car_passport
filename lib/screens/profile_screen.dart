import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/car_report.dart';
import '../providers/auth_providers.dart';
import '../services/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_surfaces.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_feedback.dart';
import '../utils/app_preferences.dart';
import '../utils/formatters.dart';
import '../widgets/common/app_user_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null) {
      return;
    }

    final bytes = result.files.single.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (context.mounted) {
        AppFeedback.showMessage(
          context,
          'The selected image could not be opened.',
        );
      }
      return;
    }

    final avatarBase64 = base64Encode(bytes);
    await ref
        .read(accountAvatarProvider.notifier)
        .setAvatarBase64(avatarBase64);
    if (context.mounted) {
      AppFeedback.showMessage(context, 'Profile photo updated.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockUser = MockData.sampleUser;
    final authUser = ref.watch(authStateChangesProvider).valueOrNull;
    final reportAccess = ref.watch(reportAccessProvider);
    final accountGarage = ref.watch(accountGarageProvider);
    final authAction = ref.watch(authControllerProvider);
    final menu = [
      ('Pricing & plans', '/pricing', Icons.workspace_premium_outlined),
      ('Saved reports', '/saved', Icons.bookmark_outline_rounded),
      ('Settings', '/settings', Icons.settings_outlined),
      ('B2B & partners', '/b2b', Icons.handshake_outlined),
    ];

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
                children: [
                  GestureDetector(
                    onTap: () => _pickAvatar(context, ref),
                    child: Stack(
                      children: [
                        AppUserAvatar(
                          radius: 40,
                          user: authUser,
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.blueMid,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 16,
                              color: AppColors.blueAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _profileName(authUser) ?? mockUser.name,
                    style: AppTextStyles.h2White,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _profileSubtitle(authUser, mockUser),
                    style:
                        AppTextStyles.body.copyWith(color: AppColors.white60),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tap the photo to change it',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white60,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _accountLabel(authUser, mockUser),
                      style: const TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
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
              110,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: _ProfileStat(
                        value: '${accountGarage.savedReports.length}',
                        label: 'Saved reports',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _ProfileStat(
                        value: '${accountGarage.searchHistory.length}',
                        label: 'Searches',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _ProfileStat(
                        value: '${mockUser.freeChecks}',
                        label: 'Free checks',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _ProfileCard(
                  title: 'Report access',
                  subtitle:
                      'Your first full car report is free. After that, you need a subscription to continue.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reportAccess.hasSubscription
                            ? 'Subscription is active for this account.'
                            : 'Free reports left: ${reportAccess.remainingFreeReports}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: context.appPrimaryTextColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () => context.push('/pricing'),
                        child: Text(
                          reportAccess.hasSubscription
                              ? 'Manage subscription'
                              : 'Get subscription',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _ProfileCard(
                  title: 'Invite friends and get free checks',
                  subtitle:
                      'Referral rewards help grow trust through social sharing and word of mouth.',
                  child: Column(
                    children: [
                      Text(
                        'Share your referral link with buyers, sellers, and car bloggers. Each successful sign-up adds one free check to your account.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appSecondaryTextColor,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () async {
                          await Clipboard.setData(
                            const ClipboardData(
                              text:
                                  'https://digitalcarpassport.kz/ref/amir-demo',
                            ),
                          );
                          if (context.mounted) {
                            AppFeedback.showMessage(
                                context, 'Referral link copied.');
                          }
                        },
                        child: const Text('Copy referral link'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _ProfileCard(
                  title: 'Payment history',
                  subtitle: 'Secure payment integration mock',
                  child: Column(
                    children: mockUser.payments
                        .map(
                          (payment) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      payment.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: context.appPrimaryTextColor,
                                      ),
                                    ),
                                    Text(
                                      payment.date,
                                      style: AppTextStyles.caption.copyWith(
                                        color: context.appHintTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      Formatters.kzt(payment.amount),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: context.appPrimaryTextColor,
                                      ),
                                    ),
                                    Text(
                                      payment.status.name,
                                      style: TextStyle(
                                        color:
                                            payment.status == PaymentStatus.paid
                                                ? AppColors.tealMuted
                                                : context.appHintTextColor,
                                        fontSize: 11,
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
                const SizedBox(height: AppSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    color: context.appCardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: context.appBorderColor),
                  ),
                  child: Column(
                    children: menu
                        .map(
                          (item) => ListTile(
                            onTap: () => context.push(item.$2),
                            leading: Icon(item.$3, color: AppColors.blueAccent),
                            title: Text(
                              item.$1,
                              style:
                                  TextStyle(color: context.appPrimaryTextColor),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: context.appHintTextColor,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: authAction.isLoading
                      ? null
                      : () async {
                          await ref
                              .read(authControllerProvider.notifier)
                              .signOut();
                          if (!context.mounted) {
                            return;
                          }

                          final state = ref.read(authControllerProvider);
                          state.whenOrNull(
                            data: (_) => AppFeedback.showMessage(
                              context,
                              'You have been logged out.',
                            ),
                            error: (error, _) => AppFeedback.showMessage(
                              context,
                              authErrorMessage(error),
                            ),
                          );
                        },
                  child:
                      Text(authAction.isLoading ? 'Logging out...' : 'Log out'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

String? _profileName(User? user) => defaultDisplayName(user);

String _profileSubtitle(User? authUser, AppUser mockUser) {
  final email = authUser?.email ?? mockUser.email;
  final provider = authUser?.providerData.any(
            (info) => info.providerId == 'google.com',
          ) ==
          true
      ? 'Google'
      : 'Email';

  return '$email • $provider account';
}

String _accountLabel(User? authUser, AppUser mockUser) {
  if (authUser == null) {
    return '${mockUser.accountType.name.toUpperCase()} ACCOUNT';
  }

  if (authUser.providerData.any((info) => info.providerId == 'google.com')) {
    return 'GOOGLE ACCOUNT';
  }

  return authUser.emailVerified ? 'VERIFIED ACCOUNT' : 'UNVERIFIED ACCOUNT';
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appBorderColor),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.blueAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: context.appSecondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ProfileCard({
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
          Text(
            title,
            style:
                AppTextStyles.h4.copyWith(color: context.appPrimaryTextColor),
          ),
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
