import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_feedback.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.showVerificationHint = false,
  });

  final bool showVerificationHint;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    await ref.read(authControllerProvider.notifier).login(
          email: _emailCtrl.text,
          password: _passCtrl.text,
        );

    final state = ref.read(authControllerProvider);
    if (!mounted) {
      return;
    }

    state.whenOrNull(
      data: (_) => AppFeedback.showMessage(context, 'Signed in successfully.'),
      error: (error, _) => AppFeedback.showMessage(
        context,
        authErrorMessage(error),
      ),
    );
  }

  Future<void> _continueWithGoogle() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();

    final state = ref.read(authControllerProvider);
    if (!mounted) {
      return;
    }

    state.whenOrNull(
      data: (_) => AppFeedback.showMessage(context, 'Signed in with Google.'),
      error: (error, _) => AppFeedback.showMessage(
        context,
        authErrorMessage(error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.blueDark, AppColors.blueMid, AppColors.surface],
            stops: [0, 0.34, 0.34],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                const AuthHero(
                  title: 'Welcome back',
                  description:
                      'Sign in to check VINs, save reports, and keep your digital car passport synced across devices.',
                ),
                const SizedBox(height: AppSpacing.xl),
                AuthCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email', style: AppTextStyles.label),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'you@example.com',
                          ),
                          validator: validateEmail,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Password', style: AppTextStyles.label),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'Enter your password',
                          ),
                          validator: validatePassword,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        if (widget.showVerificationHint) ...[
                          const SizedBox(height: AppSpacing.md),
                          const AuthStatusBanner(
                            icon: Icons.mark_email_unread_outlined,
                            title: 'Verify your email before logging in',
                            message:
                                'Check your inbox for the verification link. If you tried to sign in early, we sent a fresh email.',
                            color: AppColors.amber,
                            backgroundColor: Color(0xFFFFF8E6),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          child: Text(
                            isLoading ? 'Signing in...' : 'Sign In',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'or continue with',
                                style: AppTextStyles.caption,
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton.icon(
                          onPressed: isLoading ? null : _continueWithGoogle,
                          icon: const Icon(Icons.public, size: 18),
                          label: const Text('Continue with Google'),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const AuthStatusBanner(
                          icon: Icons.verified_user_outlined,
                          title: 'Email verification required',
                          message:
                              'Accounts created with email and password must verify the inbox link before entering the app.',
                          color: AppColors.blueAccent,
                          backgroundColor: AppColors.surface2,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.push('/register'),
                            child: const Text('Create a free account'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthHero extends StatelessWidget {
  const AuthHero({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.blueAccent,
              size: 30,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            title,
            style: AppTextStyles.h1White.copyWith(fontSize: 34),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTextStyles.body.copyWith(
              color: AppColors.white60,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120A1628),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthStatusBanner extends StatelessWidget {
  const AuthStatusBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySemibold.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
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

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) {
    return 'Enter your email address.';
  }

  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailRegex.hasMatch(email)) {
    return 'Enter a valid email address.';
  }

  return null;
}

String? validatePassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) {
    return 'Enter your password.';
  }

  if (password.length < 6) {
    return 'Password must be at least 6 characters.';
  }

  return null;
}
