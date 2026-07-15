import 'package:bostra/controllers/reward_controller.dart';
import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/models/investment_reward_model.dart';
import 'package:bostra/models/reward_tier_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/widgets/reward_tier_card.dart';
import 'package:bostra/widgets/widget_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Investor Rewards" section on the startup details screen. Lists every reward
/// tier in ascending order with locked/unlocked states, and highlights the
/// highest tier the signed-in investor has already unlocked.
class SdRewardTiers extends ConsumerWidget {
  final CampaignModel campaign;
  const SdRewardTiers({super.key, required this.campaign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignId = campaign.id ?? '';
    if (campaignId.isEmpty) return const SizedBox.shrink();

    final tiersAsync = ref.watch(rewardTiersProvider(campaignId));
    final myRewardsAsync = ref.watch(myCampaignRewardsProvider(campaignId));

    return tiersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (tiers) {
        // Hide the whole section for campaigns that never defined rewards.
        if (tiers.isEmpty) return const SizedBox.shrink();

        final goal = campaign.targetAmount;
        final sorted = RewardTierModel.sortedByThreshold(tiers, goal);

        final myRewards =
            myRewardsAsync.asData?.value ?? const <InvestmentRewardModel>[];
        final earnedTierIds =
            myRewards.map((r) => r.tierId).whereType<String>().toSet();
        final double refAmount = myRewards.isEmpty
            ? 0
            : myRewards
                .map((r) => r.amountAtInvestment)
                .reduce((a, b) => a > b ? a : b);

        // Highest unlocked tier (by threshold) to emphasise.
        RewardTierModel? highestUnlocked;
        for (final t in sorted) {
          if (t.id != null && earnedTierIds.contains(t.id)) highestUnlocked = t;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WidgetTitle(text: 'Investor Rewards'),
            if (earnedTierIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Text(
                  'You\'ve unlocked ${earnedTierIds.length} of ${tiers.length} rewards.',
                  style: AppTextStyle.bodyText2
                      .copyWith(color: AppColors.primaryColor),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                children: [
                  for (final tier in sorted) ...[
                    Builder(builder: (_) {
                      final unlocked =
                          tier.id != null && earnedTierIds.contains(tier.id);
                      final required = tier.requiredAmount(goal);
                      final progress = (!unlocked && refAmount > 0 && required > 0)
                          ? refAmount / required
                          : null;
                      return RewardTierCard(
                        tier: tier,
                        goal: goal,
                        locked: !unlocked,
                        highlighted: identical(tier, highestUnlocked),
                        progress: progress,
                        statusLabel: unlocked ? 'Unlocked' : null,
                      );
                    }),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
