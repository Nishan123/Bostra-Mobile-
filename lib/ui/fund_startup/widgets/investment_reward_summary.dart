import 'package:bostra/controllers/reward_controller.dart';
import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/models/reward_tier_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/widgets/reward_tier_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live summary of the rewards an investment of [amount] would unlock, shown
/// under the amount field on the fund screen. Encourages larger investments by
/// surfacing the next tier and how much more is needed.
class InvestmentRewardSummary extends ConsumerWidget {
  final CampaignModel campaign;
  final double amount;

  const InvestmentRewardSummary({
    super.key,
    required this.campaign,
    required this.amount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignId = campaign.id ?? '';
    if (campaignId.isEmpty) return const SizedBox.shrink();

    final tiersAsync = ref.watch(rewardTiersProvider(campaignId));
    return tiersAsync.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (tiers) {
        if (tiers.isEmpty) return const SizedBox.shrink();

        final goal = campaign.targetAmount;
        final percent = (amount > 0 && goal > 0) ? amount / goal * 100 : 0.0;
        final unlocked = RewardTierModel.unlockedTiers(tiers, amount, goal);
        final next = RewardTierModel.nextLockedTier(tiers, amount, goal);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withAlpha(12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryColor.withAlpha(60)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.card_giftcard_outlined,
                      size: 18, color: AppColors.primaryColor),
                  const SizedBox(width: 8),
                  Text('Your rewards',
                      style: AppTextStyle.h4
                          .copyWith(color: AppColors.primaryColor)),
                ],
              ),
              const SizedBox(height: 8),

              if (amount <= 0)
                Text(
                  'Enter an amount to see the rewards you\'ll unlock.',
                  style: AppTextStyle.bodyText2
                      .copyWith(color: AppColors.blackColor.withAlpha(160)),
                )
              else ...[
                Text.rich(
                  TextSpan(
                    style: AppTextStyle.bodyText1
                        .copyWith(color: AppColors.blackColor),
                    children: [
                      const TextSpan(text: 'You are investing '),
                      TextSpan(
                        text: '${percent.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const TextSpan(text: ' of this campaign.'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (unlocked.isEmpty)
                  Text(
                    next == null
                        ? 'No rewards match this amount yet.'
                        : 'Invest Rs ${formatRs(next.requiredAmount(goal))} to unlock '
                            'your first reward: ${next.title}.',
                    style: AppTextStyle.bodyText2
                        .copyWith(color: AppColors.blackColor),
                  )
                else ...[
                  Text('Rewards you will receive:',
                      style: AppTextStyle.bodyText2
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  for (final tier in unlocked)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(tier.rewardType.icon,
                              size: 16, color: AppColors.primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tier.title.isNotEmpty ? tier.title : tier.typeLabel,
                              style: AppTextStyle.bodyText2
                                  .copyWith(color: AppColors.blackColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],

                if (next != null) ...[
                  const SizedBox(height: 10),
                  _NextTierNudge(
                    needed: (next.requiredAmount(goal) - amount)
                        .clamp(0, double.infinity)
                        .toDouble(),
                    tierTitle: next.title.isNotEmpty
                        ? next.title
                        : next.typeLabel,
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _NextTierNudge extends StatelessWidget {
  final double needed;
  final String tierTitle;
  const _NextTierNudge({required this.needed, required this.tierTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.yelloColor.withAlpha(40),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt, size: 18, color: AppColors.secondryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppTextStyle.bodyText2
                    .copyWith(color: AppColors.blackColor),
                children: [
                  const TextSpan(text: 'Only '),
                  TextSpan(
                    text: 'Rs ${formatRs(needed)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: ' more to unlock $tierTitle.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
