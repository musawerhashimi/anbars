import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand — green (primary), blue (secondary), red (accent)
  static const primary = Color(0xFF16A34A);        // Green 600
  static const primaryLight = Color(0xFF4ADE80);   // Green 400
  static const primaryDark = Color(0xFF15803D);    // Green 700
  static const secondary = Color(0xFF2563EB);      // Blue 600
  static const secondaryLight = Color(0xFF60A5FA); // Blue 400
  static const accent = Color(0xFFDC2626);         // Red 600

  static const brandGradient = [primary, secondary];
  static const brandStripe = [primary, secondary, accent];

  // Accent
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFDE68A);
  static const green = primary;
  static const greenLight = Color(0xFFDCFCE7);
  static const red = accent;
  static const redLight = Color(0xFFFEE2E2);
  static const blue = secondary;
  static const blueLight = Color(0xFFDBEAFE);

  // Light surface
  static const lightBackground = Color(0xFFEEF7FC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF1F5F9);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightTextHint = Color(0xFF94A3B8);

  // Dark surface
  static const darkBackground = Color(0xFF0B1210);
  static const darkSurface = Color(0xFF131C19);
  static const darkSurfaceVariant = Color(0xFF1A2622);
  static const darkBorder = Color(0xFF26352F);
  static const darkTextPrimary = Color(0xFFF1F5F9);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkTextHint = Color(0xFF475569);

  // Status colors
  static const success = primary;
  static const warning = Color(0xFFF59E0B);
  static const error = accent;
  static const info = secondary;
}
