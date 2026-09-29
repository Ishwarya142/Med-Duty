import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final String? hintText;
  final VoidCallback? onFilterTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? padding;
  final double height;

  const SearchBarWidget({
    super.key,
    this.hintText,
    this.onFilterTap,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.padding,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchBg = isDark ? AppColors.darkSearchBg : AppColors.lightSearchBg;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final hintColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final iconColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: height,
              child: Container(
                decoration: BoxDecoration(
                  color: searchBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    hintText: hintText ?? "Search duties, clinics, hospitals...",
                    hintStyle: TextStyle(
                      color: hintColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Icon(
                        Icons.search_rounded,
                        color: iconColor,
                        size: 22,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: (height - 28) / 2,
                      horizontal: 4,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Premium filter button - perfectly aligned height
          SizedBox(
            height: height,
            width: height,
            child: Material(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(16),
              elevation: 0,
              shadowColor: AppColors.accent.withValues(alpha: 0.35),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onFilterTap ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Filter options coming soon!"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                child: Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: height * 0.44,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
