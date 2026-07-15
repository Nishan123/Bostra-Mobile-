import 'package:bostra/models/reward_tier_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/widgets/reward_tier_card.dart';
import 'package:flutter/material.dart';

/// Compact, reorderable list item for a draft reward tier in the creation
/// editor. Shows the tier order, type, title and threshold with edit / delete
/// actions and a drag handle.
class RewardTierDraftTile extends StatelessWidget {
  final RewardTierModel tier;
  final int index;
  final double goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RewardTierDraftTile({
    super.key,
    required this.tier,
    required this.index,
    required this.goal,
    required this.onEdit,
    required this.onDelete,
  });

  String get _threshold {
    if (tier.isPercentBased) {
      final pct = tier.minPercent!;
      final s = pct == pct.roundToDouble()
          ? pct.toStringAsFixed(0)
          : pct.toString();
      return goal > 0
          ? '$s% · Rs ${formatRs(tier.requiredAmount(goal))}'
          : '$s% of goal';
    }
    return 'Rs ${formatRs(tier.minAmount ?? 0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border.all(color: AppColors.primaryColor.withAlpha(70)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Order badge
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${index + 1}',
              style: AppTextStyle.bodyText3.copyWith(
                color: AppColors.whiteColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(tier.rewardType.icon, size: 20, color: AppColors.primaryColor),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.title.isNotEmpty ? tier.title : tier.typeLabel,
                  style: AppTextStyle.bodyText1
                      .copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Invest $_threshold',
                  style: AppTextStyle.bodyText3
                      .copyWith(color: AppColors.primaryColor),
                ),
              ],
            ),
          ),

          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined,
                size: 20, color: AppColors.blackColor.withAlpha(160)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, size: 20, color: AppColors.redColor),
          ),
          ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.drag_indicator,
                color: AppColors.blackColor.withAlpha(90)),
          ),
        ],
      ),
    );
  }
}
