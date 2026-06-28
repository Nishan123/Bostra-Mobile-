import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';

/// A flat card for a single month projection — matches the design screenshot:
/// features a full-width teal header bar with uniform borders and a clean flat structure.
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

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Bar ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Month ${mp.monthNumber}',
                  style: AppTextStyle.bodyText2.copyWith(color:AppColors.whiteColor,fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 1,
                      color: AppColors.whiteColor
                    ),
                  ),
                ),
                Text(
                  mp.monthLabel,
                  style: AppTextStyle.bodyText2.copyWith(color: AppColors.whiteColor)
                ),
              ],
            ),
          ),

          // ── Content Area ─────────────────────────────────────────────
          if (content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: AppTextStyle.bodyText1,
                    maxLines: _expanded ? null : 4,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded ? 'Show Less' : 'Read More',
                      style: const TextStyle(
                        color: Colors.blue, // Primary interactive action accent
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}