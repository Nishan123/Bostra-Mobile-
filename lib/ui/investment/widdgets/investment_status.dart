import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum InvestmentStatus {
  initial,
  active,
  raising,
  stopped;

  String get text {
    switch (this) {
      case InvestmentStatus.initial:
        return "Initial";
      case InvestmentStatus.active:
        return "Active";
      case InvestmentStatus.raising:
        return "Raising";
      case InvestmentStatus.stopped:
        return "Stopped";
    }
  }

  Color get color {
    switch (this) {
      case InvestmentStatus.initial:
        return AppColors.blackColor.withAlpha(120); // neutral grey
      case InvestmentStatus.active:
        return AppColors.primaryColor;
      case InvestmentStatus.raising:
        return const Color.fromARGB(255, 60, 255, 0); // Bright green from screenshot
      case InvestmentStatus.stopped:
        return AppColors.redColor;
    }
  }

  static InvestmentStatus fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'completed':
        return InvestmentStatus.active;
      case 'active':
      case 'verified':
      case 'raising':
      case 'raisingfund':
        return InvestmentStatus.raising;
      case 'stopped':
        return InvestmentStatus.stopped;
      case 'initial':
      default:
        return InvestmentStatus.initial;
    }
  }
}

class InvestmentStatusWidget extends StatelessWidget {
  final InvestmentStatus status;
  const InvestmentStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status.text, style: TextStyle(color: AppColors.whiteColor)),
    );
  }
}
