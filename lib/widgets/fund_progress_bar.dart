import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';

class FundProgressBar extends StatelessWidget {
  const FundProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8,
        thumbShape: SliderComponentShape.noThumb, // no thumb dot
        overlayShape: SliderComponentShape.noOverlay,
        activeTrackColor: AppColors.primaryColor,
        inactiveTrackColor: AppColors.turnaryColor,
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      child: Slider(value: 0.3, onChanged: (value) {}),
    );
  }
}
