import 'package:bostra/models/campaign_model.dart';

class InvestmentModel {
  final String? id;
  final String campaignId;
  final String investorId;
  final double amount;
  final DateTime? createdAt;
  final CampaignModel? campaign;

  const InvestmentModel({
    this.id,
    required this.campaignId,
    required this.investorId,
    required this.amount,
    this.createdAt,
    this.campaign,
  });

  factory InvestmentModel.fromJson(Map<String, dynamic> json) {
    return InvestmentModel(
      id: json['id'] as String?,
      campaignId: json['campaign_id'] as String,
      investorId: json['investor_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      campaign: json['campaign'] != null
          ? CampaignModel.fromJson(json['campaign'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'campaign_id': campaignId,
      'investor_id': investorId,
      'amount': amount,
      if (campaign != null) 'campaign': campaign!.toJson(),
    };
  }
}

