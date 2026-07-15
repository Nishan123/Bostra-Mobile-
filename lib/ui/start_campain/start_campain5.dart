import 'package:bostra/models/reward_tier_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/start_campain/state/campaign_state.dart';
import 'package:bostra/ui/start_campain/view_model/start_campaign_view_model.dart';
import 'package:bostra/ui/start_campain/widgets/campain_app_bar.dart';
import 'package:bostra/ui/start_campain/widgets/reward_tier_draft_tile.dart';
import 'package:bostra/ui/start_campain/widgets/reward_tier_form_sheet.dart';
import 'package:bostra/ui/start_campain/widgets/start_campain_progress.dart';
import 'package:bostra/widgets/custom_snackbar.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:bostra/widgets/reward_tier_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Step 5 of campaign creation: define the investor rewards. At least one tier
/// is required before the campaign can be published.
class StartCampain5 extends ConsumerWidget {
  const StartCampain5({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<CampaignState>(campaignViewModelProvider, (previous, next) {
      if (next.status == CampaignStatus.success) {
        CustomSnackBar.showSuccessSnackBar(
            context, 'Campaign created successfully!');
        ref.read(campaignViewModelProvider.notifier).resetStatus();
        context.go('/main');
      } else if (next.status == CampaignStatus.error) {
        CustomSnackBar.showErrorSnackBar(
            context, next.errorMessage ?? 'Failed to start campaign');
        ref.read(campaignViewModelProvider.notifier).resetStatus();
      }
    });

    final state = ref.watch(campaignViewModelProvider);
    final notifier = ref.read(campaignViewModelProvider.notifier);
    final tiers = state.rewardTiers;
    final goal = state.campaign.targetAmount;

    Future<void> addTier() async {
      final tier = await showRewardTierForm(context, goal: goal);
      if (tier != null) notifier.addRewardTier(tier);
    }

    Future<void> editTier(int index) async {
      final tier = await showRewardTierForm(
        context,
        existing: tiers[index],
        goal: goal,
      );
      if (tier != null) notifier.updateRewardTier(index, tier);
    }

    return Scaffold(
      appBar: CampainAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StartCampainProgress(currentStep: 5, totalSteps: 5),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Investor Rewards', style: AppTextStyle.h2),
                          const SizedBox(height: 6),
                          Text(
                            'Give investors a reason to back you. Add reward tiers '
                            'that unlock as they invest more of your goal.',
                            style: AppTextStyle.bodyText2.copyWith(
                              color: AppColors.blackColor.withAlpha(160),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (tiers.isEmpty)
                      _EmptyState(onAdd: addTier)
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          itemCount: tiers.length,
                          onReorder: notifier.reorderRewardTiers,
                          itemBuilder: (context, index) => RewardTierDraftTile(
                            key: ObjectKey(tiers[index]),
                            tier: tiers[index],
                            index: index,
                            goal: goal,
                            onEdit: () => editTier(index),
                            onDelete: () => notifier.removeRewardTier(index),
                          ),
                        ),
                      ),

                    if (tiers.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: _AddTierButton(onTap: addTier),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Bottom actions ─────────────────────────────────────────────
            if (tiers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
                child: TextButton.icon(
                  onPressed: () => _showPreview(context, tiers, goal),
                  icon: Icon(Icons.visibility_outlined,
                      size: 18, color: AppColors.primaryColor),
                  label: Text(
                    'Preview how investors see this',
                    style: AppTextStyle.bodyText2
                        .copyWith(color: AppColors.primaryColor),
                  ),
                ),
              ),
            PrimaryButton(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              text: 'Publish Campaign',
              isLoading: state.status == CampaignStatus.loading,
              onTap: () {
                if (tiers.isEmpty) {
                  CustomSnackBar.showErrorSnackBar(
                    context,
                    'Add at least one reward tier before publishing.',
                  );
                  return;
                }
                notifier.submitCampaign();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPreview(
    BuildContext context,
    List<RewardTierModel> tiers,
    double goal,
  ) {
    final sorted = RewardTierModel.sortedByThreshold(tiers, goal);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.blackColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Investor Preview', style: AppTextStyle.h2),
            const SizedBox(height: 4),
            Text(
              'This is how your reward tiers appear to investors.',
              style: AppTextStyle.bodyText2
                  .copyWith(color: AppColors.blackColor.withAlpha(160)),
            ),
            const SizedBox(height: 16),
            for (final tier in sorted) ...[
              RewardTierCard(tier: tier, goal: goal, locked: true),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddTierButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTierButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryColor.withAlpha(140),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 18, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Add reward tier',
              style: AppTextStyle.bodyText1.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.card_giftcard_outlined,
                size: 40, color: AppColors.primaryColor),
          ),
          const SizedBox(height: 16),
          Text('No rewards yet',
              style: AppTextStyle.h3, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            'Every campaign needs at least one investor reward. '
            'Create tiers that unlock as investors contribute more.',
            style: AppTextStyle.bodyText2
                .copyWith(color: AppColors.blackColor.withAlpha(150)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _AddTierButton(onTap: onAdd),
        ],
      ),
    );
  }
}
