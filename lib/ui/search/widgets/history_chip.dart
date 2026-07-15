import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';

/// Grey rounded pill used under "Search Histories" — tapping runs the term.
class HistoryChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const HistoryChip({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: AppTextStyle.bodyText1.copyWith(color: AppColors.blackColor),
        ),
      ),
    );
  }
}
