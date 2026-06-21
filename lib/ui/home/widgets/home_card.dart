import 'dart:ui';

import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/saved/view_model/saved_campaign_view_model.dart';
import 'package:bostra/widgets/avatars_with_count.dart';
import 'package:bostra/widgets/fund_progress_bar.dart';
import 'package:bostra/widgets/info_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeCard extends ConsumerWidget {
  final CampaignModel campaign;

  const HomeCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Granular select so only this card rebuilds when its saved state changes.
    final isSaved = ref.watch(
      savedCampaignViewModelProvider
          .select((s) => s.savedIds.contains(campaign.id)),
    );

    return GestureDetector(
      onTap: () => context.pushNamed(
        'startupDetails',
        extra: campaign,
      ),
      child: Container(
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
          // ── Cover image ─────────────────────────────────────────────────
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
                if (campaign.coverImageUrl != null)
                  Image.network(
                    campaign.coverImageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),

                // ── Like / save button ───────────────────────────────────
                Positioned(
                  top: 10,
                  right: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: GestureDetector(
                        onTap: () => ref
                            .read(savedCampaignViewModelProvider.notifier)
                            .toggleSave(campaign),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.turnaryColor,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            isSaved
                                ? Icons.favorite
                                : LucideIcons.heart,
                            color: isSaved
                                ? Colors.red
                                : AppColors.whiteColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Card details ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  campaign.startupName,
                  style: AppTextStyle.h2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                FundProgressBar(value: campaign.fundingProgress),

                Row(
                  spacing: 8,
                  children: [
                    Text(
                      'Rs ${campaign.currentFunding.toStringAsFixed(0)}',
                      style: AppTextStyle.h3,
                    ),
                    const Text('Raised of'),
                    Text('Rs ${campaign.targetAmount.toStringAsFixed(0)}'),
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
                    InfoChip(text: '${campaign.totalInvestors} investors'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),   // GestureDetector
    );
  }
}
