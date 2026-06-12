import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';

class CampaignTextfield extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const CampaignTextfield({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.maxLines = 1,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyle.bodyText2.copyWith(
              color: AppColors.blackColor.withAlpha(180),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: AppTextStyle.normalText.copyWith(
              color: AppColors.blackColor,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyle.normalText.copyWith(
                color: AppColors.blackColor.withAlpha(100),
              ),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.blackColor.withAlpha(60),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
