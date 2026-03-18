import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

final splashReadyProvider = StreamProvider<bool>((ref) async* {
  yield false;
  await Future<void>.delayed(const Duration(milliseconds: 2400));
  yield true;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authServiceProvider));
});

final authRouterNotifierProvider = Provider<AuthRouterNotifier>((ref) {
  final notifier = AuthRouterNotifier(ref.watch(authServiceProvider));
  ref.onDispose(notifier.dispose);
  return notifier;
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._authService) : super(const AsyncData(null));

  final AuthService _authService;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authService.loginWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    debugPrint(
      'AuthController.register: started for ${email.trim()}',
    );
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      debugPrint(
        'AuthController.register: calling AuthService.register for ${email.trim()}',
      );
      await _authService.register(email, password);
      debugPrint(
        'AuthController.register: AuthService.register completed, signing out unverified user',
      );
      await _authService.signOut();
      debugPrint('AuthController.register: completed successfully');
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_authService.signInWithGoogle);
  }

  Future<void> resendVerificationEmail() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_authService.sendEmailVerification);
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_authService.signOut);
  }
}

class AuthRouterNotifier extends ChangeNotifier {
  AuthRouterNotifier(AuthService authService) {
    _subscription = authService.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

String authErrorMessage(Object error) {
  if (error is AuthException) {
    return error.message;
  }

  if (error is FirebaseAuthException) {
    return error.message ?? 'Authentication failed. Please try again.';
  }

  return 'Something went wrong. Please try again.';
}

bool canAccessProtectedRoutes(User? user) {
  if (user == null) {
    return false;
  }

  if (user.emailVerified) {
    return true;
  }

  return user.providerData.any((info) => info.providerId == 'google.com');
}

String? defaultDisplayName(User? user) {
  final name = user?.displayName?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }

  final email = user?.email?.trim();
  if (email == null || email.isEmpty) {
    return null;
  }

  return email.split('@').first;
}

String userInitials(User? user) {
  final source = defaultDisplayName(user) ?? user?.email ?? 'User';
  final parts = source
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .toList();

  if (parts.isEmpty) {
    return 'U';
  }

  return parts.map((part) => part.substring(0, 1).toUpperCase()).join();
}
