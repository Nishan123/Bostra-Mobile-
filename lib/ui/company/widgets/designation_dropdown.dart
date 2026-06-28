import 'package:bostra/constants/founder_designations.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';

/// Fixed-list dropdown for picking a founder designation / post.
class DesignationDropdown extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;
  final String hint;

  const DesignationDropdown({
    super.key,
    this.selected,
    required this.onChanged,
    this.hint = 'Select designation',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.blackColor.withAlpha(60),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          hint: Text(
            hint,
            style: AppTextStyle.normalText.copyWith(
              color: AppColors.blackColor.withAlpha(100),
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.blackColor.withAlpha(150),
          ),
          items: FounderDesignations.values.map((designation) {
            return DropdownMenuItem<String>(
              value: designation,
              child: Text(
                designation,
                style: AppTextStyle.normalText.copyWith(
                  color: AppColors.blackColor,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
