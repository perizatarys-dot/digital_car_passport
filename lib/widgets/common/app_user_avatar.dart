import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_preferences.dart';

class AppUserAvatar extends ConsumerWidget {
  const AppUserAvatar({
    super.key,
    required this.radius,
    this.user,
    this.backgroundColor = AppColors.blueAccent,
    this.textStyle,
  });

  final double radius;
  final User? user;
  final Color backgroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = user ?? ref.watch(authStateChangesProvider).valueOrNull;
    final avatarBase64 = ref.watch(accountAvatarProvider);
    final networkAvatar = authUser?.photoURL?.trim();
    final imageProvider = _buildImageProvider(
      avatarBase64: avatarBase64,
      networkAvatar: networkAvatar,
    );

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Text(
              userInitials(authUser),
              style: textStyle ??
                  TextStyle(
                    color: Colors.white,
                    fontSize: radius * 0.6,
                    fontWeight: FontWeight.w800,
                  ),
            )
          : null,
    );
  }

  ImageProvider<Object>? _buildImageProvider({
    required String? avatarBase64,
    required String? networkAvatar,
  }) {
    if (avatarBase64 != null && avatarBase64.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(avatarBase64));
      } catch (_) {
        // Fall back to network avatar or initials if cached data is invalid.
      }
    }

    if (networkAvatar != null && networkAvatar.isNotEmpty) {
      return NetworkImage(networkAvatar);
    }

    return null;
  }
}
