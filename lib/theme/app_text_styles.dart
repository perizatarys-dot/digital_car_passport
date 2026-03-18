import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for Digital Car Passport
abstract class AppTextStyles {
  // ── Display / Headings ───────────────────────────────
  static TextStyle get h1 => GoogleFonts.dmSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -1.0,
        height: 1.08,
      );

  static TextStyle get h2 => GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.8,
        height: 1.1,
      );

  static TextStyle get h3 => GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.4,
        height: 1.12,
      );

  static TextStyle get h4 => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.15,
      );

  // ── White variants ───────────────────────────────────
  static TextStyle get h1White => h1.copyWith(color: Colors.white);
  static TextStyle get h2White => h2.copyWith(color: Colors.white);
  static TextStyle get h3White => h3.copyWith(color: Colors.white);

  // ── Body (DM Sans via Google Fonts) ─────────────────
  static TextStyle get body => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.6,
      );

  static TextStyle get bodySmall => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySemibold => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // ── Labels ───────────────────────────────────────────
  static TextStyle get label => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textHint,
        letterSpacing: 0.8,
      );

  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
      );

  static TextStyle get mono => const TextStyle(
        fontFamily: 'Courier',
        fontSize: 11,
        color: AppColors.textHint,
        letterSpacing: 0.5,
      );

  // ── Pill / Badge ─────────────────────────────────────
  static TextStyle get pillText => GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      );

  static TextStyle get badgeText => GoogleFonts.dmSans(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      );
}
