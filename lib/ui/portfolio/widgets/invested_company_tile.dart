import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/investment/widdgets/p_l_indicator.dart';
import 'package:flutter/material.dart';

class InvestedCompanyTile extends StatelessWidget {
  const InvestedCompanyTile({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(left: 12, right: 12, bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: AppColors.blackColor.withAlpha(80)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.only(left: 10, right: 6, top: 8, bottom: 8),
      width: mq.width,
      child: Row(
        spacing: 12,
        children: [
          CircleAvatar(backgroundColor: AppColors.turnaryColor, radius: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Text("Startup name", style: AppTextStyle.h4),
                    Text(
                      "Rs.12,000",
                      style: AppTextStyle.h4.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                Text("Company name", style: AppTextStyle.bodyText2),
              ],
            ),
          ),
          
          PLIndicator(diff: 12)
        ],
      ),
    );
  }
}
