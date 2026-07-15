import 'package:flutter/material.dart';

/// The kind of value an investor receives from a reward tier.
///
/// Preset types cover the common cases; [RewardType.custom] lets founders
/// define anything else (paired with a free-text label stored separately).
enum RewardType {
  earlyAccess,
  lifetimePremium,
  equity,
  revenueSharing,
  betaAccess,
  merchandise,
  community,
  vipEvents,
  founderCall,
  discount,
  nft,
  custom;

  /// Default human-readable label. For [custom], callers should prefer the
  /// founder-supplied label when present (see [displayLabel]).
  String get label {
    switch (this) {
      case RewardType.earlyAccess:
        return 'Early Product Access';
      case RewardType.lifetimePremium:
        return 'Lifetime Premium';
      case RewardType.equity:
        return 'Equity Ownership';
      case RewardType.revenueSharing:
        return 'Revenue Sharing';
      case RewardType.betaAccess:
        return 'Beta Access';
      case RewardType.merchandise:
        return 'Physical Merchandise';
      case RewardType.community:
        return 'Exclusive Community';
      case RewardType.vipEvents:
        return 'VIP Events';
      case RewardType.founderCall:
        return 'Founder Call';
      case RewardType.discount:
        return 'Product Discount';
      case RewardType.nft:
        return 'NFT / Digital Collectible';
      case RewardType.custom:
        return 'Custom Reward';
    }
  }

  /// Resolves the label to show, using [customLabel] for custom rewards.
  String displayLabel(String? customLabel) {
    if (this == RewardType.custom &&
        customLabel != null &&
        customLabel.trim().isNotEmpty) {
      return customLabel.trim();
    }
    return label;
  }

  IconData get icon {
    switch (this) {
      case RewardType.earlyAccess:
        return Icons.rocket_launch_outlined;
      case RewardType.lifetimePremium:
        return Icons.workspace_premium_outlined;
      case RewardType.equity:
        return Icons.pie_chart_outline;
      case RewardType.revenueSharing:
        return Icons.payments_outlined;
      case RewardType.betaAccess:
        return Icons.science_outlined;
      case RewardType.merchandise:
        return Icons.checkroom_outlined;
      case RewardType.community:
        return Icons.groups_outlined;
      case RewardType.vipEvents:
        return Icons.confirmation_number_outlined;
      case RewardType.founderCall:
        return Icons.call_outlined;
      case RewardType.discount:
        return Icons.local_offer_outlined;
      case RewardType.nft:
        return Icons.diamond_outlined;
      case RewardType.custom:
        return Icons.card_giftcard_outlined;
    }
  }

  /// Serialized value stored in the database (the enum name).
  String toJson() => name;

  static RewardType fromJson(String? value) {
    return RewardType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RewardType.custom,
    );
  }
}
