import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';

/// A single label/value row used in the Investment Details section.
class SdDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const SdDetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyle.bodyText1.copyWith(color: AppColors.black10),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyle.bodyText1.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
