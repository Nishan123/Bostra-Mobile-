import 'package:bostra/models/portfolio_models.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PortfolioPieChart extends StatelessWidget {
  final List<SectorAllocation> sectors;
  const PortfolioPieChart({super.key, required this.sectors});

  static const _palette = [
    Color(0xFF3E8E31), // green
    Color(0xFFD66862), // coral
    Color(0xFF5E7BE2), // blue
    Color(0xFFE2A53E), // amber
    Color(0xFF8E5EE2), // purple
    Color(0xFF31B0A8), // teal
  ];

  Color _colorFor(int i) => _palette[i % _palette.length];

  @override
  Widget build(BuildContext context) {
    if (sectors.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12, right: 16, left: 12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.blackColor.withAlpha(80)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 50,
                    startDegreeOffset: 270,
                    sections: [
                      for (int i = 0; i < sectors.length; i++)
                        PieChartSectionData(
                          color: _colorFor(i),
                          value: sectors[i].amount,
                          radius: 14,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
                Text(
                  '${sectors.length} ${sectors.length == 1 ? 'Sector' : 'Sectors'}',
                  style: AppTextStyle.h4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < sectors.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _MetricRow(sector: sectors[i], barColor: _colorFor(i)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final SectorAllocation sector;
  final Color barColor;
  const _MetricRow({required this.sector, required this.barColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                sector.label,
                style: AppTextStyle.h4,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('${sector.percent}%', style: AppTextStyle.h4),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: sector.fraction,
            backgroundColor: const Color(0xFFE2E2E2),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
