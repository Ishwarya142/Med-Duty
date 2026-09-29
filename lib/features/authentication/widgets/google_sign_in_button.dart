import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';

/// MedDuty-styled "Continue with Google" button.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.isDark = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFDADCE0);
    final textColor = isDark ? AppColors.darkText : const Color(0xFF1A2744);
    final surface = isDark ? AppColors.darkSurface : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: surface,
          foregroundColor: textColor,
          elevation: 0,
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Signing in with Google...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/google_g.svg',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Horizontal divider with centered "OR" label.
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key, this.isDark = false});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lineColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder.withValues(alpha: 0.8);
    final textColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(child: Divider(color: lineColor, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'OR',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: Divider(color: lineColor, thickness: 1)),
        ],
      ),
    );
  }
}
