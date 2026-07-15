import 'package:bostra/models/reward_tier_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';

/// South-Asian (lakh) digit grouping for whole rupee amounts.
String formatRs(double v) {
  final s = v.toStringAsFixed(0);
  if (s.length <= 3) return s;
  final last3 = s.substring(s.length - 3);
  String rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

/// Trims trailing zeros from a percentage (0.50 → "0.5", 2.0 → "2").
String _fmtPercent(double p) {
  var s = p.toStringAsFixed(2);
  if (s.contains('.')) {
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  return s;
}

/// Investor-facing presentation of a single reward tier. Reused in the founder
/// preview, the startup-details rewards list, and the invest summary.
class RewardTierCard extends StatelessWidget {
  final RewardTierModel tier;

  /// Campaign funding goal — used to render the absolute amount for
  /// percentage-based tiers.
  final double goal;

  /// Render greyed-out with a lock (investor doesn't yet qualify).
  final bool locked;

  /// Emphasise this card (e.g. the highest tier the investor has unlocked).
  final bool highlighted;

  /// Optional 0..1 progress toward unlocking (shown only when [locked]).
  final double? progress;

  /// Optional status/label chip on the top-right (e.g. "Unlocked", "Delivered").
  final String? statusLabel;
  final Color? statusColor;

  const RewardTierCard({
    super.key,
    required this.tier,
    required this.goal,
    this.locked = false,
    this.highlighted = false,
    this.progress,
    this.statusLabel,
    this.statusColor,
  });

  String get _requirementLabel {
    if (tier.isPercentBased) {
      final pct = '${_fmtPercent(tier.minPercent!)}% of goal';
      if (goal > 0) return '$pct · Rs ${formatRs(tier.requiredAmount(goal))}';
      return pct;
    }
    return 'Rs ${formatRs(tier.minAmount ?? 0)}';
  }

  @override
  Widget build(BuildContext context) {
    final Color accent =
        locked ? AppColors.blackColor.withAlpha(90) : AppColors.primaryColor;
    final Color borderColor = highlighted
        ? AppColors.primaryColor
        : AppColors.primaryColor.withAlpha(locked ? 40 : 90);

    return Container(
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primaryColor.withAlpha(12)
            : AppColors.whiteColor,
        border: Border.all(color: borderColor, width: highlighted ? 1.4 : 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withAlpha(28),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tier.rewardType.icon, color: accent, size: 22),
              ),
              const SizedBox(width: 12),

              // Title + requirement
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.title.isNotEmpty ? tier.title : tier.typeLabel,
                      style: AppTextStyle.h4,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Invest $_requirementLabel',
                      style: AppTextStyle.bodyText3.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Status chip or lock/unlock icon
              if (statusLabel != null)
                _Chip(
                  label: statusLabel!,
                  color: statusColor ?? AppColors.primaryColor,
                  filled: true,
                )
              else
                Icon(
                  locked ? Icons.lock_outline : Icons.lock_open_outlined,
                  size: 18,
                  color: accent,
                ),
            ],
          ),

          if (tier.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              tier.description,
              style: AppTextStyle.bodyText2.copyWith(color: AppColors.blackColor),
            ),
          ],

          const SizedBox(height: 10),

          // Meta chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(label: tier.typeLabel, color: accent),
              if (tier.deliveryEstimate != null)
                _Chip(
                  label: 'Est. ${_fmtDate(tier.deliveryEstimate!)}',
                  color: AppColors.blackColor.withAlpha(140),
                  icon: Icons.event_outlined,
                ),
              if (tier.quantityLimit != null)
                _Chip(
                  label: '${tier.quantityLimit} available',
                  color: AppColors.secondryColor,
                  icon: Icons.inventory_2_outlined,
                ),
              if (tier.isRepeatable)
                _Chip(
                  label: 'Repeatable',
                  color: AppColors.blueColor,
                  icon: Icons.repeat,
                ),
            ],
          ),

          if (locked && progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.blackColor.withAlpha(20),
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress!.clamp(0.0, 1.0) * 100).toStringAsFixed(0)}% of the way to this tier',
              style: AppTextStyle.bodyText3,
            ),
          ],
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;

  const _Chip({
    required this.label,
    required this.color,
    this.icon,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color : color.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: filled ? AppColors.whiteColor : color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyle.bodyText3.copyWith(
              color: filled ? AppColors.whiteColor : color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
