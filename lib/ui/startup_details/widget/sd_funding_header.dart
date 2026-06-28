import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/startup_details/widget/sd_expandable_text.dart';
import 'package:bostra/ui/startup_details/widget/sd_section.dart';
import 'package:bostra/widgets/fund_progress_bar.dart';
import 'package:bostra/widgets/info_chip.dart';
import 'package:flutter/material.dart';

/// Title + funding totals + days-left chip + progress bar at the top of the
/// startup details screen.
class SdFundingHeader extends StatelessWidget {
  final CampaignModel campaign;
  const SdFundingHeader({super.key, required this.campaign});

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final c = campaign;
    return SdSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SdExpandableText(
            text: c.startupName,
            style: AppTextStyle.h1.copyWith(fontSize: 22),
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Rs ${_fmt(c.currentFunding)} ',
                      style: AppTextStyle.h4.copyWith(
                        color: AppColors.blackColor,
                      ),
                    ),
                    TextSpan(
                      text: 'Raised of Rs ${_fmt(c.targetAmount)}',
                      style: AppTextStyle.bodyText3.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (c.endDate != null) InfoChip(text: c.fundingCountdownLabel),
            ],
          ),
          const SizedBox(height: 8),
          FundProgressBar(value: c.fundingProgress),
        ],
      ),
    );
  }
}
