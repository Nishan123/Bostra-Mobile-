import 'package:bostra/enums/chips_options.dart';
import 'package:bostra/models/campaign_model.dart';
import 'package:equatable/equatable.dart';

/// Immutable set of criteria used to refine a list of campaigns.
///
/// Currently supports filtering by [industry] (reusing [ChipsOptions]) and by
/// the total amount a company is requesting ([minAmount]/[maxAmount], inclusive,
/// matched against [CampaignModel.targetAmount]).
class CampaignFilter extends Equatable {
  final ChipsOptions industry;
  final double? minAmount;
  final double? maxAmount;

  const CampaignFilter({
    this.industry = ChipsOptions.all,
    this.minAmount,
    this.maxAmount,
  });

  /// Whether any non-default criterion is set.
  bool get isActive =>
      industry != ChipsOptions.all || minAmount != null || maxAmount != null;

  /// True when [campaign] satisfies every active criterion.
  bool matches(CampaignModel campaign) {
    if (industry != ChipsOptions.all &&
        campaign.industry.trim().toLowerCase() !=
            industry.text.trim().toLowerCase()) {
      return false;
    }
    if (minAmount != null && campaign.targetAmount < minAmount!) return false;
    if (maxAmount != null && campaign.targetAmount > maxAmount!) return false;
    return true;
  }

  /// Returns [list] with non-matching campaigns removed (or [list] untouched
  /// when no criterion is active).
  List<CampaignModel> apply(List<CampaignModel> list) =>
      isActive ? list.where(matches).toList() : list;

  CampaignFilter copyWith({
    ChipsOptions? industry,
    double? minAmount,
    double? maxAmount,
    bool clearMin = false,
    bool clearMax = false,
  }) {
    return CampaignFilter(
      industry: industry ?? this.industry,
      minAmount: clearMin ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMax ? null : (maxAmount ?? this.maxAmount),
    );
  }

  @override
  List<Object?> get props => [industry, minAmount, maxAmount];
}
