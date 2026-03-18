import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_feedback.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  var _verificationSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      debugPrint('RegisterScreen._register: validation blocked submit');
      return;
    }

    debugPrint(
      'RegisterScreen._register: calling authControllerProvider.register for ${_emailCtrl.text.trim()}',
    );
    await ref.read(authControllerProvider.notifier).register(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
    debugPrint('RegisterScreen._register: register call completed');

    final state = ref.read(authControllerProvider);
    if (!mounted) {
      return;
    }

    state.whenOrNull(
      data: (_) {
        setState(() => _verificationSent = true);
        AppFeedback.showMessage(
          context,
          'Verification email sent. Please verify your email, then sign in.',
        );
      },
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
                  title: 'Create your account',
                  description:
                      'Register with email and password or continue with Google to start saving reports and syncing your vehicle checks.',
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
                          autofillHints: const [AutofillHints.newPassword],
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Create a password',
                          ),
                          validator: validatePassword,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Confirm password', style: AppTextStyles.label),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _confirmCtrl,
                          obscureText: true,
                          autofillHints: const [AutofillHints.newPassword],
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'Repeat your password',
                          ),
                          validator: (value) {
                            final passwordError = validatePassword(value);
                            if (passwordError != null) {
                              return passwordError;
                            }
                            if (value != _passCtrl.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _register(),
                        ),
                        if (_verificationSent) ...[
                          const SizedBox(height: AppSpacing.md),
                          const AuthStatusBanner(
                            icon: Icons.mail_outline_rounded,
                            title: 'Verification email sent',
                            message:
                                'Open the email we just sent, tap the verification link, then return here to sign in.',
                            color: AppColors.tealMuted,
                            backgroundColor: Color(0xFFEAFBF6),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        ElevatedButton(
                          onPressed: isLoading ? null : _register,
                          child: Text(
                            isLoading
                                ? 'Creating account...'
                                : 'Create Account',
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
                          icon: Icons.mark_email_read_outlined,
                          title: 'Automatic verification email',
                          message:
                              'After email registration, Firebase sends a verification email automatically and the app keeps protected routes locked until verification is complete.',
                          color: AppColors.blueAccent,
                          backgroundColor: AppColors.surface2,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: TextButton(
                            onPressed:
                                isLoading ? null : () => context.go('/login'),
                            child:
                                const Text('Already have an account? Sign in'),
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
