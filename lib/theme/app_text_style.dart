import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextStyle {
  static final TextStyle normalText = TextStyle(fontSize: 14);
  
  static final TextStyle buttonTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textButtonColor,
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
  static final TextStyle bodyText = TextStyle(
    fontSize: 16,
  );

}
