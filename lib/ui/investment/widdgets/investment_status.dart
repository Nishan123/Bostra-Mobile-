import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum InvestmentStatus {
  active,
  raisingFund,
  stopped;

  String get text {
    switch (this) {
      case InvestmentStatus.active:
        return "Active";
      case InvestmentStatus.raisingFund:
        return "Raising Fund";
      case InvestmentStatus.stopped:
        return "Stopped";
    }
  }

  Color get color {
    switch (this) {
      case InvestmentStatus.active:
        return AppColors.primaryColor;
      case InvestmentStatus.raisingFund:
        return AppColors.yelloColor;
      case InvestmentStatus.stopped:
        return AppColors.redColor;
    }
  }
}

class InvestmentStatusWidget extends StatelessWidget {
  final InvestmentStatus status;
  const InvestmentStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status.text, style: TextStyle(color: AppColors.whiteColor)),
    );
  }
}
