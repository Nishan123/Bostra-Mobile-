import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/portfolio/state/portfolio_state.dart';
import 'package:flutter/material.dart';

/// Total invested vs. implied value, with the overall return.
class TotalsHeader extends StatelessWidget {
  final PortfolioState state;
  const TotalsHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final up = state.totalReturnPct >= 0;
    final returnColor = up ? AppColors.primaryColor : AppColors.redColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: AppColors.blackColor.withAlpha(80)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Invested', style: AppTextStyle.bodyText2),
              const SizedBox(height: 4),
              Text(
                'Rs ${state.totalInvested.toStringAsFixed(0)}',
                style: AppTextStyle.h1.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Implied Value', style: AppTextStyle.bodyText2),
              const SizedBox(height: 4),
              Text(
                'Rs ${state.totalImpliedValue.toStringAsFixed(0)}',
                style: AppTextStyle.h4,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    up ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: returnColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${up ? '+' : ''}${state.totalReturnPct.toStringAsFixed(1)}%',
                    style: AppTextStyle.bodyText2.copyWith(
                      color: returnColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
