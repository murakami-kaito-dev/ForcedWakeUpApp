import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Light theme (main screens) ──

  /// Scaffold background — soft sky blue
  static const background = Color(0xFFE5EDF5);

  /// Card / container surface — white
  static const surface = Color(0xFFFFFFFF);

  /// Selected / active state — light blue tint
  static const selected = Color(0xFFD6E4FF);

  /// Primary accent — vibrant blue
  static const accent = Color(0xFF4A6CF7);

  /// Gold for premium / achievements
  static const gold = Color(0xFFFBBF24);

  /// Primary text — near black
  static const textPrimary = Color(0xFF1A1D26);

  /// Secondary text — medium gray
  static const textSecondary = Color(0xFF6B7280);

  /// Subtle text / disabled — light gray
  static const textHint = Color(0xFF9CA3AF);

  // ── Dark theme (sleep screen only) ──

  static const darkBackground = Color(0xFF0D1117);
  static const darkSurface = Color(0xFF161B22);
  static const darkSelected = Color(0xFF1C2D4F);
}
