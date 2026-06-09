import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/investment/widdgets/investment_status.dart';
import 'package:bostra/ui/investment/widdgets/p_l_indicator.dart';
import 'package:bostra/widgets/avatars_with_count.dart';
import 'package:flutter/material.dart';

class MyInvestmentCard extends StatelessWidget {
  const MyInvestmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border.all(
          width: 0.6,
          color: AppColors.primaryColor.withAlpha(100),
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

      // 1. Wrap Row in IntrinsicHeight so the row knows the maximum height of its children
      child: IntrinsicHeight(
        child: Row(
          // 2. Change this to stretch so the children fill the height of the IntrinsicHeight wrapper
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Container(
              // 3. Removed the hardcoded height. It will now match the parent.
              width: mq.height * 0.17,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: AppColors.turnaryColor,
              ),
            ),
            const SizedBox(width: 8),

            // details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "Startup title in not more than one line",
                    style: AppTextStyle.h3,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  InvestmentStatusWidget(status: InvestmentStatus.active),
                  const SizedBox(height: 8),

                  PLIndicator(diff: 12),
                  const SizedBox(height: 4),

                  AvatarsWithCount(
                    imageUrls: const [
                      "https://images.pexels.com/photos/10143324/pexels-photo-10143324.jpeg",
                      "https://images.pexels.com/photos/10143324/pexels-photo-10143324.jpeg",
                      "https://images.pexels.com/photos/10143324/pexels-photo-10143324.jpeg",
                      "https://images.pexels.com/photos/10143324/pexels-photo-10143324.jpeg",
                    ],
                    totalBackers: 2,
                    avatarSize: 32,
                    countTextStyle: AppTextStyle.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
