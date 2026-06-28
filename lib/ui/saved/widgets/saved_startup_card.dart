import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/saved/view_model/saved_campaign_view_model.dart';
import 'package:bostra/widgets/avatars_with_count.dart';
import 'package:bostra/widgets/fund_progress_bar.dart';
import 'package:bostra/widgets/info_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SavedStartupCard extends ConsumerWidget {
  final CampaignModel campaign;

  const SavedStartupCard({super.key, required this.campaign});

  /// South-Asian (lakh) digit grouping: 100000 → "1,00,000", 20000 → "20,000".
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

  Future<bool> _confirmUnsave(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove from saved?'),
        content: Text(
          '"${campaign.startupName}" will be removed from your saved startups.',
          style: AppTextStyle.bodyText2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: AppColors.blackColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Unsave', style: TextStyle(color: AppColors.redColor)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(campaign.id ?? campaign.startupName),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmUnsave(context),
      onDismissed: (_) => ref
          .read(savedCampaignViewModelProvider.notifier)
          .toggleSave(campaign),
      background: const _SwipeToUnsaveBackground(),
      child: _CardBody(campaign: campaign, grouped: _grouped),
    );
  }
}

class _CardBody extends StatelessWidget {
  final CampaignModel campaign;
  final String Function(double) grouped;

  const _CardBody({required this.campaign, required this.grouped});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final amountStyle = AppTextStyle.bodyText1.copyWith(
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
          borderRadius: BorderRadius.circular(22),
        ),
        margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
        padding: const EdgeInsets.all(10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Cover image ────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: mq.width * 0.30,
                  child: campaign.coverImageUrl != null
                      ? Image.network(
                          campaign.coverImageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(color: AppColors.turnaryColor),
                ),
              ),
              const SizedBox(width: 12),

              // ── Details ────────────────────────────────────────────────
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.startupName,
                      style: AppTextStyle.h1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    FundProgressBar(value: campaign.fundingProgress),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Text('Rs ${grouped(campaign.currentFunding)}',
                            style: amountStyle),
                        const Spacer(),
                        Text('Rs ${grouped(campaign.targetAmount)}',
                            style: amountStyle),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: InfoChip(text: campaign.fundingCountdownLabel),
                    ),
                    const SizedBox(height: 12),

                    AvatarsWithCount(
                      investorIds: campaign.investors,
                      totalBackers: campaign.totalInvestors,
                      avatarSize: 40,
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

/// Red reveal shown while swiping a card left to unsave.
class _SwipeToUnsaveBackground extends StatelessWidget {
  const _SwipeToUnsaveBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: AppColors.redColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.heart_off, color: AppColors.whiteColor, size: 20),
          const SizedBox(width: 8),
          Text(
            'Unsave',
            style: AppTextStyle.bodyText1.copyWith(
              color: AppColors.whiteColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
