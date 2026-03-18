import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  Stream<User?> authStateChanges() => _firebaseAuth.userChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> register(String email, String password) async {
    try {
      print('AuthService.register: started for ${email.trim()}');

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user ?? _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(
          'Account was created, but no authenticated user was returned.',
        );
      }

      print('AuthService.register: user created uid=${user.uid}');

      await user.sendEmailVerification();
      print('AuthService.register: verification email sent to ${user.email}');

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? email.trim(),
        'name': user.email?.split('@').first ?? 'User',
        'avatar': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('AuthService.register: firestore user saved uid=${user.uid}');

      return credential;
    } on FirebaseAuthException catch (error) {
      print(
        'AuthService.register FirebaseAuthException: ${error.code} ${error.message}',
      );
      throw AuthException(_mapFirebaseError(error));
    } on FirebaseException catch (error) {
      print(
        'AuthService.register FirebaseException: ${error.code} ${error.message}',
      );
      throw AuthException(
        error.message ??
            'User account was created, but saving to Firestore failed.',
      );
    } catch (error) {
      print('AuthService.register unknown error: $error');
      rethrow;
    }
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await register(email, password);
    await _firebaseAuth.signOut();
    return credential;
  }

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      await user?.reload();
      final refreshedUser = _firebaseAuth.currentUser;

      if (refreshedUser != null && !refreshedUser.emailVerified) {
        await refreshedUser.sendEmailVerification();
        await _firebaseAuth.signOut();
        throw const AuthException(
          'Your email is not verified yet. We sent another verification link. '
          'Please verify your email before logging in.',
        );
      }
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseError(error));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(provider);

        final user = userCredential.user;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email ?? '',
            'name': user.displayName ?? user.email?.split('@').first ?? 'User',
            'avatar': user.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        return;
      }

      await _googleSignIn.initialize();
      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email ?? '',
          'name': user.displayName ?? user.email?.split('@').first ?? 'User',
          'avatar': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('Google sign-in was cancelled.');
      }
      throw const AuthException(
        'Google sign-in failed. Please try again.',
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseError(error));
    } on FirebaseException catch (error) {
      throw AuthException(
        error.message ?? 'Google sign-in succeeded, but Firestore save failed.',
      );
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No signed-in user found.');
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseError(error));
    }
  }

  Future<void> signOut() async {
    await Future.wait<void>([
      _firebaseAuth.signOut(),
      if (!kIsWeb) _googleSignIn.signOut(),
    ]);
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'email-already-in-use':
        return 'An account with that email already exists.';
      case 'weak-password':
        return 'Your password is too weak. Use at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection and try again.';
      case 'account-exists-with-different-credential':
        return 'This email is already linked to another sign-in method.';
      case 'popup-closed-by-user':
        return 'Google sign-in was cancelled.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}