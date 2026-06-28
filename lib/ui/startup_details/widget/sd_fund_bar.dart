import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';

/// Sticky bottom funding bar: shows the "you've backed" note, and either the
/// Fund Now button or the funding-closed notice when the due date has passed.
class SdFundBar extends StatelessWidget {
  final CampaignModel campaign;
  final bool hasInvested;
  final VoidCallback onFund;

  const SdFundBar({
    super.key,
    required this.campaign,
    required this.hasInvested,
    required this.onFund,
  });

  @override
  Widget build(BuildContext context) {
    final c = campaign;
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.blackColor.withAlpha(20),
            width: 0.6,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasInvested) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle,
                    size: 16, color: AppColors.primaryColor),
                const SizedBox(width: 6),
                Text(
                  "You've backed this campaign",
                  style: AppTextStyle.bodyText3.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (c.isPastDueDate)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.blackColor.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Funding closed — due date passed',
                style: AppTextStyle.bodyText1.copyWith(
                  color: AppColors.blackColor.withAlpha(140),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            PrimaryButton(
              text: hasInvested ? 'Add More Funding' : 'Fund Now',
              onTap: onFund,
            ),
        ],
      ),
    );
  }
}
