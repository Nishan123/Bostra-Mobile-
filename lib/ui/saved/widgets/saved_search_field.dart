import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class SavedSearchField extends StatelessWidget {
  const SavedSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: mq.height * 0.058,
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(LucideIcons.search),
            hint: Padding(
              padding: EdgeInsets.only(bottom: 0),
              child: Text(
                "Search saved",
                style: AppTextStyle.bodyText1.copyWith(
                  color: AppColors.blackColor.withAlpha(100),
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                width: 0.4,
                color: AppColors.primaryColor.withAlpha(100),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
