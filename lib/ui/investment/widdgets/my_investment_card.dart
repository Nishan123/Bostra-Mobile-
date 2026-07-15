import 'package:bostra/controllers/reward_controller.dart';
import 'package:bostra/models/investment_model.dart';
import 'package:bostra/models/investment_reward_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/investment/widdgets/investment_status.dart';
import 'package:bostra/ui/investment/widdgets/p_l_indicator.dart';
import 'package:bostra/widgets/avatars_with_count.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyInvestmentCard extends ConsumerWidget {
  final InvestmentModel investment;
  const MyInvestmentCard({super.key, required this.investment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaign = investment.campaign;

    final status = campaign?.status ?? InvestmentStatus.initial;

    // Percentage of the funding goal this investment represents.
    final goal = campaign?.targetAmount ?? 0;
    final percent = goal > 0 ? investment.amount / goal * 100 : null;

    final rewardsAsync =
        ref.watch(investmentRewardsProvider(investment.id ?? ''));

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  child: (campaign?.logoUrl != null &&
                          campaign!.logoUrl!.isNotEmpty)
                      ? Image.network(campaign.logoUrl!, fit: BoxFit.cover)
                      : (campaign?.coverImageUrl != null &&
                              campaign!.coverImageUrl!.isNotEmpty)
                          ? Image.network(campaign.coverImageUrl!,
                              fit: BoxFit.cover)
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
                    if (percent != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${percent.toStringAsFixed(2)}% of funding goal',
                        style: AppTextStyle.bodyText3,
                      ),
                    ],
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

          // ── Earned rewards ─────────────────────────────────────────────
          rewardsAsync.maybeWhen(
            orElse: () => const SizedBox.shrink(),
            data: (rewards) => _EarnedRewards(rewards: rewards),
          ),
        ],
      ),
    );
  }
}

class _EarnedRewards extends StatelessWidget {
  final List<InvestmentRewardModel> rewards;
  const _EarnedRewards({required this.rewards});

  @override
  Widget build(BuildContext context) {
    if (rewards.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 2, right: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: AppColors.blackColor.withAlpha(15)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.card_giftcard_outlined,
                  size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 6),
              Text(
                '${rewards.length} reward${rewards.length == 1 ? '' : 's'} earned',
                style: AppTextStyle.bodyText2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in rewards)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withAlpha(16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(r.rewardType.icon,
                          size: 13, color: AppColors.primaryColor),
                      const SizedBox(width: 5),
                      Text(
                        r.title.isNotEmpty ? r.title : r.typeLabel,
                        style: AppTextStyle.bodyText3
                            .copyWith(color: AppColors.blackColor),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: r.status.color.withAlpha(45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          r.status.label,
                          style: AppTextStyle.bodyText3.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor.withAlpha(180),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
