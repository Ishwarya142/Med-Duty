import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme get textTheme => TextTheme(
        displayLarge: display,
        displayMedium: heading,
        displaySmall: title,
        headlineMedium: heading,
        headlineSmall: title,
        titleLarge: title,
        titleMedium: subtitle,
        titleSmall: subtitle,
        bodyLarge: body,
        bodyMedium: body,
        bodySmall: caption,
        labelLarge: button,
        labelMedium: label,
        labelSmall: caption,
      );

  static TextStyle get display => GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
        letterSpacing: -0.5,
      );

  static TextStyle get heading => GoogleFonts.roboto(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
        letterSpacing: -0.3,
      );

  static TextStyle get title => GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      );

  static TextStyle get subtitle => GoogleFonts.roboto(
        fontSize: 15,
        color: AppColors.grey,
        height: 1.5,
      );

  static TextStyle get body => GoogleFonts.roboto(
        fontSize: 14,
        color: AppColors.black,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.roboto(
        fontSize: 12,
        color: AppColors.greyLight,
      );

  static TextStyle get button => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle get label => GoogleFonts.roboto(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
      );
}
