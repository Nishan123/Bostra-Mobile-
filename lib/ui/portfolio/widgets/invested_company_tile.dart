import 'package:bostra/models/portfolio_models.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/investment/widdgets/p_l_indicator.dart';
import 'package:flutter/material.dart';

class InvestedCompanyTile extends StatelessWidget {
  final PortfolioHolding holding;
  const InvestedCompanyTile({super.key, required this.holding});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final hasLogo =
        holding.logoUrl != null && holding.logoUrl!.startsWith('http');

    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: AppColors.blackColor.withAlpha(80)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 10, right: 6, top: 8, bottom: 8),
      width: mq.width,
      child: Row(
        spacing: 12,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.turnaryColor,
            radius: 20,
            backgroundImage: hasLogo ? NetworkImage(holding.logoUrl!) : null,
            child: hasLogo
                ? null
                : Text(
                    holding.startupName.isNotEmpty
                        ? holding.startupName[0].toUpperCase()
                        : '?',
                    style: AppTextStyle.h4.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Flexible(
                      child: Text(
                        holding.startupName,
                        style: AppTextStyle.h4,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Rs ${holding.invested.toStringAsFixed(0)}',
                      style: AppTextStyle.h4.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  holding.companyName ?? holding.sector,
                  style: AppTextStyle.bodyText2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PLIndicator(diff: holding.returnPct),
        ],
      ),
    );
  }
}
