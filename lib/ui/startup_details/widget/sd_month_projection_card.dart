import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';

/// A flat card for a single month projection — matches the design screenshot:
/// shows the month badge + label in a header row, then the content text
/// (objectives/goals/initiative) directly below, with a "Read More" inline link.
class SdMonthProjectionCard extends StatefulWidget {
  final MonthProjection projection;
  const SdMonthProjectionCard({super.key, required this.projection});

  @override
  State<SdMonthProjectionCard> createState() => _SdMonthProjectionCardState();
}

class _SdMonthProjectionCardState extends State<SdMonthProjectionCard> {
  bool _expanded = false;

  MonthProjection get mp => widget.projection;

  String get _fullContent {
    return [mp.objectives, mp.goals, mp.initiative]
        .where((s) => s.isNotEmpty)
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final content = _fullContent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.blackColor.withAlpha(25),
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Month badge + label row ────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withAlpha(22),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Month ${mp.monthNumber}',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                mp.monthLabel,
                style: AppTextStyle.bodyText2,
              ),
            ],
          ),

          if (content.isNotEmpty) ...[
            const SizedBox(height: 10),
            // ── Content text + inline Read More ──────────────────────────
            Text(
              content,
              style: AppTextStyle.bodyText2.copyWith(
                color: AppColors.blackColor.withAlpha(160),
                height: 1.55,
              ),
              maxLines: _expanded ? null : 4,
              overflow: _expanded ? null : TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Show Less' : 'Read More',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
