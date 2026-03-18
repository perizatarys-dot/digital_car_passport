import 'package:flutter/material.dart';

/// Spacing and radius constants
abstract class AppSpacing {
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 20;
  static const double xxl  = 28;
  static const double xxxl = 40;
}

abstract class AppRadius {
  static const double xs   = 6;
  static const double sm   = 10;
  static const double md   = 14;
  static const double lg   = 20;
  static const double xl   = 28;
  static const double full = 999;

  static BorderRadius get smBR  => BorderRadius.circular(sm);
  static BorderRadius get mdBR  => BorderRadius.circular(md);
  static BorderRadius get lgBR  => BorderRadius.circular(lg);
  static BorderRadius get fullBR => BorderRadius.circular(full);
}
