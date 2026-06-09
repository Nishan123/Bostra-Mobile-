import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';

enum StatCardVariant { teal, purple, amber }

class StatCard extends StatelessWidget {
  final String title;
  final num data;
  final String prefix;
  final String suffix;
  final bool isInt;
  final IconData icon;
  final StatCardVariant variant;

  const StatCard({
    super.key,
    required this.title,
    required this.data,
    required this.icon,
    this.prefix = '',
    this.suffix = '',
    this.isInt = true,
    this.variant = StatCardVariant.teal,
  });

  Color get _accentColor {
    switch (variant) {
      case StatCardVariant.teal:   return const Color(0xFF1D9E75);
      case StatCardVariant.purple: return const Color(0xFF7F77DD);
      case StatCardVariant.amber:  return const Color(0xFFBA7517);
    }
  }

  String _formatData() {
    String valueStr;
    if (isInt) {
      valueStr = data.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    } else {
      valueStr = data.toStringAsFixed(1);
    }
    return '$prefix$valueStr$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final color = _accentColor;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color:AppColors.blackColor.withAlpha(60), width: 0.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 18),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: AppTextStyle.bodyText2
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatData(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}