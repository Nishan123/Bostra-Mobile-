import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextStyle {
  static final TextStyle normalText = TextStyle(fontSize: 14);

  static final TextStyle buttonTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textButtonColor,
  );
  static final TextStyle heading = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle h1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );
  static final TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  static final TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  static final TextStyle h4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  static final TextStyle bodyText1 = TextStyle(fontSize: 16);
  static final TextStyle bodyText2 = TextStyle(fontSize: 14,color: AppColors.blackColor.withAlpha(100));
  static final TextStyle bodyText3 = TextStyle(fontSize: 12,color: AppColors.blackColor.withAlpha(100));
}
