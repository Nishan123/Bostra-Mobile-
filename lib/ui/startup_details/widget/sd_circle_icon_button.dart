import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A frosted-glass circular icon button used in the SliverAppBar.
class SdCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const SdCircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 6,
            )
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor ?? AppColors.blackColor),
      ),
    );
  }
}
