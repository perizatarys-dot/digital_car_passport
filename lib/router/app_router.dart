import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/main_shell.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/saved_reports_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/vin_search_screen.dart';
import '../screens/report_screen.dart';
import '../screens/price_estimate_screen.dart';
import '../screens/fines_check_screen.dart';
import '../screens/history_screen.dart';
import '../screens/pricing_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/b2b_partner_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final splashReady = ref.watch(splashReadyProvider);
  final authState = ref.watch(authStateChangesProvider);
  final refreshListenable = ref.watch(authRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splash';
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isLogin = state.matchedLocation == '/login';
      final isRegister = state.matchedLocation == '/register';
      final isAuthRoute = isLogin || isRegister || isOnboarding;
      final ready = splashReady.valueOrNull ?? false;
      final currentUser = authState.valueOrNull;
      final signedIn = canAccessProtectedRoutes(currentUser);

      if (!ready) {
        return isSplash ? null : '/splash';
      }

      if (isSplash) {
        return signedIn ? '/home' : '/onboarding';
      }

      if (!signedIn && !isAuthRoute) {
        return '/login';
      }

      if (signedIn && isAuthRoute) {
        return '/home';
      }

      if (_hasUnverifiedEmailSession(currentUser) && !isLogin) {
        return '/login?mode=verify';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, state) => LoginScreen(
          showVerificationHint: state.uri.queryParameters['mode'] == 'verify',
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),

      // ── Main shell with bottom nav ──────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
          GoRoute(
              path: '/saved', builder: (_, __) => const SavedReportsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ── Stack screens (no bottom nav) ───────────────────
      GoRoute(
        path: '/vin-search',
        builder: (_, __) => const VinSearchScreen(),
      ),
      GoRoute(
        path: '/report/:vin',
        builder: (_, state) => ReportScreen(vin: state.pathParameters['vin']!),
      ),
      GoRoute(
        path: '/price/:vin',
        builder: (_, state) =>
            PriceEstimateScreen(vin: state.pathParameters['vin']!),
      ),
      GoRoute(
        path: '/fines/:vin',
        builder: (_, state) =>
            FinesCheckScreen(vin: state.pathParameters['vin']!),
      ),
      GoRoute(
        path: '/history/:vin',
        builder: (_, state) => HistoryScreen(vin: state.pathParameters['vin']!),
      ),
      GoRoute(
        path: '/pricing',
        builder: (_, __) => const PricingScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/b2b',
        builder: (_, __) => const B2BPartnerScreen(),
      ),
    ],
  );
});

bool _hasUnverifiedEmailSession(User? user) {
  if (user == null) {
    return false;
  }

  if (canAccessProtectedRoutes(user)) {
    return false;
  }

  return user.email != null;
}
