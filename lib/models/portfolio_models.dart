import 'package:bostra/models/campaign_model.dart';

/// One position in the user's portfolio — all their investments into a single
/// campaign, collapsed into a single row with a derived implied value.
class PortfolioHolding {
  final CampaignModel campaign;

  /// Total the user has put into this campaign (summed across investments).
  final double invested;

  /// Estimated current worth, derived from the campaign's funding momentum.
  /// This is a traction-based proxy, not a market valuation.
  final double impliedValue;

  const PortfolioHolding({
    required this.campaign,
    required this.invested,
    required this.impliedValue,
  });

  String get startupName => campaign.startupName;

  String? get companyName => campaign.founderName;

  String? get logoUrl => campaign.logoUrl;

  String get sector => campaign.industry.trim().isNotEmpty
      ? campaign.industry.trim()
      : (campaign.category?.trim().isNotEmpty == true
          ? campaign.category!.trim()
          : 'Other');

  /// Implied gain/loss in percent. Positive = up.
  double get returnPct =>
      invested > 0 ? ((impliedValue - invested) / invested) * 100 : 0;
}

/// Share of the portfolio held in one sector — drives the diversity chart.
class SectorAllocation {
  final String label;
  final double amount;

  /// 0..1 share of total invested.
  final double fraction;

  const SectorAllocation({
    required this.label,
    required this.amount,
    required this.fraction,
  });

  int get percent => (fraction * 100).round();
}
