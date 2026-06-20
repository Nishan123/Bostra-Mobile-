import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';

class FundProgressBar extends StatelessWidget {
  /// Progress from 0.0 to 1.0. Defaults to 0.3 for placeholder use.
  final double value;

  const FundProgressBar({super.key, this.value = 0.3});

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8,
        thumbShape: SliderComponentShape.noThumb,
        overlayShape: SliderComponentShape.noOverlay,
        activeTrackColor: AppColors.primaryColor,
        inactiveTrackColor: AppColors.turnaryColor,
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      child: Slider(value: value.clamp(0.0, 1.0), onChanged: null),
    );
  }
}
