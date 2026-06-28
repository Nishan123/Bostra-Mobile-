import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/company/state/company_detail_state.dart';
import 'package:bostra/ui/investment/widdgets/investment_status.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:bostra/widgets/widget_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Campaigns section of the company detail screen — title, the list of
/// campaigns, and either a launch button or the verification-locked notice.
class CampaignsSection extends StatelessWidget {
  final CompanyDetailState state;
  final bool isVerified;
  final VoidCallback onLaunch;
  final void Function(CampaignModel campaign) onManage;

  const CampaignsSection({
    super.key,
    required this.state,
    required this.isVerified,
    required this.onLaunch,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final campaigns = state.campaigns;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetTitle(text: 'Campaigns (${campaigns.length})'),
        if (campaigns.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 16, 8),
            child: Text(
              'No campaigns under this company yet. Launch one to start raising.',
              style: AppTextStyle.bodyText2,
            ),
          )
        else
          ...campaigns.map(
            (c) => _CampaignRow(campaign: c, onManage: () => onManage(c)),
          ),
        const SizedBox(height: 16),
        if (isVerified)
          PrimaryButton(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            text: 'Launch a campaign',
            onTap: onLaunch,
          )
        else
          const _LaunchLockedNotice(),
      ],
    );
  }
}

/// Shown in place of the launch button while a company is unverified.
class _LaunchLockedNotice extends StatelessWidget {
  const _LaunchLockedNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.yelloColor.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.yelloColor.withAlpha(120)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.lock, size: 18, color: AppColors.secondryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Campaigns are locked until this company is verified. '
              'You can launch once verification is complete.',
              style: AppTextStyle.bodyText2.copyWith(
                color: AppColors.blackColor.withAlpha(200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignRow extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback onManage;
  const _CampaignRow({required this.campaign, required this.onManage});

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.blackColor.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  campaign.startupName.isNotEmpty
                      ? campaign.startupName
                      : 'Untitled campaign',
                  style: AppTextStyle.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InvestmentStatusWidget(status: campaign.status),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: campaign.fundingProgress,
              minHeight: 6,
              backgroundColor: AppColors.blackColor.withAlpha(25),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'NPR ${campaign.currentFunding.toStringAsFixed(0)} / ${campaign.targetAmount.toStringAsFixed(0)}',
                  style: AppTextStyle.bodyText3,
                ),
              ),
              Text(
                'Ends ${_formatDate(campaign.endDate)}',
                style: AppTextStyle.bodyText3,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onManage,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(
                LucideIcons.settings_2,
                size: 16,
                color: AppColors.primaryColor,
              ),
              label: Text(
                'Manage',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
