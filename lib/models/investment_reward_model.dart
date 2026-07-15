import 'package:bostra/enums/reward_status.dart';
import 'package:bostra/enums/reward_type.dart';

/// An immutable snapshot of a reward an investment earned, copied from the
/// reward tier at investment time. Maps to the `investment_rewards` table.
/// Editing the original tier later never changes this snapshot.
class InvestmentRewardModel {
  final String? id;
  final String investmentId;
  final String? tierId;
  final String campaignId;
  final String investorId;

  // Snapshot of the tier.
  final String title;
  final String description;
  final RewardType rewardType;
  final String? customTypeLabel;
  final double? minPercent;
  final double? minAmount;
  final DateTime? deliveryEstimate;
  final String? imageUrl;
  final bool isRepeatable;

  // Context at investment time.
  final double percentAtInvestment;
  final double amountAtInvestment;

  final RewardStatus status;
  final DateTime? createdAt;

  const InvestmentRewardModel({
    this.id,
    required this.investmentId,
    this.tierId,
    required this.campaignId,
    required this.investorId,
    this.title = '',
    this.description = '',
    this.rewardType = RewardType.custom,
    this.customTypeLabel,
    this.minPercent,
    this.minAmount,
    this.deliveryEstimate,
    this.imageUrl,
    this.isRepeatable = false,
    this.percentAtInvestment = 0,
    this.amountAtInvestment = 0,
    this.status = RewardStatus.pending,
    this.createdAt,
  });

  String get typeLabel => rewardType.displayLabel(customTypeLabel);

  factory InvestmentRewardModel.fromJson(Map<String, dynamic> json) {
    return InvestmentRewardModel(
      id: json['id'] as String?,
      investmentId: json['investment_id'] as String,
      tierId: json['tier_id'] as String?,
      campaignId: json['campaign_id'] as String,
      investorId: json['investor_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rewardType: RewardType.fromJson(json['reward_type'] as String?),
      customTypeLabel: json['custom_type_label'] as String?,
      minPercent: (json['min_percent'] as num?)?.toDouble(),
      minAmount: (json['min_amount'] as num?)?.toDouble(),
      deliveryEstimate: json['delivery_estimate'] != null
          ? DateTime.parse(json['delivery_estimate'] as String)
          : null,
      imageUrl: json['image_url'] as String?,
      isRepeatable: json['is_repeatable'] as bool? ?? false,
      percentAtInvestment:
          (json['percent_at_investment'] as num?)?.toDouble() ?? 0,
      amountAtInvestment:
          (json['amount_at_investment'] as num?)?.toDouble() ?? 0,
      status: RewardStatus.fromJson(json['status'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
