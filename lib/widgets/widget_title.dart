import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';

class WidgetTitle extends StatelessWidget {
  final EdgeInsets? padding;
  final String text;
  const WidgetTitle({super.key, required this.text, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding??EdgeInsets.only(left: 12,bottom: 8),
      child: Text(text,style: AppTextStyle.h2,),
    );
  }
}
