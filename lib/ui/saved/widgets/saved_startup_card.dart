import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/saved/view_model/saved_campaign_view_model.dart';
import 'package:bostra/widgets/fund_progress_bar.dart';
import 'package:bostra/widgets/info_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavedStartupCard extends ConsumerWidget {
  final CampaignModel campaign;

  const SavedStartupCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Cover image ──────────────────────────────────────────────
            // Fixed width + height so IntrinsicHeight is driven by the text
            // column, not the image's natural pixel dimensions.
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: mq.width * 0.30,
                height: 130,
                child: campaign.coverImageUrl != null
                    ? Image.network(
                        campaign.coverImageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Container(color: AppColors.turnaryColor),
              ),
            ),
            const SizedBox(width: 8),

            // ── Details ──────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Title row with unsave button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          campaign.startupName,
                          style: AppTextStyle.h3,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => ref
                            .read(savedCampaignViewModelProvider.notifier)
                            .toggleSave(campaign),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  FundProgressBar(value: campaign.fundingProgress),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Text(
                        'Rs ${campaign.currentFunding.toStringAsFixed(0)}',
                        style: AppTextStyle.normalText.copyWith(
                          color: AppColors.blackColor.withAlpha(140),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Rs ${campaign.targetAmount.toStringAsFixed(0)}',
                        style: AppTextStyle.normalText.copyWith(
                          color: AppColors.blackColor.withAlpha(140),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      InfoChip(text: '${campaign.totalInvestors} investors'),
                      const SizedBox(width: 8),
                      if (campaign.industry.isNotEmpty)
                        InfoChip(text: campaign.industry),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Unsave text hint
                  Row(
                    children: [
                      Icon(
                        LucideIcons.heart_off,
                        size: 12,
                        color: AppColors.blackColor.withAlpha(100),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap heart to unsave',
                        style: AppTextStyle.bodyText3.copyWith(
                          color: AppColors.blackColor.withAlpha(100),
                        ),
                      ),
                    ],
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
