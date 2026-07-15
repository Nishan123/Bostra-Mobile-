import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Fulfillment state of an earned reward snapshot.
enum RewardStatus {
  pending,
  delivered,
  claimed;

  String get label {
    switch (this) {
      case RewardStatus.pending:
        return 'Pending';
      case RewardStatus.delivered:
        return 'Delivered';
      case RewardStatus.claimed:
        return 'Claimed';
    }
  }

  Color get color {
    switch (this) {
      case RewardStatus.pending:
        return AppColors.yelloColor;
      case RewardStatus.delivered:
        return AppColors.primaryColor;
      case RewardStatus.claimed:
        return AppColors.blueColor;
    }
  }

  String toJson() => name;

  static RewardStatus fromJson(String? value) {
    return RewardStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RewardStatus.pending,
    );
  }
}
