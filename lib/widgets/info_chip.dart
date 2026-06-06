import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';

class InfoChip extends StatelessWidget {
  final String text;
  const InfoChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.turnaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text),
    );
  }
}
