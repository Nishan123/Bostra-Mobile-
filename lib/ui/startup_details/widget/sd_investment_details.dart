import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/ui/startup_details/widget/sd_detail_row.dart';
import 'package:bostra/ui/startup_details/widget/sd_section.dart';
import 'package:flutter/material.dart';

/// Key investment facts (minimum, equity, target, industry, founder) for the
/// startup details screen.
class SdInvestmentDetails extends StatelessWidget {
  final CampaignModel campaign;
  const SdInvestmentDetails({super.key, required this.campaign});

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final c = campaign;
    return SdSection(
      child: Column(
        children: [
          if (c.minimumInvestment > 0)
            SdDetailRow(
              label: 'Minimum Investment',
              value: 'Rs ${_fmt(c.minimumInvestment)}',
            ),
          if (c.equityOffered > 0)
            SdDetailRow(
              label: 'Equity Offered',
              value: '${c.equityOffered.toStringAsFixed(1)}%',
            ),
          SdDetailRow(
            label: 'Target Amount',
            value: 'Rs ${_fmt(c.targetAmount)}',
          ),
          if (c.industry.isNotEmpty)
            SdDetailRow(label: 'Industry', value: c.industry),
          if (c.founderName != null)
            SdDetailRow(label: 'Founder', value: c.founderName!),
        ],
      ),
    );
  }
}
