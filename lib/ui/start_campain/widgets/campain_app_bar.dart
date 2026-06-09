import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';

class CampainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;

  const CampainAppBar({
    super.key,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: onBack ?? () => Navigator.of(context).pop(),
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.blackColor.withAlpha(60),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.arrow_back,
            color: AppColors.blackColor.withAlpha(180),
            size: 18,
          ),
        ),
      ),
      title: Text(
        'Start Campaign',
        style: AppTextStyle.h3.copyWith(
          color: AppColors.primaryColor,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.6,
              color: AppColors.blackColor.withAlpha(80),
            ),
          ),
        ),
      ),
    );
  }
}
