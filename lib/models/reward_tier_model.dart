import 'package:bostra/enums/reward_type.dart';

/// A reward tier a founder defines for a campaign. Maps to the
/// `campaign_reward_tiers` table. A tier unlocks for an investment that meets
/// EITHER the percentage-of-goal threshold ([minPercent]) or the fixed-amount
/// threshold ([minAmount]).
class RewardTierModel {
  final String? id;
  final String? campaignId;
  final String title;
  final String description;
  final RewardType rewardType;
  final String? customTypeLabel;
  final double? minPercent;
  final double? minAmount;
  final DateTime? deliveryEstimate;
  final int? quantityLimit;
  final String? imageUrl;
  final bool isRepeatable;
  final int sortOrder;

  const RewardTierModel({
    this.id,
    this.campaignId,
    this.title = '',
    this.description = '',
    this.rewardType = RewardType.custom,
    this.customTypeLabel,
    this.minPercent,
    this.minAmount,
    this.deliveryEstimate,
    this.quantityLimit,
    this.imageUrl,
    this.isRepeatable = false,
    this.sortOrder = 0,
  });

  /// Label to show for the reward type (custom label wins for custom rewards).
  String get typeLabel => rewardType.displayLabel(customTypeLabel);

  /// Whether the tier's threshold is expressed as a percentage of the goal.
  bool get isPercentBased => minPercent != null;

  /// The absolute investment amount required to unlock this tier for a campaign
  /// whose funding goal is [goal].
  double requiredAmount(double goal) {
    if (minAmount != null) return minAmount!;
    if (minPercent != null && goal > 0) return minPercent! / 100 * goal;
    return 0;
  }

  /// Whether investing [amount] into a campaign with goal [goal] unlocks this
  /// tier.
  bool isUnlockedBy(double amount, double goal) {
    final required = requiredAmount(goal);
    if (required <= 0) return amount > 0;
    // Small epsilon so a "2%" tier unlocks at an exactly-2% investment despite
    // floating point rounding.
    return amount >= required - 0.01;
  }

  RewardTierModel copyWith({
    String? id,
    String? campaignId,
    String? title,
    String? description,
    RewardType? rewardType,
    String? customTypeLabel,
    double? minPercent,
    double? minAmount,
    DateTime? deliveryEstimate,
    int? quantityLimit,
    String? imageUrl,
    bool? isRepeatable,
    int? sortOrder,
    bool clearMinPercent = false,
    bool clearMinAmount = false,
    bool clearDelivery = false,
    bool clearQuantity = false,
    bool clearImage = false,
  }) {
    return RewardTierModel(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardType: rewardType ?? this.rewardType,
      customTypeLabel: customTypeLabel ?? this.customTypeLabel,
      minPercent: clearMinPercent ? null : (minPercent ?? this.minPercent),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      deliveryEstimate:
          clearDelivery ? null : (deliveryEstimate ?? this.deliveryEstimate),
      quantityLimit: clearQuantity ? null : (quantityLimit ?? this.quantityLimit),
      imageUrl: clearImage ? null : (imageUrl ?? this.imageUrl),
      isRepeatable: isRepeatable ?? this.isRepeatable,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory RewardTierModel.fromJson(Map<String, dynamic> json) {
    return RewardTierModel(
      id: json['id'] as String?,
      campaignId: json['campaign_id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rewardType: RewardType.fromJson(json['reward_type'] as String?),
      customTypeLabel: json['custom_type_label'] as String?,
      minPercent: (json['min_percent'] as num?)?.toDouble(),
      minAmount: (json['min_amount'] as num?)?.toDouble(),
      deliveryEstimate: json['delivery_estimate'] != null
          ? DateTime.parse(json['delivery_estimate'] as String)
          : null,
      quantityLimit: json['quantity_limit'] as int?,
      imageUrl: json['image_url'] as String?,
      isRepeatable: json['is_repeatable'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  /// Column map for inserting/updating the tier. [campaignId] and [sortOrder]
  /// are supplied by the caller because a draft tier may not know them yet.
  Map<String, dynamic> toInsertJson({
    required String campaignId,
    required int sortOrder,
  }) {
    return {
      'campaign_id': campaignId,
      'title': title,
      'description': description,
      'reward_type': rewardType.toJson(),
      'custom_type_label': customTypeLabel,
      'min_percent': minPercent,
      'min_amount': minAmount,
      'delivery_estimate': deliveryEstimate?.toIso8601String().split('T').first,
      'quantity_limit': quantityLimit,
      'image_url': imageUrl,
      'is_repeatable': isRepeatable,
      'sort_order': sortOrder,
    };
  }

  // ── Eligibility helpers over a list of tiers ────────────────────────────────

  /// Tiers ordered by the amount required to unlock them (ascending).
  static List<RewardTierModel> sortedByThreshold(
    List<RewardTierModel> tiers,
    double goal,
  ) {
    final copy = [...tiers];
    copy.sort((a, b) {
      final c = a.requiredAmount(goal).compareTo(b.requiredAmount(goal));
      return c != 0 ? c : a.sortOrder.compareTo(b.sortOrder);
    });
    return copy;
  }

  /// Tiers unlocked by investing [amount] (ascending by threshold).
  static List<RewardTierModel> unlockedTiers(
    List<RewardTierModel> tiers,
    double amount,
    double goal,
  ) =>
      sortedByThreshold(tiers, goal)
          .where((t) => t.isUnlockedBy(amount, goal))
          .toList();

  /// The cheapest tier NOT yet unlocked by [amount], or null if all unlocked.
  static RewardTierModel? nextLockedTier(
    List<RewardTierModel> tiers,
    double amount,
    double goal,
  ) {
    for (final t in sortedByThreshold(tiers, goal)) {
      if (!t.isUnlockedBy(amount, goal)) return t;
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RewardTierModel && id != null && other.id == id;
  }

  @override
  int get hashCode => id?.hashCode ?? identityHashCode(this);
}
