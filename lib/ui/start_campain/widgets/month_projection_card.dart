import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/start_campain/widgets/projection_textfield.dart';
import 'package:flutter/material.dart';

class MonthProjectionCard extends StatelessWidget {
  final int monthNumber;
  final String monthLabel;

  const MonthProjectionCard({
    super.key,
    required this.monthNumber,
    required this.monthLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Month $monthNumber',
                style: AppTextStyle.h4.copyWith(
                  color: AppColors.whiteColor,
                ),
              ),
              Text(
                monthLabel,
                style: AppTextStyle.bodyText2.copyWith(
                  color: AppColors.whiteColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Text fields card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primaryColor.withAlpha(80),
              width: 1,
            ),
          ),
          child: const Column(
            children: [
              ProjectionTextfield(hintText: 'Objectives'),
              SizedBox(height: 12),
              ProjectionTextfield(hintText: 'Goals'),
              SizedBox(height: 12),
              ProjectionTextfield(hintText: 'Initiative'),
            ],
          ),
        ),
      ],
    );
  }
}
