import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';

class StartCampainProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StartCampainProgress({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Step ',
                  style: AppTextStyle.bodyText2.copyWith(
                    color: AppColors.blackColor,
                  ),
                ),
                TextSpan(
                  text: '$currentStep',
                  style: AppTextStyle.bodyText2.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                TextSpan(
                  text: ' of $totalSteps',
                  style: AppTextStyle.bodyText2.copyWith(
                    color: AppColors.blackColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: currentStep / totalSteps,
              minHeight: 6,
              backgroundColor: AppColors.blackColor.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
