import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const HomeSearchBar({
    super.key,
    this.onFilterTap,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      height: 52,
      padding: const EdgeInsets.only(left: 12.0, right: 8.0),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.primaryColor.withAlpha(120),
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          // Search Icon
          Icon(LucideIcons.search, color: AppColors.primaryColor, size: 28.0),
          const SizedBox(width: 12.0),

          // Search Input Field
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Search “Organic Cafe”',
                hintStyle: AppTextStyle.bodyText2.copyWith(
                  color: AppColors.blackColor.withAlpha(100),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppTextStyle.bodyText1.copyWith(
                color: AppColors.blackColor,
              ),
            ),
          ),

          // Filter Button
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                LucideIcons.sliders_horizontal,
                color: AppColors.whiteColor,
                size: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
