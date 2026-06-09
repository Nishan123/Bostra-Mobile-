import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';

class IndustryDropdown extends StatelessWidget {
  final String? selectedIndustry;
  final ValueChanged<String?> onChanged;

  const IndustryDropdown({
    super.key,
    this.selectedIndustry,
    required this.onChanged,
  });

  static const List<String> _industries = [
    'Technology',
    'Healthcare',
    'Finance',
    'Education',
    'E-commerce',
    'Food & Beverage',
    'Real Estate',
    'Entertainment',
    'Agriculture',
    'Manufacturing',
    'Others',
  ];

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
          value: selectedIndustry,
          hint: Text(
            'Select Industry',
            style: AppTextStyle.normalText.copyWith(
              color: AppColors.blackColor.withAlpha(100),
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.blackColor.withAlpha(150),
          ),
          items: _industries.map((industry) {
            return DropdownMenuItem<String>(
              value: industry,
              child: Text(
                industry,
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
