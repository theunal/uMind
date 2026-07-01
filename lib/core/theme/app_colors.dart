import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color primaryLight;
  final Color primarySurface;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color surfaceBorder;
  final Color success;
  final Color successLight;
  final Color error;
  final Color warning;
  final Color accentPink;
  final Color accentOrange;
  final Color accentCyan;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.primarySurface,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceBorder,
    required this.success,
    required this.successLight,
    required this.error,
    required this.warning,
    required this.accentPink,
    required this.accentOrange,
    required this.accentCyan,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  static const dark = AppColors(
    primary: Color(0xFF6366F1),
    primaryLight: Color(0xFF818CF8),
    primarySurface: Color(0xFFA5B4FC),
    secondary: Color(0xFF8B5CF6),
    background: Color(0xFF0F172A),
    surface: Color(0x0DFFFFFF),
    surfaceBorder: Color(0x1AFFFFFF),
    success: Color(0xFF22C55E),
    successLight: Color(0xFF34D399),
    error: Color(0xFFEF4444),
    warning: Color(0xFFFBBF24),
    accentPink: Color(0xFFF472B6),
    accentOrange: Color(0xFFFB923C),
    accentCyan: Color(0xFF67E8F9),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xB3FFFFFF),
    textMuted: Color(0x66FFFFFF),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primarySurface,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? surfaceBorder,
    Color? success,
    Color? successLight,
    Color? error,
    Color? warning,
    Color? accentPink,
    Color? accentOrange,
    Color? accentCyan,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primarySurface: primarySurface ?? this.primarySurface,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      accentPink: accentPink ?? this.accentPink,
      accentOrange: accentOrange ?? this.accentOrange,
      accentCyan: accentCyan ?? this.accentCyan,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primarySurface: Color.lerp(primarySurface, other.primarySurface, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      accentPink: Color.lerp(accentPink, other.accentPink, t)!,
      accentOrange: Color.lerp(accentOrange, other.accentOrange, t)!,
      accentCyan: Color.lerp(accentCyan, other.accentCyan, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}
