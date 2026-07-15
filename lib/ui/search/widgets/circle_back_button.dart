import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Light-grey circular back button used in the search header.
class CircleBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const CircleBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFFECECEC),
          shape: BoxShape.circle,
        ),
        child: Icon(
          LucideIcons.arrow_left,
          color: AppColors.blackColor,
          size: 22,
        ),
      ),
    );
  }
}
