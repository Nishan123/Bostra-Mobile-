import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Backers list: "Backers till now | See All" header is handled by the parent.
/// This widget renders up to [visibleCount] backer tiles, then a centred "See All ∨" button.
class SdBackersList extends StatelessWidget {
  final int count;
  final double currentFunding;
  final int visibleCount;

  const SdBackersList({
    super.key,
    required this.count,
    required this.currentFunding,
    this.visibleCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final display = count.clamp(0, visibleCount);
    final perBacker =
        count > 0 ? (currentFunding / count) : 0.0;

    return Column(
      children: [
        ...List.generate(display, (i) {
          return _BackerTile(
            name: 'Backers Name',
            amount: perBacker > 0
                ? 'Rs ${perBacker.toStringAsFixed(0)}+'
                : 'Rs 200+',
          );
        }),
        const SizedBox(height: 2),
        TextButton(
          onPressed: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'See All  ∨',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BackerTile extends StatelessWidget {
  final String name;
  final String amount;
  const _BackerTile({required this.name, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.turnaryColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.blackColor.withAlpha(15),
                width: 0.8,
              ),
            ),
            child: Icon(
              LucideIcons.user,
              size: 18,
              color: AppColors.black10.withAlpha(100),
            ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(name, style: AppTextStyle.bodyText1),
          ),

          // Amount chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withAlpha(18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryColor.withAlpha(40),
                width: 0.6,
              ),
            ),
            child: Text(
              amount,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
