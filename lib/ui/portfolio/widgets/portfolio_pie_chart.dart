import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PortfolioPieChart extends StatelessWidget {
  const PortfolioPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Exact colors from the design
    const colorAI = Color(0xFF3E8E31);    // Green
    const colorSaaS = Color(0xFFD66862);  // Red/Coral
    const colorFood = Color(0xFF5E7BE2);  // Blue
    const colorText = Color(0xFF1B4D3E);  // Dark Teal Text

    return Container(
      padding: const EdgeInsets.only(top: 12,bottom: 12, right: 16, left: 12),
      margin: EdgeInsets.only(left: 12, right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.blackColor.withAlpha(80)),
      ),
      child: Row(
        children: [
          // Left Side: Wrapped in a SizedBox to provide definitive constraints
          SizedBox(
            width: 140,  // Adjust this size to match your exact design requirements
            height: 140, // Keeps the chart a perfect square bounding box
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 50, // Slightly reduced to fit nicely inside a 140x140 frame
                    startDegreeOffset: 270,
                    sections: [
                      PieChartSectionData(
                        color: colorAI,
                        value: 30,
                        radius: 14,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: colorSaaS,
                        value: 40,
                        radius: 14,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: colorFood,
                        value: 30,
                        radius: 14,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                // Center Text
                Text(
                  '3 Sectors',
                  style: AppTextStyle.h4,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 32),

          // Right Side: Linear Metric List
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetricRow('AI', 0.30, colorAI, colorText),
                const SizedBox(height: 12),
                _buildMetricRow('SaaS', 0.40, colorSaaS, colorText),
                const SizedBox(height: 12),
                _buildMetricRow('Food', 0.30, colorFood, colorText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to construct each linear progress row cleanly
  Widget _buildMetricRow(String label, double percentage, Color barColor, Color textColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyle.h4,
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: AppTextStyle.h4,
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFFE2E2E2),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}