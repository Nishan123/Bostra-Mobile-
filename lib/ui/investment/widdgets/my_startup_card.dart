import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/widgets/avatars_with_count.dart';
import 'package:bostra/widgets/fund_progress_bar.dart';
import 'package:bostra/widgets/info_chip.dart';
import 'package:flutter/material.dart';

class MyStartupCard extends StatelessWidget {
  final CampaignModel campaign;
  const MyStartupCard({super.key, required this.campaign});

  int getDaysLeft(DateTime? endDate) {
    if (endDate == null) return 0;
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = getDaysLeft(campaign.endDate);
    
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(left: 14, right: 14, bottom: 18),
      padding: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          width: 0.6,
          color: AppColors.primaryColor.withValues(alpha: 0.40),
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          // image container
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            clipBehavior: Clip.hardEdge,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.turnaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22.1),
                topRight: Radius.circular(22.1),
              ),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22.1),
                    topRight: Radius.circular(22.1),
                  ),
                  child: Image.network(
                    campaign.coverImageUrl ?? campaign.logoUrl ?? "https://images.pexels.com/photos/3952080/pexels-photo-3952080.jpeg",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),

                //like button
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    spacing: 4,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (campaign.industry.isNotEmpty) InfoChip(text: campaign.industry),
                      InfoChip(text: campaign.status.toUpperCase()),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                // title text
                Text(
                  campaign.startupName,
                  style: AppTextStyle.h2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // fund progress
                FundProgressBar(value: campaign.fundingProgress),

                // amount raised text
                Row(
                  spacing: 8,
                  children: [
                    Text(
                      "Rs ${campaign.currentFunding.toStringAsFixed(0)}",
                      style: AppTextStyle.h3,
                    ),
                    const Text("Raised of"),
                    Text("Rs ${campaign.targetAmount.toStringAsFixed(0)}"),
                  ],
                ),

                Row(
                  children: [
                    AvatarsWithCount(
                      investorIds: campaign.investors,
                      totalBackers: campaign.totalInvestors,
                      avatarSize: 40,
                    ),
                    const Spacer(),
                    InfoChip(text: daysLeft > 0 ? "$daysLeft days left" : "Ended"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}