import 'package:bostra/models/investment_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/investment/widdgets/investment_status.dart';
import 'package:bostra/ui/investment/widdgets/p_l_indicator.dart';
import 'package:bostra/widgets/avatars_with_count.dart';
import 'package:flutter/material.dart';

class MyInvestmentCard extends StatelessWidget {
  final InvestmentModel investment;
  const MyInvestmentCard({super.key, required this.investment});

  @override
  Widget build(BuildContext context) {
    final campaign = investment.campaign;
    
    final status = campaign?.status ?? InvestmentStatus.initial;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: 100,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppColors.turnaryColor,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: (campaign?.logoUrl != null && campaign!.logoUrl!.isNotEmpty)
                  ? Image.network(
                      campaign.logoUrl!,
                      fit: BoxFit.cover,
                    )
                  : (campaign?.coverImageUrl != null && campaign!.coverImageUrl!.isNotEmpty)
                      ? Image.network(
                          campaign.coverImageUrl!,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(),
            ),
          ),
          const SizedBox(width: 12),

          // details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  const SizedBox(height: 8),
                  Text(
                    campaign?.startupName ?? "Unknown Startup",
                    style: AppTextStyle.h3,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InvestmentStatusWidget(status: status),
                      Text(
                        "Rs ${investment.amount.toStringAsFixed(0)}",
                        style: AppTextStyle.bodyText1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  PLIndicator(diff: 12),
                  const SizedBox(height: 4),

                  AvatarsWithCount(
                    investorIds: campaign?.investors ?? const [],
                    totalBackers: campaign?.totalInvestors ?? 0,
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
      );
  }
}
