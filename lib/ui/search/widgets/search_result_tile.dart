import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/widgets/fund_progress_bar.dart';
import 'package:bostra/widgets/info_chip.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A single row in the search-results list. Tapping opens the startup details.
class SearchResultTile extends StatelessWidget {
  final CampaignModel campaign;

  const SearchResultTile({super.key, required this.campaign});

  /// South-Asian (lakh) digit grouping: 100000 → "1,00,000".
  String _grouped(double v) {
    final s = v.toStringAsFixed(0);
    final negative = s.startsWith('-');
    String digits = negative ? s.substring(1) : s;
    if (digits.length <= 3) return '${negative ? '-' : ''}$digits';

    final last3 = digits.substring(digits.length - 3);
    String rest = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '${negative ? '-' : ''}${parts.join(',')},$last3';
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final subtitle =
        campaign.shortTagline.isNotEmpty ? campaign.shortTagline : campaign.industry;
    final amountStyle = AppTextStyle.bodyText2.copyWith(
      color: AppColors.blackColor.withAlpha(140),
    );

    return GestureDetector(
      onTap: () => context.pushNamed('startupDetails', extra: campaign),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          border: Border.all(
            width: 0.6,
            color: AppColors.primaryColor.withAlpha(100),
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Cover thumbnail ────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: mq.width * 0.26,
                  child: campaign.coverImageUrl != null
                      ? Image.network(campaign.coverImageUrl!, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.turnaryColor,
                          child: Icon(
                            Icons.image_outlined,
                            color: AppColors.blackColor.withAlpha(60),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Details ────────────────────────────────────────────────────
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.startupName,
                      style: AppTextStyle.h4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyle.bodyText3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    FundProgressBar(value: campaign.fundingProgress),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('Rs ${_grouped(campaign.currentFunding)}',
                            style: amountStyle),
                        const Spacer(),
                        InfoChip(text: campaign.fundingCountdownLabel),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
