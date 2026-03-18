import 'package:flutter/material.dart';

/// Digital Car Passport – Brand Color Palette
/// Blue / Navy / Teal automotive-fintech design system
abstract class AppColors {
  // ── Brand ────────────────────────────────────────────
  static const Color blueDark   = Color(0xFF0A1628);
  static const Color blueMid    = Color(0xFF0D2346);
  static const Color blueAccent = Color(0xFF1A6FFF);
  static const Color blueLight  = Color(0xFF3D8BFF);
  static const Color blueGlow   = Color(0xFF5B9EFF);

  static const Color teal       = Color(0xFF00D4AA);
  static const Color tealMuted  = Color(0xFF00B894);
  static const Color amber      = Color(0xFFFFB703);
  static const Color danger     = Color(0xFFFF4B6E);

  // ── Surfaces ─────────────────────────────────────────
  static const Color surface    = Color(0xFFF4F7FF);
  static const Color surface2   = Color(0xFFEEF2FF);
  static const Color card       = Color(0xFFFFFFFF);
  static const Color darkCanvas = Color(0xFF07101B);
  static const Color darkSurface = Color(0xFF0D1726);
  static const Color darkCard = Color(0xFF132033);
  static const Color darkCardAlt = Color(0xFF1A2940);
  static const Color darkBorder = Color(0x2E9BB7E0);
  static const Color darkTextSecondary = Color(0xFFADC0DA);
  static const Color darkTextHint = Color(0xFF7F93AF);

  // ── Text ─────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0A1628);
  static const Color textSecondary = Color(0xFF4A6080);
  static const Color textHint      = Color(0xFF8AA0BA);

  // ── Border ───────────────────────────────────────────
  static const Color border    = Color(0x14000000); // 8% black
  static const Color borderMid = Color(0x24000000); // 14% black

  // ── Semantic ─────────────────────────────────────────
  static const Color success = teal;
  static const Color warning = amber;
  static const Color error   = danger;
  static const Color info    = blueAccent;

  // ── White alpha ──────────────────────────────────────
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white15 = Color(0x26FFFFFF);
  static const Color white40 = Color(0x66FFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);

  // ── Score pill backgrounds ───────────────────────────
  static const Color safeBg    = Color(0x2600D4AA);
  static const Color cautionBg = Color(0x26FFB703);
  static const Color riskBg    = Color(0x1FFF4B6E);

  static const Color safeText    = Color(0xFF00A882);
  static const Color cautionText = Color(0xFFC07A00);
  static const Color riskText    = Color(0xFFFF4B6E);
}
