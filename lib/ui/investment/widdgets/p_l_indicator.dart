import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class PLIndicator extends StatelessWidget {
  final double diff;
  const PLIndicator({super.key, required this.diff});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 3,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("${diff.toStringAsFixed(0).toString()}%",style: AppTextStyle.h2),
        Icon(
          diff < 0 ? LucideIcons.arrow_down : LucideIcons.arrow_up,
          size: 22,
          fontWeight: FontWeight.w900,
        ),

      ],
    );
  }
}
